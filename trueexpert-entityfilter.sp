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
//#include <entitylump>

#pragma semicolon 1
#pragma newdecls required

#define MAXPLAYER MAXPLAYERS + 1
#define MAXENTITY 2048 + 1
#define MAXLINK 512 + 1
#define MAXOUTPUT 10 + 1
#define IsValidClient(%1) (0 < %1 <= MaxClients && IsClientInGame(%1))
#define IsValidPartner(%1) 0 < Trikz_GetClientPartner(%1) <= MaxClients

Handle g_AcceptInput = INVALID_HANDLE;
Handle g_PassServerEntityFilter = INVALID_HANDLE;
bool g_stateDefaultDisabled[MAXENTITY] = {false, ...};
bool g_stateDisabled[MAXPLAYER][MAXENTITY];
float g_buttonDefaultDelay[MAXENTITY] = {0.0, ...};
float g_buttonReady[MAXPLAYER][MAXENTITY];
int g_entityID[MAXENTITY] = {0, ...};
int g_entityTotalCount = 0;
int g_mathID[MAXENTITY] = {0, ...};
int g_mathTotalCount = 0;
int g_breakID[MAXENTITY] = {0, ...};
native int Trikz_GetClientPartner(int client);
int g_linkedEntitiesDefault[MAXENTITY][MAXLINK][MAXOUTPUT];
int g_linkedEntities[MAXPLAYER][MAXENTITY];
int g_linkedMathEntitiesDefault[MAXENTITY][MAXLINK][MAXOUTPUT];
int g_maxLinks[MAXENTITY][MAXOUTPUT];
int g_maxMathLinks[MAXENTITY][MAXOUTPUT];
int g_entityOutput[MAXENTITY][MAXLINK][MAXOUTPUT];
float g_mathValueDefault[MAXENTITY] = {0.0, ...};
float g_mathValue[MAXPLAYER][MAXENTITY];
float g_mathMin[MAXENTITY] = {0.0, ...};
float g_mathMax[MAXENTITY] = {0.0, ...};
bool g_touchArtifacial[MAXPLAYER][MAXENTITY][2]; //Fully used george logic from https://github.com/Ciallo-Ani/trikz/blob/main/scripting/trikz_solid.sp. Thanks to Ciallo-Ani for opensource code.
native bool Trikz_GetDevmap();
native int GetOutputActionCount(int entity, const char[] output);
native bool GetOutputActionTarget(int entity, const char[] output, int index, char[] target, int maxlen);
native bool GetOutputActionTargetInput(int entity, const char[] output, int index, char[] targetinput, int maxlen);
native bool GetOutputActionParameter(int entity, const char[] output, int index, char[] parameter, int maxlen);
native float GetOutputActionDelay(int entity, const char[] output, int index);
native int GetOutputActionTimesToFire(int entity, const char[] output, int index);

public Plugin myinfo =
{
	name = "Entity filter",
	author = "Smesh",
	description = "Makes the game more personal.",
	version = "0.28",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	Handle gamedata = LoadGameConfigFile("sdktools.games");

	if(gamedata == INVALID_HANDLE)
	{
		SetFailState("Failed to load \"sdktools.games\" gamedata.");

		delete gamedata;
	}

	int offset = GameConfGetOffset(gamedata, "AcceptInput");

	if(offset == 0)
	{
		SetFailState("Failed to load \"AcceptInput\", invalid offset.");

		delete gamedata;
	}

	g_AcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput);
	
	DHookAddParam(g_AcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_AcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(g_AcceptInput, HookParamType_Int);

	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);

	gamedata = LoadGameConfigFile("trueexpert.games");
	
	if(gamedata == INVALID_HANDLE)
	{
		SetFailState("Failed to load \"trueexpert.games\" gamedata.");

		delete gamedata;
		delete g_PassServerEntityFilter;
	}

	g_PassServerEntityFilter = DHookCreateFromConf(gamedata, "PassServerEntityFilter");

	if(g_PassServerEntityFilter == INVALID_HANDLE)
	{
		SetFailState("Failed to setup detour PassServerEntityFilter.");
	}

	if(DHookEnableDetour(g_PassServerEntityFilter, false, PassServerEntityFilter) == false)
	{
		SetFailState("Failed to load detour PassServerEntityFilter.");
	}
	
	delete gamedata;
	delete g_PassServerEntityFilter;

	g_PassServerEntityFilter = CreateGlobalForward("Trikz_CheckSolidity", ET_Hook, Param_Cell, Param_Cell);

	RegPluginLibrary("trueexpert-entityfilter");

	/*int major = SOURCEMOD_V_MAJOR, minor = SOURCEMOD_V_MINOR;

	if(major == 1 && minor < 12)
	{
		SetFailState("SourceMod version is too old!");
	}*/

	return;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetEntityFilter", Native_GetEntityFilter);

	return APLRes_Success;
}

public void OnClientPutInServer(int client)
{
	if(Trikz_GetDevmap() == false)
	{
		SDKHook(client, SDKHook_SetTransmit, TransmitPlayer);

		for(int i = 0; i <= g_entityTotalCount; ++i)
		{
			for(int j = 0; j <= 1; j++)
			{
				g_touchArtifacial[client][g_entityID[i]][j] = false;

				continue;
			}

			continue;
		}
	}

	return;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(1.0, timer_prepare, _, TIMER_FLAG_NO_MAPCHANGE); //Make work logic_auto on delay.

	return;
}

