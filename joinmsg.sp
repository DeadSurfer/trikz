// ====[ INCLUDES ]============================================================ 
#include <sourcemod> 
#include <morecolors> 

#pragma newdecls required
#pragma semicolon 1

// ====[ DEFINES ]============================================================= 
#define PLUGIN_VERSION "1.3.0.2"

// ====[ PLUGIN ]============================================================== 
public Plugin myinfo = 
{ 
    name = "[Any] Improved Join Team Messages", 
    author = "Oshizu and ReFlexPoison (Helped many times with plugin)", 
    description = "Improves messages that appear when player joins team", 
    version = PLUGIN_VERSION, 
    url = "http://www.sourcemod.net", 
} 

// ====[ FUNCTIONS ]=========================================================== 
public void OnPluginStart() 
{
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
}

public Action Event_PlayerTeam(Handle hEvent, const char[] strName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		return Plugin_Handled;
	}
	
	int iOldTeam = GetEventInt(hEvent, "oldteam");
	int iintTeam = GetEventInt(hEvent, "team");
	
	SetEventBroadcast(hEvent, true);
	//Counter-Strike
	//2 = Terrorists (Red)
	//3 = Counter-Terrorists (Blue)
	switch(iOldTeam)
	{
		case 0, 1, 2, 3:
		{
			switch(iintTeam)
			{
				case 1: CPrintToChatAll("{orange}%N {white}joined team {gray}Spectators{white}.", client);
				case 2: CPrintToChatAll("{orange}%N {white}joined team {red}Terrorists{white}.", client);
				case 3: CPrintToChatAll("{orange}%N {white}joined team {blue}Counter-Terrorists{white}.", client);
			}
		}
	}
	
	return Plugin_Continue;
}

// ====[ STOCKS ]============================================================== 
stock bool IsValidClient(int client, bool bReplay = true) 
{ 
	if(client <= 0 || client > MaxClients || !IsClientInGame(client))
	{
		return false;
	}
	
	if(bReplay && (IsClientSourceTV(client) || IsClientReplay(client))) 
	{
		return false;
	}
	
	return true; 
}  
