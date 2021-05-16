#include <sdkhooks>
#include <sdktools>
#include <morecolors>
#include <trikz>

#pragma semicolon 1
#pragma newdecls required

int gB_MLS[MAXPLAYERS + 1];
int gI_xCount[MAXPLAYERS + 1];
bool gB_groundBoost[MAXPLAYERS + 1];
bool gB_bouncedOff[2048];

float gF_posStart[MAXPLAYERS + 1][3];
float gF_posFinish[MAXPLAYERS + 1][3];
int gI_thrower;
float gF_speedMax[MAXPLAYERS + 1];
bool gB_IsPlayerInAir[MAXPLAYERS + 1];
int gI_SpectatorTarget[MAXPLAYERS + 1];

float gF_speedPre[MAXPLAYERS + 1][1000];
float gF_speedPost[MAXPLAYERS + 1][1000];
char gS_cacheHUD[MAXPLAYERS + 1][255];
char gS_cacheHUD2[MAXPLAYERS + 1][255];
float gF_distance;
char gS_statusHUD[MAXPLAYERS + 1][64];
float gF_speed[MAXPLAYERS + 1];
char gS_status[64];
char gS_cacheFinalHUD[MAXPLAYERS + 1][255];
int gI_tick;

enum PlayerState
{
	ILLEGAL_JUMP_FLAGS:IllegalJumpFlags
}

enum ILLEGAL_JUMP_FLAGS
{
	IJF_NONE = 0,
	IJF_WORLD,
	IJF_BOOSTER,
	IJF_GRAVITY,
	IJF_TELEPORT,
	IJF_LAGGEDMOVEMENTVALUE,
	IJF_PRESTRAFE,
	IJF_SCOUT,
	IJF_NOCLIP
}

int gI_PlayerStates[MAXPLAYERS + 1][PlayerState];

// forwards
Handle gH_Forwards_boostSpeed = null;

int g_boostStep[MAXPLAYERS + 1];
int g_boostEnt[MAXPLAYERS + 1];
float g_boostVel[MAXPLAYERS + 1][3];
float g_boostTime[MAXPLAYERS + 1];
float g_playerVel[MAXPLAYERS + 1][3];
int g_playerFlags[MAXPLAYERS + 1];
bool g_groundBoost[MAXPLAYERS + 1];
bool g_bouncedOff[2048];

public Plugin myinfo =
{
	name = "Mega long stats",
	author = "Smesh, extrem, Skipper (Gurman)",
	description = "You can see the boost counts, speed, distance.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 &&
			client <= MaxClients &&
			IsClientConnected(client) &&
			IsClientInGame(client) &&
			!IsClientSourceTV(client) &&
			(!bAlive || IsPlayerAlive(client)));
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetClientStateMLS", Native_GetClientStateMLS);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_mls", Command_MLS);
	RegConsoleCmd("sm_mlsoff", Command_MLSOFF);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	HookEvent("player_jump", Event_PlayerJump);
	HookEntityOutput("trigger_teleport", "OnStartTouch", Event_OnStartTriggerTp);
	HookEntityOutput("trigger_push", "OnStartTouch", Event_OnStartTriggerPush);
	gF_distance = -1.0;
	//forwards
	gH_Forwards_boostSpeed = CreateGlobalForward("Trikz_OnBoost", ET_Event, Param_Cell, Param_Cell);
}

public void OnClientPutInServer(int client)
{
	gB_MLS[client] = 0;
	gI_SpectatorTarget[client] = -1;
	SDKHook(client, SDKHook_StartTouch, Client_StartTouchWorld);
	SDKHook(client, SDKHook_PostThinkPost, Client_PostThinkPost);
}

public void OnClientDisconnect(int client)
{
	g_boostStep[client] = 0;
	g_boostTime[client] = 0.0;
	g_playerFlags[client] = 0;
}

