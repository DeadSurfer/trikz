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
