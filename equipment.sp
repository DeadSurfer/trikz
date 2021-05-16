#include <sdktools>
#include <morecolors>

char gS_CMD_Weaponmenu[][] = {"sm_equipment", "sm_e", "sm_weapon", "sm_weapons"}
//char gS_CMD_Weapon[][] = {"sm_scout", "sm_knife", "sm_glock", "sm_usp", "sm_flashbangs", "sm_flashbang"}
char gS_CMD_Weapon[][] = {"sm_knife", "sm_glock", "sm_usp", "sm_flashbangs", "sm_flashbang"}
int g_Cooldown[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "Equipment",
	author = "Smesh",
	description = "You can give yourself glock, usp, knife, flashbangs.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
}

public void OnPluginStart()
{
	for(int i = 0; i < sizeof(gS_CMD_Weaponmenu); i++)
	{
		RegConsoleCmd(gS_CMD_Weaponmenu[i], Command_weaponmenu, "Equipment menu")
	}
	for(int i = 0; i < sizeof(gS_CMD_Weapon); i++)
	{
		RegConsoleCmd(gS_CMD_Weapon[i], Command_Weapon, "Spawn weapon")
	}
}

Action Command_weaponmenu(int client, int args)
{
	if(!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{white}You must be alive to use this feature!")
		return Plugin_Handled
	}
	weaponmenu(client) //Open equipment menu
	return Plugin_Handled
}

void weaponmenu(int client)
{
	Menu menu = new Menu(weapon_MenuHandler)
	menu.SetTitle("Equipments menu\n ")
	menu.AddItem("sm_flash", "Give flashbangs\n ")
	menu.AddItem("sm_usp", "Give usp")
	menu.AddItem("sm_glock", "Give glock\n ")
	//menu.AddItem("sm_scout", "Give scout\n ")
	menu.AddItem("sm_knife", "Give knife")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.Display(client, MENU_TIME_FOREVER)
}

int weapon_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "sm_flash"))
			{
				FakeClientCommandEx(param1, "sm_flashbangs")
			}
			if(StrEqual(item, "sm_usp"))
			{
				FakeClientCommandEx(param1, "sm_usp")
			}
			if(StrEqual(item, "sm_glock"))
			{
				FakeClientCommandEx(param1, "sm_glock")
			}
			if(StrEqual(item, "sm_scout"))
			{
				FakeClientCommandEx(param1, "sm_scout")
			}
			if(StrEqual(item, "sm_knife"))
			{
				FakeClientCommandEx(param1, "sm_knife")
			}
			weaponmenu(param1)
		}
		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					FakeClientCommandEx(param1, "sm_trikz")
				}
			}
		}
		case MenuAction_End:
		{
			delete menu
		}
	}
	return view_as<int>(Plugin_Continue)
}

Action Command_Weapon(int client, int args)
{
	if(!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{white}You must be alive to use this feature!")
		return Plugin_Handled
	}
	else
	{
		int Time = GetTime()
		int iWeapon
		char sCommand[16]
		char sWeapon[32]
		GetCmdArg(0, sCommand, sizeof(sCommand))
		GetClientWeapon(client, sWeapon, sizeof(sWeapon))
		if(StrContains(sCommand, "flashbang") != -1)
		{
			if(StrContains(sWeapon, "flashbang") == -1)
			{
				if(Time - g_Cooldown[client] <= 5)
				{
					CPrintToChat(client, "{white}You can't do that now. Try again in a few seconds.")
					return Plugin_Handled
				}
				g_Cooldown[client] = Time
				iWeapon = GetPlayerWeaponSlot(client, 3)
				if(iWeapon != -1)
					RemovePlayerItem(client, iWeapon)
				iWeapon = GivePlayerItem(client, "weapon_flashbang")
				SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2)
				FakeClientCommand(client, "use weapon_flashbang")
				CPrintToChat(client, "{white}Successfully obtained a flashbangs.")
			}
			else
			{
				CPrintToChat(client, "{white}You already have a flashbangs.")
			}
		}
		if(StrContains(sCommand, "usp") != -1)
		{
			if(StrContains(sWeapon, "usp") == -1)
			{
				if(Time - g_Cooldown[client] <= 5)
				{
					CPrintToChat(client, "{white}You can't do that now. Try again in a few seconds.")
					return Plugin_Handled
				}
				g_Cooldown[client] = Time
				iWeapon = GetPlayerWeaponSlot(client, 1)
				if(iWeapon != -1)
					RemovePlayerItem(client, iWeapon)
				iWeapon = GivePlayerItem(client, "weapon_usp")
				SetEntProp(iWeapon, Prop_Data, "m_iClip1", 90)
				FakeClientCommand(client, "use weapon_usp")
				CPrintToChat(client, "{white}Successfully obtained a usp.")
			}
			else
			{
				CPrintToChat(client, "{white}You already have a usp.")
			}
		}
		if(StrContains(sCommand, "glock") != -1)
		{
			if(StrContains(sWeapon, "glock") == -1)
			{
				if(Time - g_Cooldown[client] <= 5)
				{
					CPrintToChat(client, "{white}You can't do that now. Try again in a few seconds.")
					return Plugin_Handled
				}
				g_Cooldown[client] = Time
				iWeapon = GetPlayerWeaponSlot(client, 1)
				if(iWeapon != -1)
					RemovePlayerItem(client, iWeapon)
				iWeapon = GivePlayerItem(client, "weapon_glock")
				SetEntProp(iWeapon, Prop_Data, "m_iClip1", 90)
				FakeClientCommand(client, "use weapon_glock")
				CPrintToChat(client, "{white}Successfully obtained a glock.")
			}
			else
			{
				CPrintToChat(client, "{white}You already have a glock.")
			}
		}
		if(StrContains(sCommand, "scout") != -1)
		{
			if(StrContains(sWeapon, "scout") == -1)
			{
				if(Time - g_Cooldown[client] <= 5)
				{
					CPrintToChat(client, "{white}You can't do that now. Try again in a few seconds.")
					return Plugin_Handled
				}
				g_Cooldown[client] = Time
				iWeapon = GetPlayerWeaponSlot(client, 0)
				if(iWeapon != -1)
					RemovePlayerItem(client, iWeapon)
				iWeapon = GivePlayerItem(client, "weapon_scout")
				SetEntProp(iWeapon, Prop_Data, "m_iClip1", 90)
				FakeClientCommand(client, "use weapon_scout")
				CPrintToChat(client, "{white}Successfully obtained a scout.")
			}
			else
			{
				CPrintToChat(client, "{white}You already have a scout.")
			}
		}
		if(StrContains(sCommand, "knife") != -1)
		{
			if(StrContains(sWeapon, "knife") == -1)
			{
				if(Time - g_Cooldown[client] <= 5)
				{
					CPrintToChat(client, "{white}You can't do that now. Try again in a few seconds.")
					return Plugin_Handled
				}
				g_Cooldown[client] = Time
				iWeapon = GetPlayerWeaponSlot(client, 2)
				if(iWeapon != -1)
					RemovePlayerItem(client, iWeapon)
				iWeapon = GivePlayerItem(client, "weapon_knife")
				SetEntProp(iWeapon, Prop_Data, "m_iClip1", 90)
				FakeClientCommand(client, "use weapon_knife")
				CPrintToChat(client, "{white}Successfully obtained a knife.")
			}
			else
			{
				CPrintToChat(client, "{white}You already have a knife.")
			}
		}
	}
	return Plugin_Handled
}
