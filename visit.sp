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

#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define IsValidClient(%1) (0 < %1 <= MaxClients && IsClientInGame(%1))

char g_format[256] = "";

ConVar g_cvEnable = null, g_cvBot = null;

public Plugin myinfo =
{
	name = "Visit announcement",
	author = "Smesh",
	description = "Always show connect, disconnect, team changes message in the chat.",
	version = "0.333",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	g_cvEnable = CreateConVar("sm_visit_enable", "0.0", "Do plugin enable here?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvBot = CreateConVar("sm_visit_bot", "0.0", "Show bots on visit event?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "plugin.visit", "sourcemod");

	HookEvent("player_connect_client", connect, EventHookMode_Pre);
	//HookEvent("player_connect", connect, EventHookMode_Pre);
	HookEvent("player_disconnect", disconnect, EventHookMode_Pre);
	HookEvent("player_team", teamjoin, EventHookMode_Pre);
	HookEvent("player_changename", changename, EventHookMode_Pre);

	LoadTranslations("visit.phrases");

	return;
}

Action connect(Event event, const char[] name, bool dontBroadcast)
{
	if(g_cvEnable.FloatValue != 1.0)
	{
		return Plugin_Continue;
	}

	float bot = g_cvBot.FloatValue;

	char sName[MAX_NAME_LENGTH] = "";
	event.GetString("name", sName, sizeof(sName));

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			if(bot == 1.0 || (bot != 1.0 && IsFakeClient(i) == false))
			{
				Format(g_format, sizeof(g_format), "%T", "connect", i, sName);
				SendMessage(i, g_format);
			}
		}
	}

	event.BroadcastDisabled = true;

	return Plugin_Continue;
}

public Action disconnect(Event event, const char[] name, bool dontBroadcast)
{
	if(g_cvEnable.FloatValue != 1.0)
	{
		return Plugin_Continue;
	}

	float bot = g_cvBot.FloatValue;

	char sReason[128] = "";
	event.GetString("reason", sReason, sizeof(sReason));

	char sName[MAX_NAME_LENGTH] = "";
	event.GetString("name", sName, sizeof(sName));

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			if(bot == 1.0 || (bot != 1.0 && IsFakeClient(i) == false))
			{
				Format(g_format, sizeof(g_format), "%T", "disconnect", i, sName, sReason);
				SendMessage(i, g_format);
			}
		}
	}

	event.BroadcastDisabled = true;

	return Plugin_Continue;
}

Action teamjoin(Event event, const char[] name, bool dontBroadcast)
{
	if(g_cvEnable.FloatValue != 1.0)
	{
		return Plugin_Continue;
	}

	int client = GetClientOfUserId(event.GetInt("userid"));
	int team = event.GetInt("team");

	float bot = g_cvBot.FloatValue;

	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, sizeof(sName));

	switch(team)
	{
		case CS_TEAM_SPECTATOR:
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					if(bot == 1.0 || (bot != 1.0 && IsFakeClient(i) == false))
					{
						Format(g_format, sizeof(g_format), "%T", "joinSpectator", i, sName);
						SendMessage(i, g_format);
					}
				}
			}
		}

		case CS_TEAM_T:
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					if(bot == 1.0 || (bot != 1.0 && IsFakeClient(i) == false))
					{
						Format(g_format, sizeof(g_format), "%T", "joinTerrorist", i, sName);
						SendMessage(i, g_format);
					}
				}
			}
		}

		case CS_TEAM_CT:
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					if(bot == 1.0 || (bot != 1.0 && IsFakeClient(i) == false))
					{
						Format(g_format, sizeof(g_format), "%T", "joinCounterTerrorist", i, sName);
						SendMessage(i, g_format);
					}
				}
			}
		}
	}

	event.BroadcastDisabled = true;

	return Plugin_Continue;
}

Action changename(Event event, const char[] name, bool dontBroadcast)
{
	float bot = g_cvBot.FloatValue;
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(bot == 1.0 && IsFakeClient(client) == true)
	{
		event.BroadcastDisabled = true;
	}

	return Plugin_Continue;
}

void SendMessage(int client, const char[] text)
{
	char name[MAX_NAME_LENGTH] = "";
	GetClientName(client, name, sizeof(name));

	int team = GetClientTeam(client);

	char teamColor[32] = "";

	switch(team)
	{
		case CS_TEAM_SPECTATOR:
		{
			Format(teamColor, sizeof(teamColor), "\x07CCCCCC");
		}

		case CS_TEAM_T:
		{
			Format(teamColor, sizeof(teamColor), "\x07FF4040");
		}

		case CS_TEAM_CT:
		{
			Format(teamColor, sizeof(teamColor), "\x0799CCFF");
		}
	}

	char textReplaced[256] = "";
	Format(textReplaced, sizeof(textReplaced), "\x01%s", text);

	ReplaceString(textReplaced, sizeof(textReplaced), ";#", "\x07");
	ReplaceString(textReplaced, sizeof(textReplaced), "{default}", "\x01");
	ReplaceString(textReplaced, sizeof(textReplaced), "{teamcolor}", teamColor);

	if(IsValidClient(client) == true)
	{
		Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS); //https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/morecolors.inc#L195
		BfWrite bf = UserMessageToBfWrite(buf); //dont show color codes in console.
		bf.WriteByte(client); //Message author
		bf.WriteByte(true); //Chat message
		bf.WriteString(textReplaced); //Message text
		EndMessage();
	}

	return;
}
