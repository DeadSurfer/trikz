/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Basic Commands Plugin
 * Implements basic admin commands.
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative 1works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#pragma newdecls required

public Plugin myinfo =
{
	name = "Basic Commands",
	author = "AlliedModders LLC",
	description = "Basic Admin Commands",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

TopMenu hTopMenu;

Menu g_MapList;
StringMap g_ProtectedVars;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");
	LoadTranslations("playercommands.phrases");
	LoadTranslations("funcommands.phrases");

	//RegAdminCmd("sm_slay", Command_Slay, ADMFLAG_SLAY, "sm_slay <#userid|name>");
	RegAdminCmd("sm_kick", Command_Kick, ADMFLAG_KICK, "sm_kick <#userid|name> [reason]");
	RegAdminCmd("sm_map", Command_Map, ADMFLAG_CHANGEMAP, "sm_map <map>");
	RegAdminCmd("sm_rcon", Command_Rcon, ADMFLAG_RCON, "sm_rcon <args>");
	RegAdminCmd("sm_cvar", Command_Cvar, ADMFLAG_CONVARS, "sm_cvar <cvar> [value]");
	RegAdminCmd("sm_resetcvar", Command_ResetCvar, ADMFLAG_CONVARS, "sm_resetcvar <cvar>");
	RegAdminCmd("sm_who", Command_Who, ADMFLAG_GENERIC, "sm_who [#userid|name]");
	RegAdminCmd("sm_reloadadmins", Command_ReloadAdmins, ADMFLAG_BAN, "sm_reloadadmins");
	RegAdminCmd("sm_cancelvote", Command_CancelVote, ADMFLAG_VOTE, "sm_cancelvote");
	RegAdminCmd("sm_noclip", Command_NoClip, ADMFLAG_SLAY|ADMFLAG_CHEATS, "sm_noclip <#userid|name>");
	RegConsoleCmd("sm_revote", Command_ReVote);
	
	/* Account for late loading */
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}
	
	g_MapList = new Menu(MenuHandler_ChangeMap, MenuAction_Display);
	g_MapList.SetTitle("%T", "Please select a map", LANG_SERVER);
	g_MapList.ExitBackButton = true;
	
	char mapListPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, mapListPath, sizeof(mapListPath), "configs/adminmenu_maplist.ini");
	SetMapListCompatBind("sm_map menu", mapListPath);
	
	g_ProtectedVars = new StringMap();
	ProtectVar("rcon_password");
	ProtectVar("sm_show_activity");
	ProtectVar("sm_immunity_mode");
}

public void OnConfigsExecuted()
{
	LoadMapList(g_MapList);
}

void ProtectVar(const char[] cvar)
{
	g_ProtectedVars.SetValue(cvar, 1);
}

bool IsVarProtected(const char[] cvar)
{
	int dummy_value;
	return g_ProtectedVars.GetValue(cvar, dummy_value);
}

bool IsClientAllowedToChangeCvar(int client, const char[] cvarname)
{
	ConVar hndl = FindConVar(cvarname);

	bool allowed = false;
	int client_flags = client == 0 ? ADMFLAG_ROOT : GetUserFlagBits(client);
	
	if (client_flags & ADMFLAG_ROOT)
	{
		allowed = true;
	}
	else
	{
		if (hndl.Flags & FCVAR_PROTECTED)
		{
			allowed = ((client_flags & ADMFLAG_PASSWORD) == ADMFLAG_PASSWORD);
		}
		else if (StrEqual(cvarname, "sv_cheats"))
		{
			allowed = ((client_flags & ADMFLAG_CHEATS) == ADMFLAG_CHEATS);
		}
		else if (!IsVarProtected(cvarname))
		{
			allowed = true;
		}
	}

	return allowed;
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	/* Build the "Player Commands" category */
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);
	
	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		//hTopMenu.AddItem("sm_slay", AdminMenu_Slay, player_commands, "sm_slay", ADMFLAG_SLAY);
		hTopMenu.AddItem("sm_kick", AdminMenu_Kick, player_commands, "sm_kick", ADMFLAG_KICK);
		hTopMenu.AddItem("sm_who", AdminMenu_Who, player_commands, "sm_who", ADMFLAG_GENERIC);
		hTopMenu.AddItem("sm_noclip", AdminMenu_NoClip, player_commands, "sm_noclip", ADMFLAG_SLAY);
	}

	TopMenuObject server_commands = hTopMenu.FindCategory(ADMINMENU_SERVERCOMMANDS);

	if (server_commands != INVALID_TOPMENUOBJECT)
	{
		hTopMenu.AddItem("sm_reloadadmins", AdminMenu_ReloadAdmins, server_commands, "sm_reloadadmins", ADMFLAG_BAN);
		hTopMenu.AddItem("sm_map", AdminMenu_Map, server_commands, "sm_map", ADMFLAG_CHANGEMAP);	
	}

	TopMenuObject voting_commands = hTopMenu.FindCategory(ADMINMENU_VOTINGCOMMANDS);

	if (voting_commands != INVALID_TOPMENUOBJECT)
	{
		hTopMenu.AddItem("sm_cancelvote", AdminMenu_CancelVote, voting_commands, "sm_cancelvote", ADMFLAG_VOTE);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "adminmenu") == 0)
	{
		hTopMenu = null;
	}
}

