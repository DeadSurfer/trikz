/*
	GNU GENERAL PUBLIC LICENSE

	VERSION 2, JUNE 1991

	Copyright (C) 1989, 1991 Free Software Foundation, Inc.
	51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.

	GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
	Copyright (C) 2007 Free Software Foundation, Inc. {http://fsf.org/}
	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.

							Preamble

	The GNU General Public License is a free, copyleft license for
	software and other kinds of works.

	The licenses for most software and other practical works are designed
	to take away your freedom to share and change the works. By contrast,
	the GNU General Public license is intended to guarantee your freedom to 
	share and change all versions of a progrm--to make sure it remins free
	software for all its users. We, the Free Software Foundation, use the
	GNU General Public license for most of our software; it applies also to
	any other work released this way by its authors. You can apply it to
	your programs, too.
*/
#include <dhooks>
#include <sdktools>
#include <sdkhooks>
#include <trikz>
#include <shavit>

Handle gH_AcceptInput
Handle gH_PassServerEntityFilter
bool gB_stateDefaultDisabled[2048 + 1]
bool gB_stateDisabled[MAXPLAYERS + 1][2048 + 1]
float gF_buttonDefaultDelay[2048 + 1]
float gF_buttonReady[MAXPLAYERS + 1][2048 + 1]
int gI_countTriggers[2048 + 1]
int gI_countButtons[2048 + 1]
int gI_totalTriggers
int gI_totalButtons

