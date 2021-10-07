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