#define FLAG_STRINGS		14
char g_FlagNames[FLAG_STRINGS][20] =
{
	"res",
	"admin",
	"kick",
	"ban",
	"unban",
	"slay",
	"map",
	"cvars",
	"cfg",
	"chat",
	"vote",
	"pass",
	"rcon",
	"cheat"
};

int CustomFlagsToString(char[] buffer, int maxlength, int flags)
{
	char joins[6][6];
	int total;
	
	for (int i=view_as<int>(Admin_Custom1); i<=view_as<int>(Admin_Custom6); i++)
	{
		if (flags & (1<<i))
		{
			IntToString(i - view_as<int>(Admin_Custom1) + 1, joins[total++], 6);
		}
	}
	
	ImplodeStrings(joins, total, ",", buffer, maxlength);
	
	return total;
}

void FlagsToString(char[] buffer, int maxlength, int flags)
{
	char joins[FLAG_STRINGS+1][32];
	int total;

	for (int i=0; i<FLAG_STRINGS; i++)
	{
		if (flags & (1<<i))
		{
			strcopy(joins[total++], 32, g_FlagNames[i]);
		}
	}
	
	char custom_flags[32];
	if (CustomFlagsToString(custom_flags, sizeof(custom_flags), flags))
	{
		Format(joins[total++], 32, "custom(%s)", custom_flags);
	}

	ImplodeStrings(joins, total, ", ", buffer, maxlength);
}

Action Command_Cvar(int client, int args)
{
	if (args < 1)
	{
		if (client == 0)
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <cvar|protect> [value]");
		}
		else
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <cvar> [value]");
		}
		return Plugin_Handled;
	}

	char cvarname[64];
	GetCmdArg(1, cvarname, sizeof(cvarname));
	
	if (client == 0 && StrEqual(cvarname, "protect"))
	{
		if (args < 2)
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <protect> <cvar>");
			return Plugin_Handled;
		}
		GetCmdArg(2, cvarname, sizeof(cvarname));
		ProtectVar(cvarname);
		ReplyToCommand(client, "[SM] %t", "Cvar is now protected", cvarname);
		return Plugin_Handled;
	}

	ConVar hndl = FindConVar(cvarname);
	if (hndl == null)
	{
		ReplyToCommand(client, "[SM] %t", "Unable to find cvar", cvarname);
		return Plugin_Handled;
	}

	if (!IsClientAllowedToChangeCvar(client, cvarname))
	{
		ReplyToCommand(client, "[SM] %t", "No access to cvar");
		return Plugin_Handled;
	}

	char value[255];
	if (args < 2)
	{
		hndl.GetString(value, sizeof(value));

		ReplyToCommand(client, "[SM] %t", "Value of cvar", cvarname, value);
		return Plugin_Handled;
	}

	GetCmdArg(2, value, sizeof(value));
	
	// The server passes the values of these directly into ServerCommand, following exec. Sanitize.
	if (StrEqual(cvarname, "servercfgfile", false) || StrEqual(cvarname, "lservercfgfile", false))
	{
		int pos = StrContains(value, ";", true);
		if (pos != -1)
		{
			value[pos] = '\0';
		}
	}

	if ((hndl.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED)
	{
		ShowActivity2(client, "[SM] ", "%t", "Cvar changed", cvarname, value);
	}
	else
	{
		ReplyToCommand(client, "[SM] %t", "Cvar changed", cvarname, value);
	}

	LogAction(client, -1, "\"%L\" changed cvar (cvar \"%s\") (value \"%s\")", client, cvarname, value);

	hndl.SetString(value, true);

	return Plugin_Handled;
}

