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
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

bool gB_Hurt[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Hurting sounds",
	author = "https://forums.alliedmods.net/showthread.php?p=2316188 (NeoxX), modofied by Smesh",
	description = "Make able to toggle sounds of hurting.",
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

public void OnPluginStart()
{
	RegConsoleCmd("sm_hurt", Command_Hurt); //Thanks to extrem
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	AddNormalSoundHook(NSH_hurt);
}

public void OnClientPutInServer(int client)
{
	gB_Hurt[client] = false;
}

Action Command_Hurt(int client, int args)
{
	gB_Hurt[client] = !gB_Hurt[client];

	if(gB_Hurt[client])
	{
		CPrintToChat(client, "{white}Hurt sounds is on.");
	}
	
	else
	{
		CPrintToChat(client, "{white}Hurt sounds is off.");
	}
	
	return Plugin_Handled;
}

//Thanks to https://forums.alliedmods.net/showthread.php?p=2316188
Action NSH_hurt(int clients[64], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if(0 < entity <= MaxClients)
	{
		if(!gB_Hurt[entity])
		{
			//Disable hurt sounds	
			if(StrContains(sample, "player/damage") != -1)
			{
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}
