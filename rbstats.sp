#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <morecolors>
#include <msharedutil/ents>

#pragma semicolon 1
#pragma newdecls required

#define MIN_RB_TICKS 700
#define MIN_DISTANCE 500

#define MAX_RB_TICKS 1000
#define MAX_DISTANCE 610

#define MAX_STRAFES 50

bool g_bRbStats[MAXPLAYERS + 1];
bool g_bRbHasBeen[MAXPLAYERS + 1];
bool g_bJumpAfterRb[MAXPLAYERS + 1];

float g_flStartPos[MAXPLAYERS + 1][3];
float g_flFinishPos[MAXPLAYERS + 1][3];
float g_flOtherPos[MAXPLAYERS + 1][3];
int g_iOther[MAXPLAYERS + 1];
float flPreSpeedB[MAXPLAYERS + 1];
float flPreSpeedF[MAXPLAYERS + 1];
float flPreSpeedFReal[MAXPLAYERS + 1];

float g_iStartJumpTick[MAXPLAYERS + 1];

char sStatus[MAXPLAYERS +1][128];

int g_iStrafeCount[MAXPLAYERS + 1];
strafeDir dirThisStrafe[MAXPLAYERS + 1];
strafeDir dirPrevStrafe[MAXPLAYERS + 1];
int g_iStrafeTicks[MAXPLAYERS + 1][MAX_STRAFES];
int g_iGoodSyncTicks[MAXPLAYERS + 1][MAX_STRAFES];
int g_iBadSyncTicks[MAXPLAYERS + 1][MAX_STRAFES];
float g_flGain[MAXPLAYERS + 1][MAX_STRAFES];
float g_flLoss[MAXPLAYERS + 1][MAX_STRAFES];
int g_nSpectatorTarget[MAXPLAYERS + 1];

enum PlayerState
{
	ILLEGAL_JUMP_FLAGS:IllegalJumpFlags,
	STRAFE_DIRECTION:CurStrafeDir,
	nStrafes,
	STRAFE_DIRECTION:StrafeDir[MAX_STRAFES],
	vLastAngles[3],
	vLastVelocity[3],
	nStrafeTicks[MAX_STRAFES]
}

enum ILLEGAL_JUMP_FLAGS
{
	IJF_NONE = 0,
	IJF_WORLD = 1 << 0,
	IJF_BOOSTER = 1 << 1,
	IJF_GRAVITY = 1 << 2,
	IJF_TELEPORT = 1 << 3,
	IJF_LAGGEDMOVEMENTVALUE = 1 << 4,
	IJF_PRESTRAFE = 1 << 5,
	IJF_SCOUT = 1 << 6,
	IJF_NOCLIP = 1 << 7
}

enum STRAFE_DIRECTION
{
	SD_NONE,
	SD_W,
	SD_D,
	SD_A,
	SD_S,
	SD_WA,
	SD_WD,
	SD_SA,
	SD_SD,
	SD_END
}

enum strafeDir
{
	strafeNone = 0,
	strafeLeft,
	strafeRight,
	strafeBoth
}

int g_PlayerStates[MAXPLAYERS + 1][PlayerState];

public Plugin myinfo = 
{
	name = "[Trikz] Stats RB",
	author = "Skipper"
}

bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_rbs", Command_RbStats);
	HookEvent("player_jump", Event_PlayerJump);
	HookEntityOutput("trigger_teleport", "OnStartTouch", Event_OnStartTriggerTp);
	HookEntityOutput("trigger_push", "OnStartTouch", Event_OnStartTriggerPush);
	for(int i = 1; i <= MaxClients; i++) 
			if(IsClientInGame(i)) 
				OnClientPutInServer(i);
}

public void OnClientPutInServer(int client)
{
	g_bRbStats[client] = false;
	g_bRbHasBeen[client] = false;
	g_bJumpAfterRb[client] = false;
	
	g_nSpectatorTarget[client] = -1;
	
	SDKHook(client, SDKHook_Touch, Client_StartTouch);
	SDKHook(client, SDKHook_StartTouch, Client_StartTouchWorld);
}