Action Command_ResetCvar(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_resetcvar <cvar>");

		return Plugin_Handled;
	}

	char cvarname[64];
	GetCmdArg(1, cvarname, sizeof(cvarname));
	
	ConVar hndl = FindConVar(cvarname);
	if (hndl == null)
	{
		ReplyToCommand(client, "[SM] %t", "Unable to find cvar", cvarname);
		return Plugin_Handled;
	}
	
	if (!IsClientAllowedToChangeCvar(client, cvarname))
	{
		ReplyToCommand(client, "[SM] %t", "No access to cvar");
		return Plugin_Handled;
	}

	hndl.RestoreDefault();

	char value[255];
	hndl.GetString(value, sizeof(value));

	if ((hndl.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED)
	{
		ShowActivity2(client, "[SM] ", "%t", "Cvar changed", cvarname, value);
	}
	else
	{
		ReplyToCommand(client, "[SM] %t", "Cvar changed", cvarname, value);
	}

	LogAction(client, -1, "\"%L\" reset cvar (cvar \"%s\") (value \"%s\")", client, cvarname, value);

	return Plugin_Handled;
}

Action Command_Rcon(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_rcon <args>");
		return Plugin_Handled;
	}

	char argstring[255];
	GetCmdArgString(argstring, sizeof(argstring));

	LogAction(client, -1, "\"%L\" console command (cmdline \"%s\")", client, argstring);

	if (client == 0) // They will already see the response in the console.
	{
		ServerCommand("%s", argstring);
	} else {
		char responseBuffer[4096];
		ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", argstring);
		ReplyToCommand(client, responseBuffer);
	}

	return Plugin_Handled;
}

Action Command_ReVote(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	if (!IsVoteInProgress())
	{
		ReplyToCommand(client, "[SM] %t", "Vote Not In Progress");
		return Plugin_Handled;
	}
	
	if (!IsClientInVotePool(client))
	{
		ReplyToCommand(client, "[SM] %t", "Cannot participate in vote");
		return Plugin_Handled;
	}
	
	if (!RedrawClientVoteMenu(client))
	{
		ReplyToCommand(client, "[SM] %t", "Cannot change vote");
	}
	
	return Plugin_Handled;
}

void PerformCancelVote(int client)
{
	if (!IsVoteInProgress())
	{
		ReplyToCommand(client, "[SM] %t", "Vote Not In Progress");
		return;
	}

	ShowActivity2(client, "[SM] ", "%t", "Cancelled Vote");
	
	CancelVote();
}
	
void AdminMenu_CancelVote(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Cancel vote", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		PerformCancelVote(param);
		RedisplayAdminMenu(topmenu, param);	
	}
	else if (action == TopMenuAction_DrawOption)
	{
		buffer[0] = IsVoteInProgress() ? ITEMDRAW_DEFAULT : ITEMDRAW_IGNORE;
	}
}

Action Command_CancelVote(int client, int args)
{
	PerformCancelVote(client);

	return Plugin_Handled;
}

void PerformKick(int client, int target, const char[] reason)
{
	LogAction(client, target, "\"%L\" kicked \"%L\" (reason \"%s\")", client, target, reason);

	if (reason[0] == '\0')
	{
		KickClient(target, "%t", "Kicked by admin");
	}
	else
	{
		KickClient(target, "%s", reason);
	}
}

void DisplayKickMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Kick);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "Kick player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	//AddTargetsToMenu(menu, client, false, false);
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void AdminMenu_Kick(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Kick player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayKickMenu(param);
	}
}