Action timer_prepare(Handle timer)
{
	g_entityTotalCount = 0;
	g_mathTotalCount = 0;

	for(int i = 0; i < MAXENTITY; ++i)
	{
		for(int j = 0; j < MAXOUTPUT; j++)
		{
			g_maxLinks[i][j] = 0;
			g_maxMathLinks[i][j] = 0;

			continue;
		}

		g_entityID[i] = 0;
		g_mathID[i] = 0;
		g_breakID[i] = 0;
		g_stateDefaultDisabled[i] = false;
		g_buttonDefaultDelay[i] = 0.0;

		for(int j = 0; j < MAXLINK; ++j)
		{
			for(int k = 0; k < MAXOUTPUT; k++)
			{
				g_linkedEntitiesDefault[i][j][k] = 0;
				g_linkedMathEntitiesDefault[i][j][k] = 0;
				g_entityOutput[i][j][k] = 0;

				continue;
			}

			continue;
		}

		for(int j = 0; j <= MaxClients; j++)
		{
			g_stateDisabled[j][i] = false;
			g_linkedEntities[j][i] = 0;
			g_buttonReady[j][i] = 0.0;

			for(int k = 0; k <= 1; k++)
			{
				g_touchArtifacial[j][i][k] = false;

				continue;
			}

			continue;
		}

		continue;
	}

	if(Trikz_GetDevmap() == true)
	{
		return Plugin_Continue;
	}
	
	char classname[][] = {"trigger_multiple", "trigger_teleport", "trigger_teleport_relative", "trigger_push", "trigger_gravity", "func_button", "math_counter"};
	char output[][] = {"OnStartTouch", "OnEndTouchAll", "OnEndTouch", "OnTrigger", "OnStartTouchAll", "OnPressed", "OnDamaged", "OnUser3", "OnUser4", "OnHitMin", "OnHitMax"};

	for(int i = 0; i < sizeof(classname); i++)
	{
		int entity = 0;

		while((entity = FindEntityByClassname(entity, classname[i])) != INVALID_ENT_REFERENCE)
		{
			if(i <= 4)
			{
				if(!(GetEntProp(entity, Prop_Data, "m_spawnflags", 4, 0) & 1))
				{
					break; //If trigger doesn't have client check, go to next entity.
				}
			}

			for(int j = 0; j < sizeof(output); j++)
			{
				if((i <= 4 && j <= 4) || (i == 5 && (j == 5 || j == 6)) || (i == 6 && j == 9 || j == 10))
				{
					LinkProcess(entity, output[j]);
				}

				continue;
			}

			continue;
		}

		for(int j = 0; j < sizeof(output); j++)
		{
			if(j < 9)
			{
				HookEntityOutput(classname[i], output[j], EntityOutputHook);
			}

			continue;
		}
	}

	PrintToServer("Total entities in proccess: %i. Math counters: %i", g_entityTotalCount, g_mathTotalCount);

	return Plugin_Continue;
}

void LinkProcess(int entity, const char[] output)
{
	char outputFormated[24] = "";
	Format(outputFormated, sizeof(outputFormated), "m_%s", output);
	int count = GetOutputActionCount(entity, outputFormated);
	char input[16] = "", target[256] = "", classname[][] = {"func_brush", "func_wall_toggle", "trigger_*", "func_breakable", "prop_dynamic"};

	for(int i = 0; i < count; i++)
	{
		GetOutputActionTargetInput(entity, outputFormated, i, input, sizeof(input));
		GetOutputActionTarget(entity, outputFormated, i, target, sizeof(target));

		if(StrEqual(input, "Enable", false) == true || 
			StrEqual(input, "Disable", false) == true || 
			StrEqual(input, "Toggle", false) == true || 
			StrEqual(input, "Break", false) == true || 
			StrEqual(input, "TurnOn", false) == true || 
			StrEqual(input, "TurnOff", false) == true)
		{
			for(int j = 0; j < sizeof(classname); j++)
			{
				int entityLinked = 0;

				while((entityLinked = FindLinkedEntity(entityLinked, classname[j], target, entity)) != INVALID_ENT_REFERENCE)
				{
					AddToLink(entity, output, entityLinked);

					Prepare(entityLinked, classname[j], target);

					if(StrEqual(output, "OnPressed", false) == true || StrEqual(output, "OnDamaged", false) == true)
					{
						Prepare(entity, "func_button", "");
					}

					continue;
				}

				continue;
			}
		}

		else if(StrEqual(input, "Unlock", false) == true || StrEqual(input, "Lock", false) == true)
		{
			int entityLinked = 0;

			while((entityLinked = FindLinkedEntity(entityLinked, "func_button", target, 0)) != INVALID_ENT_REFERENCE)
			{
				AddToLink(entity, output, entityLinked);

				Prepare(entityLinked, "func_button", "");

				DHookEntity(g_AcceptInput, false, entityLinked, INVALID_FUNCTION, AcceptInputButton);

				continue;
			}
		}

		else if(StrEqual(input, "Add", false) == true || StrEqual(input, "Subtract", false) == true)
		{
			int entityLinked = 0;

			while((entityLinked = FindLinkedEntity(entityLinked, "math_counter", target, 0)) != INVALID_ENT_REFERENCE)
			{
				Prepare(entityLinked, "math_counter", "");

				continue;
			}
		}

		continue;
	}

	return;
}

