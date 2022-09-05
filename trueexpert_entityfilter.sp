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

#define MAXPLAYER MAXPLAYERS + 1
#define MAXENTITY 2048 + 1

Handle g_AcceptInput
Handle g_PassServerEntityFilter
bool g_stateDefaultDisabled[MAXENTITY]
bool g_stateDisabled[MAXPLAYER][MAXENTITY]
float g_buttonDefaultDelay[MAXENTITY]
float g_buttonReady[MAXPLAYER][MAXENTITY]
int g_entityID[MAXENTITY]
int g_entityTotalCount
int g_mathID[MAXENTITY]
int g_mathTotalCount
int g_breakID[MAXENTITY]
native int Trikz_GetClientPartner(int client)
int g_linkedEntitiesDefault[MAXENTITY][MAXENTITY]
int g_linkedEntities[MAXPLAYER][MAXENTITY]
int g_linkedMathEntitiesDefault[MAXENTITY][MAXENTITY]
int g_maxLinks[MAXENTITY]
int g_maxMathLinks[MAXENTITY]
int g_entityOutput[11][MAXENTITY]
float g_mathValueDefault[MAXENTITY]
float g_mathValue[MAXPLAYER][MAXENTITY]
float g_mathMin[MAXENTITY]
float g_mathMax[MAXENTITY]
bool g_StartTouchArtifacial[MAXPLAYER][2][MAXENTITY] //Fully used george logic from https://github.com/Ciallo-Ani/trikz/blob/main/scripting/trikz_solid.sp. Thanks to Ciallo-Ani for opensource code.
native int Trikz_GetDevmap()

public Plugin myinfo =
{
	name = "Entity filter",
	author = "Smesh",
	description = "Makes the game more personal",
	version = "0.23",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	Handle gamedata = LoadGameConfigFile("sdktools.games")
	if(!gamedata)
	{
		SetFailState("Failed to load \"sdktools.games\" gamedata.")
		delete gamedata
	}
	int offset = GameConfGetOffset(gamedata, "AcceptInput")
	if(!offset)
	{
		SetFailState("Failed to load \"AcceptInput\", invalid offset.")
		delete gamedata
	}
	g_AcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput)
	DHookAddParam(g_AcceptInput, HookParamType_CharPtr)
	DHookAddParam(g_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(g_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(g_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP) //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(g_AcceptInput, HookParamType_Int)
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post)
	gamedata = LoadGameConfigFile("trueexpert.games")
	if(!gamedata)
	{
		SetFailState("Failed to load \"trueexpert.games.txt\" gamedata.")
		delete gamedata
		delete g_PassServerEntityFilter
	}
	g_PassServerEntityFilter = DHookCreateFromConf(gamedata, "PassServerEntityFilter")
	if(!g_PassServerEntityFilter)
		SetFailState("Failed to setup detour PassServerEntityFilter.")
	if(!DHookEnableDetour(g_PassServerEntityFilter, false, PassServerEntityFilter))
		SetFailState("Failed to load detour PassServerEntityFilter.")
	delete gamedata
	delete g_PassServerEntityFilter
	g_PassServerEntityFilter = CreateGlobalForward("Trikz_CheckSolidity", ET_Hook, Param_Cell, Param_Cell)
	RegPluginLibrary("trueexpert-entityfilter")
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetEntityFilter", Native_GetEntityFilter)
	return APLRes_Success
}

public void OnClientPutInServer(int client)
{
	if(!Trikz_GetDevmap())
		SDKHook(client, SDKHook_SetTransmit, TransmitPlayer)
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!Trikz_GetDevmap())
		CreateTimer(1.0, timer_load, _, TIMER_FLAG_NO_MAPCHANGE) //Make work logic_auto on delay.
}

