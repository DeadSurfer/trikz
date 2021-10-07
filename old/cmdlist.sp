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
char gS_CMD[][] = {"sm_cmd", "sm_cmds", "sm_commands", "sm_command", "sm_help"}

public Plugin myinfo =
{
	name = "Command-list",
	author = "Smesh",
	description = "You can check all plugin commands.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
}

public void OnPluginStart()
{
	for(int i = 0; i < sizeof(gS_CMD); i++)
		RegConsoleCmd(gS_CMD[i], Command_CMD, "List of command")
}

Action Command_CMD(int client, int args)
{	
	Menu menu = new Menu(CMD_Chooser)
	menu.SetTitle("Choose a category of commands\n ")
	menu.AddItem("sm_timer", "Commands of timer")
	menu.AddItem("sm_statistics", "Commands of statistics")
	menu.AddItem("sm_miscellaneous", "Commands of miscellaneous")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.Display(client, MENU_TIME_FOREVER)
	return Plugin_Handled
}

void Command_CMD_Timer(int client, int item)
{	
	Menu menu = new Menu(CMD_Timer)
	menu.SetTitle("Commands of timer\n ")
	menu.AddItem("0", "Go to start. Usage: /s /r /m")
	menu.AddItem("1", "Go to bonus start. Usage: /b")
	menu.AddItem("2", "Go to solobonus start. Usage: /sb")
	menu.AddItem("3", "Go to end. Usage: /end")
	menu.AddItem("4", "Go to bonus end. Usage: /bend")
	menu.AddItem("5", "Go to solobonus end. Usage: /sbend")
	menu.AddItem("6", "Choose your bhop style. Usage: /style")
	menu.AddItem("7", "Stop your timer. Usage: /stop")
	menu.AddItem("8", "Toggle pause. Usage: /pause")
	menu.AddItem("9", "View the leaderboard of a map. Usage: /wr map_name")
	menu.AddItem("10", "View the recent #1 times set. Usage: /rr")
	menu.AddItem("11", "Show the player's profile. Usage: /profile [target]")
	menu.AddItem("12", "Show maps that the player has finished. Usage: /mapsdone [target]")
	menu.AddItem("13", "Show maps that the player has not finished yet. Usage: /mapsleft [target]")
	menu.AddItem("14", "Opens the bot menu. Usage: /replay")
	menu.AddItem("15", "Prints the map's tier to chat. Usage: /tier alias")
	menu.AddItem("16", "Show your or someone else's rank. Usage: /rank [name]")
	menu.AddItem("17", "Show the top 100 players. Usage: /top")
	menu.AddItem("18", "Show a list of spectators. Usage: /specs")
	menu.AddItem("19", "Opens the HUD settings menu. Usage: /hud")
	menu.AddItem("20", "View a menu with all the obtainable chat ranks. Usage: /ranks")
	menu.AddItem("21", "Opens partner selector. Usage: /p")
	menu.AddItem("22", "Opens partnership disabler. Usage: /unp")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.DisplayAt(client, item, MENU_TIME_FOREVER)
}

void Command_CMD_Statistics(int client)
{	
	Menu menu = new Menu(CMD_Statistics)
	menu.SetTitle("Commands of statistics\n ")
	menu.AddItem("0", "Toggle jump stats. Usage: /js /lj")
	menu.AddItem("1", "Toggle mega long stats. Usage: mls")
	menu.AddItem("2", "Toggle run boost stats. Usage: /rbs")
	menu.AddItem("3", "Toggle boost stats. Usage: /bs /ts")
	menu.AddItem("4", "Toggle angles check. Usage: /ac")
	menu.AddItem("5", "Toggle button announcer. Usage: /button")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.Display(client, MENU_TIME_FOREVER)
}

