#include <trikz>
#include <shavit>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

char gS_CMD_Block[][] = {"sm_bl", "sm_block", "sm_ghost", "sm_switch"};

public Plugin myinfo =
{
	name = "Noblock",
	author = "Smesh, credits: Shavit (trikz redux)",
	description = "You can toggle collision (solid, no-solid).",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{	
	for(int i = 0; i < sizeof(gS_CMD_Block); i++)
	{
		RegConsoleCmd(gS_CMD_Block[i], Command_Block, "Toggle blocking");
	}
}

Action Command_Block(int client, int args)
{
	if(!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{white}You must be alive to use this feature!");
		
		return Plugin_Handled;
	}
	
	if(Shavit_GetClientTrack(client) != Track_Solobonus)
	{
		if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5)
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
			SetEntityRenderMode(client, RENDER_TRANSALPHA);
			//SetEntityRenderColor(client, 255, 255, 255, 75);
			SetEntityRenderColor(client, Trikz_GetClientColorR(client), Trikz_GetClientColorG(client), Trikz_GetClientColorB(client), 100);
			CPrintToChat(client, "{white}You are ghost.");
			
			return Plugin_Handled;
		}
			
		if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
			SetEntityRenderMode(client, RENDER_NORMAL);
			CPrintToChat(client, "{white}You are blocking.");
			
			return Plugin_Handled;
		}
	}
	
	else
	{
		CPrintToChat(client, "{dimgray}[{white}TIMER{dimgray}] {white}Block cannot be toggled in solobonus track. Type {orange}/r {white}or {orange}/b {white}or {orange}/end {white}or {orange}/bend {white}to change the track.");
	}
	
	return Plugin_Handled;
}