int MenuHandler_Kick(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			ShowActivity2(param1, "[SM] ", "%t", "Kicked target", "_s", name);
			PerformKick(param1, target, "");
		}
		
		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayKickMenu(param1);
		}
	}
}

Action Command_Kick(int client, int args)
{
	if (args < 1)
	{
		if ((GetCmdReplySource() == SM_REPLY_TO_CHAT) && (client != 0))
		{
			DisplayKickMenu(client);
		}
		else
		{
			ReplyToCommand(client, "[SM] Usage: sm_kick <#userid|name> [reason]");
		}
		
		return Plugin_Handled;
	}

	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));

	char arg[65];
	int len = BreakString(Arguments, arg, sizeof(arg));
	
	if (len == -1)
	{
		/* Safely null terminate */
		len = 0;
		Arguments[0] = '\0';
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client, 
			target_list, 
			MAXPLAYERS, 
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		char reason[64];
		Format(reason, sizeof(reason), Arguments[len]);

		if (tn_is_ml)
		{
			if (reason[0] == '\0')
			{
				ShowActivity2(client, "[SM] ", "%t", "Kicked target", target_name);
			}
			else
			{
				ShowActivity2(client, "[SM] ", "%t", "Kicked target reason", target_name, reason);
			}
		}
		else
		{
			if (reason[0] == '\0')
			{
				ShowActivity2(client, "[SM] ", "%t", "Kicked target", "_s", target_name);            
			}
			else
			{
				ShowActivity2(client, "[SM] ", "%t", "Kicked target reason", "_s", target_name, reason);
			}
		}
		
		int kick_self = 0;
		
		for (int i = 0; i < target_count; i++)
		{
			/* Kick everyone else first */
			if (target_list[i] == client)
			{
				kick_self = client;
			}
			else
			{
				PerformKick(client, target_list[i], reason);
			}
		}
		
		if (kick_self)
		{
			PerformKick(client, client, reason);
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}

	return Plugin_Handled;
}

int MenuHandler_ChangeMap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char map[PLATFORM_MAX_PATH];
		
		menu.GetItem(param2, map, sizeof(map));
	
		ShowActivity2(param1, "[SM] ", "%t", "Changing map", map);

		LogAction(param1, -1, "\"%L\" changed map to \"%s\"", param1, map);

		DataPack dp;
		CreateDataTimer(3.0, Timer_ChangeMap, dp);
		dp.WriteString(map);
	}
	else if (action == MenuAction_Display)
	{
		char title[128];
		Format(title, sizeof(title), "%T", "Please select a map", param1);

		Panel panel = view_as<Panel>(param2);
		panel.SetTitle(title);
	}
}

void AdminMenu_Map(TopMenu topmenu, 
							  TopMenuAction action,
							  TopMenuObject object_id,
							  int param,
							  char[] buffer,
							  int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Choose Map", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		g_MapList.Display(param, MENU_TIME_FOREVER);
	}
}

Action Command_Map(int client, int args)
{
	if (args < 1)
	{
		if ((GetCmdReplySource() == SM_REPLY_TO_CHAT) && (client != 0))
		{
			g_MapList.SetTitle("%T", "Choose Map", client);
			g_MapList.Display(client, MENU_TIME_FOREVER);
		}
		else 
		{
			ReplyToCommand(client, "[SM] Usage: sm_map <map>");
		}
		return Plugin_Handled;
	}

	char map[PLATFORM_MAX_PATH];
	char displayName[PLATFORM_MAX_PATH];
	GetCmdArg(1, map, sizeof(map));

	if (FindMap(map, displayName, sizeof(displayName)) == FindMap_NotFound)
	{
		ReplyToCommand(client, "[SM] %t", "Map was not found", map);
		return Plugin_Handled;
	}

	GetMapDisplayName(displayName, displayName, sizeof(displayName));

	ShowActivity2(client, "[SM] ", "%t", "Changing map", displayName);
	LogAction(client, -1, "\"%L\" changed map to \"%s\"", client, map);

	DataPack dp;
	CreateDataTimer(3.0, Timer_ChangeMap, dp);
	dp.WriteString(map);

	return Plugin_Handled;
}

