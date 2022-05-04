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
#pragma semicolon 1
#pragma newdecls required

#define debug false

public Plugin myinfo =
{
	name = "Visit announcement",
	author = "Smesh",
	description = "Always show connect, disconnect, team changes message in the chat.",
	version = "0.32",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	HookEvent("player_connect_client", connect, EventHookMode_Pre);
	HookEvent("player_disconnect", disconnect, EventHookMode_Pre);
	HookEvent("player_team", teamjoin, EventHookMode_Pre);

	LoadTranslations("visit.phrases");
}

public Action connect(Event event, const char[] name, bool dontBroadcast)
{
	char sName[MAX_NAME_LENGTH];
	event.GetString("name", sName, sizeof(sName));
	//PrintToChatAll("Player %s has joined the game", name_)
	//PrintToChatAll("%T", "connect", 0, name_);
	//PrintToChatAll("%t", "connect");
	char format[256];

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			//PrintToChat(i, "\x01%T", "connect", i, sName);
			//PrintToChat(i, "\x01%T", "connect", i, sName);
			Format(format, sizeof(format), "%T", "connect", i, sName);
			SendMessage(format, false, i);
		}
	}

	SetEventBroadcast(event, true);

	return Plugin_Continue;
}

public Action disconnect(Event event, const char[] name, bool dontBroadcast)
{
	char sReason[128];
	event.GetString("reason", sReason, sizeof(sReason));
	char sName[MAX_NAME_LENGTH];
	event.GetString("name", sName, sizeof(sName));
	//PrintToChatAll("Player %s left the game (%s)", name_, reason)
	//PrintToChatAll("\x01%T", "disconnect", sName, sReason);
	char format[256];

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			//PrintToChat(i, "\x01%T", "disconnect", i, sName, sReason);
			Format(format, sizeof(format), "%T", "disconnect", i, sName, sReason);
			SendMessage(format, false, i);
		}
	}

	SetEventBroadcast(event, true);

	return Plugin_Continue;
}

public Action teamjoin(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int team = event.GetInt("team");

	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, sizeof(sName));

	char format[256];

	switch(team)
	{
		case 1:
		{
			//PrintToChatAll("%N is joining the Spectators", client);
			//PrintToChatAll("\x01%T", "joinSpectator", sName);
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					Format(format, sizeof(format), "%T", "joinSpectator", i, sName);
					SendMessage(format, false, i);
					//PrintToChat(i, "\x01%T", "joinSpectator", i, sName);
				}
			}
		}

		case 2:
		{
			//PrintToChatAll("%N is joining the Terrorist force", client);
			//PrintToChatAll("\x01%T", "joinTerrorist", sName);
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					//PrintToChat(i, "\x01%T", "joinTerrorist", i, sName);
					Format(format, sizeof(format), "%T", "joinTerrorist", i, sName);
					SendMessage(format, false, i);
				}
			}
		}

		case 3:
		{
			//PrintToChatAll("%N is joining the Counter-Terrorist force", client);
			//PrintToChatAll("\x01%T", "joinCounterTerrorist", sName);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					Format(format, sizeof(format), "%T", "joinCounterTerrorist", i, sName);
					SendMessage(format, false, i);
					//PrintToChat(i, "\x01%T", "joinCounterTerrorist", i, sName);
				}
			}
		}
	}

	SetEventBroadcast(event, true);

	return Plugin_Continue;
}

/*public void SendMessage(int client, bool all)
{
	if(IsClientInGame(i))
	{
	}
}*/


public void SendMessage(const char[] text, bool all, int client)
{
	//char text[256];
	char name[MAX_NAME_LENGTH] = "";
	GetClientName(client, name, sizeof(name));

	int team = GetClientTeam(client);

	//char teamName[32] = "";
	char teamColor[32] = "";

	switch(team)
	{
		case 1:
		{
			//Format(teamName, sizeof(teamName), "\x01%T", "Spectator", client);
			//Format(teamName, sizeof(teamName), "\x01%T")
			Format(teamColor, sizeof(teamColor), "\x07CCCCCC");
		}

		case 2:
		{
			//Format(teamName, sizeof(teamName), "\x01%T", "Terrorist", client);
			Format(teamColor, sizeof(teamColor), "\x07FF4040");
		}

		case 3:
		{
			//Format(teamName, sizeof(teamName), "\x01%T", "Counter-Terrorist", client);
			Format(teamColor, sizeof(teamColor), "\x0799CCFF");
		}
	}

	//Format(text, 256, "\x01%T", "Hello", client, "FakeExpert", name, teamName);
	char textReplaced[256] = "";
	Format(textReplaced, sizeof(textReplaced), "\x01%s", text);

	ReplaceString(textReplaced, sizeof(textReplaced), ";#", "\x07");
	ReplaceString(textReplaced, sizeof(textReplaced), "{default}", "\x01");
	ReplaceString(textReplaced, sizeof(textReplaced), "{teamcolor}", teamColor);

	if(all == true)
	{
		PrintToChatAll("%s", textReplaced);
	}

	else if(all == false)
	{
		if(client > 0 && IsClientInGame(client) == true)
		{
			PrintToChat(client, "%s", textReplaced);
		}
	}

	#if debug true
	//PrintToChat(client, "%i MessageDebug", client)
	#endif
	return;
}