Action Command_RbStats(int client, int args)
{
	g_bRbStats[client] = !g_bRbStats[client];
	
	CPrintToChat(client, "{white}RB stats is %s.", g_bRbStats[client] ? "on" : "off");
	
	return Plugin_Handled;
}

Action Client_StartTouch(int client, int other) 
{
	if(!(IsValidClient(client, true) && IsValidClient(other, true)) || !g_bRbStats[client])
	{
		return;
	}
	
	float clientOrigin[3];
	float clientMaxs[3];
	
	GetClientAbsOrigin(client, clientOrigin);
	GetClientAbsOrigin(other, g_flStartPos[client]);
	GetClientMaxs(client, clientMaxs);

	g_PlayerStates[client][IllegalJumpFlags] = IJF_NONE;
	g_PlayerStates[g_iOther[client]][IllegalJumpFlags] = IJF_NONE;
	g_PlayerStates[client][CurStrafeDir] = SD_NONE;
	g_PlayerStates[client][nStrafes] = 0;
	g_iStrafeCount[client] = 0;
	dirThisStrafe[client] = strafeNone;
	dirPrevStrafe[client] = strafeNone;
	flPreSpeedB[g_iOther[client]] = 0.0;
	flPreSpeedFReal[client] = 0.0;
	
	g_iOther[client] = other;
	
	float delta = g_flStartPos[client][2] - clientOrigin[2] - clientMaxs[2];
	
	//if(-124.031250 >= delta >= -125.476501)
	if(delta <= -124.031250)
	{
		GetClientAbsOrigin(other, g_flOtherPos[other]);
		g_bRbHasBeen[client] = true;
		g_bJumpAfterRb[client] = false;
	}
}

Action Client_StartTouchWorld(int client, int other) 
{	
	if(g_bRbStats[client] && !other && g_bJumpAfterRb[client] && !(GetEntityFlags(client) & FL_ONGROUND))
	{
		g_PlayerStates[client][IllegalJumpFlags] = IJF_WORLD;
	}
}

Action Event_PlayerJump(Handle event, const char[] name, bool dB)
{	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(g_bRbStats[client] && g_bRbHasBeen[client]) 
	{
		g_iStartJumpTick[client] = GetGameTime();
		g_bRbHasBeen[client] = false;
		g_bJumpAfterRb[client] = true;
		flPreSpeedF[client] = GetEntitySpeed(client);
		flPreSpeedFReal[client] = flPreSpeedF[client];
		
		if(flPreSpeedF[client])
		{
			flPreSpeedB[g_iOther[client]] = GetEntitySpeed(g_iOther[client]);
		}
	}
}

Action Event_OnStartTriggerTp(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator))
	{
		g_PlayerStates[activator][IllegalJumpFlags] = IJF_TELEPORT;
	}
}

