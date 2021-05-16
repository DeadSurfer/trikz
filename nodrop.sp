#include <sdktools>
#include <sdkhooks>
#include <shavit>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "No weapon drop",
	author = "Smesh, thanks to https://forums.alliedmods.net/showthread.php?p=1612843 (TnTSCS), shavit",
	description = "Remove the weapon instantly on drop.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

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
	if(!IsValidClient(client))
	{
		return;
	}
	
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client))
	{
		return;
	}
	
	int entity = -1;
	
	while((entity = FindEntityByClassname(entity, "weapon_*")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
		{
			RequestFrame(RemoveWeapon, EntIndexToEntRef(entity));
		}
	}
}

void RemoveWeapon(any data)
{
	if(IsValidEntity(data))
	{
		AcceptEntityInput(data, "Kill");
	}
}

//Thanks to https://forums.alliedmods.net/showthread.php?p=1612843
Action OnWeaponDrop(int client, int entity)
{
	if(IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "Kill");
	}
}
