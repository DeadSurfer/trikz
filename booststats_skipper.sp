#include <morecolors>
#include <sdkhooks>
#include <msharedutil/ents>
#include <trikz>

#pragma semicolon 1
#pragma newdecls required

bool gB_boostStats[MAXPLAYERS + 1]; 
float gF_boostTime[MAXPLAYERS + 1];
int gI_SpectatorTarget[MAXPLAYERS + 1]; 

public Plugin myinfo = 
{
	name = "[Trikz] Stats throw",
	author = "Skipper"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_bs", Command_BoostStats);
	RegConsoleCmd("sm_ts", Command_BoostStats);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	gB_boostStats[client] = false;
	gI_SpectatorTarget[client] = -1;
}

Action Command_BoostStats(int client, int args)
{
	gB_boostStats[client] = !gB_boostStats[client];
	
	CPrintToChat(client, "{white}Boost stats is %s.", gB_boostStats[client] ? "on" : "off");
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	char sWeapon[32];
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(IsValidEntity(iWeapon))
	{
		GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));
	}
	
	if(!(IsPlayerAlive(client) && StrEqual(sWeapon, "weapon_flashbang")))
	{
		return;
	}
	
	if(GetEntProp(client, Prop_Data, "m_afButtonReleased") & IN_ATTACK)
	{
		gF_boostTime[client] = GetEngineTime();
	}
	
	if(!(GetEntityFlags(client) & FL_ONGROUND && buttons & IN_JUMP))
	{
		return;
	}
	
	float flSpeed = GetEntitySpeed(client);
	
	float fProfTime = (GetEngineTime() - gF_boostTime[client]) * 1000;
	float fProfTimeLate = (GetEngineTime() - gF_boostTime[client]) * 1000;
	char sStatus[32];
	int iPartner = Trikz_FindPartner(client);
	
	if(101.562500 < fProfTimeLate < 600) 
	{
		fProfTimeLate = fProfTimeLate - 101.562500;
		sStatus = "{red}Too late";
		
		if(gB_boostStats[client])
		{
			CPrintToChat(client, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s", flSpeed, fProfTimeLate, sStatus);
			
			if(iPartner != -1)
			{
				if(gB_boostStats[iPartner])
				{
					CPrintToChat(iPartner, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s {dimgray}| {orange}%N", flSpeed, fProfTimeLate, sStatus, client);
				}
			}
		}
		
		if(iPartner == -1)
		{
			SpectatorCheck(client);
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && gB_boostStats[i])
				{
					if(gI_SpectatorTarget[i] == client)
					{
						CPrintToChat(i, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s", flSpeed, fProfTimeLate, sStatus);
					}
				}
			}
		}
		
		else
		{
			SpectatorCheck(iPartner);
		
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && gB_boostStats[i])
				{
					if(gI_SpectatorTarget[i] == client || gI_SpectatorTarget[i] == iPartner)
					{
						CPrintToChat(i, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s {dimgray}| {orange}%N", flSpeed, fProfTimeLate, sStatus, client);
					}
				}
			}
		}
	}
	
	if(99 < fProfTime <= 101.562500)
	{
		sStatus = "{white}Perfect";
	}
	
	if(89 < fProfTime < 100)
	{
		sStatus = "{lightblue}Near perfect insane";
	}
	
	if(69 < fProfTime < 90)
	{
		sStatus = "{lime}Great";
	}
	
	if(49 < fProfTime < 70)
	{
		sStatus = "{yellow}Good";
	}
	
	if(29 < fProfTime < 50)
	{
		sStatus = "{orange}Okay";
	}
	
	if(0 <= fProfTime < 30)
	{
		sStatus = "{red}Too early";
	}
	
	fProfTime = (fProfTime - 101.562499) * -1;
	
	if(0 <= fProfTime <= 101.562500)
	{
		if(gB_boostStats[client])
		{
			CPrintToChat(client, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s", flSpeed, fProfTime, sStatus);
			
			if(iPartner != -1)
			{
				if(gB_boostStats[iPartner])
				{
					CPrintToChat(iPartner, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s {dimgray}| {orange}%N", flSpeed, fProfTime, sStatus, client);
				}
			}
		}
		
		if(iPartner == -1)
		{
			SpectatorCheck(client);
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && gB_boostStats[i])
				{
					if(gI_SpectatorTarget[i] == client)
					{
						CPrintToChat(i, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s", flSpeed, fProfTime, sStatus);
					}
				}
			}
		}
		
		else
		{
			SpectatorCheck(iPartner);
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && gB_boostStats[i])
				{
					if(gI_SpectatorTarget[i] == client || gI_SpectatorTarget[i] == iPartner)
					{
						CPrintToChat(i, "{dimgray}[{white}BS{dimgray}] {white}Speed: {orange}%.1f{dimgray} | {white}Jump: {orange}%.1f {white}ms{dimgray} | %s {dimgray}| {orange}%N", flSpeed, fProfTime, sStatus, client);
					}
				}
			}
		}
	}
}

void SpectatorCheck(int client)
{
	//Manage spectators
	if(!IsClientObserver(client) && !gB_boostStats[client])
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