Action Event_OnStartTriggerPush(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator))
	{
		g_PlayerStates[activator][IllegalJumpFlags] = IJF_BOOSTER;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float Angle[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	SpectatorCheck(client);
	
	if(g_bRbStats[client] && IsPlayerAlive(client) && g_bJumpAfterRb[client])
	{		
		float fGravity = GetEntPropFloat(client, Prop_Data, "m_flGravity");
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_BOOSTER)
		{
			sStatus[client] = "{dimgray}({white}Push{dimgray})";
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_TELEPORT)
		{
			sStatus[client] = "{dimgray}({white}Teleport{dimgray})";
		}
		
		if(fGravity != 1.0 && fGravity != 0.0)
		{
			g_PlayerStates[client][IllegalJumpFlags] = IJF_GRAVITY;
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_GRAVITY)
		{
			sStatus[client] = "{dimgray}({white}Gravity{dimgray})";
		}
		
		if(GetEntityMoveType(client) & MOVETYPE_NOCLIP)
		{
			g_PlayerStates[client][IllegalJumpFlags] = IJF_NOCLIP;
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_NOCLIP)
		{
			sStatus[client] = "{dimgray}({white}Noclip{dimgray})";
		}
		
		if(GetEntPropFloat(client, Prop_Data, "m_flMaxspeed") > 250.0)
		{
			char strPlayerWeapon[32];
			GetClientWeapon(client, strPlayerWeapon, sizeof(strPlayerWeapon));
			
			if(!strcmp(strPlayerWeapon, "weapon_scout") || strPlayerWeapon[0] == 0)
			{
				g_PlayerStates[client][IllegalJumpFlags] = IJF_SCOUT;
			}
		}
		
		if(GetEntPropFloat(g_iOther[client], Prop_Data, "m_flMaxspeed") > 250.0)
		{
			char strPlayerWeapon[32];
			GetClientWeapon(g_iOther[client], strPlayerWeapon, sizeof(strPlayerWeapon));
			
			if(!strcmp(strPlayerWeapon, "weapon_scout") || strPlayerWeapon[0] == 0)
			{
				g_PlayerStates[client][IllegalJumpFlags] = IJF_SCOUT;
			}
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_SCOUT)
		{
			sStatus[client] = "{dimgray}({white}Scout{dimgray})";
		}
		
		if(GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1.0)
		{
			g_PlayerStates[client][IllegalJumpFlags] = IJF_LAGGEDMOVEMENTVALUE;
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_LAGGEDMOVEMENTVALUE)
		{
			sStatus[client] = "{dimgray}({white}Lagged movement value{dimgray})";
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_WORLD)
		{
			sStatus[client] = "{dimgray}({white}Hit wall/surf{dimgray})";
			//sStatus[client] = "{dimgray}({white}Lateral world collision {dimgray}({white}hit wall/surf{dimgray}))"; //DLL_MessageEnd:  Refusing to send user message SayText2 of 256 bytes to client, user message size limit is 255 bytes
		}
		
		if(g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE)
		{
			sStatus[client] = "";
		}
		
		//check for multiple keys -- it will spam strafes when multiple are held without this
		int nButtonCount;
		
		if(buttons & IN_MOVELEFT)
		{
			nButtonCount++;
		}
		
		if(buttons & IN_MOVERIGHT)
		{
			nButtonCount++;
		}
		
		if(buttons & IN_FORWARD)
		{
			nButtonCount++;
		}
		
		if(buttons & IN_BACK)
		{
			nButtonCount++;
		}
		
		if(nButtonCount == 1)
		{
			if(g_PlayerStates[client][CurStrafeDir] != SD_A && buttons & IN_MOVELEFT)
			{
				g_PlayerStates[client][StrafeDir][g_PlayerStates[client][nStrafes]] = SD_A;
				g_PlayerStates[client][CurStrafeDir] = SD_A;
				g_PlayerStates[client][nStrafes]++;
			}
			
			else if(g_PlayerStates[client][CurStrafeDir] != SD_D && buttons & IN_MOVERIGHT)
			{		
				g_PlayerStates[client][StrafeDir][g_PlayerStates[client][nStrafes]] = SD_D;
				g_PlayerStates[client][CurStrafeDir] = SD_D;
				g_PlayerStates[client][nStrafes]++;
			}
			
			else if(g_PlayerStates[client][CurStrafeDir] != SD_W && buttons & IN_FORWARD)
			{
				g_PlayerStates[client][StrafeDir][g_PlayerStates[client][nStrafes]] = SD_W;
				g_PlayerStates[client][CurStrafeDir] = SD_W;
				g_PlayerStates[client][nStrafes]++;
			}
			
			else if(g_PlayerStates[client][CurStrafeDir] != SD_S && buttons & IN_BACK)
			{				
				g_PlayerStates[client][StrafeDir][g_PlayerStates[client][nStrafes]] = SD_S;
				g_PlayerStates[client][CurStrafeDir] = SD_S;
				g_PlayerStates[client][nStrafes]++;
			}
		}
		
		ProcessStrafeData(client);
		
		if(GetEntityFlags(client) & FL_ONGROUND)
		{
			GetClientAbsOrigin(client, g_flFinishPos[client]);
			
			float flDistance = CalculateJumpDistance(client, g_flStartPos[client], g_flFinishPos[client]);
			float flHeight = (g_flOtherPos[g_iOther[client]][2] - g_flFinishPos[client][2] + 2) * -1;
			float iJumpTicks = (GetGameTime() - g_iStartJumpTick[client]) * 1000;
			
			float flSync = 0.0;
			float flAvgSync = 0.0;

			for(int Strafe = 0; Strafe < g_iStrafeCount[client]; Strafe++)
			{
				flSync = float(g_iGoodSyncTicks[client][Strafe]) / float(g_iStrafeTicks[client][Strafe]) * 100.0;
				flAvgSync += flSync;
			}
			
			flAvgSync = flAvgSync / float(g_iStrafeCount[client]);
			
			if(flPreSpeedB[g_iOther[client]] >= 100.0 && MIN_DISTANCE < flDistance < MAX_DISTANCE && MIN_RB_TICKS < iJumpTicks < MAX_RB_TICKS)
			{
				if(-0.034729 >= flHeight >= -2.0)
				{
					if(g_bRbStats[client] && !(g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE))
					{
						CPrintToChat(client, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n%s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, sStatus[client]);
					}
					
					if(g_bRbStats[g_iOther[client]] && !(g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE))
					{
						CPrintToChat(g_iOther[client], "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n%s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, sStatus[client]);
					}
					
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && g_bRbStats[i] && !(g_PlayerStates[i][IllegalJumpFlags] == IJF_NONE))
						{
							if(g_nSpectatorTarget[i] == client || g_nSpectatorTarget[i] == g_iOther[client])
							{
								CPrintToChat(i, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n%s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, sStatus[client]);
							}
						}
					}
					
					if(g_bRbStats[client] && g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE)
					{
						CPrintToChat(client, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync);
					}
					
					if(g_bRbStats[g_iOther[client]] && g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE)
					{
						CPrintToChat(g_iOther[client], "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync);
					}
					
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && g_bRbStats[i] && g_PlayerStates[i][IllegalJumpFlags] == IJF_NONE)
						{
							if(g_nSpectatorTarget[i] == client || g_nSpectatorTarget[i] == g_iOther[client])
							{
								CPrintToChat(i, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync);
							}
						}
					}
				}
				
				else
				{
					if(flHeight == 0.0)
					{
						flHeight = 0.1;
					}
					
					if(g_bRbStats[client] && !(g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE))
					{
						CPrintToChat(client, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray}) %s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight, sStatus[client]);
					}
					
					if(g_bRbStats[g_iOther[client]] && !(g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE))
					{
						CPrintToChat(g_iOther[client], "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray}) %s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight, sStatus[client]);
					}
					
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && g_bRbStats[i] && !(g_PlayerStates[i][IllegalJumpFlags] == IJF_NONE))
						{
							if(g_nSpectatorTarget[i] == client || g_nSpectatorTarget[i] == g_iOther[client])
							{
								CPrintToChat(i, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray}) %s", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight, sStatus[client]);
							}
						}
					}
					
					if(g_bRbStats[client] && g_PlayerStates[client][IllegalJumpFlags] == IJF_NONE)
					{
						CPrintToChat(client, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray})", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight);
					}
					
					if(g_bRbStats[g_iOther[client]])
					{
						CPrintToChat(g_iOther[client], "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray})", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight);
					}
					
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && g_bRbStats[i] && g_PlayerStates[i][IllegalJumpFlags] == IJF_NONE)
						{
							if(g_nSpectatorTarget[i] == client || g_nSpectatorTarget[i] == g_iOther[client])
							{
								CPrintToChat(i, "{dimgray}[{white}RBS{dimgray}] {white}D: {orange}%.1f {dimgray}| {white}Pre B/F: {orange}%.1f{white}/{orange}%.1f {dimgray}| {white}Strafe: {orange}%d {dimgray}| {white}Sync: {orange}%.1f{white}%%\n{dimgray}({white}Diff. height: {orange}%.1f{dimgray})", flDistance, flPreSpeedB[g_iOther[client]], flPreSpeedFReal[client], g_PlayerStates[client][nStrafes], flAvgSync, flHeight);
							}
						}
					}
				}
			}
			
			g_bJumpAfterRb[client] = false;
		}
	}
}

