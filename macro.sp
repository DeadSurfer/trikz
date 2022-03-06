#include <sdkhooks>

#define required newdecls

float g_macroTime[MAXPLAYERS + 1];
bool g_macroOpened[MAXPLAYERS + 1];
bool g_macroDisabled[MAXPLAYERS + 1];
ConVar gCV_mainDelay;
ConVar gCV_repeatDelay;
float g_macroMainDelay;
float g_macroRepeatDelay;

public Plugin myinfo =
{
	name = "Macro",
	author = "Nick Jurevich",
	description = "Make trikz game more comfortable.",
	version = "0.9",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_macro", cmd_macro);
	gCV_mainDelay = CreateConVar("mainDelay", "0.11", "Make main delay for attack2", 0, false, 0.0, true, 0.11);
	gCV_repeatDelay = CreateConVar("repeatDelay", "0.34", "Make repeat delay if hold attack2", 0, false, 0.0, true, 0.4);
	AutoExecConfig(true);
	//g_macroMainDelay = GetConVarFloat(gCV_mainDelay);
	//g_macroRepeatDelay = GetConVarFloat(gCV_repeatDelay);
}

public Action cmd_macro(int client, int args)
{
	g_macroDisabled[client] = !g_macroDisabled[client];

	PrintToServer("Macro is %s", g_macroDisabled[client] ? "Macro is disabled." : "Macro is enabled.");

	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	g_macroDisabled[client] = false;
	g_macroTime[client] = 0.0;
	g_macroOpened[client] = false;
	g_macroMainDelay = GetConVarFloat(gCV_mainDelay);
	g_macroRepeatDelay = GetConVarFloat(gCV_repeatDelay);
}

public Action OnPlayerRunCmd(int client, int& buttons)
{
	if(buttons & IN_ATTACK2)
	{
		char classname[32];
		GetClientWeapon(client, classname, sizeof(classname))

		if(StrEqual(classname, "weapon_flashbang", false))
		{
			if(g_macroOpened[client] == false && (g_macroTime[client] == 0.0 || GetEngineTime() - g_macroTime[client] >= g_macroRepeatDelay))
			{
				g_macroTime[client] = GetEngineTime();
				g_macroOpened[client] = true;
			}

			if(g_macroOpened[client] == true && GetEngineTime() - g_macroTime[client] <= 0.02)
			{
				buttons |= IN_ATTACK;
			}
		}
	}

	if(g_macroOpened[client] == true && GetEngineTime () - g_macroTime[client] >= g_macroMainDelay)
	{
		buttons |= IN_JUMP;
		g_macroTime[client] = GetEngineTime();
		g_macroOpened[client] = false;
	}

	return Plugin_Continue;
}
