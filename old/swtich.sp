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
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

#pragma newdecls required
#pragma semicolon 1

bool gB_AutoSwitch[MAXPLAYERS + 1];
bool gB_AutoFlash[MAXPLAYERS + 1];
bool gB_FlashThrown[MAXPLAYERS + 1];
float gF_LastThrowTime[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Switch",
	author = "Log, modified by Smesh",
	description = "Make able to see good nade and swtich to flashbang after throw.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/profiles/76561198095502113/"
};

bool IsValidClient(int client)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_autoswitch", Command_AutoSwitch);
	RegConsoleCmd("sm_as", Command_AutoSwitch);
	RegConsoleCmd("sm_autoflash", Command_AutoFlash);
	RegConsoleCmd("sm_af", Command_AutoFlash);
	
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
	gB_AutoSwitch[client] = true;
	gB_AutoFlash[client] = true;
	gB_FlashThrown[client] = false;
}

Action Command_AutoSwitch(int client, int args)
{
	gB_AutoSwitch[client] = !gB_AutoSwitch[client];

	if(gB_AutoSwitch[client])
	{  
		CPrintToChat(client, "{white}Autoswitch is on.");
	}

	else
	{
		CPrintToChat(client, "{white}Autoswitch is off.");
	}

	return Plugin_Handled;
}

Action Command_AutoFlash(int client, int args)
{
	gB_AutoFlash[client] = !gB_AutoFlash[client];

	if(gB_AutoFlash[client])
	{  
		CPrintToChat(client, "{white}Autoflash is on.");
	}

	else
	{
		CPrintToChat(client, "{white}Autoflash is off.");
	}

	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(!IsPlayerAlive(client) || IsFakeClient(client) || !gB_AutoSwitch[client])
	{
		return;
	}

	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(!IsValidEntity(iWeapon))
	{
		return;
	}
	
	float iTime = GetGameTime();
	
	if(iTime - gF_LastThrowTime[client] > 1.3 && gB_FlashThrown[client])
	{
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", 0.0);
		SetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack", 0.0);
		
		gB_FlashThrown[client] = false;
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
	{
		SDKHook(entity, SDKHook_Spawn, FlashbangProjectile_Spawn); 
	}
}

Action FlashbangProjectile_Spawn(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	if(!IsValidClient(client) || !IsValidEntity(entity))
	{
		return;
	}
	
	if(gB_AutoFlash[client])
	{
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2);
	}
	
	if(!gB_AutoSwitch[client])
	{
		return;
	}
	
	gB_FlashThrown[client] = true;
	
	float iTime = GetGameTime();
	gF_LastThrowTime[client] = iTime;
	
	int iWeapon = GetPlayerWeaponSlot(client, 1);
	int iTeam = GetClientTeam(client);
	
	if(iWeapon == -1 && iTeam == CS_TEAM_T)
	{
		GivePlayerItem(client, "weapon_glock");
		iWeapon = GetPlayerWeaponSlot(client, 1);
	}
	
	if(iWeapon == -1 && iTeam == CS_TEAM_CT)
	{
		GivePlayerItem(client, "weapon_usp");
		iWeapon = GetPlayerWeaponSlot(client, 1);
	}
	
	char sWeapon[17];
	GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));
	FakeClientCommand(client, "use %s", sWeapon);
	
	//Hide sWeapon model
	iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 0.0);
	 
	int iViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	
	if(iViewModel != INVALID_ENT_REFERENCE) 
	{
		SetEntPropFloat(iViewModel, Prop_Send, "m_flPlaybackRate", 0.0);
	}
	
	SetEntPropFloat(iWeapon, Prop_Send, "m_flTimeWeaponIdle", 20.0);
	
	//Make nade visible
	ClientCommand(client, "lastinv");
}
