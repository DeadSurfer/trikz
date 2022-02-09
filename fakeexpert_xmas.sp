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
#include <sdktools>
#include <sdkhooks>

char g_file[PLATFORM_MAX_PATH]
ConVar g_steamid
int g_hat[MAXPLAYERS + 1]
native int Trikz_GetClientPartner(int client)

public Plugin myinfo =
{
	name = "Xmas",
	author = "Nick Jurevics (Smesh, Smesh292)",
	description = "Snowman, gifts, big Christmas tree, Santa hat.",
	version = "1.0",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	g_steamid = CreateConVar("steamid", "", "Set steamid for control the plugin ex. 120192594. Use status to check your uniqueid, without 'U:1:'.")
	AutoExecConfig(true) //https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy)
	HookEvent("player_spawn", OnSpawn, EventHookMode_PostNoCopy)
	HookEvent("player_death", OnDeath, EventHookMode_PostNoCopy)
	HookEvent("player_team", OnTeam, EventHookMode_Pre) //https://forums.alliedmods.net/showthread.php?t=135521
	RegConsoleCmd("sm_xmas", cmd_xmas)
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			CreateHat(i)
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Trikz_GetClientPartner")
	return APLRes_Success
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			RemoveHat(i)
}

public void OnMapStart()
{
	char path[4][PLATFORM_MAX_PATH] = {"models/fakeexpert/xmas/", "models/fakeexpert/santahat/", "materials/fakeexpert/xmas/", "materials/fakeexpert/santahat/"}
	for(int i = 0; i < sizeof(path); i++)
	{
		DirectoryListing dir = OpenDirectory(path[i])
		char filename[4][PLATFORM_MAX_PATH]
		FileType type
		char pathFull[4][PLATFORM_MAX_PATH]
		while(dir.GetNext(filename[i], PLATFORM_MAX_PATH, type))
		{
			if(type == FileType_File)
			{
				Format(pathFull[i], PLATFORM_MAX_PATH, "%s%s", path[i], filename[i])
				if(StrContains(pathFull[i], ".mdl") != -1)
					PrecacheModel(pathFull[i], true)
				AddFileToDownloadsTable(pathFull[i])
			}
		}
		delete dir
	}
	char map[192]
	GetCurrentMap(map, 192)
	BuildPath(Path_SM, path[0], PLATFORM_MAX_PATH, "data/fakeexpert/")
	if(!DirExists(path[0]))
		CreateDirectory(path[0], 511)
	BuildPath(Path_SM, path[0], PLATFORM_MAX_PATH, "data/fakeexpert/xmas/")
	if(!DirExists(path[0]))
		CreateDirectory(path[0], 511)
	Format(g_file, PLATFORM_MAX_PATH, "%s%s.cfg", path[0], map)
}

public void OnClientDisconnect(int client)
{
	RemoveHat(client)
}

void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	KeyValues kv = new KeyValues("xmas")
	if(FileToKeyValues(kv, g_file) && kv.GotoFirstSubKey())
	{
		char nameKey[32]
		do
		{
			if(kv.GetSectionName(nameKey, 32))
			{
				float origin[3]
				float angles[3]
				char type[64]
				int skin
				kv.GetVector("origin", origin)
				kv.GetVector("angles", angles)
				kv.GetString("type", type, 64)
				skin = kv.GetNum("skin")
				CreateItem(origin, angles, type, skin)
			}
		}
		while(kv.GotoNextKey())
	}
	delete kv
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			RemoveHat(i)
			CreateHat(i)
		}
	}
}

void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	char model[PLATFORM_MAX_PATH]
	GetClientModel(client, model, PLATFORM_MAX_PATH)
	if(StrEqual(model, "models/player/ct_gsg9.mdl"))
		SetEntityModel(client, "models/player/ct_urban.mdl")
	else if(StrEqual(model, "models/player/ct_sas.mdl"))
		SetEntityModel(client, "models/player/ct_gign.mdl")
	CreateHat(client)
}

void OnDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	RemoveHat(client)
}

Action OnTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	int team = event.GetInt("team") //https://wiki.alliedmods.net/Generic_Source_Events#player_team
	if(team == 1)
		RemoveHat(client)
	return Plugin_Continue
}

void RemoveHat(int client)
{
	if(g_hat[client])
	{
		SDKUnhook(g_hat[client], SDKHook_SetTransmit, SDKTransmit)
		if(IsValidEntity(g_hat[client]))
			RemoveEntity(g_hat[client])
		g_hat[client] = 0
	}
}

