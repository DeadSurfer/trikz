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
public Plugin myinfo =
{
	name = "Visit announcement",
	author = "Smesh",
	description = "Always show connect, disconnect, team changes message in the chat.",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	HookEvent("player_connect_client", connect, EventHookMode_Pre)
	HookEvent("player_disconnect", disconnect, EventHookMode_Pre)
	HookEvent("player_team", teamjoin, EventHookMode_Pre)
}

Action connect(Event event, const char[] name, bool dontBroadcast)
{
	char sName[MAX_NAME_LENGTH]
	event.GetString("name", sName, MAX_NAME_LENGTH)
	PrintToChatAll("Player %s has joined the game", sName)
	SetEventBroadcast(event, true)
}

Action disconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	char reason[32]
	event.GetString("reason", reason, 32)
	PrintToChatAll("Player %N left the game (%s)", client, reason)
	SetEventBroadcast(event, true)
}

Action teamjoin(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	int team = event.GetInt("team")
	switch(team)
	{
		case 1:
			PrintToChatAll("%N is joining the Spectators", client)
		case 2:
			PrintToChatAll("%N is joining the Terrorist force", client)
		case 3:
			PrintToChatAll("%N is joining the Counter-Terrorist force", client)
	}
	SetEventBroadcast(event, true)
}
