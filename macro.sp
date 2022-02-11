#include <sdkhooks>

float g_macroTime[MAXPLAYERS + 1];
bool g_macroOpened[MAXPLAYERS + 1];
//float g_macroAttackTime[MAXPLAYERS + 1]
bool g_macroClosed[MAXPLAYERS + 1];
bool g_macroSpawned[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Macro",
	author = "Nick Jurevich",
	description = "Make trikz game more comfortable.",
	version = "0.6",
	url = "http://www.sourcemod.net/"
}

public void OnClientPutInServer(int client)
{
	//SDKHook(client,
}

public Action OnPlayerRunCmd(int client, int& buttons)
{
	//if(buttons & IN_ATTACK2)
	//{
		//g_macroTime[client] = GetEngineTime()
		//g_macroOpened[client] = true
		//buttons |= IN_ATTACK
	//}
	//if(0.02 < GetEngineTime() - g_macroTime[client] >= 0.1 && g_macroOpened[client])
	//{
		//buttons |= IN_JUMP
		//g_macroOpened[client] = false
	//}
	//return Plugin_Continue
	//if(buttons & IN_ATTACK2 && !g_macroSpawned[client])
	if(buttons & IN_ATTACK2)
	{
		//char classname[32];
		//GetClientWeapon(client, classname, sizeof(classname))
		//if(StrEqual(classname, "weapon_flashbang", false))
		{
			//PrintToServer("%s", classname); //TODO: DO JUMP CHECK IN CORRECT WAY.
			//if(GetEntPropFloat(GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon"), Prop_Send, "m_fThrowTime") > 0.0 && GetEntPropFloat(GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon"), Prop_Send, "m_fThrowTime") < GetGameTime())
			{
				if(!g_macroClosed[client])
				{
					g_macroTime[client] = GetEngineTime();
					g_macroClosed[client] = true;
					PrintToServer("debug1");
				}
				if(0.02 <= GetEngineTime() - g_macroTime[client] <= 0.04)
				{
					g_macroOpened[client] = true;
					buttons |= IN_ATTACK;
					PrintToServer("debug2");
					g_macroSpawned[client] = true;
				}
			}
		}
	}
	else
	{
		g_macroClosed[client] = false;
	}
	if(GetEngineTime() - g_macroTime[client] >= 0.1 && g_macroOpened[client])
	{
		buttons |= IN_JUMP;
		g_macroOpened[client] = false;
		g_macroClosed[client] = false;
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile", false))
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnPost);
	}
}

public void SDKSpawnPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	g_macroSpawned[client] = false;
}
