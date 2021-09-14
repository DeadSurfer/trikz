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
native int Trikz_GetClientPartner(int client)
int gI_linkedTogglesDefault[2048 + 1][2048 + 1]
int gI_linkedToggles[MAXPLAYERS + 1][2048 + 1]
int gI_maxLinks[2048 + 1]
int gI_entityOutput[9][2048 + 1]
//bool gB_button[2048 + 1]
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
	HookEvent("round_start", Event_RoundStart)
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
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetThisPlugin", Native_GetThisPlugin)
	return APLRes_Success
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SetTransmit, TransmitPlayer)
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	char sClassname[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_breakable", "func_button", "math_counter"}
	gI_entityTotalCount = 0
	gI_mathTotalCount = 0
	for(int i = 0; i <= 2048; i++)
	{
		gI_maxLinks[i] = 0
		gI_entityID[i] = 0
		gI_mathID[i] = 0
		//gB_button[i] = false
	}
	//bool gB_once
	for(int i = 0; i < sizeof(sClassname); i++)
	{
		int entity
		while((entity = FindEntityByClassname(entity, sClassname[i])) != INVALID_ENT_REFERENCE)
		{
			if(1 < i < 7)
			{
				char sOutput[][] = {"m_OnStartTouch", "m_OnEndTouchAll", "m_OnTouching", "m_OnEndTouch", "m_OnTrigger", "m_OnStartTouchAll"}
				for(int j = 0; j < sizeof(sOutput); j++)
					LinkedEntities(entity, sOutput[j], sClassname[i])
			}
			else if(i == 8)
			{
				char sOutput[][] = {"m_OnPressed", "m_OnDamaged"}
				for(int j = 0; j < sizeof(sOutput); j++)
					LinkedEntities(entity, sOutput[j], sClassname[i])
			}
			else if(i == 9)
			{
				char sOutput[][] = {"m_OnHitMin", "m_OnHitMax"}
				for(int j = 0; j < sizeof(sOutput); j++)
					if(GetOutputActionCount(entity, "m_OutValue") || GetOutputActionCount(entity, "m_OnGetValue") || GetOutputActionCount(entity, "m_OnUser3") || GetOutputActionCount(entity, "m_OnUser4"))
						LinkedEntities(entity, sOutput[j], sClassname[i])
			}
			//else
			//	IsOutputOrInput(entity, sClassname[i])
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
						while((breakable = FindEntityByClassname(breakable, "func_breakable")) != INVALID_ENT_REFERENCE)
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
							while((template = FindEntityByClassname(template, "point_template")) != INVALID_ENT_REFERENCE)
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
							gI_entityID[gI_entityTotalCount++] = breakable
							gB_once = true
						}
					}
				}
			}*/
			/*else if(i == 8)
			{
				SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
				gB_stateDefaultDisabled[entity] = false
				gB_stateDisabled[0][entity] = false
				gI_entityID[gI_entityTotalCount++] = entity
			}*/
		}
	}
	//char sTriggers[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity"}
	//char sOutputs[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnEndTouch", "OnTrigger", "OnStartTouchAll"}
	//for(int i = 0; i < sizeof(sTriggers); i++)
		//for(int j = 0; j < sizeof(sOutputs); j++)
			//HookEntityOutput(sTriggers[i], sOutputs[j], TriggerOutputHook) //make able to work !self
	PrintToServer("Total entities in proccess: %i. Math counters: %i", gI_entityTotalCount, gI_mathTotalCount)
	//return Plugin_Continue
}