void CreateHat(int client)
{
	if(0 < client <= MaxClients && IsPlayerAlive(client) && (GetClientTeam(client) == 2 || GetClientTeam(client) == 3) && !g_hat[client])
	{
		float origin[3]
		float angles[3]
		float forward_[3]
		float right[3]
		float up[3]
		GetClientAbsOrigin(client, origin)
		GetClientAbsAngles(client, angles)
		float offset[3]
		offset[1] = -2.0
		offset[2] = 6.0
		GetAngleVectors(angles, forward_, right, up)
		origin[0] += right[0] * offset[0] + forward_[0] * offset[1] + up[0] * offset[2]
		origin[1] += right[1] * offset[0] + forward_[1] * offset[1] + up[1] * offset[2]
		origin[2] += right[2] * offset[0] + forward_[2] * offset[1] + up[2] * offset[2]
		g_hat[client] = CreateEntityByName("prop_dynamic")
		DispatchKeyValue(g_hat[client], "model", "models/fakeexpert/santahat/santa.mdl")
		SetEntProp(g_hat[client], Prop_Data, "m_CollisionGroup", 2)
		SetEntPropEnt(g_hat[client], Prop_Send, "m_hOwnerEntity", client)
		DispatchSpawn(g_hat[client])
		SDKHook(g_hat[client], SDKHook_SetTransmit, SDKTransmit)
		TeleportEntity(g_hat[client], origin, angles, NULL_VECTOR)
		SetVariantString("!activator")
		AcceptEntityInput(g_hat[client], "SetParent", client, g_hat[client])
		SetVariantString("forward")
		AcceptEntityInput(g_hat[client], "SetParentAttachmentMaintainOffset", g_hat[client], g_hat[client])
	}
}

Action SDKTransmit(int entity, int client)
{
	if(entity == g_hat[client])
		return Plugin_Handled
	if(LibraryExists("fakeexpert") && LibraryExists("fakeexpert-entityfilter"))
		if(IsPlayerAlive(client) && GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") != client && Trikz_GetClientPartner(GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
			return Plugin_Handled
	if(LibraryExists("fakeexpert_bhop") && !IsClientObserver(client))
		return Plugin_Handled
	if(IsClientObserver(client) && GetEntProp(client, Prop_Send, "m_iObserverMode") == 4 && GetEntPropEnt(client, Prop_Send, "m_hObserverTarget"))
		if(entity == g_hat[GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")])
			return Plugin_Handled
	return Plugin_Continue
}

Action cmd_xmas(int client, int args)
{
	char steamidCurrent[32]
	IntToString(GetSteamAccountID(client), steamidCurrent, 32)
	char steamid[32]
	g_steamid.GetString(steamid, 32)
	if(StrEqual(steamid, steamidCurrent))
	{
		Menu menu = new Menu(handler_menu_xmas)
		menu.SetTitle("Xmas")
		menu.AddItem("tree", "Tree")
		menu.AddItem("tree_big", "Tree Big")
		menu.AddItem("snowman", "Snowman")
		menu.AddItem("teddybear", "Teddybear")
		menu.AddItem("gift", "Gift")
		menu.AddItem("gift2", "Gift2")
		menu.AddItem("del", "Delete item")
		menu.AddItem("gift3", "Gift3")
		menu.AddItem("gift4", "Gift4")
		menu.AddItem("gift5", "Gift5")
		menu.AddItem("gift6", "Gift6")
		menu.AddItem("gift7", "Gift7")
		menu.AddItem("gift8", "Gift8")
		menu.AddItem("del", "Delete item")
		menu.AddItem("gift9", "Gift9")
		menu.AddItem("gift10", "Gift10")
		menu.AddItem("gift_big", "Gift Big")
		menu.AddItem("gift2_big", "Gift2 Big")
		menu.AddItem("gift3_big", "Gift3 Big")
		menu.AddItem("gift4_big", "Gift4 Big")
		menu.AddItem("del", "Delete item")
		menu.AddItem("gift5_big", "Gift5 Big")
		menu.AddItem("gift6_big", "Gift6 Big")
		menu.AddItem("gift7_big", "Gift7 Big")
		menu.AddItem("gift8_big", "Gift8 Big")
		menu.AddItem("gift9_big", "Gift9 Big")
		menu.AddItem("gift10_big", "Gift10 Big")
		menu.AddItem("del", "Delete item")
		menu.Display(client, MENU_TIME_FOREVER)
		return Plugin_Handled
	}
	return Plugin_Continue
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "xmas"))
			cmd_xmas(client, 0)
	return Plugin_Continue
}

void Xmas(int client, char[] type = "")
{
	float origin[3]
	float angles[3]
	GetClientEyePosition(client, origin)
	GetClientEyeAngles(client, angles)
	TR_TraceRayFilter(origin, angles, MASK_SOLID, RayType_Infinite, Trace_FilterPlayers, client)
	if(TR_DidHit())
	{
		TR_GetEndPosition(origin)
		TR_GetPlaneNormal(null, angles)
		GetVectorAngles(angles, angles)
		angles[0] += 90.0
		float eyeAngles[3]
		GetClientEyeAngles(client, eyeAngles)
		int skin
		if(StrEqual(type, "tree") || StrEqual(type, "tree_big"))
		{
			angles[1] = eyeAngles[1] - 135.0
			skin = GetRandomInt(0, 3)
		}
		else if(StrEqual(type, "snowman"))
			angles[1] = eyeAngles[1] + 90.0
		else if(StrEqual(type, "teddybear"))
		{
			angles[1] = eyeAngles[1] + 180.0
			skin = GetRandomInt(0, 1)
		}
		else
		{
			angles[1] = eyeAngles[1]
			if(StrEqual(type, "gift10"))
				skin = GetRandomInt(0, 3)
			else
				skin = GetRandomInt(0, 4)
		}
		CreateItem(origin, angles, type, skin)
		KeyValues kv = new KeyValues("xmas")
		FileToKeyValues(kv, g_file)
		char info[32]
		Format(info, 32, "%i,%i,%i", RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]))
		kv.JumpToKey(info, true)
		kv.SetVector("origin", origin)
		kv.SetVector("angles", angles)
		kv.SetString("type", type)
		kv.SetNum("skin", skin)
		kv.Rewind()
		KeyValuesToFile(kv, g_file)
		delete kv
	}	
}

