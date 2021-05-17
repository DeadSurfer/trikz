#include <sdktools>
#include <sdkhooks>

bool gB_block[MAXPLAYERS + 1]
int gI_partner[MAXPLAYERS + 1]

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
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			OnClientPutInServer(i)
}

public void OnClientPutInServer(int client)
{
	gI_partner[client] = 0
	gI_partner[gI_partner[client]] = 0
	SDKHook(client, SDKHook_SpawnPost, SDKPlayerSpawn)
}

Action cmd_trikz(int client, int args)
{
	Trikz(client)
}

void Trikz(int client)
{
	Menu menu = new Menu(trikz_handler)
	menu.SetTitle("Trikz")
	char sDisplay[32]
	Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
	menu.AddItem("block", sDisplay)
	Format(sDisplay, 32, gI_partner[client] ? "Cancel partnership" : "Select partner")
	menu.AddItem("partner", sDisplay)
	menu.AddItem("restart", "Restart")
	menu.Display(client, 20)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					Block(param1)
					Trikz(param1)
				}
				case 1:
				{
					Partner(param1)
				}
			}
		}
	}
}

Action cmd_block(int client, int args)
{
	Block(client)
}

Action Block(int client)
{
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
		SetEntityRenderMode(client, RENDER_TRANSALPHA)
		SetEntityRenderColor(client, 255, 255, 255, 75)
		gB_block[client] = false
		return Plugin_Handled
	}
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		gB_block[client] = true
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action cmd_partner(int client, int args)
{
	Partner(client)
}

void Partner(int client)
{
	if(gI_partner[client] == 0)
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
	else
	{
		Menu menu = new Menu(cancelpartner_handler)
		menu.SetTitle("Cancel partnership")
		char sName[MAX_NAME_LENGTH]
		GetClientName(gI_partner[client], sName, MAX_NAME_LENGTH)
		char sPartner[32]
		IntToString(gI_partner[client], sPartner, 32)
		menu.AddItem(sPartner, "Yes")
		menu.AddItem("", "No")
		menu.Display(client, 20)
	}
}

int partner_handler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[32]
			menu.GetItem(param2, sItem, 32)
			int partner = StringToInt(sItem)
			Menu menu2 = new Menu(askpartner_handle)
			menu2.SetTitle("Agree partner with %N?", param1)
			menu2.AddItem(sItem, "Yes")
			menu2.AddItem(sItem, "No")
			menu2.Display(partner, 20)
		}
	}
}

int askpartner_handle(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
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
					if(gI_partner[partner] == 0)
					{
						gI_partner[param1] = partner
						gI_partner[partner] = param1
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

int cancelpartner_handler(Menu menu, MenuAction action, int param1, int param2)
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
					gI_partner[param1] = 0
					gI_partner[partner] = 0
					PrintToChat(param1, "Partnership is canceled with %N", partner)
				}
				case 1:
				{
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(buttons & IN_JUMP && !(GetEntityFlags(client) & FL_ONGROUND) && IsPlayerAlive(client)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags
	{
		buttons &= ~IN_JUMP //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	StrContains(classname, "projectile")
	{
		SDKHook(entity, SDKHook_Spawn, SDKProjectile)
	}
}

Action SDKProjectile(int entity)
{
	PrintToServer("projectile")
}

void SDKPlayerSpawn(int client)
{
	GivePlayerItem(client, "weapon_flashbang")
	SetEntProp(client, Prop_Data, "m_iAmmo", 12 * 4, 2) //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
	for(int i = 0; i <= 128; i++)
		SetEntProp(client, Prop_Data, "m_iAmmo", i, 2)
	//PrintToServer("%N", client)
	//GivePlayerAmmo(client, 2, 48, true)
	RequestFrame(frame, client)
}

void frame(int client)
{
	RequestFrame(frame2, client)
	//for(int i = 0; i <= 128; i++)
	SetEntProp(client, Prop_Data, "m_iAmmo", 12 * 4, 2)
}

void frame2(int client)
{
	//for(int i = 0; i <= 128; i++)
	SetEntProp(client, Prop_Data, "m_iAmmo", 12 * 4, 2)
	//SetEntData(client, FindDataMapInfo(client, "m_iAmmo"), 12 * 4, 2)
}
