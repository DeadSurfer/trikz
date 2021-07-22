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
#pragma semicolon 1
#pragma newdecls optional

char RADIO_PLAYER_URL[] = "http://hive365.co.uk/plugin/player/player_manual.html";

public Plugin myinfo = 
{
	name = "Hive365 Player",
	author = "Hive365.co.uk, simplified version by Smesh",
	description = "Hive365 In-Game Radio Player",
	version = "0.1",
	url = "http://www.hive365.co.uk"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_radio", CMD_radio);
}

Action CMD_radio(int client, int args)
{
	char sURL[sizeof(RADIO_PLAYER_URL) + 15];
	Format(sURL, sizeof(sURL), RADIO_PLAYER_URL);
	LoadMOTDPanel(client, "Hive365", sURL, true);
	
	return Plugin_Handled;
}

void LoadMOTDPanel(int client, const char[] title, const char[] page, bool display)
{
	if(client > 0  || IsClientInGame(client))
	{
		KeyValues kv = new KeyValues("data");
		kv.SetString("title", title);
		kv.SetNum("type", MOTDPANEL_TYPE_URL);
		kv.SetString("msg", page);
		ShowVGUIPanel(client, "info", kv, display);
		delete kv;
	}
}