Action Command_MLS(int client, int args)
{
	if(gB_MLS[client] == 0)
	{
		CPrintToChat(client, "{white}ML stats is on. Mode: Chat.");
		gB_MLS[client] = 1;
	}

	else if(gB_MLS[client] == 1)
	{
		CPrintToChat(client, "{white}ML stats is on. Mode: Hud.");
		gB_MLS[client] = 2;
		CreateTimer(6.0, Timer_UpdateHud, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		UpdateHud(client);
	}

	else if(gB_MLS[client] == 2)
	{ 
		CPrintToChat(client, "{white}ML stats is on. Mode: Both.");
		gB_MLS[client] = 3;
	}

	else if(gB_MLS[client] == 3)
	{
		CPrintToChat(client, "{white}ML stats is off.");
		gB_MLS[client] = 0;
	}

	return Plugin_Handled;
}

Action Command_MLSOFF(int client, int args)
{
	gB_MLS[client] = 0;
	CPrintToChat(client, "{white}ML stats is off.");
	
	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "_projectile") != -1)
	{
		SDKHook(entity, SDKHook_StartTouch, Projectile_StartTouch);
		SDKHook(entity, SDKHook_EndTouch, Projectile_EndTouch);
		gB_bouncedOff[entity] = false;
		SDKHook(entity, SDKHook_StartTouch, Projectile_StartTouch2);
		SDKHook(entity, SDKHook_EndTouch, Projectile_EndTouch2);
		g_bouncedOff[entity] = false;
	}
}

Action Projectile_StartTouch(int entity, int client)
{
	if(!IsValidClient(client, true) || !IsValidEntity(entity))
	{
		return Plugin_Continue;
	}
	
	float entityOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityOrigin);

	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);

	float entityMaxs[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", entityMaxs);

	float delta = clientOrigin[2] - entityOrigin[2] - entityMaxs[2];
	
	if(!(0.0 < delta < 2.0))
	{
		return Plugin_Continue;
	}
	
	gB_groundBoost[client] = !gB_bouncedOff[entity];
	
	if(!gB_groundBoost[client])
	{
		return Plugin_Continue;
	}
	
	gI_xCount[client]++;
	
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	
	//Thanks to https://github.com/Nickelony/Velocities/blob/5a8915c81e2806797adc26a5f742edb52af20605/scripting/velocities.sp#L162
	gF_speedPre[client][gI_xCount[client]] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	
	if(IsValidEntity(entity))
	{
		gI_thrower = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	}
	
	return Plugin_Continue;
}

Action Projectile_EndTouch(int entity, int other)
{
	if(other)
	{
		gB_bouncedOff[entity] = true;
	}
}

public void Trikz_OnBoost(int client, float velxy)
{
	if(!IsValidClient(client) || !IsValidClient(gI_thrower))
	{
		return;
	}
	
	gF_speedPost[client][gI_xCount[client]] = velxy;
	
	GetHUDTarget(client);
	
	if(gB_MLS[client] == 1 || gB_MLS[client] == 3)
	{
		CPrintToChat(client, "{dimgray}[{white}MLS{dimgray}] {white}{orange}X%d {dimgray}| {orange}%.1f {white}- {orange}%.1f {white}u/s", gI_xCount[client], gF_speedPre[client][gI_xCount[client]], gF_speedPost[client][gI_xCount[client]]);
	}
	
	if(gB_MLS[gI_thrower] == 1 || gB_MLS[gI_thrower] == 3)
	{
		CPrintToChat(gI_thrower, "{dimgray}[{white}MLS{dimgray}] {white}{orange}X%d {dimgray}| {orange}%.1f {white}- {orange}%.1f {white}u/s", gI_xCount[client], gF_speedPre[client][gI_xCount[client]], gF_speedPost[client][gI_xCount[client]]);
	}
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && (gB_MLS[i] == 1 || gB_MLS[i] == 3))
		{
			if(gI_SpectatorTarget[i] == client || gI_SpectatorTarget[i] == gI_thrower)
			{
				CPrintToChat(i, "{dimgray}[{white}MLS{dimgray}] {white}{orange}X%d {dimgray}| {orange}%.1f {white}- {orange}%.1f {white}u/s", gI_xCount[client], gF_speedPre[client][gI_xCount[client]], gF_speedPost[client][gI_xCount[client]]);
			}
		}
	}
	
	UpdateHud(client);
	UpdateHud(gI_thrower);
}