Action Timer_ChangeMap(Handle timer, DataPack dp)
{
	char map[PLATFORM_MAX_PATH];

	dp.Reset();
	dp.ReadString(map, sizeof(map));

	ForceChangeLevel(map, "sm_map Command");

	return Plugin_Stop;
}

Handle g_map_array = null;
int g_map_serial = -1;

int LoadMapList(Menu menu)
{
	Handle map_array;
	
	if ((map_array = ReadMapList(g_map_array,
			g_map_serial,
			"sm_map menu",
			MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_MAPSFOLDER))
		!= null)
	{
		g_map_array = map_array;
	}
	
	if (g_map_array == null)
	{
		return 0;
	}
	
	menu.RemoveAllItems();
	
	char map_name[PLATFORM_MAX_PATH];
	int map_count = GetArraySize(g_map_array);
	
	for (int i = 0; i < map_count; i++)
	{
		GetArrayString(g_map_array, i, map_name, sizeof(map_name));
		menu.AddItem(map_name, map_name);
	}
	
	return map_count;
}

void PerformReloadAdmins(int client)
{
	/* Dump it all! */
	DumpAdminCache(AdminCache_Groups, true);
	DumpAdminCache(AdminCache_Overrides, true);

	LogAction(client, -1, "\"%L\" refreshed the admin cache.", client);
	ReplyToCommand(client, "[SM] %t", "Admin cache refreshed");
}

void AdminMenu_ReloadAdmins(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Reload admins", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		PerformReloadAdmins(param);
		RedisplayAdminMenu(topmenu, param);	
	}
}

Action Command_ReloadAdmins(int client, int args)
{
	PerformReloadAdmins(client);

	return Plugin_Handled;
}

void PerformWho(int client, int target, ReplySource reply, bool is_admin)
{
	char name[MAX_NAME_LENGTH];
	GetClientName(target, name, sizeof(name));
	
	bool show_name = false;
	char admin_name[MAX_NAME_LENGTH];
	AdminId id = GetUserAdmin(target);
	if (id != INVALID_ADMIN_ID && id.GetUsername(admin_name, sizeof(admin_name)))
	{
		show_name = true;
	}
	
	ReplySource old_reply = SetCmdReplySource(reply);
	
	if (id == INVALID_ADMIN_ID)
	{
		ReplyToCommand(client, "[SM] %t", "Player is not an admin", name);
	}
	else
	{
		if (!is_admin)
		{
			ReplyToCommand(client, "[SM] %t", "Player is an admin", name);
		}
		else
		{
			int flags = GetUserFlagBits(target);
			char flagstring[255];
			if (flags == 0)
			{
				strcopy(flagstring, sizeof(flagstring), "none");
			}
			else if (flags & ADMFLAG_ROOT)
			{
				strcopy(flagstring, sizeof(flagstring), "root");
			}
			else
			{
				FlagsToString(flagstring, sizeof(flagstring), flags);
			}
			
			if (show_name)
			{
				ReplyToCommand(client, "[SM] %t", "Admin logged in as", name, admin_name, flagstring);
			}
			else
			{
				ReplyToCommand(client, "[SM] %t", "Admin logged in anon", name, flagstring);
			}
		}
	}
	
	SetCmdReplySource(old_reply);
}

void DisplayWhoMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Who);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "Identify player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	//AddTargetsToMenu2(menu, 0, COMMAND_FILTER_CONNECTED);
	AddTargetsToMenu2(menu, 0, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void AdminMenu_Who(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Identify player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayWhoMenu(param);
	}
}

int MenuHandler_Who(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			PerformWho(param1, target, SM_REPLY_TO_CHAT, (GetUserFlagBits(param1) != 0 ? true : false));
		}
		
		/* Re-draw the menu if they're still valid */
		
		/* - Close the menu? redisplay? jump back up to the category?
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayWhoMenu(param1);
		}
		*/
	}
}