int FindLinkedEntity(int entity, const char[] classname, const char[] target, int parent = 0)
{
	char name[256] = "";

	while((entity = FindEntityByClassname(entity, classname)) != INVALID_ENT_REFERENCE)
	{
		if(StrEqual(target, "!self", false) == true && entity == parent)
		{
			return entity;
		}

		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name), 0) == 0)
		{
			continue;
		}

		if(StrEqual(target, name, false) == true)
		{
			return entity;
		}

		continue;
	}

	return INVALID_ENT_REFERENCE;
}

void Prepare(int entity, const char[] output, const char[] target = "")
{
	int i = 0;

	if(StrEqual(output, "func_brush", false) == true)
	{
		i = 0;
	}

	else if(StrEqual(output, "func_wall_toggle", false) == true)
	{
		i = 1;
	}

	else if(StrEqual(output, "trigger_*", false) == true)
	{
		i = 2;

		if(!(GetEntProp(entity, Prop_Data, "m_spawnflags", 4, 0) & 1))
		{
			return; //If trigger doesn't have client check, quit function here.
		}
	}

	else if(StrEqual(output, "func_breakable", false) == true)
	{
		i = 3;
	}

	else if(StrEqual(output, "func_button", false) == true)
	{
		i = 4;
	}

	else if(StrEqual(output, "math_counter", false) == true)
	{
		i = 5;
	}

	else if(StrEqual(output, "prop_dynamic", false) == true)
	{
		i = 6;
	}

	if(entity > 0)
	{
		for(int j = 0; j <= g_entityTotalCount; ++j)
		{
			if(g_entityID[j] == entity)
			{
				return;
			}
		}

		g_entityID[++g_entityTotalCount] = entity;
	}

	else if(entity < 0)
	{
		for(int j = 0; j <= g_mathTotalCount; ++j)
		{
			if(g_mathID[j] == entity)
			{
				return;
			}
		}

		g_mathID[++g_mathTotalCount] = entity;
	}

	if(i == 3)
	{
		int template = 0;

		bool quit = false;

		char name[256] = "";

		while((template = FindEntityByClassname(template, "point_template")) != INVALID_ENT_REFERENCE)
		{
			for(int j = 0; j < 16; j++)
			{
				Format(name, sizeof(name), "m_iszTemplateEntityNames[%i]", j);
				GetEntPropString(template, Prop_Data, name, name, sizeof(name), 0);

				if(StrEqual(target, name, false) == true)
				{
					g_breakID[g_entityTotalCount] = template;

					DHookEntity(g_AcceptInput, false, template);

					quit = true;

					break;
				}

				continue;
			}

			if(quit == true)
			{
				break;
			}

			continue;
		}

		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit);

		AddOutput(entity, "OnBreak", "OnUser4");

		DHookEntity(g_AcceptInput, false, entity);
	}

	if(i == 5)
	{
		if(IsValidEntity(entity) == true && (GetOutputActionCount(entity, "m_OutValue") == 0 && 
											GetOutputActionCount(entity, "m_OnGetValue") == 0 && 
											GetOutputActionCount(entity, "m_OnUser3") == 0 && 
											GetOutputActionCount(entity, "m_OnUser4") == 0)) //thanks to george for original code.
		{
			g_mathValueDefault[g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_OutValue", 0);
			g_mathValue[0][g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_OutValue", 0);

			g_mathMin[g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMin", 0);
			g_mathMax[g_mathTotalCount] = GetEntPropFloat(entity, Prop_Data, "m_flMax", 0);

			AddOutput(entity, "OnHitMin", "OnUser4");
			AddOutput(entity, "OnHitMax", "OnUser3");

			DHookEntity(g_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputMath);
		}
	}

	if(i < 3 || i == 6)
	{
		DHookEntity(g_AcceptInput, false, entity);
	}

	else if(i == 4)
	{
		SDKHook(entity, SDKHook_Use, HookButton);
		SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage);

		g_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait", 0);

		SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1, 0);
	}

	if(i < 2 || i == 6)
	{
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit);
	}

	else if(i == 2)
	{
		SDKHook(entity, SDKHook_Touch, TouchTrigger);
	}

	if((i == 0 && GetEntProp(entity, Prop_Data, "m_iDisabled", 4, 0) == 1) || 
		(i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags", 4, 0) == 1) || 
		(i == 2 && GetEntProp(entity, Prop_Data, "m_bDisabled", 4, 0) == 1) || 
		(i == 4 && GetEntProp(entity, Prop_Data, "m_bLocked", 4, 0) == 1) || 
		(i == 6 && GetEntProp(entity, Prop_Data, "m_bStartDisabled", 4, 0) == 1))
	{
		g_stateDefaultDisabled[entity] = true;
		g_stateDisabled[0][entity] = true;
	}

	if(i == 0 || i == 2 || i == 6)
	{
		AcceptEntityInput(entity, "Enable");
	}

	else if(i == 1 && GetEntProp(entity, Prop_Data, "m_spawnflags", 4, 0) == 1)
	{
		AcceptEntityInput(entity, "Toggle");
	}

	else if(i == 4 && GetEntProp(entity, Prop_Data, "m_bLocked", 4, 0) == 1)
	{
		AcceptEntityInput(entity, "Unlock");
	}

	return;
}