void Command_CMD_Miscellaneous(int client, int item)
{	
	Menu menu = new Menu(CMD_Miscellaneous)
	menu.SetTitle("Commands of miscellaneous\n ")
	menu.AddItem("0", "Opens equipments menu. Usage: /e")
	menu.AddItem("1", "Toggle blocking. Usage: /bl")
	menu.AddItem("2", "Opens checkpoints menu. Usage: /cp")
	menu.AddItem("3", "Opens teleport to player menu. Usage: /tp")
	menu.AddItem("4", "Toggle hide. Usage: /hide")
	menu.AddItem("5", "Toggle noclip. Usage: /nc")
	menu.AddItem("6", "Toggle viewmodel. Usage: /vm")
	menu.AddItem("7", "Toggle autoswitch. Usage: /as")
	menu.AddItem("8", "Toggle autoflash. Usage: /af")
	menu.AddItem("9", "Toggle bunnyhopping. Usage: /bhop")
	menu.AddItem("10", "Toggle sound of hurting. Usage: /hurt")
	menu.AddItem("11", "Join the Spectators. Usage: /sp")
	menu.AddItem("12", "Opens flashbang preference. Usage: /fl")
	menu.AddItem("13", "Opens skin preferences. Usage: /skin")
	menu.AddItem("14", "Toggle showtriggers. Usage: /st")
	menu.AddItem("15", "Opens rate checker. Usage: /rate [name]")
	menu.AddItem("16", "Can be helped while stuck. Usage: /stuck")
	menu.AddItem("17", "Opens radio menu. Usage: /radio")
	menu.AddItem("18", "Opens trikz menu. Usage: /t")
	menu.AddItem("19", "Opens list of commands menu. Usage: /cmd")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.DisplayAt(client, item, MENU_TIME_FOREVER)
}

int CMD_Chooser(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "sm_timer"))
				Command_CMD_Timer(param1, 0)
			if(StrEqual(item, "sm_statistics"))
				Command_CMD_Statistics(param1)
			if(StrEqual(item, "sm_miscellaneous"))
				Command_CMD_Miscellaneous(param1, 0)
		}
		case MenuAction_Cancel:
			switch(param2)
			{
				case MenuCancel_ExitBack:
					FakeClientCommandEx(param1, "sm_trikz")
			}
		case MenuAction_End:
			delete menu
	}
	
	return view_as<int>(Plugin_Continue)
}

int CMD_Timer(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "0"))
				FakeClientCommandEx(param1, "sm_r")
			if(StrEqual(item, "1"))
				FakeClientCommandEx(param1, "sm_b")
			if(StrEqual(item, "2"))
				FakeClientCommandEx(param1, "sm_sb")
			if(StrEqual(item, "3"))
				FakeClientCommandEx(param1, "sm_end")
			if(StrEqual(item, "4"))
				FakeClientCommandEx(param1, "sm_bend")
			if(StrEqual(item, "5"))
				FakeClientCommandEx(param1, "sm_sbend")
			if(StrEqual(item, "6"))
				FakeClientCommandEx(param1, "sm_style")
			if(StrEqual(item, "7"))
				FakeClientCommandEx(param1, "sm_stop")
			if(StrEqual(item, "8"))
				FakeClientCommandEx(param1, "sm_pause")
			if(StrEqual(item, "9"))
				FakeClientCommandEx(param1, "sm_wr")
			if(StrEqual(item, "10"))
				FakeClientCommandEx(param1, "sm_rr")
			if(StrEqual(item, "11"))
				FakeClientCommandEx(param1, "sm_profile")
			if(StrEqual(item, "12"))
				FakeClientCommandEx(param1, "sm_mapsdone")
			if(StrEqual(item, "13"))
				FakeClientCommandEx(param1, "sm_mapsleft")
			if(StrEqual(item, "14"))
				FakeClientCommandEx(param1, "sm_replay")
			if(StrEqual(item, "15"))
				FakeClientCommandEx(param1, "sm_tier")
			if(StrEqual(item, "16"))
				FakeClientCommandEx(param1, "sm_rank")
			if(StrEqual(item, "17"))
				FakeClientCommandEx(param1, "sm_top")
			if(StrEqual(item, "18"))
				FakeClientCommandEx(param1, "sm_specs")
			if(StrEqual(item, "19"))
				FakeClientCommandEx(param1, "sm_hud")
			if(StrEqual(item, "20"))
				FakeClientCommandEx(param1, "sm_ranks")
			if(StrEqual(item, "21"))
				FakeClientCommandEx(param1, "sm_p")
			if(StrEqual(item, "22"))
				FakeClientCommandEx(param1, "sm_unp")
			Command_CMD_Timer(param1, GetMenuSelectionPosition())
		}
		
		case MenuAction_Cancel:
			switch(param2)
			{
				case MenuCancel_ExitBack:
					Command_CMD(param1, 1)
			}
		case MenuAction_End:
			delete menu
	}
	
	return view_as<int>(Plugin_Continue)
}

