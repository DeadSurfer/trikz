bool gB_block[MAXPLAYERS + 1]
bool gB_partner[MAXPLAYERS + 1]

public void OnPluginStart()
{
	RegConsoleCmd("sm_t", cmd_trikz)
	RegConsoleCmd("sm_tr", cmd_trikz)
	RegConsoleCmd("sm_tri", cmd_trikz)
	RegConsoleCmd("sm_trik", cmd_trikz)
	RegConsoleCmd("sm_trikz", cmd_trikz)
	RegConsoleCmd("sm_b", cmd_block)
	RegConsoleCmd("sm_bl", cmd_block)
	RegConsoleCmd("sm_blo", cmd_block)
	RegConsoleCmd("sm_bloc", cmd_block)
	RegConsoleCmd("sm_block", cmd_block)
	RegConsoleCmd("sm_p", cmd_partner)
	RegConsoleCmd("sm_pa", cmd_partner)
	RegConsoleCmd("sm_par", cmd_partner)
	RegConsoleCmd("sm_part", cmd_partner)
	RegConsoleCmd("sm_partn", cmd_partner)
	RegConsoleCmd("sm_partne", cmd_partner)
	RegConsoleCmd("sm_partner", cmd_partner)
}

void OnClientPutInServer(int client)
{
	gB_partner[client] = 0
	gB_partner[gB_partner[client]] = 0
}

Action cmd_trikz(int client, int args)
{
	Trikz(client)
}

void Trikz(int client)
{
	Menu menu = new Menu(trikz_handler)
	menu.SetTitle("Trikz")
	menu.AddItem("block", "Block")
	menu.AddItem("partner", "Partner")
	menu.AddItem("restart", "Restart")
	menu.Display(client, 20)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	
}

Action cmd_block(int client, int args)
{
	Block(client)
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

Action cmd_partner(int client, int args)
{
	Partner(client)
}

void Partner(int client)
{
	Menu menu = new Menu(partner_handler)
	menu.SetTitle("Choose partner")
	char sName[MAX_NAME_LENGTH]
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
		{
			GetClientName(i, sName, MAX_NAME_LENGTH)
			char sNameID[32]
			IntToString(i, sNameID, 32)
			menu.AddItem(sNameID, sName)
		}
	}
	menu.Display(client, 20)
}

int partner_handler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[32]
			menu.GetItem(param2, sItem, 32)
			int partner = StringToInt(sItem)
			Menu menu = new Menu(askpartner_handle)
			menu.SetTitle("Agree partner with %N?", param1)
			menu.AddItem(sItem, "Yes")
			menu.AddItem(sItem, "No")
			menu.Display(partner, 20)
		}
	}
}

int askpartner_handle(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[32]
			menu.GetItem(param2, sItem, 32)
			int partner = StringToInt(sItem)
			switch(param2)
			{
				case 0:
				{
					if(gB_partner[partner] == 0)
					{
						gB_partner[param1] = partner
						gB_partner[partner] = param1
						PrintToChat(param1, "Partnersheep agreed with %N.", partner)
					}
					else
					{
						PrintToChat(param1, "A player already have a partner.")
					}
				}
				case 1:
				{
					PrintToChat(param1, "Partnersheep declined with %N.", partner)
				}
			}
		}
	}
}