Action timer_load(Handle timer)
{
	char classname[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "math_counter"}
	g_entityTotalCount = 0
	g_mathTotalCount = 0
	for(int i = 1; i <= 2048; i++)
	{
		g_maxLinks[i] = 0
		g_maxMathLinks[i] = 0
		g_entityID[i] = 0
		g_mathID[i] = 0
		g_breakID[i] = 0
		g_stateDefaultDisabled[i] = false
		g_linkedEntitiesDefault[i][i] = 0
		g_linkedMathEntitiesDefault[i][i] = 0
		g_buttonDefaultDelay[i] = 0.0
		for(int j = 0; j <= 10; j++)
			g_entityOutput[j][i] = 0
		for(int j = 0; j <= MaxClients; j++)
		{
			g_stateDisabled[j][i] = false
			g_linkedEntities[j][i] = 0
			g_buttonReady[j][i] = 0.0
			for(int k = 0; k <= 1; k++)
				g_StartTouchArtifacial[j][k][i] = false
		}
	}
	for(int i = 0; i < sizeof(classname); i++)
	{
		int entity
		while((entity = FindEntityByClassname(entity, classname[i])) != INVALID_ENT_REFERENCE)
		{
			if(i < 5)
			{
				char output[][] = {"m_OnStartTouch", "m_OnEndTouchAll", "m_OnTouching", "m_OnEndTouch", "m_OnTrigger", "m_OnStartTouchAll"}
				for(int j = 0; j < sizeof(output); j++)
					EntityLinked(entity, output[j])
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
		}
	}
	char trigger[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "math_counter"}
	char output[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnEndTouch", "OnTrigger", "OnStartTouchAll", "OnPressed", "OnDamaged", "OnUser3", "OnUser4", "OnHitMin", "OnHitMax"}
	for(int i = 0; i < sizeof(trigger); i++)
		for(int j = 0; j < sizeof(output); j++)
			HookEntityOutput(trigger[i], output[j], EntityOutputHook)
	PrintToServer("Total entities in proccess: %i. Math counters: %i", g_entityTotalCount, g_mathTotalCount)
	return Plugin_Continue
}

void EntityLinked(int entity, char[] output)
{
	int count = GetOutputActionCount(entity, output)
	char input[32]
	for(int i = 0; i < count; i++)
	{
		GetOutputActionTargetInput(entity, output, i, input, 32)
		char target[64]
		GetOutputActionTarget(entity, output, i, target, 64)
		if(StrEqual(input, "Enable", false) || StrEqual(input, "Disable", false) || StrEqual(input, "Toggle", false) || StrEqual(input, "Break", false))
		{
			char classname[][] = {"func_brush", "func_wall_toggle", "trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_breakable"}
			for(int j = 0; j < sizeof(classname); j++)
			{
				int entityLinked
				while((entityLinked = FindLinkedEntity(entityLinked, classname[j], target, entity)) != INVALID_ENT_REFERENCE)
				{
					OutputInput(entityLinked, classname[j], target)
					if(StrEqual(output, "m_OnPressed") || StrEqual(output, "m_OnDamaged"))
						OutputInput(entity, "func_button")
					if(entity > 0)
					{
						g_linkedEntitiesDefault[++g_maxLinks[entity]][entity] = entityLinked
						g_entityOutput[GetOutput(output)][entityLinked] = 1
					}
					else
					{
						for(int k = 1; k <= g_mathTotalCount; k++)
						{
							int math = k
							if(g_mathID[math] == entity)
							{
								g_linkedMathEntitiesDefault[++g_maxMathLinks[math]][math] = entityLinked
								g_entityOutput[GetOutput(output)][entityLinked] = 1
								break
							}
						}
					}
				}
			}
		}
		else if(StrEqual(input, "Unlock", false) || StrEqual(input, "Lock", false))
		{
			int entityLinked
			while((entityLinked = FindLinkedEntity(entityLinked, "func_button", target)) != INVALID_ENT_REFERENCE)
			{
				OutputInput(entityLinked, "func_button")
				if(entity > 0)
				{
					g_linkedEntitiesDefault[++g_maxLinks[entity]][entity] = entityLinked
					g_entityOutput[GetOutput(output)][entityLinked] = 1
				}
				else
				{
					for(int k = 1; k <= g_mathTotalCount; k++)
					{
						int math = k
						if(g_mathID[math] == entity)
						{
							g_linkedMathEntitiesDefault[++g_maxMathLinks[math]][math] = entityLinked
							g_entityOutput[GetOutput(output)][entityLinked] = 1
							break
						}
					}
				}
				DHookEntity(g_AcceptInput, false, entityLinked, INVALID_FUNCTION, AcceptInputButton)
			}
		}
		else if(StrEqual(input, "Add", false) || StrEqual(input, "Subtract", false))
		{
			int entityLinked
			while((entityLinked = FindLinkedEntity(entityLinked, "math_counter", target)) != INVALID_ENT_REFERENCE)
				OutputInput(entityLinked, "math_counter")
		}
	}
}

int FindLinkedEntity(int entity, char[] classname, char[] target, int parent = 0)
{
	char name[64]
	while((entity = FindEntityByClassname(entity, classname)) != INVALID_ENT_REFERENCE)
	{
		if(StrEqual(target, "!self", false) && entity == parent)
			return entity
		if(!GetEntPropString(entity, Prop_Data, "m_iName", name, 64))
			continue
		if(StrEqual(target, name, false))
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
		for(int j = 1; j <= g_entityTotalCount; j++)
			if(g_entityID[j] == entity)
				return
		g_entityID[++g_entityTotalCount] = entity
	}
	else
	{
		for(int j = 1; j <= g_mathTotalCount; j++)
			if(g_mathID[j] == entity)
				return
		g_mathID[++g_mathTotalCount] = entity
	}
	if(i == 7)
	{
		int template
		bool break_
		while((template = FindEntityByClassname(template, "point_template")) != INVALID_ENT_REFERENCE)
		{
			char name[64]
			for(int j = 0; j < 16; j++)
			{
				Format(name, 64, "m_iszTemplateEntityNames[%i]", j)
				GetEntPropString(template, Prop_Data, name, name, 64)
				if(StrEqual(target, name, false))
				{
					g_breakID[g_entityTotalCount] = template
					DHookEntity(g_AcceptInput, false, template)
					break_ = true
					break
				}
			}
			if(break_)
				break
		}
		g_stateDefaultDisabled[entity] = false
		g_stateDisabled[0][entity] = false
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
		AddOutput(entity, "m_OnBreak", "OnUser4")
		DHookEntity(g_AcceptInput, false, entity)
	}
	if(i == 9)
	{
		if(IsValidEntity(entity) && (!GetOutputActionCount(entity, "m_OutValue") || !GetOutputActionCount(entity, "m_OnGetValue") || !GetOutputActionCount(entity, "m_OnUser3") || !GetOutputActionCount(entity, "m_OnUser4"))) //thanks to george for original code.
		{
			g_mathValueDefault[g_mathTotalCount] = GetEntDataFloat(entity, FindDataMapInfo(entity, "m_OutValue"))
			g_mathValue[0][g_mathTotalCount] = GetEntDataFloat(entity, FindDataMapInfo(entity, "m_OutValue"))
			g_mathMin[g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMin")
			g_mathMax[g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMax")
			AddOutput(entity, "m_OnHitMin", "OnUser4")
			AddOutput(entity, "m_OnHitMax", "OnUser3")
			DHookEntity(g_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputMath)
		}
	}
	if(i < 7)
		DHookEntity(g_AcceptInput, false, entity)
	else if(i == 8)
	{
		SDKHook(entity, SDKHook_Use, HookButton)
		SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage)
		g_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
		g_buttonReady[0][entity] = 0.0
		SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
	}
	if(i < 2)
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
	else if(1 < i < 7)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
	if((!i && GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 8 && GetEntProp(entity, Prop_Data, "m_bLocked")))
	{
		g_stateDefaultDisabled[entity] = true
		g_stateDisabled[0][entity] = true
	}
	else if((!i && !GetEntProp(entity, Prop_Data, "m_iDisabled")) || (i == 1 && !GetEntProp(entity, Prop_Data, "m_spawnflags")) || (1 < i < 7 && !GetEntProp(entity, Prop_Data, "m_bDisabled")) || (i == 8 && !GetEntProp(entity, Prop_Data, "m_bLocked")))
	{
		g_stateDefaultDisabled[entity] = false
		g_stateDisabled[0][entity] = false
	}
	if(!i || 1 < i < 7)
		AcceptEntityInput(entity, "Enable")
	else if(i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags"))
		AcceptEntityInput(entity, "Toggle")
	else if(i == 8 && GetEntProp(entity, Prop_Data, "m_bLocked"))
		AcceptEntityInput(entity, "Unlock")
}

void AddOutput(int entity, char[] output, char[] outputtype)
{
	int count = GetOutputActionCount(entity, output)
	char output_[4][256]
	for(int i = 0; i < count; i++)
	{
		GetOutputActionTarget(entity, output, i, output_[0], 256)
		GetOutputActionTargetInput(entity, output, i, output_[1], 256)
		GetOutputActionParameter(entity, output, i, output_[2], 256)
		float delay = GetOutputActionDelay(entity, output, i)
		int fire = GetOutputActionTimesToFire(entity, output, i)
		Format(output_[3], 256, "%s %s:%s:%s:%f:%i", outputtype, output_[0], output_[1], output_[2], delay, fire)
		SetVariantString(output_[3])
		AcceptEntityInput(entity, "AddOutput")
	}
}

void Reset(int client)
{
	for(int i = 1; i <= g_entityTotalCount; i++)
	{
		g_stateDisabled[client][g_entityID[i]] = g_stateDefaultDisabled[g_entityID[i]]
		g_buttonReady[client][g_entityID[i]] = 0.0
		g_linkedEntities[client][g_entityID[i]] = 0
		for(int j = 0; j <= 1; j++)
			g_StartTouchArtifacial[client][j][g_entityID[i]] = false
	}
	for(int i = 1; i <= g_mathTotalCount; i++)
		g_mathValue[client][i] = g_mathValueDefault[i]
}

public void Trikz_OnRestart(int client, int partner)
{
	Reset(client)
	Reset(partner)
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	char input[32]
	DHookGetParamString(hParams, 1, input, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		if(IsFakeClient(activator))
		{
			if(StrEqual(input, "Volume", false) || StrEqual(input, "ToggleSound", false) || StrEqual(input, "PlaySound", false) || StrEqual(input, "StopSound", false)) //https://github.com/Kxnrl/MapMusic-API/blob/master/mapmusic.sp
			{
				DHookSetReturn(hReturn, false)
				return MRES_Supercede
			}
		}
		if(!StrEqual(input, "Enable", false) && !StrEqual(input, "Disable", false) && !StrEqual(input, "Toggle", false) && !StrEqual(input, "Break", false) && !StrEqual(input, "ForceSpawn", false))
			return MRES_Ignored
		int partner = Trikz_GetClientPartner(activator)
		if(StrEqual(input, "Enable", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = false
				g_stateDisabled[partner][pThis] = false
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = false
				g_linkedEntities[0][pThis]--
			}
		}
		else if(StrEqual(input, "Disable", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = true
				g_stateDisabled[partner][pThis] = true
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = true
				g_linkedEntities[0][pThis]--
			}
		}
		else if(StrEqual(input, "Toggle", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = !g_stateDisabled[activator][pThis]
				g_stateDisabled[partner][pThis] = !g_stateDisabled[partner][pThis]
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = !g_stateDisabled[0][pThis]
				g_linkedEntities[0][pThis]--
			}
		}
		else if(StrEqual(input, "Break", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = true
				g_stateDisabled[partner][pThis] = true
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = true
				g_linkedEntities[0][pThis]--
			}
			AcceptEntityInput(pThis, "FireUser4", activator, pThis) //make fire brush with output
		}
		else
		{
			int thisIndex
			for(int i = 1; i <= g_entityTotalCount; i++)
			{
				if(g_breakID[i] == pThis)
				{
					thisIndex = g_entityID[i]
					break
				}
			}
			if(thisIndex)
			{
				if(g_stateDisabled[activator][thisIndex] && partner)
				{
					g_stateDisabled[activator][thisIndex] = false
					g_stateDisabled[partner][thisIndex] = false
				}
				if(g_stateDisabled[0][thisIndex])
					g_stateDisabled[0][thisIndex] = false
			}
		}
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
	}
	return MRES_Ignored
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	char input[32]
	DHookGetParamString(hParams, 1, input, 32)
	if(!StrEqual(input, "Lock", false) && !StrEqual(input, "Unlock", false))
		return MRES_Ignored
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(StrEqual(input, "Unlock", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = false
				g_stateDisabled[partner][pThis] = false
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = false
				g_linkedEntities[0][pThis]--
			}
		}
		else if(StrEqual(input, "Lock", false))
		{
			if(g_linkedEntities[activator][pThis] && partner)
			{
				g_stateDisabled[activator][pThis] = true
				g_stateDisabled[partner][pThis] = true
				g_linkedEntities[activator][pThis]--
				g_linkedEntities[partner][pThis]--
			}
			if(g_linkedEntities[0][pThis])
			{
				g_stateDisabled[0][pThis] = true
				g_linkedEntities[0][pThis]--
			}
		}
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
	}
	return MRES_Ignored
}

MRESReturn AcceptInputMath(int pThis, Handle hReturn, Handle hParams)
{
	char input[32]
	DHookGetParamString(hParams, 1, input, 32)
	if(!StrEqual(input, "Add", false) && !StrEqual(input, "Subtract", false) && !StrEqual(input, "SetValue", false) && !StrEqual(input, "SetValueNoFire", false))
		return MRES_Ignored
	int activator
	if(!DHookIsNullParam(hParams, 2))
		activator = DHookGetParam(hParams, 2)
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		char value_[64]
		DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, value_, 64)
		float value = StringToFloat(value_)
		int thisIndex
		for(int i = 1; i <= g_mathTotalCount; i++)
		{
			if(g_mathID[i] == pThis)
			{
				thisIndex = i
				break
			}
		}
		if(!thisIndex)
			return MRES_Ignored
		if(StrEqual(input, "Add", false))
		{
			if(g_mathValue[activator][thisIndex] < g_mathMax[thisIndex])
			{
				g_mathValue[activator][thisIndex] += value
				g_mathValue[partner][thisIndex] += value
				if(g_mathValue[activator][thisIndex] >= g_mathMax[thisIndex])
				{
					g_mathValue[activator][thisIndex] = g_mathMax[thisIndex]
					g_mathValue[partner][thisIndex] = g_mathMax[thisIndex]
					AcceptEntityInput(pThis, "FireUser3", activator, activator)
				}
			}
		}
		else if(StrEqual(input, "Subtract", false))
		{
			if(g_mathValue[activator][thisIndex] > g_mathMin[thisIndex])
			{
				g_mathValue[activator][thisIndex] -= value
				g_mathValue[partner][thisIndex] -= value
				if(g_mathValue[activator][thisIndex] <= g_mathMin[thisIndex])
				{
					g_mathValue[activator][thisIndex] = g_mathMin[thisIndex]
					g_mathValue[partner][thisIndex] = g_mathMin[thisIndex]
					AcceptEntityInput(pThis, "FireUser4", activator, activator)
				}
			}
		}
		else
		{
			g_mathValue[activator][thisIndex] = value
			g_mathValue[partner][thisIndex] = value
			if(g_mathValue[activator][thisIndex] < g_mathMin[thisIndex])
			{
				g_mathValue[activator][thisIndex] = g_mathMin[thisIndex]
				g_mathValue[partner][thisIndex] = g_mathMin[thisIndex]
			}
			else if(g_mathValue[activator][thisIndex] > g_mathMax[thisIndex])
			{
				g_mathValue[activator][thisIndex] = g_mathMax[thisIndex]
				g_mathValue[partner][thisIndex] = g_mathMax[thisIndex]
			}
		}
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
	}
	return MRES_Ignored
}

Action TouchTrigger(int entity, int other)
{
	/*char classname[32]
	GetEntityClassname(entity, classname, 32)
	char classname2[32]
	GetEntityClassname(other, classname2, 32)
	PrintToServer("e: %i/%s o: %i/%s", entity, classname, other, classname2)
	int owner = GetEntPropEnt(other, Prop_Data, "m_hOwnerEntity")
	if(StrEqual(classname2, "flashbang_projectile", true))
		AcceptEntityInput(entity, "StartTouch", owner, owner)*/
	if(0 < other <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(other)
		if(g_stateDisabled[partner][entity])
		{
			if(g_StartTouchArtifacial[partner][1][entity])
				AcceptEntityInput(entity, "EndTouch", other, other)
			return Plugin_Handled
		}
		else
		{
			if(!g_StartTouchArtifacial[partner][1][entity])
			{
				g_StartTouchArtifacial[partner][0][entity] = true
				AcceptEntityInput(entity, "StartTouch", other, other)
			}
		}
		g_StartTouchArtifacial[partner][1][entity] = g_stateDisabled[partner][entity] ? false : true
	}
	return Plugin_Continue
}

Action EntityVisibleTransmit(int entity, int client)
{
	if(0 < client <= MaxClients)
	{
		if(IsPlayerAlive(client))
		{
			int partner = Trikz_GetClientPartner(client)
			if(g_stateDisabled[partner][entity])
				return Plugin_Handled
		}
		else
		{
			int target = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")
			if(0 < target <= MaxClients)
			{
				int partner = Trikz_GetClientPartner(target)
				if(g_stateDisabled[partner][entity])
					return Plugin_Handled
			}
		}
	}
	return Plugin_Continue
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	int partner = Trikz_GetClientPartner(activator)
	if(partner)
	{
		if(g_buttonReady[activator][entity] > GetGameTime() || g_stateDisabled[activator][entity])
			return Plugin_Handled
		g_buttonReady[activator][entity] = GetGameTime() + g_buttonDefaultDelay[entity]
		g_buttonReady[partner][entity] = GetGameTime() + g_buttonDefaultDelay[entity]
	}
	else
	{
		if(g_buttonReady[partner][entity] > GetGameTime() || g_stateDisabled[partner][entity])
			return Plugin_Handled
		g_buttonReady[partner][entity] = GetGameTime() + g_buttonDefaultDelay[entity]
	}
	return Plugin_Continue
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker)
	return Plugin_Continue
}

