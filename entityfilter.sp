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
#include <outputinfo>

Handle gH_AcceptInput
Handle gH_PassServerEntityFilter
bool gB_stateDefaultDisabled[2048 + 1]
bool gB_stateDisabled[MAXPLAYERS + 1][2048 + 1]
float gF_buttonDefaultDelay[2048 + 1]
float gF_buttonReady[MAXPLAYERS + 1][2048 + 1]
int gI_entityID[2048 + 1]
int gI_entityTotalCount
int gI_mathID[2048 + 1]
int gI_mathTotalCount
int gI_breakID[2048 + 1]
native int Trikz_GetClientPartner(int client)
int gI_linkedTogglesDefault[2048 + 1][2048 + 1]
int gI_linkedToggles[MAXPLAYERS + 1][2048 + 1]
int gI_linkedMathTogglesDefault[2048 + 1][2048 + 1]
int gI_maxLinks[2048 + 1]
int gI_maxMathLinks[2048 + 1]
int gI_entityOutput[11][2048 + 1]
int gI_mathOutput[11][2048 + 1]
float gF_mathValueDefault[2048 + 1]
float gF_mathValue[MAXPLAYERS + 1][2048 + 1]
float gF_mathMin[2048 + 1]
float gF_mathMax[2048 + 1]

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
	DHookAddParam(gH_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP) //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(gH_AcceptInput, HookParamType_Int)
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post)
	hGamedata = LoadGameConfigFile("entityfilter")
	if(!hGamedata)
	{
		SetFailState("Failed to load \"entityfilter.txt\" gamedata.")
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
	RegPluginLibrary("fakeexpert-entityfilter")
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SetTransmit, TransmitPlayer)
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(2.0, timer_load, _, TIMER_FLAG_NO_MAPCHANGE) //Make work logic_auto on delay.
}