void ProcessStrafeData(int client)
{
	float VelDelta;
	int StrafeIndex;

	dirThisStrafe[client] = GetPlayerMoveStrafeDir(client);
	
	if(IsNewStrafe(client) == true && g_iStrafeCount[client] < MAX_STRAFES)
	{	
		dirPrevStrafe[client] = dirThisStrafe[client];
		g_iStrafeCount[client]++;
		g_iStrafeTicks[client][g_iStrafeCount[client]] = 0;
		g_iGoodSyncTicks[client][g_iStrafeCount[client]] = 0;
		g_iBadSyncTicks[client][g_iStrafeCount[client]] = 0;
		g_flGain[client][g_iStrafeCount[client]] = 0.0;
		g_flLoss[client][g_iStrafeCount[client]] = 0.0;
	}

	StrafeIndex = g_iStrafeCount[client] - 1;

	if(StrafeIndex >= 0 && StrafeIndex < MAX_STRAFES)
	{
		VelDelta = CalculateGainsAndLosses(client, StrafeIndex);
		CalculateSync(client, StrafeIndex, VelDelta);
	}
}

void CalculateSync(int client, int StrafeIndex, float VelocityDelta)
{
	g_iStrafeTicks[client][StrafeIndex]++;

	if(!(GetClientButtons(client) & IN_MOVELEFT) || !(GetClientButtons(client) & IN_MOVERIGHT))
	{
		if(VelocityDelta > 0.0)
		{
			g_iGoodSyncTicks[client][StrafeIndex]++;
		}
		
		else if(VelocityDelta < 0.0)
		{
			g_iBadSyncTicks[client][StrafeIndex]++;
		}
	}
}