void LinkedEntities(int entity, char[] output, char[] classname)
{
	int count = GetOutputActionCount(entity, output)
	char sInput[64]
	if(count)
		OutputsOrInputs(entity, classname)
	//PrintToServer("%s", output)
	for(int i = 0; i < count; i++)
	{
		GetOutputActionTargetInput(entity, output, i, sInput, 64)
		//PrintToServer("%s", sInput)
		if(StrEqual(sInput, "Enable") || StrEqual(sInput, "Disable") || StrEqual(sInput, "Toggle") || StrEqual(sInput, "Break") || StrEqual(sInput, "Lock") || StrEqual(sInput, "Unlock") || StrEqual(sInput, "Add") || StrEqual(sInput, "Subtract"))
		{
			char sTarget[64]
			GetOutputActionTarget(entity, output, i, sTarget, 64)
			//PrintToServer("%s", sTarget)
			char sName[64]
			//char sClassnameToggle[][] = {"func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button"}
			char sClassnameToggle[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_breakable", "func_button", "math_counter"}
			for(int j = 0; j < sizeof(sClassnameToggle); j++)
			{
				int entity2
				while((entity2 = FindEntityByClassname(entity2, sClassnameToggle[j])) != INVALID_ENT_REFERENCE)
				{
					//if(IsValidEntity(entity2) || (StrEqual(sClassnameToggle[j], "math_counter") && (GetOutputActionCount(entity, "m_OutValue") || GetOutputActionCount(entity, "m_OnGetValue") || GetOutputActionCount(entity, "m_OnUser3") || GetOutputActionCount(entity, "m_OnUser4"))))
					//if(IsValidEntity(entity2))
					{
						GetEntPropString(entity2, Prop_Data, "m_iName", sName, 64)
						if(StrEqual(sTarget, sName) || (StrEqual(sTarget, "!self") && entity2 == entity))
						{
							//if(StrEqual(sInput, "Toggle") && !StrEqual(sClassnameToggle[j], "math_counter"))
							if(StrEqual(sInput, "Toggle") && !StrEqual(sClassnameToggle[j], "math_counter"))
							{
								if(1 < j < 7)
									HookEntityOutput(sClassnameToggle[j], output, TriggerOutputHook)
								if(0 <= j < 8)
								{
									gI_linkedTogglesDefault[++gI_maxLinks[entity]][entity] = entity2
									gI_entityOutput[GetOutput(output)][entity2]++
								}
							}
							//else if((StrEqual(sInput, "Add") || StrEqual(sInput, "Subtract")) && StrEqual(classname, "math_counter"))
							//else if((StrEqual(sInput, "Add") || StrEqual(sInput, "Subtract")) && StrEqual(sClassnameToggle[j], "math_counter"))
							//{

							//}
							if(StrEqual(sClassnameToggle[j], "math_counter"))
							{
								if(StrEqual(sInput, "Add") || StrEqual(sInput, "Subtract"))
									OutputsOrInputs(entity, sClassnameToggle[j], entity2)
							}
							else
								OutputsOrInputs(entity2, sClassnameToggle[j])
							/*if(StrEqual(sClassnameToggle[j], sClassnameToggle[6]))
							{
								gB_button[toggle] = true
								DHookEntity(gH_AcceptInput, false, toggle, INVALID_FUNCTION, AcceptInputButton)
							}*/
						}
					}
				}
			}
		}
	}
}

void OutputsOrInputs(int entity, char[] output, int entity2 = 0)
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
	if(i == 9)
	{
		PrintToServer("%i %i", entity, entity2)
		for(int j = 1; j <= gI_mathTotalCount; j++)
			if(gI_mathID[j] == entity2)
				continue
		gI_mathID[++gI_mathTotalCount] = entity2
		gF_mathValueDefault[gI_mathTotalCount] = GetEntDataFloat(entity, FindDataMapInfo(entity2, "m_OutValue"))
		gF_mathMin[gI_mathTotalCount] = GetEntPropFloat(entity2, Prop_Data, "m_flMin")
		gF_mathMax[gI_mathTotalCount] = GetEntPropFloat(entity2, Prop_Data, "m_flMax")
		OutputChange(entity2, "m_OnHitMmin", "OnUser3")
		OutputChange(entity2, "m_OnHitMax", "OnUser4")
		DHookEntity(gH_AcceptInput, false, entity2, INVALID_FUNCTION, AcceptInputMath)
	}
	else
	{
		for(int j = 1; j <= gI_entityTotalCount; j++)
			if(gI_entityID[j] == entity)
				continue
		gI_entityID[++gI_entityTotalCount] = entity
	}
	if(i < 7)
		DHookEntity(gH_AcceptInput, false, entity)
	else if(i == 7)
	{
	}
	else if(i == 8)
	{
		DHookEntity(gH_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputButton)
		SDKHook(entity, SDKHook_Use, HookButton)
		SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage)
		gF_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
		SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
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

void OutputChange(int entity, char[] output, char[] outputtype)
{
	int count = GetOutputActionCount(entity, "output")
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
	Reset(Trikz_GetClientPartner(client))
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	//if(DHookIsNullParam(hParams, 1) || DHookIsNullParam(hParams, 2))
	//	return MRES_Ignored
	//PrintToServer("test")
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	int activator = DHookGetParam(hParams, 2)
	//if(1 > activator || activator > MaxClients)
	//	return MRES_Ignored
	//if(activator < 1)
	//	return MRES_Ignored
    /*if(0 > activator || activator > MaxClients)
    {
        DHookSetReturn(hReturn, false)
        return MRES_Supercede
    }*/
	int partner = Trikz_GetClientPartner(activator)
	//int caller = DHookGetParam(hParams, 3)
	//int outputid = DHookGetParam(hParams, 5)
	//if(0 < activator <= MaxClients)
	{
		if(StrEqual(sInput, "Enable"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			else
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Disable"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else
				gB_stateDisabled[0][pThis] = true
		}
		else if(StrEqual(sInput, "Toggle"))
		{
			if(partner)
			{
				if(gI_linkedToggles[activator][pThis])
				{
					gB_stateDisabled[activator][pThis] = !gB_stateDisabled[activator][pThis]
					gB_stateDisabled[partner][pThis] = !gB_stateDisabled[partner][pThis]
					gI_linkedToggles[activator][pThis]--
					gI_linkedToggles[partner][pThis]--
				}
			}
			else
				gB_stateDisabled[0][pThis] = !gB_stateDisabled[0][pThis]
		}
		/*else if(StrEqual(sInput, "Break"))
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
		}*/
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
	//return MRES_Ignored
	//DHookSetReturn(hReturn, false)
	//return MRES_Supercede
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	//if(!gB_button[pThis])
	//	return MRES_Ignored
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	//if(DHookIsNullParam(hParams, 2))
	//	return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	//if(activator < 1)
	//	return MRES_Ignored
	//int caller = DHookGetParam(hParams, 3)
	int partner = Trikz_GetClientPartner(activator)
	//int outputid = DHookGetParam(hParams, 5)
	//if(activator < 0 || activator > MaxClients)
	//{
	//	DHookSetReturn(hReturn, false)
	//	return MRES_Supercede
	//}
	//if(0 < activator <= MaxClients)
	{
		if(StrEqual(sInput, "Unlock"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = false
				gB_stateDisabled[partner][pThis] = false
			}
			else
				gB_stateDisabled[0][pThis] = false
		}
		else if(StrEqual(sInput, "Lock"))
		{
			if(partner)
			{
				gB_stateDisabled[activator][pThis] = true
				gB_stateDisabled[partner][pThis] = true
			}
			else
				gB_stateDisabled[0][pThis] = true
		}
		//DHookSetReturn(hReturn, false)
		//return MRES_Supercede
	}
	//return MRES_Ignored
}

MRESReturn AcceptInputMath(int pThis, Handle hReturn, Handle hParams)
{
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
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
			pThisIndex = gI_mathTotalCount
			continue
		}
	}
	if(StrEqual(sInput, "Add"))
	{
		if(gF_mathValue[activator][pThisIndex] < gF_mathMax[pThisIndex])
		{
			if(partner)
			{
				gF_mathValue[activator][pThisIndex] += flValue
				gF_mathValue[activator][partner] += flValue
				if(gF_mathValue[activator][pThisIndex] >= gF_mathMax[pThisIndex])
				{
					gF_mathValue[activator][pThisIndex] = gF_mathMax[pThisIndex]
					gF_mathValue[partner][pThisIndex] = gF_mathMax[pThisIndex]
					AcceptEntityInput(pThis, "FireUser3", activator, activator)
				}
			}
			else
			{
				gF_mathValue[0][pThisIndex] += flValue
				if(gF_mathValue[0][pThisIndex] >= gF_mathMax[pThisIndex])
				{
					gF_mathValue[0][pThisIndex] = gF_mathMax[pThisIndex]
					AcceptEntityInput(pThis, "FireUser3", activator, activator)
				}
			}
		}
	}
	else if(StrEqual(sInput, "Subtract"))
	{
		if(gF_mathValue[activator][pThisIndex] > gF_mathMax[pThisIndex])
		{
			if(partner)
			{
				gF_mathValue[activator][pThisIndex] -= flValue
				gF_mathValue[activator][partner] -= flValue
				if(gF_mathValue[activator][pThisIndex] <= gF_mathMax[pThisIndex])
				{
					gF_mathValue[activator][pThisIndex] = gF_mathMax[pThisIndex]
					gF_mathValue[partner][pThisIndex] = gF_mathMax[pThisIndex]
					AcceptEntityInput(pThis, "FireUser4", activator, activator)
				}
			}
			else
			{
				gF_mathValue[0][pThisIndex] += flValue
				if(gF_mathValue[0][pThisIndex] >= gF_mathMax[pThisIndex])
				{
					gF_mathValue[0][pThisIndex] = gF_mathMax[pThisIndex]
					AcceptEntityInput(pThis, "FireUser4", activator, activator)
				}
			}
		}
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

Action TouchTrigger(int entity, int other)
{
	if(0 < other <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(other)
		if(partner)
		{
			if(gB_stateDisabled[other][entity])
				return Plugin_Handled
		}
		else
			if(gB_stateDisabled[0][entity])
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
				client = target
		}
		int partner = Trikz_GetClientPartner(client)
		if(partner)
		{
			if(gB_stateDisabled[client][entity])
				return Plugin_Handled
		}
		else
		{
			client = 0
			if(gB_stateDisabled[client][entity])
				return Plugin_Handled
		}
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
		for(int i = 1; i <= gI_maxLinks[entity]; i++)
		{
			gI_linkedToggles[activator][gI_linkedTogglesDefault[i][entity]]++
			gI_linkedToggles[partner][gI_linkedTogglesDefault[i][entity]]++
		}
	}
	else
	{
		if(gF_buttonReady[0][entity] > GetGameTime() || gB_stateDisabled[0][entity])
			return Plugin_Handled
		gF_buttonReady[0][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
	}
	if(GetEntProp(entity, Prop_Data, "m_bLocked"))
		AcceptEntityInput(entity, "Unlock")
	return Plugin_Continue
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker)
}

Action TriggerOutputHook(char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(partner)
		{
			if(gB_stateDisabled[activator][caller])
				return Plugin_Handled
			for(int i = 1; i <= gI_maxLinks[caller]; i++)
				if(gI_linkedToggles[activator][gI_linkedTogglesDefault[i][caller]])
					return Plugin_Handled
			char sOrigOutput[32]
			Format(sOrigOutput, 32, "m_%s", output)
			for(int i = 1; i <= gI_maxLinks[caller]; i++)
			{
				gI_linkedToggles[activator][gI_linkedTogglesDefault[i][caller]] = gI_entityOutput[GetOutput(sOrigOutput)][gI_linkedTogglesDefault[i][caller]]
				gI_linkedToggles[partner][gI_linkedTogglesDefault[i][caller]] = gI_entityOutput[GetOutput(sOrigOutput)][gI_linkedTogglesDefault[i][caller]]
			}
		}
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
	int partner
	if(0 < ent2 <= MaxClients)
		partner = Trikz_GetClientPartner(ent2)
	if(0 < ent2 <= MaxClients && ((!gB_stateDisabled[ent2][ent1] && partner) || (!gB_stateDisabled[0][ent1] && !partner)))
		return MRES_Ignored
	char classname[32]
	GetEntPropString(ent2, Prop_Data, "m_iClassname", classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients && ((!gB_stateDisabled[ent2owner][ent1] && partner) || (!gB_stateDisabled[0][ent1] && !partner)))
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
	else
		return 8
}

Action TransmitPlayer(int entity, int client) //entity - me, client - loop all clients
{	
	if(client != entity && 0 < entity <= MaxClients && IsPlayerAlive(client))
	{
		if(Trikz_GetClientPartner(entity) == client) //make visible partner
			return Plugin_Continue
		if(!Trikz_GetClientPartner(entity) && !Trikz_GetClientPartner(client)) //make visible no mates for no mate
			return Plugin_Continue
		return Plugin_Handled
	}
	return Plugin_Continue
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(IsValidEntity(entity) && StrContains(classname, "_projectile") != -1)
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade)
}

Action TransmitNade(int entity, int client) //entity - nade, client - loop all clients
{	
	int entOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	int partner = Trikz_GetClientPartner(entOwner)
	if(IsPlayerAlive(client))
	{		
		if(entOwner == client) //make visible own nade
			return Plugin_Continue
		if(partner == client) //make visible partner
			return Plugin_Continue
		if(!partner && !Trikz_GetClientPartner(client)) //make visible nade only for no mates
			return Plugin_Continue
		return Plugin_Handled
	}
	return Plugin_Continue
}

public Action Trikz_CheckSolidity(int ent1, int ent2)
{	
	int ent1Partner
	int ent2Partner
	int entOwner
	int entOwnerPartner
	if(0 < ent1 <= MaxClients && 0 < ent2 <= MaxClients && IsFakeClient(ent1) && IsFakeClient(ent2)) //make no collide with bot
		return Plugin_Handled //result = false
	char sClassname[32]
	GetEntityClassname(ent1, sClassname, 32)
	int iPreventNadeBoostAndFallThroughBrush
	if(StrContains(sClassname, "projectile") != -1)
		iPreventNadeBoostAndFallThroughBrush = GetMaxEntities()
	else
		iPreventNadeBoostAndFallThroughBrush = MaxClients
	if(0 < ent1 <= iPreventNadeBoostAndFallThroughBrush)
	{
		if(0 < ent2 <= MaxClients && !IsFakeClient(ent2))
			ent2Partner = Trikz_GetClientPartner(ent2)
		entOwner = GetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity")
		if(0 < entOwner <= MaxClients && !IsFakeClient(entOwner))
			entOwnerPartner = Trikz_GetClientPartner(entOwner)
		GetEntityClassname(ent1, sClassname, 32)
		if(StrContains(sClassname, "projectile") != -1)
		{			
			//make nade collide for all nomates.
			if(!entOwnerPartner && !ent2Partner)
			{
				//make nade no collide for owner.
				if(entOwner == ent2)
					return Plugin_Handled
				return Plugin_Continue
			}
			//make nade no colide if target is not mate.
			if(entOwner != ent2Partner)
				return Plugin_Handled
			//make nade collide for mate.
			if(entOwnerPartner && entOwnerPartner == ent2)
			{
				//make nade no collide for owner.
				if(entOwner == ent2)
					return Plugin_Handled
				return Plugin_Continue
			}
		}
		GetEntityClassname(ent2, sClassname, 32)
		if(StrContains(sClassname, "projectile") != -1)
		{
			if(0 < ent1 <= MaxClients && !IsFakeClient(ent1))
				ent1Partner = Trikz_GetClientPartner(ent1)
			entOwner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
			if(0 < entOwner <= MaxClients && !IsFakeClient(entOwner))
				entOwnerPartner = Trikz_GetClientPartner(entOwner)
			//make nade collide for all nomates.
			if(!entOwnerPartner && !ent1Partner)
			{
				//make nade no collide for owner.
				if(entOwner == ent1)
					return Plugin_Handled
				return Plugin_Continue
			}
			//make nade no colide if target is not mate.
			if(entOwner != ent1Partner)
				return Plugin_Handled
			//make nade collide for mate.
			if(entOwnerPartner && entOwnerPartner == ent1)
			{
				//make nade no collide for owner.
				if(entOwner == ent1)
					return Plugin_Handled
				return Plugin_Continue
			}
		}
	}
	if(0 < ent1 <= MaxClients && 0 < ent2 <= MaxClients)
	{
		//make no collide with all players.
		if(GetEntProp(ent2, Prop_Data, "m_CollisionGroup") == 2)
			return Plugin_Handled
		//make able for nomate to collide with nomate.
		else if(Trikz_GetClientPartner(ent2) == Trikz_GetClientPartner(ent1))
			return Plugin_Continue
		//make collide for mate.
		else if(Trikz_GetClientPartner(ent2) != ent1 && Trikz_GetClientPartner(ent1) != ent2)
			return Plugin_Handled
	}
	return Plugin_Continue
}

int Native_GetThisPlugin(Handle plugin, int numParams)
{
	return true
}