void AddOutput(int entity, const char[] output, const char[] outputtype)
{
	char outputFormted[24] = "";
	Format(outputFormted, sizeof(outputFormted), "m_%s", output);
	int count = GetOutputActionCount(entity, outputFormted);
	char output_[4][768];

	for(int i = 0; i < count; i++)
	{
		GetOutputActionTarget(entity, outputFormted, i, output_[0], 256);
		GetOutputActionTargetInput(entity, outputFormted, i, output_[1], 32);
		GetOutputActionParameter(entity, outputFormted, i, output_[2], 256);
		float delay = GetOutputActionDelay(entity, outputFormted, i);
		int fire = GetOutputActionTimesToFire(entity, outputFormted, i);
		Format(output_[3], 768, "%s %s:%s:%s:%f:%i", outputtype, output_[0], output_[1], output_[2], delay, fire);
		SetVariantString(output_[3]);
		AcceptEntityInput(entity, "AddOutput");

		continue;
	}

	return;
}

void AddToLink(int entity, const char[] output, int entityLinked)
{
	int maxLinks = 0, maxMathLinks = 0, outputNum = GetOutput(output);

	if(entity > 0)
	{
		maxLinks = ++g_maxLinks[entity][outputNum];

		g_linkedEntitiesDefault[entity][maxLinks][outputNum] = entityLinked;

		g_entityOutput[entityLinked][maxLinks][outputNum] = 1;
	}

	else if(entity < 0)
	{
		for(int k = 0; k <= g_mathTotalCount; ++k)
		{
			int math = k;

			if(g_mathID[math] == entity)
			{
				maxMathLinks = ++g_maxMathLinks[math][outputNum];

				g_linkedMathEntitiesDefault[math][maxMathLinks][outputNum] = entityLinked;

				g_entityOutput[entityLinked][maxMathLinks][outputNum] = 1;

				break;
			}

			continue;
		}
	}

	return;
}

void Reset(int client)
{
	for(int i = 0; i <= g_entityTotalCount; ++i)
	{
		g_stateDisabled[client][g_entityID[i]] = g_stateDefaultDisabled[g_entityID[i]];
		g_buttonReady[client][g_entityID[i]] = 0.0;
		g_linkedEntities[client][g_entityID[i]] = 0;

		for(int j = 0; j <= 1; j++)
		{
			g_touchArtifacial[client][g_entityID[i]][j] = false;

			continue;
		}

		continue;
	}

	for(int i = 0; i <= g_mathTotalCount; ++i)
	{
		g_mathValue[client][i] = g_mathValueDefault[i];

		continue;
	}

	return;
}

public void Trikz_OnRestart(int client, int partner)
{
	Reset(client);
	Reset(partner);

	return;
}

MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	char input[16] = "";
	DHookGetParamString(hParams, 1, input, sizeof(input));

	if(DHookIsNullParam(hParams, 2) == true)
	{
		return MRES_Ignored;
	}

	int activator = DHookGetParam(hParams, 2);

	char classname[32] = "";
	GetEntityClassname(activator, classname, sizeof(classname));

	if(StrContains(classname, "projectile", false) != -1)
	{
		DHookSetReturn(hReturn, false);
		
		return MRES_Supercede;
	}

	if(IsValidClient(activator) == true)
	{
		if(IsFakeClient(activator) == true)
		{
			if(StrEqual(input, "Volume", false) == true || 
				StrEqual(input, "ToggleSound", false) == true || 
				StrEqual(input, "PlaySound", false) == true || 
				StrEqual(input, "StopSound", false) == true) //https://github.com/Kxnrl/MapMusic-API/blob/master/mapmusic.sp
			{
				DHookSetReturn(hReturn, false);

				return MRES_Supercede;
			}
		}

		if(StrEqual(input, "Enable", false) == false && 
			StrEqual(input, "Disable", false) == false && 
			StrEqual(input, "Toggle", false) == false && 
			StrEqual(input, "Break", false) == false && 
			StrEqual(input, "ForceSpawn", false) == false && 
			StrEqual(input, "TurnOn", false) == false && 
			StrEqual(input, "TurnOff", false) == false)
		{
			return MRES_Ignored;
		}

		int partner = Trikz_GetClientPartner(activator);

		if(StrEqual(input, "Enable", false) == true || StrEqual(input, "TurnOn", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = false;
				g_stateDisabled[partner][pThis] = false;
				
				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = false;

				g_linkedEntities[0][pThis]--;
			}
		}

		else if(StrEqual(input, "Disable", false) == true || StrEqual(input, "TurnOff", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = true;
				g_stateDisabled[partner][pThis] = true;

				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = true;

				g_linkedEntities[0][pThis]--;
			}
		}

		else if(StrEqual(input, "Toggle", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = !g_stateDisabled[activator][pThis];
				g_stateDisabled[partner][pThis] = !g_stateDisabled[partner][pThis];

				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = !g_stateDisabled[0][pThis];

				g_linkedEntities[0][pThis]--;
			}
		}

		else if(StrEqual(input, "Break", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = true;
				g_stateDisabled[partner][pThis] = true;

				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = true;

				g_linkedEntities[0][pThis]--;
			}

			AcceptEntityInput(pThis, "FireUser4", activator, pThis); //make fire brush with output
		}

		else if(StrEqual(input, "ForceSpawn", false) == true)
		{
			int thisIndex = 0;

			for(int i = 0; i <= g_entityTotalCount; ++i)
			{
				if(g_breakID[i] == pThis)
				{
					thisIndex = g_entityID[i];

					break;
				}

				continue;
			}

			if(thisIndex > 0)
			{
				if(g_stateDisabled[activator][thisIndex] == true && IsValidPartner(activator) == true)
				{
					g_stateDisabled[activator][thisIndex] = false;
					g_stateDisabled[partner][thisIndex] = false;
				}

				if(g_stateDisabled[0][thisIndex] == true)
				{
					g_stateDisabled[0][thisIndex] = false;
				}
			}
		}

		DHookSetReturn(hReturn, false);

		return MRES_Supercede;
	}

	return MRES_Ignored;
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	char input[16] = "";
	DHookGetParamString(hParams, 1, input, sizeof(input));

	if(StrEqual(input, "Lock", false) == false && StrEqual(input, "Unlock", false) == false)
	{
		return MRES_Ignored;
	}

	if(DHookIsNullParam(hParams, 2) == true)
	{
		return MRES_Ignored;
	}

	int activator = DHookGetParam(hParams, 2);

	if(IsValidClient(activator) == true)
	{
		int partner = Trikz_GetClientPartner(activator);

		if(StrEqual(input, "Unlock", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = false;
				g_stateDisabled[partner][pThis] = false;

				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = false;

				g_linkedEntities[0][pThis]--;
			}
		}

		else if(StrEqual(input, "Lock", false) == true)
		{
			if(g_linkedEntities[activator][pThis] > 0 && IsValidPartner(activator) == true)
			{
				g_stateDisabled[activator][pThis] = true;
				g_stateDisabled[partner][pThis] = true;

				g_linkedEntities[activator][pThis]--;
				g_linkedEntities[partner][pThis]--;
			}

			if(g_linkedEntities[0][pThis] > 0)
			{
				g_stateDisabled[0][pThis] = true;

				g_linkedEntities[0][pThis]--;
			}
		}

		DHookSetReturn(hReturn, false);

		return MRES_Supercede;
	}

	return MRES_Ignored;
}

MRESReturn AcceptInputMath(int pThis, Handle hReturn, Handle hParams)
{
	char input[16] = "";
	DHookGetParamString(hParams, 1, input, sizeof(input));

	if(StrEqual(input, "Add", false) == false && 
		StrEqual(input, "Subtract", false) == false && 
		StrEqual(input, "SetValue", false) == false && 
		StrEqual(input, "SetValueNoFire", false) == false)
	{
		return MRES_Ignored;
	}

	if(DHookIsNullParam(hParams, 2) == true)
	{
		return MRES_Ignored;
	}

	int activator = DHookGetParam(hParams, 2);

	if(IsValidClient(activator) == true)
	{
		int partner = Trikz_GetClientPartner(activator);

		char value_[16] = "";
		DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, value_, sizeof(value_));

		float value = StringToFloat(value_);

		int thisIndex = 0;

		for(int i = 0; i <= g_mathTotalCount; ++i)
		{
			if(g_mathID[i] == pThis)
			{
				thisIndex = i;

				break;
			}

			continue;
		}

		if(thisIndex == 0)
		{
			return MRES_Ignored;
		}

		if(StrEqual(input, "Add", false) == true)
		{
			if(g_mathValue[partner][thisIndex] < g_mathMax[thisIndex])
			{
				if(IsValidPartner(activator) == true)
				{
					g_mathValue[activator][thisIndex] += value;
				}

				g_mathValue[partner][thisIndex] += value;

				if(g_mathValue[partner][thisIndex] >= g_mathMax[thisIndex])
				{
					if(IsValidPartner(activator) == true)
					{
						g_mathValue[activator][thisIndex] = g_mathMax[thisIndex];
					}

					g_mathValue[partner][thisIndex] = g_mathMax[thisIndex];

					AcceptEntityInput(pThis, "FireUser3", activator, activator);
				}
			}
		}

		else if(StrEqual(input, "Subtract", false) == true)
		{
			if(g_mathValue[partner][thisIndex] > g_mathMin[thisIndex])
			{
				if(IsValidPartner(activator) == true)
				{
					g_mathValue[activator][thisIndex] -= value;
				}

				g_mathValue[partner][thisIndex] -= value;

				if(g_mathValue[partner][thisIndex] <= g_mathMin[thisIndex])
				{
					if(IsValidPartner(activator) == true)
					{
						g_mathValue[activator][thisIndex] = g_mathMin[thisIndex];
					}

					g_mathValue[partner][thisIndex] = g_mathMin[thisIndex];

					AcceptEntityInput(pThis, "FireUser4", activator, activator);
				}
			}
		}

		else if(StrEqual(input, "SetValue", true) == false || StrEqual(input, "SetValueNoFire", false) == true)
		{
			if(IsValidPartner(activator) == true)
			{
				g_mathValue[activator][thisIndex] = value;
			}

			g_mathValue[partner][thisIndex] = value;

			if(g_mathValue[partner][thisIndex] < g_mathMin[thisIndex])
			{
				if(IsValidPartner(activator) == true)
				{
					g_mathValue[activator][thisIndex] = g_mathMin[thisIndex];
				}

				g_mathValue[partner][thisIndex] = g_mathMin[thisIndex];
			}

			else if(g_mathValue[partner][thisIndex] > g_mathMax[thisIndex])
			{
				if(IsValidPartner(activator) == true)
				{
					g_mathValue[activator][thisIndex] = g_mathMax[thisIndex];
				}

				g_mathValue[partner][thisIndex] = g_mathMax[thisIndex];
			}
		}

		DHookSetReturn(hReturn, false);

		return MRES_Supercede;
	}

	return MRES_Ignored;
}

