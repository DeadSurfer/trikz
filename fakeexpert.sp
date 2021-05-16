bool gB_block[MAXPLAYERS + 1]
bool gB_partner[MAXPLAYERS + 1]

public void OnPluginStart()
{
	RegConsoleCmd("sm_t", cmd_trikz)
	RegConsoleCmd("sm_tr", cmd_trikz)
	RegConsoleCmd("sm_tri", cmd_trikz)
	RegConsoleCmd("sm_trik", cmd_trikz)
	RegConsoleCmd("sm_trikz", cmd_trikz)
}

Action cmd_trikz(int client, int args)
{
	Trikz()
}

void Trikz()
{
	Menu menu = new Menu(trikz_handler)
	menu.SetTitle("Trikz")
	menu.AddItem("block", "Block")
	menu.AddItem("partner", "Partner")
	menu.AddItem("restart" "Restart")
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	
}

void Block(int client)
{
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
	}
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
	}
}

void Partner(int client)
{
	Menu menu = new Menu(partner_handler)
	menu.SetTitle("Choose partner")
	char sName[MAX_NAME_LENGTH]
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsPlayerAlive(i) && !IsFakeClient(i))
		{
			GetClientName(i, sName, MAX_NAME_LENGTH)
			menu.AddItem("player", sName)
		}
	}
}