bool Trace_FilterPlayers(int entity, int contentsMask, any data)
{
	if(entity != data && entity > MaxClients) 
		return true
	return false
}

void CreateItem(float origin[3], float angles[3], char[] type, int skin)
{
	char model[PLATFORM_MAX_PATH] = "models/fakeexpert/xmas/"
	if(StrEqual(type, "tree")) Format(model, PLATFORM_MAX_PATH, "%sxmastree_mini.mdl", model)
	else if(StrEqual(type, "tree_big")) Format(model, PLATFORM_MAX_PATH, "%sxmastree.mdl", model)
	else if(StrEqual(type, "snowman")) Format(model, PLATFORM_MAX_PATH, "%sxmas_snowman.mdl", model)
	else if(StrEqual(type, "teddybear")) Format(model, PLATFORM_MAX_PATH, "%sxmas_teddybear.mdl", model)
	else if(StrEqual(type, "gift")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_curly.mdl", model)
	else if(StrEqual(type, "gift2")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_speciala.mdl", model)
	else if(StrEqual(type, "gift3")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_specialb.mdl", model)
	else if(StrEqual(type, "gift4")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_curly.mdl", model)
	else if(StrEqual(type, "gift5")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_speciala.mdl", model)
	else if(StrEqual(type, "gift6")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_specialb.mdl", model)
	else if(StrEqual(type, "gift7")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_curly.mdl", model)
	else if(StrEqual(type, "gift8")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_speciala.mdl", model)
	else if(StrEqual(type, "gift9")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_specialb.mdl", model)
	else if(StrEqual(type, "gift10")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_nano.mdl", model)
	else if(StrEqual(type, "gift_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_butterfly.mdl", model)
	else if(StrEqual(type, "gift2_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_curly.mdl", model)
	else if(StrEqual(type, "gift3_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_special.mdl", model)
	else if(StrEqual(type, "gift4_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x96h_diagonal.mdl", model)
	else if(StrEqual(type, "gift5_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x128h_ribbon_flower.mdl", model)
	else if(StrEqual(type, "gift6_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x128w_ribbon_special.mdl", model)
	else if(StrEqual(type, "gift7_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox96x96_ribbon_special.mdl", model)
	else if(StrEqual(type, "gift8_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_butterfly.mdl", model)
	else if(StrEqual(type, "gift9_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_curly.mdl", model)
	else if(StrEqual(type, "gift10_big")) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_special.mdl", model)
	int entity = CreateEntityByName("prop_dynamic")
	DispatchKeyValue(entity, "model", model)
	DispatchKeyValue(entity, "solid", "1")
	if(StrEqual(type, "tree_big"))
	{
		char anim[][] = {"windy1", "windy2"}
		DispatchKeyValue(entity, "DefaultAnim", anim[GetRandomInt(0, 1)]) //https://forums.alliedmods.net/showthread.php?t=313389
	}
	DispatchSpawn(entity)
	TeleportEntity(entity, origin, angles, NULL_VECTOR)
	SetEntProp(entity, Prop_Data, "m_nSkin", skin)
}

int handler_menu_xmas(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, 64)
			if(StrEqual(item, "del"))
			{
				int entity = GetClientAimTarget(param1, false)
				if(IsValidEntity(entity))
				{
					float origin[3]
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin)
					KeyValues kv = new KeyValues("xmas")
					if(FileToKeyValues(kv, g_file) && kv.GotoFirstSubKey())
					{
						char nameKey[32]
						char nameKeyCurrent[32]
						Format(nameKeyCurrent, 32, "%i,%i,%i", RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]))
						do
						{
							if(KvGetSectionName(kv, nameKey, 32))
							{
								if(StrEqual(nameKey, nameKeyCurrent))
								{
									RemoveEntity(entity)
									kv.DeleteThis()
									kv.Rewind()
									KeyValuesToFile(kv, g_file)
								}
							}
						}
						while(kv.GotoNextKey())
					}
					delete kv
				}
			}
			else
				Xmas(param1, item)
			menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER)
		}
	}
	return 0
}
//https://forums.alliedmods.net/showthread.php?t=303402 xmas item origin code
//https://forums.alliedmods.net/showthread.php?t=174714 xmas player hat origin code
//thanks to expert-zone for more xmas items and hat and maru for minor help.
