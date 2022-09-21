/*
	GNU GENERAL PUBLIC LICENSE

	VERSION 2, JUNE 1991

	Copyright (C) 1989, 1991 Free Software Foundation, Inc.
	51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.

	GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.
*/
#define semicolon 1
#define required newdecls

#define MAXPLAYER MAXPLAYERS + 1

float g_macroTime[MAXPLAYER] = {0.0, ...};
bool g_macroOpened[MAXPLAYER] = {false, ...};
bool g_macroDisabled[MAXPLAYER] = {false, ...};
ConVar gCV_mainDelay = null;
ConVar gCV_repeatDelay = null;
ConVar gCV_enableMacro = null;
float g_macroMainDelay = 0.0;
float g_macroRepeatDelay = 0.0;

public Plugin myinfo =
{
	name = "Macro",
	author = "Nick Jurevich",
	description = "Make trikz game more comfortable.",
	version = "0.96",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_macro", cmd_macro);

	gCV_enableMacro = CreateConVar("sm_macro_enable", "0.0", "Do enable plugin here.", FCVAR_NOTIFY, false, 0.0, true, 1.0);
	gCV_mainDelay = CreateConVar("sm_macro_main_delay", "0.11", "Make main delay for attack2", FCVAR_NOTIFY, false, 0.0, true, 0.11);
	gCV_repeatDelay = CreateConVar("sm_macro_repeat_delay", "0.36", "Make repeat delay if hold attack2", FCVAR_NOTIFY, true, 3.6, true, 0.4);

	AutoExecConfig(true);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			OnClientPutInServer(i);
		}
	}

	return;
}

public Action cmd_macro(int client, int args)
{
	float convar = GetConVarFloat(gCV_enableMacro);

	if(convar == 0.0)
	{
		return Plugin_Continue;
	}

	g_macroDisabled[client] = !g_macroDisabled[client];

	PrintToServer("Macro is %s now.", g_macroDisabled[client] == true ? "disabled" : "enabled");

	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	bool macro = gCV_enableMacro.BoolValue;
	
	if(macro == false)
	{
		return;
	}

	g_macroDisabled[client] = false;
	g_macroTime[client] = 0.0;
	g_macroOpened[client] = false;
	g_macroMainDelay = gCV_mainDelay.FloatValue;
	g_macroRepeatDelay = gCV_repeatDelay.FloatValue;

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	bool macro = gCV_enableMacro.BoolValue;
	
	if(macro == true && g_macroDisabled[client] == false)
	{
		if(buttons & IN_ATTACK2)
		{
			char classname[32] = "";
			GetClientWeapon(client, classname, sizeof(classname))

			if(StrEqual(classname, "weapon_flashbang", false) == true || StrEqual(classname, "weapon_hegrenade", false) == true || StrEqual(classname, "weapon_smokegrenade", false) == true)
			{
				if(g_macroOpened[client] == false && GetEngineTime() - g_macroTime[client] >= g_macroRepeatDelay)
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
	}

	return Plugin_Continue;
}