void UpdateHud(int client)
{
	char sTextX[128];
	char sText[255];
	char sTextStart[32];
	char sTextEnd[64];
	
	for(int i = 1; i <= gI_xCount[client]; i++)
	{
		Format(sTextX, sizeof(sTextX), "X%i | %.1f - %.1f\n", i, gF_speedPre[client][i], gF_speedPost[client][i]);
		Format(sText, sizeof(sText), "%s%s", sText, sTextX);
	}
	
	Format(sTextStart, sizeof(sTextStart), "ML-Stats\n\n");
	
	if(0 < gI_xCount[client] < 11)
	{
		gS_cacheHUD[client] = sText;
		Format(sText, sizeof(sText), "%s%s", sTextStart, gS_cacheHUD[client]);
		gS_cacheHUD2[client] = sText;
		gS_cacheHUD2[gI_thrower] = sText;
		gS_cacheFinalHUD[client] = sText;
		gS_cacheFinalHUD[gI_thrower] = sText;
	}
	
	if(gI_xCount[client] > 10)
	{
		Format(sText, sizeof(sText), "%s%s...\nX%i | %.1f - %.1f\n", sTextStart, gS_cacheHUD[client], gI_xCount[client], gF_speedPre[client][gI_xCount[client]], gF_speedPost[client][gI_xCount[client]]);
		gS_cacheHUD2[client] = sText;
		gS_cacheHUD2[gI_thrower] = sText;
		gS_cacheFinalHUD[client] = sText;
		gS_cacheFinalHUD[gI_thrower] = sText;
	}
	
	if(gI_xCount[client] == 0 && gI_tick == 1)
	{
		gS_statusHUD[gI_thrower] = gS_statusHUD[client];
		gF_speedMax[gI_thrower] = gF_speedMax[client];
		Format(sTextEnd, sizeof(sTextEnd), "\nDistance: %.1f units %s\nMax: %.1f u/s", gF_distance, gS_statusHUD[client], gF_speedMax[client]);
		
		if(gF_distance == -1.0)
		{
			Format(sText, sizeof(sText), "%s", gS_cacheHUD2[client]);
		}
		
		else
		{
			Format(sText, sizeof(sText), "%s%s", gS_cacheHUD2[client], sTextEnd);
		}
		
		gS_cacheFinalHUD[client] = sText;
		gS_cacheFinalHUD[gI_thrower] = sText;
	}
	
	if(IsValidClient(client) && strlen(gS_cacheFinalHUD[client]) > 0 && gB_MLS[client] > 1)
	{
		Handle hKeyHintText = StartMessageOne("KeyHintText", client);
		BfWriteByte(hKeyHintText, 1);
		BfWriteString(hKeyHintText, gS_cacheFinalHUD[client]);
		EndMessage();
	}
	
	if(IsValidClient(gI_thrower) && strlen(gS_cacheFinalHUD[gI_thrower]) > 0&& gB_MLS[gI_thrower] > 1)
	{
		Handle hKeyHintText = StartMessageOne("KeyHintText", gI_thrower);
		BfWriteByte(hKeyHintText, 1);
		BfWriteString(hKeyHintText, gS_cacheFinalHUD[gI_thrower]);
		EndMessage();
	}
	
	GetHUDTarget(client);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && gB_MLS[i] > 1)
		{
			if(gI_SpectatorTarget[i] == client)
			{
				gS_cacheFinalHUD[i] = gS_cacheFinalHUD[client];
				
				Handle hKeyHintText = StartMessageOne("KeyHintText", i);
				BfWriteByte(hKeyHintText, 1); 
	 			BfWriteString(hKeyHintText, gS_cacheFinalHUD[client]);
				EndMessage();
			}
		}
	}
}
 
Action Timer_UpdateHud(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		UpdateHud(client);
	}
}

Action Event_PlayerJump(Handle event, const char[] name, bool dB)
{	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAbsOrigin(client, gF_posStart[client]);
}

Action Event_OnStartTriggerTp(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator))
	{
		if(!(GetEntityFlags(activator) & FL_ONGROUND) && gI_xCount[activator] > 0)
		{
			gI_PlayerStates[activator][IllegalJumpFlags] = IJF_TELEPORT;
			GetClientAbsOrigin(activator, gF_posFinish[activator]);
			gS_status = "{dimgray}({white}TP{dimgray})";
			gS_statusHUD[activator]= "(TP)";
		}
	}
}

Action Event_OnStartTriggerPush(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator))
	{
		if(!(GetEntityFlags(activator) & FL_ONGROUND) && gI_xCount[activator] > 0)
		{
			gI_PlayerStates[activator][IllegalJumpFlags] = IJF_BOOSTER;
			gS_status = "{dimgray}({white}PUSH{dimgray})";
			gS_statusHUD[activator]= "(PUSH)";
		}
	}
}