Action timer_load(Handle timer)
{
	char sClassname[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "math_counter", "logic_relay"}
	gI_entityTotalCount = 0
	gI_mathTotalCount = 0
	for(int i = 1; i <= 2048; i++)
	{
		gI_maxLinks[i] = 0
		gI_maxMathLinks[i] = 0
		gI_entityID[i] = 0
		gI_mathID[i] = 0
		gI_breakID[i] = 0
		gB_stateDefaultDisabled[i] = false
		gB_stateDisabled[0][i] = false
		for(int j = 0; j <= 10; j++)
		{
			gI_entityOutput[j][i] = 0
			gI_mathOutput[j][i] = 0
		}
	}
	for(int i = 0; i < sizeof(sClassname); i++)
	{
		int entity
		while((entity = FindEntityByClassname(entity, sClassname[i])) != INVALID_ENT_REFERENCE)
		{
			if(i < 5)
			{
				char sOutput[][] = {"m_OnStartTouch", "m_OnEndTouchAll", "m_OnTouching", "m_OnEndTouch", "m_OnTrigger", "m_OnStartTouchAll"}
				for(int j = 0; j < sizeof(sOutput); j++)
					EntityLinked(entity, sOutput[j])
			}
			else if(i == 5)
			{
				EntityLinked(entity, "m_OnPressed")
				EntityLinked(entity, "m_OnDamaged")
			}
			else if(i == 6)
			{
				EntityLinked(entity, "m_OnHitMin")
				EntityLinked(entity, "m_OnHitMax")
			}
			else if(i == 7)
				EntityLinked(entity, "m_OnTrigger")
		}
	}
	char sTriggers[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "math_counter"}
	char sOutputs[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnEndTouch", "OnTrigger", "OnStartTouchAll", "OnPressed", "OnDamaged", "OnUser3", "OnUser4", "OnHitMin", "OnHitMax"}
	for(int i = 0; i < sizeof(sTriggers); i++)
		for(int j = 0; j < sizeof(sOutputs); j++)
			HookEntityOutput(sTriggers[i], sOutputs[j], EntityOutputHook)
	PrintToServer("Total entities in proccess: %i. Math counters: %i", gI_entityTotalCount, gI_mathTotalCount)
}

void EntityLinked(int entity, char[] output)
{
	int count = GetOutputActionCount(entity, output)
	char sInput[32]
	for(int i = 0; i < count; i++)
	{
		GetOutputActionTargetInput(entity, output, i, sInput, 32)
		char sTarget[64]
		GetOutputActionTarget(entity, output, i, sTarget, 64)
		if(StrEqual(sInput, "Enable") || StrEqual(sInput, "Disable") || StrEqual(sInput, "Toggle") || StrEqual(sInput, "Break") || StrEqual(sInput, "Trigger") || StrEqual(sInput, "CancelPending"))
		{
			char sClassname[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_breakable"}
			for(int j = 0; j < sizeof(sClassname); j++)
			{
				int entityLinked
				while((entityLinked = FindLinkedEntity(entityLinked, sClassname[j], sTarget, StrEqual(sInput, "Toggle") ? entity : 0)) != INVALID_ENT_REFERENCE)
				{
					OutputInput(entityLinked, sClassname[j], sTarget)
					if(StrEqual(output, "m_OnPressed") || StrEqual(output, "m_OnDamaged"))
						OutputInput(entity, "func_button")
					if(StrEqual(sInput, "Toggle"))
					{
						if(entity > 0)
						{
							gI_linkedTogglesDefault[++gI_maxLinks[entity]][entity] = entityLinked
							gI_entityOutput[GetOutput(output)][entityLinked]++
						}
						else
						{
							int math
							bool mathExist
							for(int k = 1; k <= gI_mathTotalCount; k++)
							{
								math = k
								if(gI_mathID[math] == entity)
								{
									mathExist = true
									break
								}
							}
							if(mathExist)
							{
								gI_linkedMathTogglesDefault[++gI_maxMathLinks[math]][math] = entityLinked
								gI_mathOutput[GetOutput(output)][entityLinked]++
							}
						}
					}
				}
			}
		}
		else if(StrEqual(sInput, "Unlock") || StrEqual(sInput, "Lock"))
		{
			int entityLinked
			while((entityLinked = FindLinkedEntity(entityLinked, "func_button", sTarget)) != INVALID_ENT_REFERENCE)
			{
				OutputInput(entityLinked, "func_button")
				if(GetEntProp(entityLinked, Prop_Data, "m_bLocked"))
					AcceptEntityInput(entityLinked, "Unlock")
				DHookEntity(gH_AcceptInput, false, entityLinked, INVALID_FUNCTION, AcceptInputButton)
			}
		}
		else if(StrEqual(sInput, "Add") || StrEqual(sInput, "Subtract"))
		{
			int entityLinked = FindLinkedEntity(entityLinked, "math_counter", sTarget)
			OutputInput(entityLinked, "math_counter")
		}
	}
}

int FindLinkedEntity(int entity, char[] classname, char[] target, int parent = 0)
{
	char sName[64]
	while((entity = FindEntityByClassname(entity, classname)) != INVALID_ENT_REFERENCE)
	{
		if(StrEqual(target, "!self") && entity == parent)
			return entity
		if(!GetEntPropString(entity, Prop_Data, "m_iName", sName, 64))
			continue
		if(StrEqual(target, sName))
			return entity
	}
	return INVALID_ENT_REFERENCE
}

void OutputInput(int entity, char[] output, char[] target = "")
{
	int i
	if(StrEqual(output, "func_brush"))
		i = 0
	else if(StrEqual(output, "func_wall_toggle"))
		i = 1
	else if(StrEqual(output, "trigger_multiple"))
		i = 2
	else if(StrEqual(output, "trigger_teleport"))
		i = 3
	else if(StrEqual(output, "trigger_teleport_relative"))
		i = 4
	else if(StrEqual(output, "trigger_push"))
		i = 5
	else if(StrEqual(output, "trigger_gravity"))
		i = 6
	else if(StrEqual(output, "func_breakable"))
		i = 7
	else if(StrEqual(output, "func_button"))
		i = 8
	else if(StrEqual(output, "math_counter"))
		i = 9
	if(entity > 0)
	{
		for(int j = 1; j <= gI_entityTotalCount; j++)
			if(gI_entityID[j] == entity)
				return
		gI_entityID[++gI_entityTotalCount] = entity
	}
	else
	{
		for(int j = 1; j <= gI_mathTotalCount; j++)
			if(gI_mathID[j] == entity)
				return
		gI_mathID[++gI_mathTotalCount] = entity
	}
	if(i == 7)
	{
		int template
		bool bBreak
		while((template = FindEntityByClassname(template, "point_template")) != INVALID_ENT_REFERENCE)
		{
			char sName[64]
			for(int j = 0; j < 16; j++)
			{
				Format(sName, 64, "m_iszTemplateEntityNames[%i]", j)
				GetEntPropString(template, Prop_Data, sName, sName, 64)
				if(StrEqual(target, sName))
				{
					gI_breakID[gI_entityTotalCount] = template
					DHookEntity(gH_AcceptInput, false, template)
					bBreak = true
					break
				}
			}
			if(bBreak)
				break
		}
		gB_stateDefaultDisabled[entity] = false
		gB_stateDisabled[0][entity] = false
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
		AddOutput(entity, "m_OnBreak", "OnUser4")
		DHookEntity(gH_AcceptInput, false, entity)
	}
	if(i == 9)
	{
		if(IsValidEntity(entity) && (!GetOutputActionCount(entity, "m_OutValue") || !GetOutputActionCount(entity, "m_OnGetValue") || !GetOutputActionCount(entity, "m_OnUser3") || !GetOutputActionCount(entity, "m_OnUser4"))) //thanks to george for original code.
		{
			gF_mathValueDefault[gI_mathTotalCount] = GetEntDataFloat(entity, FindDataMapInfo(entity, "m_OutValue"))
			gF_mathValue[0][gI_mathTotalCount] = GetEntDataFloat(entity, FindDataMapInfo(entity, "m_OutValue"))
			gF_mathMin[gI_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMin")
			gF_mathMax[gI_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMax")
			AddOutput(entity, "m_OnHitMin", "OnUser4")
			AddOutput(entity, "m_OnHitMax", "OnUser3")
			DHookEntity(gH_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputMath)
		}
	}
	if(i < 7)
		DHookEntity(gH_AcceptInput, false, entity)
	else if(i == 8)
	{
		SDKHook(entity, SDKHook_Use, HookButton)
		SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage)
		gF_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
		gF_buttonReady[0][entity] = 0.0
		SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
		gB_stateDefaultDisabled[entity] = false
		gB_stateDisabled[0][entity] = false
	}
	if(i < 2)
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
	else if(1 < i < 7)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
	if((!i && GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 8 && GetEntProp(entity, Prop_Data, "m_bLocked")))
	{
		gB_stateDefaultDisabled[entity] = true
		gB_stateDisabled[0][entity] = true
	}
	else if((!i && !GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && !GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && !GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 8 && !GetEntProp(entity, Prop_Data, "m_bLocked")))
	{
		gB_stateDefaultDisabled[entity] = false
		gB_stateDisabled[0][entity] = false
	}
	if(!i || 1 < i < 7)
		AcceptEntityInput(entity, "Enable")
	else if(i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags"))
		AcceptEntityInput(entity, "Toggle")
}

void AddOutput(int entity, char[] output, char[] outputtype)
{
	int count = GetOutputActionCount(entity, output)
	char sOutput[4][256]
	for(int i = 0; i < count; i++)
	{
		GetOutputActionTarget(entity, output, i, sOutput[0], 256)
		GetOutputActionTargetInput(entity, output, i, sOutput[1], 256)
		GetOutputActionParameter(entity, output, i, sOutput[2], 256)
		float delay = GetOutputActionDelay(entity, output, i)
		int fire = GetOutputActionTimesToFire(entity, output, i)
		Format(sOutput[3], 256, "%s %s:%s:%s:%f:%i", outputtype, sOutput[0], sOutput[1], sOutput[2], delay, fire)
		SetVariantString(sOutput[3])
		AcceptEntityInput(entity, "AddOutput")
	}
}

void Reset(int client)
{
	for(int i = 1; i <= gI_entityTotalCount; i++)
	{
		gB_stateDisabled[client][gI_entityID[i]] = gB_stateDefaultDisabled[gI_entityID[i]]
		gF_buttonReady[client][gI_entityID[i]] = 0.0
		gI_linkedToggles[client][gI_entityID[i]] = 0
	}
	for(int i = 1; i <= gI_mathTotalCount; i++)
		gF_mathValue[client][i] = gF_mathValueDefault[i]
}

public void Trikz_Start(int client)
{
	Reset(client)
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(StrEqual(sInput, "Enable"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Disable"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			gB_stateDisabled[0][pThis] = true
		}
		else if(StrEqual(sInput, "Toggle"))
		{
			if(gI_linkedToggles[activator][pThis] && partner)
			{
				gB_stateDisabled[activator][pThis] = !gB_stateDisabled[activator][pThis]
				gB_stateDisabled[partner][pThis] = !gB_stateDisabled[partner][pThis]
				gI_linkedToggles[activator][pThis]--
				gI_linkedToggles[partner][pThis]--
			}
			if(gI_linkedToggles[0][pThis])
			{
				gB_stateDisabled[0][pThis] = !gB_stateDisabled[0][pThis]
				gI_linkedToggles[0][pThis]--
			}
		}
		else if(StrEqual(sInput, "Break"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			gB_stateDisabled[0][pThis] = true
			AcceptEntityInput(pThis, "FireUser4", activator, pThis) //make fire brush with output
		}
		else
		{
			int pThisIndex
			for(int i = 1; i <= gI_entityTotalCount; i++)
			{
				if(gI_breakID[i] == pThis)
				{
					pThisIndex = gI_entityID[i]
					break
				}
			}
			if(!pThisIndex)
				return MRES_Ignored
			if(partner)
			{
				gB_stateDisabled[activator][pThisIndex] = false
				gB_stateDisabled[partner][pThisIndex] = false
			}
			gB_stateDisabled[0][pThisIndex] = false
		}
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	if(!StrEqual(sInput, "Lock") || !StrEqual(sInput, "Unlock"))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	int partner = Trikz_GetClientPartner(activator)
	if(StrEqual(sInput, "Unlock"))
	{
		if(partner)
		{
			gB_stateDisabled[activator][pThis] = false
			gB_stateDisabled[partner][pThis] = false
		}
		gB_stateDisabled[0][pThis] = false
	}
	else if(StrEqual(sInput, "Lock"))
	{
		if(partner)
		{
			gB_stateDisabled[activator][pThis] = true
			gB_stateDisabled[partner][pThis] = true
		}
		gB_stateDisabled[0][pThis] = true
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

MRESReturn AcceptInputMath(int pThis, Handle hReturn, Handle hParams)
{
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(!StrEqual(sInput, "Add") && !StrEqual(sInput, "Subtract") && !StrEqual(sInput, "SetValue") && !StrEqual(sInput, "SetValueNoFire"))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	int partner = Trikz_GetClientPartner(activator)
	char sValue[64]
	DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, sValue, 64)
	float flValue = StringToFloat(sValue)
	int pThisIndex
	for(int i = 1; i <= gI_mathTotalCount; i++)
	{
		if(gI_mathID[i] == pThis)
		{
			pThisIndex = i
			break
		}
	}
	if(!pThisIndex)
		return MRES_Ignored
	if(StrEqual(sInput, "Add"))
	{
		if(gF_mathValue[activator][pThisIndex] < gF_mathMax[pThisIndex] && partner)
		{
			gF_mathValue[activator][pThisIndex] += flValue
			gF_mathValue[partner][pThisIndex] += flValue
			if(gF_mathValue[activator][pThisIndex] >= gF_mathMax[pThisIndex])
			{
				gF_mathValue[activator][pThisIndex] = gF_mathMax[pThisIndex]
				gF_mathValue[partner][pThisIndex] = gF_mathMax[pThisIndex]
				AcceptEntityInput(pThis, "FireUser3", activator, activator)
			}
		}
		if(gF_mathValue[0][pThisIndex] < gF_mathMax[pThisIndex])
		{
			gF_mathValue[0][pThisIndex] += flValue
			if(gF_mathValue[0][pThisIndex] >= gF_mathMax[pThisIndex])
			{
				gF_mathValue[0][pThisIndex] = gF_mathMax[pThisIndex]
				AcceptEntityInput(pThis, "FireUser3", activator, activator)
			}
		}
	}
	else if(StrEqual(sInput, "Subtract"))
	{
		if(gF_mathValue[activator][pThisIndex] > gF_mathMin[pThisIndex] && partner)
		{
			gF_mathValue[activator][pThisIndex] -= flValue
			gF_mathValue[partner][pThisIndex] -= flValue
			if(gF_mathValue[activator][pThisIndex] <= gF_mathMin[pThisIndex])
			{
				gF_mathValue[activator][pThisIndex] = gF_mathMin[pThisIndex]
				gF_mathValue[partner][pThisIndex] = gF_mathMin[pThisIndex]
				AcceptEntityInput(pThis, "FireUser4", activator, activator)
			}
		}
		if(gF_mathValue[0][pThisIndex] > gF_mathMin[pThisIndex])
		{
			gF_mathValue[0][pThisIndex] -= flValue
			if(gF_mathValue[0][pThisIndex] <= gF_mathMin[pThisIndex])
			{
				gF_mathValue[0][pThisIndex] = gF_mathMin[pThisIndex]
				AcceptEntityInput(pThis, "FireUser4", activator, activator)
			}
		}
	}
	else
	{
		if(partner)
		{
			gF_mathValue[activator][pThisIndex] = flValue
			gF_mathValue[partner][pThisIndex] = flValue
			if(gF_mathValue[activator][pThisIndex] < gF_mathMin[pThisIndex])
			{
				gF_mathValue[activator][pThisIndex] = gF_mathMin[pThisIndex]
				gF_mathValue[partner][pThisIndex] = gF_mathMin[pThisIndex]
			}
			else if(gF_mathValue[activator][pThisIndex] > gF_mathMax[pThisIndex])
			{
				gF_mathValue[activator][pThisIndex] = gF_mathMax[pThisIndex]
				gF_mathValue[partner][pThisIndex] = gF_mathMax[pThisIndex]
			}
		}
		gF_mathValue[0][pThisIndex] = flValue
		if(gF_mathValue[0][pThisIndex] < gF_mathMin[pThisIndex])
			gF_mathValue[0][pThisIndex] = gF_mathMin[pThisIndex]
		else if(gF_mathValue[0][pThisIndex] > gF_mathMax[pThisIndex])
			gF_mathValue[0][pThisIndex] = gF_mathMax[pThisIndex]
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

Action TouchTrigger(int entity, int other)
{
	if(0 < other <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(other)
		if(gB_stateDisabled[partner][entity])
			return Plugin_Handled
	}
	return Plugin_Continue
}

Action EntityVisibleTransmit(int entity, int client)
{
	if(0 < client <= MaxClients)
	{
		if(!IsPlayerAlive(client))
		{
			int target = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")
			if(0 < target <= MaxClients)
			{
				int partner = Trikz_GetClientPartner(target)
				if(gB_stateDisabled[partner][entity])
					return Plugin_Handled
			}
		}
		int partner = Trikz_GetClientPartner(client)
		if(gB_stateDisabled[partner][entity])
			return Plugin_Handled
	}
	return Plugin_Continue
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	int partner = Trikz_GetClientPartner(activator)
	if(partner)
	{
		if(gF_buttonReady[activator][entity] > GetGameTime() || gB_stateDisabled[activator][entity])
			return Plugin_Handled
		gF_buttonReady[activator][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
		gF_buttonReady[partner][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
	}
	else
	{
		if(gF_buttonReady[partner][entity] > GetGameTime() || gB_stateDisabled[partner][entity])
			return Plugin_Handled
		gF_buttonReady[partner][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
	}
	return Plugin_Continue
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker)
}

Action EntityOutputHook(char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(caller > 0)
		{
			for(int i = 1; i <= gI_maxLinks[caller]; i++)
			{
				if(partner)
				{
					if(gI_linkedToggles[activator][gI_linkedTogglesDefault[i][caller]])
						return Plugin_Handled
				}
				else
					if(gI_linkedToggles[partner][gI_linkedTogglesDefault[i][caller]])
						return Plugin_Handled
			}
			char sOutput[32]
			Format(sOutput, 32, "m_%s", output)
			for(int i = 1; i <= gI_maxLinks[caller]; i++)
			{
				if(partner)
					gI_linkedToggles[activator][gI_linkedTogglesDefault[i][caller]] = gI_entityOutput[GetOutput(sOutput)][gI_linkedTogglesDefault[i][caller]]
				gI_linkedToggles[partner][gI_linkedTogglesDefault[i][caller]] = gI_entityOutput[GetOutput(sOutput)][gI_linkedTogglesDefault[i][caller]]
			}
		}
		else
		{
			for(int i = 1; i <= gI_mathTotalCount; i++)
			{
				if(gI_mathID[i] == caller)
				{
					int math = i
					for(int j = 1; j <= gI_maxMathLinks[math]; j++)
					{
						if(partner)
						{
							if(gI_linkedToggles[activator][gI_linkedMathTogglesDefault[j][math]])
								return Plugin_Handled
						}
						else
							if(gI_linkedToggles[partner][gI_linkedMathTogglesDefault[j][math]])
								return Plugin_Handled
					}
					char sOutput[32]
					if(StrEqual(output, "OnUser3"))
						Format(sOutput, 32, "m_OnHitMax", output)
					else if(StrEqual(output, "OnUser4"))
						Format(sOutput, 32, "m_OnHitMin", output)
					for(int j = 1; j <= gI_maxMathLinks[math]; j++)
					{
						if(partner)
							gI_linkedToggles[activator][gI_linkedMathTogglesDefault[j][math]] = gI_mathOutput[GetOutput(sOutput)][gI_linkedMathTogglesDefault[j][math]]
						gI_linkedToggles[partner][gI_linkedMathTogglesDefault[j][math]] = gI_mathOutput[GetOutput(sOutput)][gI_linkedMathTogglesDefault[j][math]]
					}
				}
			}
		}
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
	int partner
	if(0 < ent2 <= MaxClients)
		partner = Trikz_GetClientPartner(ent2)
	if(!gB_stateDisabled[partner][ent1])
		return MRES_Ignored
	char sClassname[32]
	GetEntityClassname(ent2, sClassname, 32)
	if(StrContains(sClassname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients)
			partner = Trikz_GetClientPartner(ent2owner)
		if(!gB_stateDisabled[partner][ent1])
			return MRES_Ignored
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(IsValidEntity(entity) && StrContains(classname, "_projectile") != -1)
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade)
}

int GetOutput(char[] output)
{
	if(StrEqual(output, "m_OnStartTouch"))
		return 0
	else if(StrEqual(output, "m_OnEndTouchAll"))
		return 1
	else if(StrEqual(output, "m_OnTouching"))
		return 2
	else if(StrEqual(output, "m_OnEndTouch"))
		return 3
	else if(StrEqual(output, "m_OnTrigger"))
		return 4
	else if(StrEqual(output, "m_OnStartTouchAll"))
		return 5
	else if(StrEqual(output, "m_OnPressed"))
		return 6
	else if(StrEqual(output, "m_OnDamaged"))
		return 7
	else if(StrEqual(output, "m_OnHitMin"))
		return 8
	else if(StrEqual(output, "m_OnHitMax"))
		return 9
	else
		return 10
}

Action TransmitPlayer(int entity, int client) //entity - me, client - loop all clients
{
	//make visible only partner
	if(client != entity && 0 < entity <= MaxClients && IsPlayerAlive(client))
		if(Trikz_GetClientPartner(entity) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
			return Plugin_Handled
	return Plugin_Continue
}

Action TransmitNade(int entity, int client) //entity - nade, client - loop all clients
{
	//make visible nade only for partner
	if(IsPlayerAlive(client) && GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") != client && Trikz_GetClientPartner(GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
		return Plugin_Handled
	return Plugin_Continue
}

public Action Trikz_CheckSolidity(int ent1, int ent2)
{
	if(0 < ent1 <= MaxClients && 0 < ent2 <= MaxClients && IsFakeClient(ent1) && IsFakeClient(ent2)) //make no collide with bot
		return Plugin_Handled //result = false
	char sClassname[32]
	GetEntityClassname(ent2, sClassname, 32)
	if(StrContains(sClassname, "projectile") != -1)
		if(0 < ent1 <= MaxClients)
			if(Trikz_GetClientPartner(GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity")) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1))))
				return Plugin_Handled
	if(0 < ent1 <= MaxClients && 0 < ent2 <= MaxClients)
	{
		//make no collide with all players.
		if(GetEntProp(ent2, Prop_Data, "m_CollisionGroup") == 2)
			return Plugin_Handled
		//colide for partner
		if(Trikz_GetClientPartner(ent2) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1))))
			return Plugin_Handled
	}
	return Plugin_Continue
}