Action EntityOutputHook(char[] output, int caller, int activator, float delay)
{
	//PrintToServer("c:%i a: %i", caller, activator)
	if(activator > MaxClients)
	{
		activator = GetEntPropEnt(activator, Prop_Data, "m_hOwnerEntity")
		if(activator < 0)
			activator = 0
	}
	if(0 < activator <= MaxClients)
	{
		int partner = Trikz_GetClientPartner(activator)
		if(caller > 0)
		{
			char outputFormated[32]
			Format(outputFormated, 32, "m_%s", output)
			if(!g_stateDisabled[partner][caller])
			{
				for(int i = 1; i <= g_maxLinks[caller]; i++)
				{
					if(partner)
					{
						g_linkedEntities[activator][g_linkedEntitiesDefault[i][caller]] += g_entityOutput[GetOutput(outputFormated)][g_linkedEntitiesDefault[i][caller]]
						g_linkedEntities[partner][g_linkedEntitiesDefault[i][caller]] += g_entityOutput[GetOutput(outputFormated)][g_linkedEntitiesDefault[i][caller]]
					}
					else
						g_linkedEntities[partner][g_linkedEntitiesDefault[i][caller]] += g_entityOutput[GetOutput(outputFormated)][g_linkedEntitiesDefault[i][caller]]
				}
			}
			if(partner)
			{
				if(StrContains(output, "OnStartTouch") != -1)
				{
					if(g_StartTouchArtifacial[partner][0][caller])
					{
						g_StartTouchArtifacial[activator][0][caller] = false
						g_StartTouchArtifacial[partner][0][caller] = false
						return Plugin_Continue
					}
					if(g_stateDisabled[partner][caller])
						return Plugin_Handled
					g_StartTouchArtifacial[activator][1][caller] = true
					g_StartTouchArtifacial[partner][1][caller] = true
				}
				else if(StrContains(output, "OnEndTouch") != -1)
				{
					if(g_stateDisabled[partner][caller] && !g_StartTouchArtifacial[partner][1][caller])
						return Plugin_Handled
					g_StartTouchArtifacial[activator][1][caller] = false
					g_StartTouchArtifacial[partner][1][caller] = false
				}
			}
			else
			{
				if(StrContains(output, "OnStartTouch") != -1)
				{
					if(g_StartTouchArtifacial[partner][0][caller])
					{
						g_StartTouchArtifacial[partner][0][caller] = false
						return Plugin_Continue
					}
					if(g_stateDisabled[partner][caller])
						return Plugin_Handled
					g_StartTouchArtifacial[partner][1][caller] = true
				}
				else if(StrContains(output, "OnEndTouch") != -1)
				{
					if(g_stateDisabled[partner][caller] && !g_StartTouchArtifacial[partner][1][caller])
						return Plugin_Handled
					g_StartTouchArtifacial[partner][1][caller] = false
				}
			}
		}
		else
		{
			char outputFormated[32]
			if(StrEqual(output, "OnUser3"))
				Format(outputFormated, 32, "m_OnHitMax", output)
			else if(StrEqual(output, "OnUser4"))
				Format(outputFormated, 32, "m_OnHitMin", output)
			for(int i = 1; i <= g_mathTotalCount; i++)
			{
				if(g_mathID[i] == caller)
				{
					int math = i
					for(int j = 1; j <= g_maxMathLinks[math]; j++)
					{
						if(partner)
						{
							g_linkedEntities[activator][g_linkedMathEntitiesDefault[j][math]] += g_entityOutput[GetOutput(outputFormated)][g_linkedMathEntitiesDefault[j][math]]
							g_linkedEntities[partner][g_linkedMathEntitiesDefault[j][math]] += g_entityOutput[GetOutput(outputFormated)][g_linkedMathEntitiesDefault[j][math]]
						}
						else
							g_linkedEntities[partner][g_linkedMathEntitiesDefault[j][math]] += g_entityOutput[GetOutput(outputFormated)][g_linkedMathEntitiesDefault[j][math]]
					}
				}
			}
		}
	}
	return Plugin_Continue
}

MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) || DHookIsNullParam(hParams, 2) || Trikz_GetDevmap())
		return MRES_Ignored
	int ent1 = DHookGetParam(hParams, 1) //touch reciever
	int ent2 = DHookGetParam(hParams, 2) //touch sender
	Action result
	Call_StartForward(g_PassServerEntityFilter)
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
	{
		partner = Trikz_GetClientPartner(ent2)
		if(!g_stateDisabled[partner][ent1])
			return MRES_Ignored
	}
	char classname[32]
	GetEntityClassname(ent2, classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients)
		{
			partner = Trikz_GetClientPartner(ent2owner)
			if(!g_stateDisabled[partner][ent1])
				return MRES_Ignored
		}
	}
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "_projectile") != -1)
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade)
	else if(StrEqual(classname, "ambient_generic"))
		DHookEntity(g_AcceptInput, false, entity)
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
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
	if(owner < 0)
		owner = 0
	if(IsPlayerAlive(client) && entity > 0 && owner != client && Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
		return Plugin_Handled
	return Plugin_Continue
}

public Action Trikz_CheckSolidity(int ent1, int ent2)
{
	char classname[32]
	GetEntityClassname(ent2, classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		if(0 < ent1 <= MaxClients)
		{
			int owner = GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity")
			if(owner < 0)
				owner = 0
			if(Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1))))
				return Plugin_Handled
		}
	}
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

int Native_GetEntityFilter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int entity = GetNativeCell(2)
	int partner = Trikz_GetClientPartner(client)
	return g_stateDisabled[partner][entity]
}
