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
