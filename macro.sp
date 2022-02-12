#include <sdkhooks>
//#include <sdktools>

float g_macroTime[MAXPLAYERS + 1];
bool g_macroOpened[MAXPLAYERS + 1];
//float g_macroAttackTime[MAXPLAYERS + 1]
//bool g_macroClosed[MAXPLAYERS + 1];
//bool g_macroSpawned[MAXPLAYERS + 1];
bool g_macroDisabled[MAXPLAYERS + 1];
//bool g_macroOnce[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Macro",
	author = "Nick Jurevich",
	description = "Make trikz game more comfortable.",
	version = "0.8",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_macro", cmd_macro);
}

public Action cmd_macro(int client, int args)
{
	g_macroDisabled[client] = !g_macroDisabled[client];

	PrintToServer("Macro is %s", g_macroDisabled[client] ? "Macro is disabled." : "Macro is enabled.");

	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	//SDKHook(client,
	g_macroDisabled[client] = false;
	//SDKHook(client, SDKHook_PostThink, SDKThink);
	//PrintToServer("1")
	//g_macroOnce[client] = false;
	g_macroTime[client] = 0.0;
	g_macroOpened[client] = false;
}

/*public void SDKThink(int client)
{
	char weapon[32]
	GetClientWeapon(client, weapon, sizeof(weapon))
	if(StrEqual(weapon, "weapon_flashbang", false))
	{
		int active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon")
		float throwTime = GetEntPropFloat(active, Prop_Send, "m_fThrowTime")
		if(throwTime > 0.0)
		{
			PrintToServer("6 %f %f", throwTime, GetGameTime())
		}
	}
	//PrintToServer("1z")
}*/

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
		char classname[32];
		GetClientWeapon(client, classname, sizeof(classname))
		if(StrEqual(classname, "weapon_flashbang", false))
		{
			//PrintToServer("%s", classname); //TODO: DO JUMP CHECK IN CORRECT WAY.
			//int owner = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
			//if(GetEntPropFloat(owner, Prop_Send, "m_fThrowTime") > 0.0 && GetEntPropFloat(owner, Prop_Send, "m_fThrowTime") < GetGameTime())
			//PrintToServer("%f", GetEntPropFloat(owner, Prop_Send, "m_fThrowTime"));
			//if((GetEntPropFloat(owner, Prop_Send, "m_fThrowTime") > 0.0) || (GetEntPropFloat(owner, Prop_Send, "m_fThrowTime") < GetGameTime()))
			//float x = GetEntPropFloat(owner, Prop_Send, "m_fThrowTime");
			//float done = GetEntPropFloat(client, Prop_Data, "m_flMoveDoneTime");
			//PrintToServer("%f %f %f", x, GetGameTime(), done);
			//if(GetEntPropFloat(owner, Prop_Data, "m_flNextPrimaryAttack") >= GetGameTime())
			{
				//if(!g_macroClosed[client] && g_macroOpened[client] == false && ((GetEngineTime() - g_macroTime[client] == 0.0 && g_macroOpened[client] == false) || GetEngineTime() - g_macroTime[client] >= 0.34))
				//if(g_macroTime[client] == 0.0 || (GetEngineTime() - g_macroTime[client] >= 0.34 && GetEngineTime() - g_macroTime[client] <= 0.4))
				if(g_macroOpened[client] == false && (g_macroTime[client] == 0.0 || GetEngineTime() - g_macroTime[client] >= 0.34))
				{
					g_macroTime[client] = GetEngineTime();
					//g_macroOnce[client] = true;
					//g_macroClosed[client] = true;
					//PrintToServer("debug1");
					//int owner = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
					//PrintToServer("%i", owner);
					//PrintToServer("%f", GetEntPropFloat(owner, Prop_Send, "m_fThrowTime"));
					//PrintToServer("%f %f", GetEntPropFloat(owner, Prop_Data, "m_flNextSecondaryAttack"), GetGameTime())
					//PrintToServer("%i", GetTime())
					//PrintToServer("x %f", GetEngineTime() - g_macroTime[client])
					g_macroOpened[client] = true;
				}
				//if(0.02 <= GetEngineTime() - g_macroTime[client] <= 0.04)
				if(g_macroOpened[client] == true && GetEngineTime() - g_macroTime[client] <= 0.02)
				{
					//if(x > 0.0)
					{
						//g_macroOpened[client] = true;
						buttons |= IN_ATTACK;
						//PrintToServer("debug2");
						//g_macroSpawned[client] = true;
					}
				}
			}
		}
	}
	else
	{
		//g_macroClosed[client] = false;
		//g_macroTime[client] = 0.0;
		//g_macroOpened[client] = false;
	}
	//if(GetEngineTime() - g_macroTime[client] >= 0.1 && g_macroOpened[client])
	//if(GetEngineTime() - g_macroTime[client] >= 0.1 && GetEngineTime() - g_macroTime[client] <= 0.2)
	//if(g_macroOpened[client] == true && GetEngineTime() - g_macroTime[client] >= 0.1)
	//i
	if(g_macroOpened[client] == true && GetEngineTime () - g_macroTime[client] >= 0.11)
	{
		buttons |= IN_JUMP;
		g_macroTime[client] = GetEngineTime();
		//g_macroOpened[client] = false;
		//g_macroClosed[client] = false;
		//PrintToServer("%f", GetEngineTime() - g_macroTime[client])
		//if(GetEngineTime() - g_macroTime[client] >= 0.15)
		//{
			//g_macroTime[client] = 0.0;
		//}
		g_macroOpened[client] = false;
	}

	return Plugin_Continue;
}

/*public void OnEntityCreated(int entity, const char[] classname)
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
}*/