Action Client_StartTouchWorld(int client, int other) 
{
	if(!(GetEntityFlags(client) & FL_ONGROUND) && gI_xCount[client] > 0 && other == 0)
	{		
		gI_PlayerStates[client][IllegalJumpFlags] = IJF_WORLD;
		gS_status = "{dimgray}({white}HIT WALL/SURF{dimgray})";
		gS_statusHUD[client]= "(HIT WALL/SURF)";
	}
}

void CheckIfHitInFeet(int client)
{	
	float velocity[3];

	if(g_boostStep[client])
	{
		if(g_boostStep[client] == 2)
		{
			velocity[0] = g_playerVel[client][0] - g_boostVel[client][0];
			velocity[1] = g_playerVel[client][1] - g_boostVel[client][1];
			velocity[2] = g_boostVel[client][2];
			
			g_boostStep[client] = 3;
		}
		
		else if(g_boostStep[client] == 3)
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
			
			if(g_groundBoost[client])
			{
				velocity[0] += g_boostVel[client][0];
				velocity[1] += g_boostVel[client][1];
				velocity[2] += g_boostVel[client][2];
			}
			
			else
			{
				velocity[0] += g_boostVel[client][0] * 0.135;
				velocity[1] += g_boostVel[client][1] * 0.135;
			}

			g_boostStep[client] = 0;
			
			Call_StartForward(gH_Forwards_boostSpeed);
			Call_PushCell(client);
			Call_PushCell(SquareRoot(Pow(velocity[0], 2.0) + Pow(velocity[1], 2.0)));
			Call_Finish();
		}
	}
}

Action Projectile_StartTouch2(int entity, int client)
{
	if(!IsValidClient(client, true))
	{
		return Plugin_Continue;
	}
	
	if(g_boostStep[client] || g_playerFlags[client] & FL_ONGROUND)
	{
		return Plugin_Continue;
	}
	
	float entityOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityOrigin);

	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);

	float entityMaxs[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", entityMaxs);

	float delta = clientOrigin[2] - entityOrigin[2] - entityMaxs[2];
	
	if(delta > 0.0 && delta < 2.0)
	{
		g_boostStep[client] = 1;
		g_boostEnt[client] = EntIndexToEntRef(entity);
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", g_boostVel[client]);
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", g_playerVel[client]);
		g_groundBoost[client] = g_bouncedOff[entity];
		g_boostTime[client] = GetGameTime();
	}
 
	return Plugin_Continue;
}
 
Action Projectile_EndTouch2(int entity, int other)
{
	if(!other)
	{
		g_bouncedOff[entity] = true;
	}
}

