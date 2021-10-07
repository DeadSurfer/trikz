/*GNU GENERAL PUBLIC LICENSE

VERSION 2, JUNE 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.*/

/*GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.*/
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
