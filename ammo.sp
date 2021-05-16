// Code Created By Skydive On (14-10-12)
// You Are Free To Redistribute Or Use This In Your Own Work Without Restriction Whatsoever.

#include <sdktools>
#include <sdkhooks>
#include <morecolors>

#pragma newdecls required
#pragma semicolon 1

Handle Ammo[MAXPLAYERS + 1];

bool gB_Ammo[MAXPLAYERS + 1];
bool check[MAXPLAYERS + 1];

public Plugin myinfo= 
{
	name = "Infinite Ammo Frenzy",
	author = "Skydive, modifyed by Smesh",
	description = "Reloading is no longer necessary.",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_ammo", Command_Ammo);
	
	HookEventEx("weapon_fire", Weapon_Fire);
	
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
	SDKHook(client, SDKHook_WeaponEquipPost, WeaponEquip);
	
	gB_Ammo[client] = true;
	check[client] = true;
}

public void OnClientDisconnect(int client)
{	
	if(!check[client])
	{
		delete Ammo[client];
	}
}

void Weapon_Fire(Event event, const char[] name, bool dB)
{	
	int client = GetClientOfUserId(event.GetInt("userid"));
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	
	if(!IsValidEntity(weapon))
	{
		return;
	}
	
	char sWeapon[20];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(StrEqual(sWeapon, "weapon_flashbang") || StrEqual(sWeapon, "weapon_hegrenade") || StrEqual(sWeapon, "weapon_smokegrenade") || StrEqual(sWeapon, "weapon_knife"))
	{
		return;
	}
	
	if(check[client])
	{
		Ammo[client] = CreateTimer(6.0, Timer_Ammo, client); //Less server-side load
		
		check[client] = false;
	}
}

Action Command_Ammo(int client, int args)
{
	gB_Ammo[client] = !gB_Ammo[client];
	
	if(gB_Ammo[client])
	{
		CPrintToChat(client, "{white}Infinite ammonition is on.");
	}
	
	else
	{
		CPrintToChat(client, "{white}Infinite ammonition is off.");
	}
	
	int Slot1 = GetPlayerWeaponSlot(client, 0);
	int Slot2 = GetPlayerWeaponSlot(client, 1);
	
	if(IsPlayerAlive(client) && gB_Ammo[client])
	{
		if(IsValidEntity(Slot1))
		{
			if(GetEntProp(Slot1, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot1, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot1, FindDataMapInfo(client, "m_iClip1"));
			}
		}
		
		if(IsValidEntity(Slot2))
		{
			if(GetEntProp(Slot2, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot2, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot2, FindDataMapInfo(client, "m_iClip1"));
			}
		}
	}
	
	return Plugin_Handled;
}

Action Timer_Ammo(Handle timer, int client)
{
	int Slot1 = GetPlayerWeaponSlot(client, 0);
	int Slot2 = GetPlayerWeaponSlot(client, 1);
	
	if(IsPlayerAlive(client) && gB_Ammo[client])
	{
		if(IsValidEntity(Slot1))
		{
			if(GetEntProp(Slot1, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot1, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot1, FindDataMapInfo(client, "m_iClip1"));
			}
		}
		
		if(IsValidEntity(Slot2))
		{
			if(GetEntProp(Slot2, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot2, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot2, FindDataMapInfo(client, "m_iClip1"));
			}
		}
	}
	
	check[client] = true;
}

void WeaponEquip(int client)
{	
	int Slot1 = GetPlayerWeaponSlot(client, 0);
	int Slot2 = GetPlayerWeaponSlot(client, 1);
	
	if(IsPlayerAlive(client) && gB_Ammo[client])
	{
		if(IsValidEntity(Slot1))
		{
			if(GetEntProp(Slot1, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot1, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot1, FindDataMapInfo(client, "m_iClip1"));
			}
		}
		
		if(IsValidEntity(Slot2))
		{
			if(GetEntProp(Slot2, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot2, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot2, FindDataMapInfo(client, "m_iClip1"));
			}
		}
		
		RequestFrame(doublecheck, client);
	}
}

void doublecheck(int client)
{
	if(!IsClientInGame(client))
	{
		return;
	}
	
	int Slot1 = GetPlayerWeaponSlot(client, 0);
	int Slot2 = GetPlayerWeaponSlot(client, 1);
	
	if(IsPlayerAlive(client) && gB_Ammo[client])
	{
		if(IsValidEntity(Slot1))
		{
			if(GetEntProp(Slot1, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot1, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot1, FindDataMapInfo(client, "m_iClip1"));
			}
		}
		
		if(IsValidEntity(Slot2))
		{
			if(GetEntProp(Slot2, Prop_Data, "m_iClip1") <= 90)
			{
				SetEntProp(Slot2, Prop_Data, "m_iClip1", 90);
				ChangeEdictState(Slot2, FindDataMapInfo(client, "m_iClip1"));
			}
		}
	}
}