Action TouchTrigger(int entity, int other)
{
	char classname[32] = "";
	GetEntityClassname(other, classname, sizeof(classname));
	
	int activator = other;

	if(StrContains(classname, "projectile", false) != -1)
	{
		activator = GetEntPropEnt(other, Prop_Data, "m_hOwnerEntity", 0);
	}
	
	if(IsValidClient(activator) == true)
	{
		int partner = Trikz_GetClientPartner(activator);

		if(g_stateDisabled[partner][entity] == true)
		{
			if(g_touchArtifacial[activator][entity][1] == true)
			{
				AcceptEntityInput(entity, "EndTouch", other, other);
			}

			return Plugin_Handled;
		}

		else if(g_stateDisabled[partner][entity] == false)
		{
			if(g_touchArtifacial[activator][entity][1] == false)
			{
				if(StrContains(classname, "projectile", false) == -1)
				{
					g_touchArtifacial[activator][entity][0] = true;
				}

				AcceptEntityInput(entity, "StartTouch", other, other);
			}
		}

		/*if(g_touchArtifacial[activator][entity][1] == true || (g_touchArtifacial[activator][entity][1] == true && StrContains(classname, "projectile", false) == -1 && g_stateDisabled[partner][entity] == true))
		{
			AcceptEntityInput(entity, "EndTouch", other, other);
		}
		
		else if(g_touchArtifacial[activator][entity][1] == false || (g_touchArtifacial[activator][entity][1] == false && StrContains(classname, "projectile", false) == -1 && g_stateDisabled[partner][entity] == false))
		{
			if(StrContains(classname, "projectile", false) == -1)
			{
				g_touchArtifacial[activator][entity][0] = true;
			}

			AcceptEntityInput(entity, "StartTouch", other, other);
		}

		if(g_stateDisabled[partner][entity] == true)
		{
			return Plugin_Handled;
		}*/

		g_touchArtifacial[activator][entity][1] = g_stateDisabled[partner][entity] == true ? false : true;
	}

	return Plugin_Continue;
}

Action EntityVisibleTransmit(int entity, int client)
{
	if(IsValidClient(client) == true)
	{
		if(IsPlayerAlive(client) == true)
		{
			int partner = Trikz_GetClientPartner(client);

			if(g_stateDisabled[partner][entity] == true)
			{
				return Plugin_Handled;
			}
		}

		else if(IsPlayerAlive(client) == false)
		{
			int target = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget", 0);

			if(IsValidClient(target) == true)
			{
				int partner = Trikz_GetClientPartner(target);

				if(g_stateDisabled[partner][entity] == true)
				{
					return Plugin_Handled;
				}
			}
		}
	}

	return Plugin_Continue;
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	int partner = Trikz_GetClientPartner(activator);

	if(g_buttonReady[partner][entity] > GetGameTime() || g_stateDisabled[partner][entity] == true)
	{
		return Plugin_Handled;
	}

	if(IsValidPartner(activator) == true)
	{
		g_buttonReady[activator][entity] = GetGameTime() + g_buttonDefaultDelay[entity];
	}

	g_buttonReady[partner][entity] = GetGameTime() + g_buttonDefaultDelay[entity];

	return Plugin_Continue;
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker, 0);

	return Plugin_Continue;
}

