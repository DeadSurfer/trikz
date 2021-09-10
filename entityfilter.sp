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
//#include <trikz>
//#include <outputinfo>

Handle gH_AcceptInput
Handle gH_PassServerEntityFilter
bool gB_stateDefaultDisabled[2048 + 1]
bool gB_stateDisabled[MAXPLAYERS + 1][2048 + 1]
float gF_buttonDefaultDelay[2048 + 1]
float gF_buttonReady[MAXPLAYERS + 1][2048 + 1]
int gI_countEntity[2048 + 1]
int gI_totalEntity
forward void Trikz_Start(int client, int partner)
native int Trikz_GetClientPartner(int client)

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
	if(!hGamedata)
	{
		SetFailState("Failed to load \"sdktools.games\" gamedata.")
		delete hGamedata
	}
	int offset = GameConfGetOffset(hGamedata, "AcceptInput")
	if(!offset)
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
	if(!hGamedata)
	{
		SetFailState("Failed to load \"collisionhook.txt\" gamedata.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	gH_PassServerEntityFilter = DHookCreateFromConf(hGamedata, "PassServerEntityFilter")
	if(!gH_PassServerEntityFilter)
		SetFailState("Failed to setup detour PassServerEntityFilter.")
	if(!DHookEnableDetour(gH_PassServerEntityFilter, false, PassServerEntityFilter))
		SetFailState("Failed to load detour PassServerEntityFilter.")
	delete hGamedata
	delete gH_PassServerEntityFilter
	gH_PassServerEntityFilter = CreateGlobalForward("Trikz_CheckSolidity", ET_Hook, Param_Cell, Param_Cell)
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	int entity
	char sClassname[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "func_breakable"}
	gI_totalEntity = 0
	//bool gB_once
	for(int i = 0; i < sizeof(sClassname); i++)
	{
		while((entity = FindEntityByClassname(entity, sClassname[i])) > 0)
		{
			DHookEntity(gH_AcceptInput, false, entity)
			if(i < 2)
				SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
			if((!i && GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 7 && GetEntProp(entity, Prop_Data, "m_bLocked")))
			{
				if(i == 3)
				{
					char sTarget[64]
					GetEntPropString(entity, Prop_Data, "m_target", sTarget, 64)
					if(strlen(sTarget))
						break
					char sDestination[][] = {"info_teleport_destination", "point_teleport"}
					for(int j = 0; j < sizeof(sDestination); j++)
					{
						int destination
						while((destination = FindEntityByClassname(destination, sDestination[j])) > 0)
						{
							char sName[64]
							GetEntPropString(destination, Prop_Data, "m_iName", sName, 64)
							if(StrEqual(sTarget, sName))
								break
						}
					}
				}
				if(!i || 1 < i < 7)
				{
					SDKHook(entity, SDKHook_Touch, TouchTrigger)
					AcceptEntityInput(entity, "Enable")
				}
				else if (i == 1)
					AcceptEntityInput(entity, "Toggle")
				else if(i == 7)
				{
					SDKHook(entity, SDKHook_Use, HookButton)
					SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage);
					gF_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
					SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
				}
				gB_stateDefaultDisabled[entity] = true
				gB_stateDisabled[0][entity] = true
				gI_countEntity[gI_totalEntity++] = entity
			}
			else if((!i && !GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && !GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && !GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 7 && !GetEntProp(entity, Prop_Data, "m_bLocked")))
			{
				if(i == 3)
				{
					char sTarget[64]
					GetEntPropString(entity, Prop_Data, "m_target", sTarget, 64)
					if(strlen(sTarget))
						break
					char sDestination[][] = {"info_teleport_destination", "point_teleport"}
					for(int j = 0; j < sizeof(sDestination); j++)
					{
						int destination
						while((destination = FindEntityByClassname(destination, sDestination[j])) > 0)
						{
							char sName[64]
							GetEntPropString(destination, Prop_Data, "m_iName", sName, 64)
							if(StrEqual(sTarget, sName))
								break
						}
					}
				}
				gB_stateDefaultDisabled[entity] = false
				gB_stateDisabled[0][entity] = false
				gI_countEntity[gI_totalEntity++] = entity
			}
			/*if(!gB_once)
			{
				char sOutputs[][] = {"m_OnEndTouchAll", "m_OnTouching", "m_OnStartTouch", "m_OnTrigger", "m_OnStartTouchAll", "m_OnPressed"}
				for(int i = 0; i < sizeof(sOutputs); i++)
				{
					int count = GetOutputActionCount(breakable, sOutputs[i])
					char sTarget[256]
					for(int i = 0; i < count; i++)
					{
						int breakable
						GetOutputActionTarget(entity, sOutputs[i], i, sTarget, 256)
						char sName[64]
						while((breakable = FindEntityByClassname(breakable, "func_breakable")) > 0)
						{
							if(StrEqual(sTarget, "!self") && breakable == -1)
								break
							if(GetEntPropString(breakable, Prop_Data, "m_iName", sName, 64))
								if(!strlen(sName))	
									continue
							if(StrEqual(sName, sTarget))
								break
							int template
							bool bBreak
							while((template = FindEntityByClassname(template, "point_template")) > 0)
							{
								//char sName[64]
								for(int i = 0; i <= 16; i++)
								{
									Format(sName, 64, "m_iszTemplateEntityNames[%i]", i)
									GetEntPropString(template, Prop_Data, sName, sName, 64)
									//char sTarget[64]
									GetOutputActionTarget(entity, "m_OnBreak", i, sTarget, 64)
									if(StrEqual(sName, sTarget))
										break
								}
							}
							count = GetOutputActionCount(breakable, "m_OnBreak")
							char sOutput[3][256]
							for(int i = 0; i < count; i++)
							{
								GetOutputActionTarget(iTarget, "m_OnBreak", i, sOutput[0], 256)
								GetOutputActionTargetInput(iTarget, "m_OnBreak", i, sOutput[1], 256)
								GetOutputActionParameter(iTarget, "m_OnBreak", i, sOutput[2], 256)
								float iOutputDelay = GetOutputActionDelay(iTarget, "m_OnBreak", i)
								int iOutputTimesToFire = GetOutputActionTimesToFire(iTarget, "m_OnBreak", i)
								Format(sOutput[0], 256, "OnUser4 %s:%s:%s:%f:%i", sOutput[0], sOutput[1], sOutput[2], iOutputDelay, iOutputTimesToFire)
								SetVariantString(sOutput[0])
								AcceptEntityInput(iTarget, "AddOutput")
							}
							DHookEntity(gH_AcceptInput, false, entity)
							SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
							gB_stateDefaultDisabled[breakable] = false
							gB_stateDisabled[0][breakable] = false
							gI_countEntity[gI_totalEntity++] = breakable
							gB_once = true
						}
					}
				}
			}*/
			else if(i == 8)
			{
				SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
				gB_stateDefaultDisabled[entity] = false
				gB_stateDisabled[0][entity] = false
				gI_countEntity[gI_totalEntity++] = entity
			}
		}
	}
	char sTriggers[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity"}
	char sOutputs[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger", "OnStartTouchAll"}
	for(int i = 0; i < sizeof(sTriggers); i++)
		for(int j = 0; j < sizeof(sOutputs); j++)
			HookEntityOutput(sTriggers[i], sOutputs[j], TriggerOutputHook) //make able to work !self
	PrintToServer("Total entities in proccess: %i", gI_totalEntity)
}

void Reset(int client)
{
	for(int i = 1; i <= gI_countEntity[gI_totalEntity]; i++)
	{
		gB_stateDisabled[client][gI_countEntity[i]] = gB_stateDefaultDisabled[gI_countEntity[i]]
		gF_buttonReady[client][gI_countEntity[i]] = 0.0
	}
}

public void Trikz_Start(int client, int partner)
{
	Reset(client)
	Reset(partner)
	PrintToServer("%N %N %N", client, partner, Trikz_GetClientPartner(client))
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	//if(DHookIsNullParam(hParams, 1) || DHookIsNullParam(hParams, 2))
	//	return MRES_Ignored
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	int activator = DHookGetParam(hParams, 2)
	//int caller = DHookGetParam(hParams, 3)
	//int outputid = DHookGetParam(hParams, 5)
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(StrEqual(sInput, "Enable") || StrEqual(sInput, "Unlock"))
		{
			if(partner > 0)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
				PrintToServer("1")
			}
			else if(partner < 1)
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Disable") || StrEqual(sInput, "Lock"))
		{
			if(partner > 0)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else if(partner < 1)
				gB_stateDisabled[0][pThis] = true
		}
		else if(StrEqual(sInput, "Toggle"))
		{
			if(partner > 0)
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
			else if(partner < 1)
			{
				if(gB_stateDisabled[0][pThis])
					gB_stateDisabled[0][pThis] = true
				else
					gB_stateDisabled[0][pThis] = false
			}
		}
		else if(StrEqual(sInput, "Break"))
		{
			//AcceptEntityInput(pThis, "FireUser4", activator, pThis)
			if(partner > 0)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			else if(partner < 1)
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "ForceSpawn"))
		{
			if(partner > 0)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else if(partner < 1)
				gB_stateDisabled[0][pThis] = true
		}
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
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
	return MRES_Ignored
}

Action TouchTrigger(int entity, int other)
{
	if(0 < other <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(other)
		if(partner > 0)
		{
			if(gB_stateDisabled[other][entity])
				return Plugin_Handled
		}
		else if(partner < 1)
			if(gB_stateDisabled[0][entity])
				return Plugin_Handled
	}
	return Plugin_Continue
}

Action EntityVisibleTransmit(int entity, int client)
{
	if(0 < client <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(client)
		if(partner > 0)
		{
			if(gB_stateDisabled[client][entity])
				return Plugin_Handled
		}
		else if(partner < 1)
			if(gB_stateDisabled[0][entity])
				return Plugin_Handled
	}
	return Plugin_Continue
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	int partner = Trikz_GetClientPartner(activator)
	if(partner > 0)
	{
		if(gF_buttonReady[activator][entity] > GetGameTime() || gB_stateDisabled[activator][entity])
			return Plugin_Handled
		gF_buttonReady[activator][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
		gF_buttonReady[partner][entity] = gF_buttonReady[activator][entity]
	}
	else if(partner < 1)
	{
		if(gF_buttonReady[0][entity] > GetGameTime() || gB_stateDisabled[0][entity])
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
		int partner = Trikz_GetClientPartner(activator)
		if(partner > 0)
		{
			if(gB_stateDisabled[activator][caller])
				return Plugin_Handled
		}
		else if(partner < 1)
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

/*public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "func_breakable"))
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnPost)
}

void SDKSpawnPost(int entity)
{
	AcceptEntityInput(entity, "Kill")
}*/