float CalculateGainsAndLosses(int client, int StrafeIndex)
{
	float XyVel = GetEntitySpeed(client);
	float Delta = 0.0;

	if(GetClientButtons(client) & IN_MOVELEFT || GetClientButtons(client) & IN_MOVERIGHT)
	{
		Delta = XyVel - flPreSpeedF[client];

		if(Delta > 0.0)
		{
			g_flGain[client][StrafeIndex] += Delta;
		}
		
		else if(Delta < 0.0)
		{
			g_flLoss[client][StrafeIndex] -= Delta;
		}
	}

	flPreSpeedF[client] = XyVel;

	return Delta;
}

strafeDir GetPlayerMoveStrafeDir(int client)
{
	if(GetClientButtons(client) & IN_MOVELEFT && GetClientButtons(client) & IN_MOVERIGHT)
	{
		return strafeBoth;
	}
	
	else if(GetClientButtons(client) & IN_MOVELEFT)
	{
		return strafeLeft;
	}
	
	else if(GetClientButtons(client) & IN_MOVERIGHT)
	{
		return strafeRight;
	}
	
	else
	{
		return strafeNone;
	}
}

bool IsNewStrafe(int client)
{
	bool IsNewStrafeRet = false;

	if(g_iStrafeCount[client] == 0 && (dirThisStrafe[client] == 1 || dirThisStrafe[client] == 2))
	{
		IsNewStrafeRet = true;
	}
	
	if(dirThisStrafe[client] == 1 && dirPrevStrafe[client] == 2)
	{
		IsNewStrafeRet = true;
	}
	
	else if(dirThisStrafe[client] == 2 && dirPrevStrafe[client] == 1)
	{
		IsNewStrafeRet = true;
	}

	return IsNewStrafeRet;
}

float CalculateJumpDistance(any ..., float startPos[3], float endPos[3])
{
	float X = endPos[0] - startPos[0];
	float Y = endPos[1] - startPos[1];

	return SquareRoot(Pow(X, 2.0) + Pow(Y, 2.0)) + 32.0;
}

void SpectatorCheck(int client)
{
	//Manage spectators
	if(!IsClientObserver(client) && !g_bRbStats[client])
	{
		return;
	}
	
	int nObserverMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	
	if(4 <= nObserverMode <= 6)
	{
		int nTarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if(g_nSpectatorTarget[client] != nTarget)
		{
			g_nSpectatorTarget[client] = nTarget;
		}
	}
	
	else
	{
		if(g_nSpectatorTarget[client] != -1)
		{
			g_nSpectatorTarget[client] = -1;
		}
	}
}