Action EntityOutputHook(char[] output, int caller, int activator, float delay)
{
	if(activator > MaxClients)
	{
		char classname[32] = "";
		GetEntityClassname(activator, classname, sizeof(classname));

		if(StrContains(classname, "projectile", false) != -1)
		{
			activator = GetEntPropEnt(activator, Prop_Data, "m_hOwnerEntity");

			if(activator < 0)
			{
				activator = 0;
			}
		}
	}

	if(IsValidClient(activator) == true)
	{
		int outputNum = -1, linkedEntity = 0, linkedMathEntity = 0, partner = Trikz_GetClientPartner(activator);

		if(caller > 0)
		{
			outputNum = GetOutput(output);

			for(int i = 0; i <= g_maxLinks[caller][outputNum]; ++i)
			{
				linkedEntity = g_linkedEntitiesDefault[caller][i][outputNum];

				if(IsValidPartner(activator) == true)
				{
					g_linkedEntities[activator][linkedEntity] += g_entityOutput[linkedEntity][i][outputNum];
				}

				g_linkedEntities[partner][linkedEntity] += g_entityOutput[linkedEntity][i][outputNum];

				continue;
			}

			if(StrContains(output, "OnStartTouch", false) != -1)
			{
				if(g_touchArtifacial[activator][caller][0] == true)
				{
					g_touchArtifacial[activator][caller][0] = false;

					return Plugin_Continue;
				}

				if(g_stateDisabled[partner][caller] == true)
				{
					return Plugin_Handled;
				}

				if(g_touchArtifacial[activator][caller][0] == false && g_stateDisabled[partner][caller] == false)
				{
					g_touchArtifacial[activator][caller][1] = true;
				}
			}

			else if(StrContains(output, "OnEndTouch", false) != -1)
			{
				if(g_stateDisabled[partner][caller] == true && g_touchArtifacial[activator][caller][1] == false)
				{
					return Plugin_Handled;
				}

				if(g_touchArtifacial[activator][caller][1] == true)
				{
					g_touchArtifacial[activator][caller][1] = false;
				}
			}
		}

		else if(caller < 0)
		{
			char outputChanged[24] = "";

			if(StrEqual(output, "OnUser3", false) == true)
			{
				Format(outputChanged, sizeof(outputChanged), "OnHitMax");
			}

			else if(StrEqual(output, "OnUser4", false) == true)
			{
				Format(outputChanged, sizeof(outputChanged), "OnHitMin");
			}

			outputNum = GetOutput(outputChanged);

			for(int i = 0; i <= g_mathTotalCount; ++i)
			{
				if(g_mathID[i] == caller)
				{
					int math = i;

					for(int j = 0; j <= g_maxMathLinks[math][outputNum]; ++j)
					{
						linkedMathEntity = g_linkedMathEntitiesDefault[math][j][outputNum];

						if(IsValidPartner(activator) == true)
						{
							g_linkedEntities[activator][linkedMathEntity] += g_entityOutput[linkedMathEntity][j][outputNum];
						}

						g_linkedEntities[partner][linkedMathEntity] += g_entityOutput[linkedMathEntity][j][outputNum];

						continue;
					}

					break;
				}

				continue;
			}
		}
	}

	return Plugin_Continue;
}

MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) == true || DHookIsNullParam(hParams, 2) == true || Trikz_GetDevmap() == true)
	{
		return MRES_Ignored;
	}

	int ent1 = DHookGetParam(hParams, 1); //touch reciever
	int ent2 = DHookGetParam(hParams, 2); //touch sender

	Action result = Plugin_Continue;

	Call_StartForward(g_PassServerEntityFilter);
	Call_PushCell(ent1);
	Call_PushCell(ent2);
	Call_Finish(result);

	if(result > Plugin_Continue)
	{
		DHookSetReturn(hReturn, false);

		return MRES_Supercede;
	}

	int partner = 0;

	if(IsValidClient(ent2) == true)
	{
		partner = Trikz_GetClientPartner(ent2);

		if(g_stateDisabled[partner][ent1] == false)
		{
			return MRES_Ignored;
		}
	}

	char classname[32] = "";
	GetEntityClassname(ent2, classname, sizeof(classname));

	if(StrContains(classname, "projectile", false) != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity", 0);

		if(IsValidClient(ent2owner) == true)
		{
			partner = Trikz_GetClientPartner(ent2owner);

			if(g_stateDisabled[partner][ent1] == false)
			{
				return MRES_Ignored;
			}
		}
	}

	DHookSetReturn(hReturn, false);

	return MRES_Supercede;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(Trikz_GetDevmap() == true)
	{
		return;
	}

	if(StrContains(classname, "projectile", false) != -1)
	{
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade);
	}

	else if(StrEqual(classname, "ambient_generic", false) == true)
	{
		DHookEntity(g_AcceptInput, false, entity);
	}

	return;
}

int GetOutput(const char[] output)
{
	if(StrEqual(output, "OnStartTouch", false) == true)
	{
		return 0;
	}

	else if(StrEqual(output, "OnEndTouchAll", false) == true)
	{
		return 1;
	}

	else if(StrEqual(output, "OnEndTouch", false) == true)
	{
		return 2;
	}

	else if(StrEqual(output, "OnTrigger", false) == true)
	{
		return 3;
	}

	else if(StrEqual(output, "OnStartTouchAll", false) == true)
	{
		return 4;
	}

	else if(StrEqual(output, "OnPressed", false) == true)
	{
		return 5;
	}

	else if(StrEqual(output, "OnDamaged", false) == true)
	{
		return 6;
	}

	else if(StrEqual(output, "OnHitMin", false) == true)
	{
		return 7;
	}

	else if(StrEqual(output, "OnHitMax", false) == true)
	{
		return 8;
	}

	else
	{
		return 9;
	}
}

