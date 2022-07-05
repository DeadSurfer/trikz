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
#include <sdkhooks>

#define semicolon 1
#define required newdecls

#define MAXPLAYER MAXPLAYERS + 1

float g_macroTime[MAXPLAYER];
bool g_macroOpened[MAXPLAYER];
bool g_macroDisabled[MAXPLAYER];
ConVar gCV_mainDelay;
ConVar gCV_repeatDelay;
ConVar gCV_enableMacro;
float g_macroMainDelay;
float g_macroRepeatDelay;

public Plugin myinfo =
{
	name = "Macro",
	author = "Nick Jurevich",
	description = "Make trikz game more comfortable.",
	version = "0.94",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_macro", cmd_macro);

	gCV_enableMacro = CreateConVar("sm_enable_macro", "0.0", "Do enable plugin here.", 0, false, 0.0, true, 1.0);
	gCV_mainDelay = CreateConVar("sm_main_delay", "0.10", "Make main delay for attack2", 0, false, 0.0, true, 0.12);
	gCV_repeatDelay = CreateConVar("sm_repeat_delay", "0.4", "Make repeat delay if hold attack2", 0, false, 0.0, true, 0.4);

	AutoExecConfig(true);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public Action cmd_macro(int client, int args)
{
	float convar = GetConVarFloat(gCV_enableMacro);

	if(convar == 0.0)
	{
		return Plugin_Continue;
	}

	g_macroDisabled[client] = !g_macroDisabled[client];

	PrintToServer("Macro is %s", g_macroDisabled[client] ? "Macro is disabled." : "Macro is enabled.");

	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	float convar = GetConVarFloat(gCV_enableMacro);
	
	if(convar == 0.0)
	{
		return;
	}

	g_macroDisabled[client] = false;
	g_macroTime[client] = 0.0;
	g_macroOpened[client] = false;
	g_macroMainDelay = GetConVarFloat(gCV_mainDelay);
	g_macroRepeatDelay = GetConVarFloat(gCV_repeatDelay);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	float convar = GetConVarFloat(gCV_enableMacro);

	if(convar == 0.0)
	{
		return Plugin_Continue;
	}

	if(buttons & IN_ATTACK2)
	{
		char classname[32];
		GetClientWeapon(client, classname, sizeof(classname))

		if(StrEqual(classname, "weapon_flashbang", false))
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

	return Plugin_Continue;
}