void Client_PostThinkPost(int client)
{
	if(g_boostStep[client] == 1)
	{
		int entity = EntRefToEntIndex(g_boostEnt[client]);

		if(entity != INVALID_ENT_REFERENCE)
		{
			float velocity[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", velocity);

			if(velocity[2] > 0.0)
			{
				velocity[0] = g_boostVel[client][0] * 0.135;
				velocity[1] = g_boostVel[client][1] * 0.135;
				velocity[2] = g_boostVel[client][2] * -0.135;
			}
		}

		g_boostStep[client] = 2;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) 
{
	CheckIfHitInFeet(client);
	
	if(!IsPlayerAlive(client))
	{		
		return Plugin_Continue;
	}
	
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	
	gF_speed[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	
	//Player max speed
	if(gF_speed[client] > gF_speedMax[client])
	{
		gF_speedMax[client] = gF_speed[client];
	}
	
	if(GetEntityFlags(client) & FL_ONGROUND && gI_xCount[client] == 0)
	{
		gF_speedMax[client] = 0.0;
		gI_xCount[client] = 0; //Thanks to extrem
		gB_IsPlayerInAir[client] = false;
		gI_PlayerStates[client][IllegalJumpFlags] = IJF_NONE;
	}
	
	if(!(GetEntityFlags(client) & FL_ONGROUND) && gI_xCount[client] > 0)
	{		
		gB_IsPlayerInAir[client] = true;
	}
	
	int iGroundEntity = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	
	GetHUDTarget(client);
	
	if(!IsValidEdict(iGroundEntity))
	{
		return Plugin_Continue;
	}
	
	char sClass[64];
	GetEdictClassname(iGroundEntity, sClass, 64);
	
	//If ground entity is not grenade and boost is not 0
	if(!(StrContains(sClass, "_projectile", false) == -1)) //Thanks to Log
	{
		return Plugin_Continue;
	}
	
	if(!(GetEntityFlags(client) & FL_ONGROUND && gI_xCount[client] > 0)) //Thanks to extrem
	{
		return Plugin_Continue;
	}
	
	if(gI_PlayerStates[client][IllegalJumpFlags] != IJF_TELEPORT)
	{
		GetClientAbsOrigin(client, gF_posFinish[client]);
	}
	
	gF_distance = CalculateJumpDistance(client, gF_posStart[client], gF_posFinish[client]);
	
	if(!gB_IsPlayerInAir[client])
	{	
		return Plugin_Continue;
	}
	
	float fGravity = GetEntPropFloat(client, Prop_Data, "m_flGravity");
	
	if(fGravity != 1.0 && fGravity != 0.0)
	{
		gI_PlayerStates[client][IllegalJumpFlags] = IJF_GRAVITY;
	}
	
	if(gI_PlayerStates[client][IllegalJumpFlags] == IJF_GRAVITY)
	{
		gS_status = "{dimgray}({white}GRAV{dimgray})";
		gS_statusHUD[client]= "(GRAV)";
	}
	
	if(gI_PlayerStates[client][IllegalJumpFlags] == IJF_NONE)
	{
		gS_status = "";
		gS_statusHUD[client]= "";
	}
	
	if(gB_MLS[client] == 1 || gB_MLS[client] == 3)
	{
		CPrintToChat(client, "{dimgray}[{white}MLS{dimgray}] {white}Counted: {orange}X%i {dimgray}| {white}Distance: {orange}%.1f {dimgray}| {white}Max: {orange}%.1f {white}u/s\n%s", gI_xCount[client], gF_distance, gF_speedMax[client], gS_status);
	}
	
	if((gB_MLS[gI_thrower] == 1 || gB_MLS[gI_thrower] == 3) && IsValidClient(gI_thrower) && !IsClientObserver(gI_thrower))
	{
		CPrintToChat(gI_thrower, "{dimgray}[{white}MLS{dimgray}] {white}Counted: {orange}X%i {dimgray}| {white}Distance: {orange}%.1f {dimgray}| {white}Max: {orange}%.1f {white}u/s\n%s", gI_xCount[client], gF_distance, gF_speedMax[client], gS_status);
	}
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && (gB_MLS[i] == 1 || gB_MLS[i] == 3))
		{
			if(gI_SpectatorTarget[i] == client || gI_SpectatorTarget[i] == gI_thrower)
			{
				CPrintToChat(i, "{dimgray}[{white}MLS{dimgray}] {white}Counted: {orange}X%i {dimgray}| {white}Distance: {orange}%.1f {dimgray}| {white}Max: {orange}%.1f {white}u/s\n%s", gI_xCount[client], gF_distance, gF_speedMax[client], gS_status);
			}
		}
	}
	
	gI_xCount[client] = 0; //Thanks to extrem
	gB_IsPlayerInAir[client] = false;
	gI_PlayerStates[client][IllegalJumpFlags] = IJF_NONE;
	
	if(gI_tick == 0)
	{
		gI_tick++;
	}
	
	UpdateHud(client);
	UpdateHud(gI_thrower);
	
	gF_speedMax[client] = 0.0;
	gI_tick = 0;
	
	return Plugin_Continue;
}

//Thanks to Skipper
float CalculateJumpDistance(any ..., float posStart[3], float posEnd[3])
{
	float X = posEnd[0] - posStart[0];
	float Y = posEnd[1] - posStart[1];
	
	return SquareRoot(Pow(X, 2.0) + Pow(Y, 2.0)) + 32.0;
}

//Thanks to https://forums.alliedmods.net/showthread.php?t=229785
void GetHUDTarget(int client)
{
	//Manage spectators
	if(!IsClientObserver(client) && gB_MLS[client] < 2)
	{
		return;
	}
	
	int iObserverMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	
	if(3 < iObserverMode < 7)
	{
		int iTarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(gI_SpectatorTarget[client] != iTarget)
		{
			gI_SpectatorTarget[client] = iTarget;
		}
	}
	
	else
	{
		if(gI_SpectatorTarget[client] != -1)
		{
			gI_SpectatorTarget[client] = -1;
		}
	}
}

int Native_GetClientStateMLS(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
	
    return gB_MLS[client];
}