Action TransmitPlayer(int entity, int client) //entity - me, client - loop all clients
{
	//make visible only partner
	if(client != entity && IsValidClient(entity) == true && IsPlayerAlive(client) == true)
	{
		if(Trikz_GetClientPartner(entity) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

Action TransmitNade(int entity, int client) //entity - nade, client - loop all clients
{
	//make visible nade only for partner
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

	if(owner < 0)
	{
		owner = 0;
	}

	if(IsPlayerAlive(client) == true && entity > MaxClients && owner != client && Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action Trikz_CheckSolidity(int ent1, int ent2)
{
	char classname[32] = "";
	GetEntityClassname(ent2 > MaxClients ? ent2 : ent1, classname, sizeof(classname));

	if(StrContains(classname, "projectile", false) != -1)
	{
		if(IsValidClient(ent1) == true || IsValidClient(ent2) == true)
		{
			int owner = GetEntPropEnt(ent2 > MaxClients ? ent2 : ent1, Prop_Data, "m_hOwnerEntity", 0);

			if(owner < 0)
			{
				owner = 0;
			}

			if(Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1 <= MaxClients ? ent1 : ent2))))
			{
				return Plugin_Handled;
			}
		}
	}

	if(IsValidClient(ent1) == true && IsValidClient(ent2) == true)
	{
		//make no collide with all players.
		if(GetEntProp(ent2, Prop_Data, "m_CollisionGroup", 4, 0) == 2 || GetEntProp(ent1, Prop_Data, "m_CollisionGroup", 4, 0) == 2)
		{
			return Plugin_Handled;
		}

		//colide for partner
		if(Trikz_GetClientPartner(ent2) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1))))
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

int Native_GetEntityFilter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int entity = GetNativeCell(2);

	int partner = Trikz_GetClientPartner(client);

	return g_stateDisabled[partner][entity];
}

/*EntityLumpEntry FindEntityLumpEntry(int entity)
{
	int hammerid = GetEntProp(entity, Prop_Data, "m_iHammerID", 4, 0); //https://forums.alliedmods.net/showpost.php?p=1643574&postcount=2

	char value[64] = "";
	char exploded[3][16];
	float origin[3] = {0.0, ...};
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin, 0);

	if(hammerid == 0) //Is fully old map?
	{
		char classname[32] = "";
		GetEntityClassname(entity, classname, sizeof(classname));
		PrintToServer("[%s] hammerid: 0; origin: %f %f %f", classname, origin[0], origin[1], origin[2]);
	}

	for(int i = 0; i < EntityLump.Length(); i++) //Closed, unitll entitylump got fully post to approve stripper changes
	{
		EntityLumpEntry entry = EntityLump.Get(i);

		//if(entry.GetNextKey("hammerid", value, sizeof(value)) != -1 && StringToInt(value) == hammerid)
		if(entry.GetNextKey("origin", value, sizeof(value)) != -1)
		{
			ExplodeString(value, " ", exploded, 3, 16, false);

			if(origin[0] == StringToFloat(exploded[0]) && origin[1] == StringToFloat(exploded[1]) && origin[2] == StringToFloat(exploded[2]))
			{
				return entry;
			}
		}

		delete entry;
	}

	return null;
}

any GetOutputAction(int entity, const char[] output = "", int count, char[] result, int maxlength, int type)
{
	EntityLumpEntry entry = FindEntityLumpEntry(entity);

	if(entry == INVALID_HANDLE)
	{
		return INVALID_HANDLE;
	}

	char key[64] = "", value[512] = "", exploded[5][256];
	int countLocal = 0;

	for(int i = 0; i < entry.Length; i++)
	{
		entry.Get(i, key, sizeof(key), value, sizeof(value));

		//if(StrContains(value, "math_counter", true) != -1)
		//{
		//	PrintToServer("%s %s", key, value);
		//}

		if(FindCharInString(key, 'O', false) != -1)
		{
			if(strlen(output) > 0 ? StrEqual(key, output, true) == true : StrContains(key, "On", true) != -1)
			{
				if(type == 0)
				{
					countLocal++;
				}

				else if(type > 0)
				{
					if(++countLocal == count)
					{
						//if(StrContains(value, "relay", true) != -1)
						//{
						//	PrintToServer("%s", value);
						//}

						ExplodeString(value, ",", exploded, 5, 256, false);

						switch(type)
						{
							case 1, 2, 3:
							{
								Format(result, maxlength, "%s", exploded[type - 1]);

								return true;
							}

							case 4:
							{
								return StringToFloat(exploded[3]);
							}

							case 5:
							{
								return StringToInt(exploded[4], 10);
							}
						}
					}
				}
			}
		}

		//break; //loop doesn't work here
	}

	delete entry;

	return countLocal;
}

int GetOutputCount(int entity, const char[] output = "")
{
    return GetOutputAction(entity, output, 0, "", 0, 0);
}

int GetOutputTarget(int entity, const char[] output = "", int count, char[] target, int maxlength)
{
    return GetOutputAction(entity, output, count, target, maxlength, 1);
}

int GetOutputTargetInput(int entity, const char[] output = "", int count, char[] input, int maxlength)
{
    return GetOutputAction(entity, output, count, input, maxlength, 2);
}

int GetOutputParameter(int entity, const char[] output = "", int count, char[] parameter, int maxlength)
{
    return GetOutputAction(entity, output, count, parameter, maxlength, 3);
}

float GetOutputDelay(int entity, const char[] output = "", int count)
{
    return GetOutputAction(entity, output, count, "", 0, 4);
}

int GetOutputTimesToFire(int entity, const char[] output = "", int count)
{
    return GetOutputAction(entity, output, count, "", 0, 5);
}*/