public Plugin myinfo =
{
	name = "Entity filter",
	author = "Smesh",
	description = "Makes the game more personal",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	Handle hGamedata = LoadGameConfigFile("sdktools.games")
	if(hGamedata == null)
	{
		SetFailState("Failed to load \"sdktools.games\" gamedata.")
		delete hGamedata
	}
	int offset = GameConfGetOffset(hGamedata, "AcceptInput")
	if(offset == 0)
	{
		SetFailState("Failed to load \"AcceptInput\", invalid offset.")
		delete hGamedata
	}
	gH_AcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput)
	DHookAddParam(gH_AcceptInput, HookParamType_CharPtr)
	DHookAddParam(gH_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(gH_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(gH_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP) //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(gH_AcceptInput, HookParamType_Int)
	HookEvent("round_start", Event_RoundStart)
	hGamedata = LoadGameConfigFile("collisionhook")
	if(hGamedata == null)
	{
		SetFailState("Failed to load \"collisionhook.txt\" gamedata.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	gH_PassServerEntityFilter = DHookCreateFromConf(hGamedata, "PassServerEntityFilter")
	if(!gH_PassServerEntityFilter)
	{
		SetFailState("Failed to setup detour PassServerEntityFilter.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	if(!DHookEnableDetour(gH_PassServerEntityFilter, false, PassServerEntityFilter))
	{
		SetFailState("Failed to load detour PassServerEntityFilter.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	delete hGamedata
	delete gH_PassServerEntityFilter
	gH_PassServerEntityFilter = CreateGlobalForward("Trikz_CheckSolidity", ET_Hook, Param_Cell, Param_Cell)
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	int entity
	char sClassName[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button"}
	gI_totalTriggers = 0
	gI_totalButtons = 0
	for(int i = 0; i < sizeof(sClassName); i++)
	{
		while((entity = FindEntityByClassname(entity, sClassName)) > 0)
		{
			DHookEntity(gH_AcceptInput, false, entity)
			if(i < 2)
				SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
			if((!i && GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 7 && GetEntProp(entity, Prop_Data, "m_bLocked")))
			{
				if(i == 7)
					gI_countTriggers[gI_totalTriggers++] = entity
				else
					gI_countButtons[gI_totalButtons++] = entity
				if(!i || 1 < i < 7)
					AcceptEntityInput(entity, "Enable")
				else if (i == 1)
					AcceptEntityInput(entity, "Toggle")
				else if(i == 7)
				{
					DHookEntity(gH_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputButton)
					SDKHook(entity, SDKHook_Use, HookButton)
					SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage);
					gF_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
					SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
				}
				gB_stateDefaultDisabled[entity] = true
				gB_stateDisabled[0][entity] = true
			}
			else if((!i && !GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && !GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && !GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 7 && !GetEntProp(entity, Prop_Data, "m_bLocked")))
			{
				if(i == 7)
					gI_countTriggers[gI_totalTriggers++] = entity
				else
					gI_countButtons[gI_totalButtons++] = entity
				gB_stateDefaultDisabled[entity] = false
				gB_stateDisabled[0][entity] = false
			}
		}
	}
	//char sOutputs[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger"}
	char sOutputs[][] = {"OnStartTouch", "OnEndTouchAll", "OnStartTouch", "OnStartTouchAll"}
	for(int i = 0; i < sizeof(sOutputs); i++)
	{
		HookEntityOutput("trigger_multiple", sOutputs[i], TriggerOutputHook) //make able to work !self
		if(i < 3)
		{
			HookEntityOutput("trigger_teleport", sOutputs[i], TriggerOutputHook) //make able to work !self
			HookEntityOutput("trigger_teleport_relative", sOutputs[i], TriggerOutputHook) //make able to work !self
			HookEntityOutput("trigger_push", sOutputs[i], TriggerOutputHook) //make able to work !self
			HookEntityOutput("trigger_gravity", sOutputs[i], TriggerOutputHook) //make able to work !self
		}
	}
	PrintToServer("Total triggers in proccess: %i. Total buttons in proccess: %i", gI_totalTriggers, gI_totalButtons)
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		//int caller = DHookGetParam(hParams, 3)
		int partner = Trikz_FindPartner(activator)
		//int outputid = DHookGetParam(hParams, 5)
		if(StrEqual(sInput, "Enable"))
		{
			if(partner != -1)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			else
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Disable"))
		{
			if(partner != -1)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else
				gB_stateDisabled[0][pThis] = true
		}
		else if(StrEqual(sInput, "Toggle"))
		{
			if(partner != -1)
			{
				if(gB_stateDisabled[activator][pThis])
				{
					gB_stateDisabled[activator][pThis] = true
					gB_stateDisabled[partner][pThis] = true
				}
				else
				{
					gB_stateDisabled[activator][pThis] = false
					gB_stateDisabled[partner][pThis] = false
				}
			}
			else
			{
				if(gB_stateDisabled[0][pThis])
					gB_stateDisabled[0][pThis] = true
				else
					gB_stateDisabled[0][pThis] = false
			}
		}
	}
	/*char sClassname[32]
	char sName[32]
	char sCClassname[32]
	char sCName[32]
	GetEntPropString(pThis, Prop_Data, "m_iClassname", sClassname, 32)
	GetEntPropString(pThis, Prop_Data, "m_iName", sName, 32)
	GetEntPropString(caller, Prop_Data, "m_iClassname", sCClassname, 32)
	GetEntPropString(caller, Prop_Data, "m_iName", sCName, 32)
	PrintToServer("AcceptInput (%s | %s) pThis: %i input: %s activator: %N (%i) caller: %i (%s | %s) outputid: %i", sClassname, sName, pThis, sInput, activator, activator, caller, sCClassname, sCName, outputid)*/
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		//int caller = DHookGetParam(hParams, 3)
		int partner = Trikz_FindPartner(activator)
		//int outputid = DHookGetParam(hParams, 5)
		if(StrEqual(sInput, "Unlock"))
		{
			if(partner != -1)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			else
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Lock"))
		{
			if(partner != -1)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else
				gB_stateDisabled[0][pThis] = true
		}
	}
	return MRES_Ignored
}

Action TouchTrigger(int entity, int other)
{
	if(0 < other <= MaxClients)
	{
		int partner = Trikz_FindPartner(other)
		if(partner != -1)
			if(gB_stateDisabled[other][entity])
				return Plugin_Handled
		else
			if(gB_stateDisabled[0][entity])
				return Plugin_Handled
	}
	return Plugin_Continue
}

Action EntityVisibleTransmit(int entity, int client)
{
	int partner = Trikz_FindPartner(client)
	if(partner != -1)
		if(0 < client <= MaxClients && gB_stateDisabled[client][entity])
			return Plugin_Handled
	else
		if(0 < client <= MaxClients && gB_stateDisabled[0][entity])
			return Plugin_Handled
	return Plugin_Continue
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	int partner = Trikz_FindPartner(activator)
	if(partner != -1)
	{
		if(0.0 < gF_buttonReady[activator][entity] > GetGameTime())
			return Plugin_Handled
		if(gB_stateDisabled[activator][entity])
			return Plugin_Handled
		gF_buttonReady[activator][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
		gF_buttonReady[partner][entity] = gF_buttonReady[activator][entity]
	}
	else
	{
		if(0.0 < gF_buttonReady[0][entity] > GetGameTime())
			return Plugin_Handled
		if(gB_stateDisabled[0][entity])
			return Plugin_Handled
		gF_buttonReady[0][entity] = gF_buttonReady[activator][entity]
	}
	if(GetEntProp(entity, Prop_Data, "m_bLocked"))
		AcceptEntityInput(entity, "Unlock")
	return Plugin_Continue
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker)
}

Action TriggerOutputHook(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_FindPartner(activator)
		if(partner != -1)
			if(gB_stateDisabled[activator][caller])
				return Plugin_Handled
		else
			if(gB_stateDisabled[0][caller])
				return Plugin_Handled
	}
	return Plugin_Continue
}

MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) || DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int ent1 = DHookGetParam(hParams, 1) //touch reciever
	int ent2 = DHookGetParam(hParams, 2) //touch sender
	Action result
	Call_StartForward(gH_PassServerEntityFilter)
	Call_PushCell(ent1)
	Call_PushCell(ent2)
	Call_Finish(result)
	if(result > Plugin_Continue)
	{
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
	}
	if(0 < ent2 <= MaxClients && !gB_stateDisabled[ent2][ent1])
		return MRES_Ignored
	char classname[32]
	GetEntPropString(ent2, Prop_Data, "m_iClassname", classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients && !gB_stateDisabled[ent2owner][ent1])
			return MRES_Ignored
	}
	//PrintToServer("ent1 %i, ent2 %i", ent1, ent2)
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}
