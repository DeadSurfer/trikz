#include <sdktools>
#include <sdkhooks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name        = "Player spawn",
	author      = "Smesh, credits: trikz redux (Shavit)",
	description = "Make instant flashbangs to player after spawn.",
	version     = "14.01.2021",
	url         = "https://steamcommunity.com/id/smesh292/"
};

bool IsValidClient(int client)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}

public void OnPluginStart()
{	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SpawnPost, SpawnPostClient);
}

void SpawnPostClient(int client)
{
	if(!IsValidClient(client) || IsFakeClient(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
	SetEntityRenderMode(client, RENDER_NORMAL);
	
	if(GetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + (12 * 4))) == 0)
	{
		GivePlayerItem(client, "weapon_flashbang");
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2);
	}
	
	if(GetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + (12 * 4))) == 1)
	{
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2);
	}
}