Action Command_Who(int client, int args)
{
	bool is_admin = false;
	
	if (!client || (client && GetUserFlagBits(client) != 0))
	{
		is_admin = true;
	}
	
	if (args < 1)
	{
		/* Display header */
		char t_access[16], t_name[16], t_username[16];
		Format(t_access, sizeof(t_access), "%T", "Admin access", client);
		Format(t_name, sizeof(t_name), "%T", "Name", client);
		Format(t_username, sizeof(t_username), "%T", "Username", client);

		if (is_admin)
		{
			PrintToConsole(client, "    %-24.23s %-18.17s %s", t_name, t_username, t_access);
		}
		else
		{
			PrintToConsole(client, "    %-24.23s %s", t_name, t_access);
		}

		/* List all players */
		char flagstring[255];

		for (int i=1; i<=MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}
			int flags = GetUserFlagBits(i);
			AdminId id = GetUserAdmin(i);
			if (flags == 0)
			{
				strcopy(flagstring, sizeof(flagstring), "none");
			}
			else if (flags & ADMFLAG_ROOT)
			{
				strcopy(flagstring, sizeof(flagstring), "root");
			}
			else
			{
				FlagsToString(flagstring, sizeof(flagstring), flags);
			}
			char name[MAX_NAME_LENGTH];
			char username[MAX_NAME_LENGTH];
			
			GetClientName(i, name, sizeof(name));
			
			if (id != INVALID_ADMIN_ID)
			{
				id.GetUsername(username, sizeof(username));
			}
			
			if (is_admin)
			{
				PrintToConsole(client, "%2d. %-24.23s %-18.17s %s", i, name, username, flagstring);
			}
			else
			{
				if (flags == 0)
				{
					PrintToConsole(client, "%2d. %-24.23s %t", i, name, "No");
				}
				else
				{
					PrintToConsole(client, "%2d. %-24.23s %t", i, name, "Yes");
				}
			}
		}

		if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
		{
			ReplyToCommand(client, "[SM] %t", "See console for output");
		}

		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	int target = FindTarget(client, arg, false, false);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	PerformWho(client, target, GetCmdReplySource(), is_admin);

	return Plugin_Handled;
}

/*void PerformSlay(int client, int target)
{
	LogAction(client, target, "\"%L\" slayed \"%L\"", client, target);
	ForcePlayerSuicide(target);
}

void DisplaySlayMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Slay);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "Slay player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu(menu, client, true, true);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void AdminMenu_Slay(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Slay player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplaySlayMenu(param);
	}
}

int MenuHandler_Slay(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu != null)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else if (!IsPlayerAlive(target))
		{
			ReplyToCommand(param1, "[SM] %t", "Player has since died");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformSlay(param1, target);
			ShowActivity2(param1, "[SM] ", "%t", "Slayed target", "_s", name);
		}
		
		DisplaySlayMenu(param1);
	}
}

Action Command_Slay(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_slay <#userid|name>");
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		PerformSlay(client, target_list[i]);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Slayed target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Slayed target", "_s", target_name);
	}

	return Plugin_Handled;
}*/

void PerformNoClip(int client, int target)
{
	MoveType movetype = GetEntityMoveType(target);

	if (movetype != MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(target, MOVETYPE_NOCLIP);
	}
	else
	{
		SetEntityMoveType(target, MOVETYPE_WALK);
	}
	
	LogAction(client, target, "\"%L\" toggled noclip on \"%L\"", client, target);
}

public void AdminMenu_NoClip(TopMenu topmenu, 
					  TopMenuAction action,
					  TopMenuObject object_id,
					  int param,
					  char[] buffer,
					  int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "NoClip player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayNoClipMenu(param);
	}
}

void DisplayNoClipMenu(int client)
{
	Menu menu = new Menu(MenuHandler_NoClip);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "NoClip player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	//AddTargetsToMenu(menu, client, true, true);
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_NoClip(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			
			PerformNoClip(param1, target);
			ShowActivity2(param1, "[SM] ", "%t", "Toggled noclip on target", "_s", name);
		}
		
		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayNoClipMenu(param1);
		}
	}
}

public Action Command_NoClip(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_noclip <#userid|name>");
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		PerformNoClip(client, target_list[i]);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Toggled noclip on target", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Toggled noclip on target", "_s", target_name);
	}
	
	return Plugin_Handled;
}