int CMD_Statistics(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "0"))
				FakeClientCommandEx(param1, "sm_js")
			if(StrEqual(item, "1"))
				FakeClientCommandEx(param1, "sm_mls")
			if(StrEqual(item, "2"))
				FakeClientCommandEx(param1, "sm_rbs")
			if(StrEqual(item, "3"))
				FakeClientCommandEx(param1, "sm_bs")
			if(StrEqual(item, "4"))
				FakeClientCommandEx(param1, "sm_ac")
			if(StrEqual(item, "5"))
				FakeClientCommandEx(param1, "sm_button")
			Command_CMD_Statistics(param1)
		}
		case MenuAction_Cancel:
			switch(param2)
			{
				case MenuCancel_ExitBack:
					Command_CMD(param1, 1)
			}
		case MenuAction_End:
			delete menu
	}
	return view_as<int>(Plugin_Continue)
}

int CMD_Miscellaneous(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "0"))
				FakeClientCommandEx(param1, "sm_e")
			if(StrEqual(item, "1"))
				FakeClientCommandEx(param1, "sm_bl")
			if(StrEqual(item, "2"))
				FakeClientCommandEx(param1, "sm_cp")
			if(StrEqual(item, "3"))
				FakeClientCommandEx(param1, "sm_tp")
			if(StrEqual(item, "4"))
				FakeClientCommandEx(param1, "sm_hide")
			if(StrEqual(item, "5"))
				ClientCommand(param1, "sm_nc")
			if(StrEqual(item, "6"))
				FakeClientCommandEx(param1, "sm_vm")
			if(StrEqual(item, "7"))
				FakeClientCommandEx(param1, "sm_as")
			if(StrEqual(item, "8"))
				FakeClientCommandEx(param1, "sm_af")
			if(StrEqual(item, "9"))
				FakeClientCommandEx(param1, "sm_bhop")
			if(StrEqual(item, "10"))
				FakeClientCommandEx(param1, "sm_hurt")
			if(StrEqual(item, "11"))
				FakeClientCommandEx(param1, "sm_sp")
			if(StrEqual(item, "12"))
				FakeClientCommandEx(param1, "sm_fl")
			if(StrEqual(item, "13"))
				FakeClientCommandEx(param1, "sm_skin")
			if(StrEqual(item, "14"))
				FakeClientCommandEx(param1, "sm_st")
			if(StrEqual(item, "15"))
				FakeClientCommandEx(param1, "sm_rate")
			if(StrEqual(item, "16"))
				FakeClientCommandEx(param1, "sm_stuck")
			if(StrEqual(item, "17"))
				FakeClientCommandEx(param1, "sm_radio")
			if(StrEqual(item, "18"))
				FakeClientCommandEx(param1, "sm_t")
			if(StrEqual(item, "19"))
				FakeClientCommandEx(param1, "sm_cmd")
			Command_CMD_Miscellaneous(param1, GetMenuSelectionPosition())
		}
		case MenuAction_Cancel:
			switch(param2)
			{
				case MenuCancel_ExitBack:
					Command_CMD(param1, 1)
			}
		case MenuAction_End:
			delete menu
	}
	return view_as<int>(Plugin_Continue)
}
