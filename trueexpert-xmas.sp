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
#include <cstrike>

#define semicolon 1
#define newdecls required
#define MAXPLAYER MAXPLAYERS + 1

//https://forums.alliedmods.net/showpost.php?p=2544030&postcount=7
#define SPECMODE_NONE 0
#define SPECMODE_FIRSTPERSON 4
#define SPECMODE_3RDPERSON 5
#define SPECMODE_FREELOOK 6

char g_file[PLATFORM_MAX_PATH] = "";

int g_hat[MAXPLAYERS] = {0, ...};

native int Trikz_GetClientPartner(int client);

ConVar g_enable = null, g_dateStart = null, g_dateEnd = null, g_move[3] = {null, ...}, g_rotation[3] = {null, ...}, g_scaleT = null, g_scaleCT = null;

float g_hatMove[3] = {0.0, ...}, g_hatRotate[3] = {0.0, ...};

public Plugin myinfo =
{
	name = "Xmas",
	author = "Niks Jurēvičs (Smesh, Smesh292)",
	description = "Snowman, gifts, big Christmas tree, Santa hat.",
	version = "1.32",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	g_enable = CreateConVar("sm_te_xmas_enable", "0.0", "Do active plugin?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_dateStart = CreateConVar("sm_te_date_start", "11.0", "Month of start the xmass", FCVAR_NOTIFY, true, 1.0, true, 12.0);
	g_dateEnd = CreateConVar("sm_te_date_end", "2.0", "Month of end the xmass", FCVAR_NOTIFY, true, 1.0, true, 12.0);
	g_move[0] = CreateConVar("sm_te_move_x", "0.0", "Move to X coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_move[1] = CreateConVar("sm_te_move_y", "-1.85", "Move to Y coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_move[2] = CreateConVar("sm_te_move_z", "4.6", "Move to Z coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_rotation[0] = CreateConVar("sm_te_rotate_x", "0.0", "Rorate to X coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_rotation[1] = CreateConVar("sm_te_rotate_y", "0.0", "Rorate to Y coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_rotation[2] = CreateConVar("sm_te_rotate_z", "0.0", "Rorate to Z coordinate.", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_scaleT = CreateConVar("sm_te_scale_t", "0.9", "Hat scale for Terrorist", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	g_scaleCT = CreateConVar("sm_te_scale_ct", "1.05", "Hat scale for Counter-Terrorist", FCVAR_NOTIFY, false, 0.0, false, 0.0);
	AutoExecConfig(true, "plugin.trueexpert-xmass", "sourcemod");

	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_PostNoCopy);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre); //https://forums.alliedmods.net/showthread.php?t=135521
	//AddCommandListener(ListenerJoinclass, "joinclass");

	RegConsoleCmd("sm_xmas", CommandXmas, "Open the xmas menu.");
	RegConsoleCmd("sm_hat", CommandHat, "Do move menu for hat from aim target (!hat m,0,-1.9,4.6) m - move, r - rotate");

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			RemoveHat(i);
			CreateHat(i);
		}

		continue;
	}

	return;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Trikz_GetClientPartner");

	return APLRes_Success;
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			RemoveHat(i);
		}

		continue;
	}

	return;
}

bool TestDate()
{
	float monthStart = g_dateStart.FloatValue;
	float monthEnd = g_dateEnd.FloatValue;

	int dateCurrent = GetTime({0, 0});

	char buffer[32] = "";
	FormatTime(buffer, sizeof(buffer), "%m", dateCurrent);

	int monthCurrent = StringToInt(buffer);

	if((monthStart <= monthCurrent && monthEnd >= monthCurrent) || (monthStart <= monthCurrent && monthEnd <= monthCurrent) || (monthStart >= monthCurrent && monthEnd >= monthCurrent))
	{
		return true;
	}

	return false;
}

public void OnMapStart()
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}

	if(TestDate() == false)
	{
		return;
	}

	char path[4][PLATFORM_MAX_PATH] = {"models/expert_zone/xmas/", "models/expert_zone/santahat/", "materials/expert_zone/xmas/", "materials/expert_zone/santahat/"};

	for(int i = 0; i < sizeof(path); i++)
	{
		DirectoryListing dir = OpenDirectory(path[i]);

		char filename[4][PLATFORM_MAX_PATH];

		FileType type = FileType_Unknown;

		char pathFull[4][PLATFORM_MAX_PATH];

		while(dir.GetNext(filename[i], PLATFORM_MAX_PATH, type) == true)
		{
			if(type == FileType_File)
			{
				Format(pathFull[i], PLATFORM_MAX_PATH, "%s%s", path[i], filename[i]);

				if(StrContains(pathFull[i], ".mdl", false) != -1)
				{
					PrecacheModel(pathFull[i], true);
				}

				AddFileToDownloadsTable(pathFull[i]);
			}

			continue;
		}

		delete dir;

		continue;
	}

	char map[192] = "";
	GetCurrentMap(map, sizeof(map));

	BuildPath(Path_SM, path[0], PLATFORM_MAX_PATH, "data/trueexpert/");

	if(DirExists(path[0]) == false)
	{
		CreateDirectory(path[0], 511, false, "DEFAULT_WRITE_PATH");
	}

	BuildPath(Path_SM, path[0], PLATFORM_MAX_PATH, "data/trueexpert/xmas/");

	if(DirExists(path[0]) == false)
	{
		CreateDirectory(path[0], 511, false, "DEFAULT_WRITE_PATH");
	}

	Format(g_file, PLATFORM_MAX_PATH, "%s%s.cfg", path[0], map);

	return;
}

public void OnClientDisconnect(int client)
{
	RemoveHat(client);

	return;
}

void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}

	if(TestDate() == false)
	{
		return;
	}

	KeyValues kv = new KeyValues("xmas");

	if(kv.ImportFromFile(g_file) == true && kv.GotoFirstSubKey() == true)
	{
		char nameKey[32] = "";

		do
		{
			if(kv.GetSectionName(nameKey, sizeof(nameKey)) == true)
			{
				float origin[3] = {0.0, ...}, angles[3] = {0.0, ...};
				int skin = 0;
				char type[64] = "";

				kv.GetVector("origin", origin);
				kv.GetVector("angles", angles);
				kv.GetString("type", type, sizeof(type));

				skin = kv.GetNum("skin");

				CreateItem(origin, angles, type, skin);
			}

			continue;
		}

		while(kv.GotoNextKey(true) == true);
	}

	delete kv;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			RemoveHat(i);

			CreateHat(i);
		}

		continue;
	}

	return;
}

void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}
	
	if(TestDate() == false)
	{
		return;
	}

	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	char model[PLATFORM_MAX_PATH] = "";
	GetClientModel(client, model, PLATFORM_MAX_PATH);

	if(StrEqual(model, "models/player/ct_gsg9.mdl", false) == true)
	{
		SetEntityModel(client, "models/player/ct_urban.mdl");
	}

	else if(StrEqual(model, "models/player/ct_sas.mdl", false) == true)
	{
		SetEntityModel(client, "models/player/ct_gign.mdl");
	}

	RemoveHat(client);
	CreateHat(client);

	return;
}

void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	RemoveHat(client);

	return;
}

Action OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(TestDate() == false)
	{
		return Plugin_Continue;
	}

	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	int team = event.GetInt("team"); //https://wiki.alliedmods.net/Generic_Source_Events#player_team

	if(team == CS_TEAM_SPECTATOR)
	{
		RemoveHat(client);
	}

	return Plugin_Continue;
}

/*Action ListenerJoinclass(int client, const char[] command, int argc)
{
	if(TestDate() == false)
	{
		return Plugin_Continue;
	}

	RemoveHat(client);

	return Plugin_Continue
}*/

void RemoveHat(int client)
{
	if(g_hat[client] > 0)
	{
		SDKUnhook(g_hat[client], SDKHook_SetTransmit, OnHatTransmit);

		if(IsValidEntity(g_hat[client]) == true)
		{
			RemoveEntity(g_hat[client]);
		}

		g_hat[client] = 0;
	}

	return;
}

void CreateHat(int client)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}

	if(0 < client <= MaxClients && IsPlayerAlive(client) == true && (GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT) && g_hat[client] == 0)
	{
		//declanation
		float origin[3], angles[3], offset[3], forward_[3], right[3], up[3], rotation[3];

		//initialization
		GetClientAbsOrigin(client, origin);
		GetClientAbsAngles(client, angles);

		offset[0] = g_move[0].FloatValue;
		offset[1] = g_move[1].FloatValue;
		offset[2] = g_move[2].FloatValue;

		GetAngleVectors(angles, forward_, right, up);

		origin[0] += right[0] * offset[0] + forward_[0] * offset[1] + up[0] * offset[2];
		origin[1] += right[1] * offset[0] + forward_[1] * offset[1] + up[1] * offset[2];
		origin[2] += right[2] * offset[0] + forward_[2] * offset[1] + up[2] * offset[2];

		g_hat[client] = CreateEntityByName("prop_dynamic_override");

		DispatchKeyValue(g_hat[client], "model", "models/expert_zone/santahat/santa.mdl");

		SetEntProp(g_hat[client], Prop_Data, "m_CollisionGroup", 2);

		SetEntPropEnt(g_hat[client], Prop_Send, "m_hOwnerEntity", client);

		rotation[0] = g_rotation[0].FloatValue;
		rotation[1] = g_rotation[1].FloatValue;
		rotation[2] = g_rotation[2].FloatValue;

		SetEntPropVector(g_hat[client], Prop_Data, "m_angRotation", rotation);

		char model[PLATFORM_MAX_PATH] = "";
		GetClientModel(client, model, PLATFORM_MAX_PATH);

		if(StrContains(model, "/t_", false) != -1)
		{
			SetEntPropFloat(g_hat[client], Prop_Data, "m_flModelScale", g_scaleT.FloatValue);
		}

		else if(StrContains(model, "/ct_", false) != -1)
		{
			SetEntPropFloat(g_hat[client], Prop_Data, "m_flModelScale", g_scaleCT.FloatValue);
		}

		DispatchSpawn(g_hat[client]);

		SDKHook(g_hat[client], SDKHook_SetTransmit, OnHatTransmit);

		TeleportEntity(g_hat[client], origin, angles, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(g_hat[client], "SetParent", client, g_hat[client]);

		SetVariantString("forward");
		AcceptEntityInput(g_hat[client], "SetParentAttachmentMaintainOffset", g_hat[client], g_hat[client]);
	}

	return;
}

Action OnHatTransmit(int entity, int client)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return Plugin_Continue;
	}

	if(entity == g_hat[client])
	{
		return Plugin_Handled;
	}

	if(LibraryExists("trueexpert") == true && LibraryExists("trueexpert-entityfilter") == true)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

		if(IsPlayerAlive(client) == true && owner != client && Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(client))))
		{
			return Plugin_Handled;
		}
	}

	if(LibraryExists("trueexpert_bhop") == true && IsClientObserver(client) == false)
	{
		return Plugin_Handled;
	}

	int mode = GetEntProp(client, Prop_Send, "m_iObserverMode");
	int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");

	if(IsClientObserver(client) == true && mode == SPECMODE_FIRSTPERSON && target > 0)
	{
		if(entity == g_hat[target])
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

Action CommandXmas(int client, int args)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return Plugin_Continue;
	}

	if(TestDate() == false)
	{
		return Plugin_Continue;
	}

	int flags = GetUserFlagBits(client);
	
	if(flags & ADMFLAG_CUSTOM1)
	{
		Menu menu = new Menu(XmasMenuHandler);

		menu.SetTitle("Xmas");

		menu.AddItem("tree", "Tree");
		menu.AddItem("tree_big", "Tree Big");
		menu.AddItem("snowman", "Snowman");
		menu.AddItem("teddybear", "Teddybear");
		menu.AddItem("gift", "Gift");
		menu.AddItem("gift2", "Gift2");
		menu.AddItem("del", "Delete item");

		menu.AddItem("gift3", "Gift3");
		menu.AddItem("gift4", "Gift4");
		menu.AddItem("gift5", "Gift5");
		menu.AddItem("gift6", "Gift6");
		menu.AddItem("gift7", "Gift7");
		menu.AddItem("gift8", "Gift8");
		menu.AddItem("del", "Delete item");

		menu.AddItem("gift9", "Gift9");
		menu.AddItem("gift10", "Gift10");
		menu.AddItem("gift_big", "Gift Big");
		menu.AddItem("gift2_big", "Gift2 Big");
		menu.AddItem("gift3_big", "Gift3 Big");
		menu.AddItem("gift4_big", "Gift4 Big");
		menu.AddItem("del", "Delete item");

		menu.AddItem("gift5_big", "Gift5 Big");
		menu.AddItem("gift6_big", "Gift6 Big");
		menu.AddItem("gift7_big", "Gift7 Big");
		menu.AddItem("gift8_big", "Gift8 Big");
		menu.AddItem("gift9_big", "Gift9 Big");
		menu.AddItem("gift10_big", "Gift10 Big");
		menu.AddItem("del", "Delete item");

		menu.Display(client, MENU_TIME_FOREVER);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action CommandHat(int client, int args)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return Plugin_Continue;
	}

	if(TestDate() == false)
	{
		return Plugin_Continue;
	}

	int flags = GetUserFlagBits(client);
	
	if(flags & ADMFLAG_CUSTOM1)
	{
		//declanation
		float origin[3], angles[3], offset[3], forward_[3], right[3], up[3], rotation[3];

		int target = GetClientAimTarget(client, true);

		char buffer[32] = "";
		GetCmdArgString(buffer, sizeof(buffer));

		char buffers[4][32];
		ExplodeString(buffer, ",", buffers, 4, 32, false);

		if(StrEqual(buffers[0], "m", false) == true)
		{
			g_hatMove[0] = StringToFloat(buffers[1]);
			g_hatMove[1] = StringToFloat(buffers[2]);
			g_hatMove[2] = StringToFloat(buffers[3]);
		}

		else if(StrEqual(buffers[0], "r", false) == true)
		{
			g_hatRotate[0] = StringToFloat(buffers[1]);
			g_hatRotate[1] = StringToFloat(buffers[2]);
			g_hatRotate[2] = StringToFloat(buffers[3]);
		}

		//initialization
		GetClientAbsOrigin(target, origin);
		GetClientAbsAngles(target, angles);

		offset[0] = g_hatMove[0];
		offset[1] = g_hatMove[1];
		offset[2] = g_hatMove[2];

		GetAngleVectors(angles, forward_, right, up);

		origin[0] += right[0] * offset[0] + forward_[0] * offset[1] + up[0] * offset[2];
		origin[1] += right[1] * offset[0] + forward_[1] * offset[1] + up[1] * offset[2];
		origin[2] += right[2] * offset[0] + forward_[2] * offset[1] + up[2] * offset[2];

		RemoveHat(target);

		g_hat[target] = CreateEntityByName("prop_dynamic_override");

		DispatchKeyValue(g_hat[target], "model", "models/expert_zone/santahat/santa.mdl");

		SetEntProp(g_hat[target], Prop_Data, "m_CollisionGroup", 2);

		SetEntPropEnt(g_hat[target], Prop_Send, "m_hOwnerEntity", target);

		rotation[0] = g_hatRotate[0];
		rotation[1] = g_hatRotate[1];
		rotation[2] = g_hatRotate[2];

		SetEntPropVector(g_hat[target], Prop_Data, "m_angRotation", rotation);

		char model[PLATFORM_MAX_PATH] = "";
		GetClientModel(target, model, PLATFORM_MAX_PATH);

		if(StrContains(model, "/t_", false) != -1)
		{
			SetEntPropFloat(g_hat[target], Prop_Data, "m_flModelScale", g_scaleT.FloatValue);
		}

		else if(StrContains(model, "/ct_", false) != -1)
		{
			SetEntPropFloat(g_hat[target], Prop_Data, "m_flModelScale", g_scaleCT.FloatValue);
		}

		DispatchSpawn(g_hat[target]);

		SDKHook(g_hat[target], SDKHook_SetTransmit, OnHatTransmit);

		TeleportEntity(g_hat[target], origin, angles, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(g_hat[target], "SetParent", target, g_hat[target]);

		SetVariantString("forward");
		AcceptEntityInput(g_hat[target], "SetParentAttachmentMaintainOffset", g_hat[target], g_hat[target]);
	}

	return Plugin_Continue;
}

void Xmas(int client, char[] type)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}

	//declaration
	float origin[3] = {0.0, ...}, angles[3] = {0.0, ...};

	//initialization
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);

	TR_TraceRayFilter(origin, angles, MASK_SOLID, RayType_Infinite, TraceFilterPlayers, client);

	if(TR_DidHit(INVALID_HANDLE) == true)
	{
		//declanation
		float eyeAngles[3] = {0.0, ...};
		int skin = 0;
		char info[64] = "";

		//initialization
		TR_GetEndPosition(origin);
		TR_GetPlaneNormal(null, angles);

		GetVectorAngles(angles, angles);
		angles[0] += 90.0;

		GetClientEyeAngles(client, eyeAngles);

		if(StrEqual(type, "tree", false) == true || StrEqual(type, "tree_big", false) == true)
		{
			angles[1] = eyeAngles[1] - 135.0;

			skin = GetRandomInt(0, 3);
		}

		else if(StrEqual(type, "snowman", false) == true)
		{
			angles[1] = eyeAngles[1] + 90.0;
		}

		else if(StrEqual(type, "teddybear", false) == true)
		{
			angles[1] = eyeAngles[1] + 180.0;

			skin = GetRandomInt(0, 1);
		}

		else if(StrEqual(type, "tree", false) == false || StrEqual(type, "tree_big", false) == false || StrEqual(type, "snowman", false) == false || StrEqual(type, "teddybear", false) == false)
		{
			angles[1] = eyeAngles[1];

			if(StrEqual(type, "gift10", false) == true)
			{
				skin = GetRandomInt(0, 3);
			}

			else if(StrEqual(type, "gift10", false) == false)
			{
				skin = GetRandomInt(0, 4);
			}
		}

		CreateItem(origin, angles, type, skin);

		KeyValues kv = new KeyValues("xmas");

		kv.ImportFromFile(g_file);

		Format(info, sizeof(info), "%i,%i,%i", RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]));

		kv.JumpToKey(info, true);

		kv.SetVector("origin", origin);
		kv.SetVector("angles", angles);

		kv.SetString("type", type);

		kv.SetNum("skin", skin);

		kv.Rewind();

		kv.ExportToFile(g_file);

		delete kv;

		char auth[32] = "";
		GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

		LogToFileEx("addons/sourcemod/logs/trueexpert-xmas.log", "SteamID64: [%s] Name: [%N] Added: [%s] at [%i %i %i]", auth, client, type, RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]));
	}

	return;
}

bool TraceFilterPlayers(int entity, int contentsMask, any data)
{
	if(entity != data && entity > MaxClients) 
	{
		return true;
	}

	return false;
}

void CreateItem(float origin[3], float angles[3], char[] type, int skin)
{
	char value[3 + 1] = "";
	g_enable.GetString(value, sizeof(value));
	float enable = StringToFloat(value);

	if(enable != 1.0)
	{
		return;
	}
	
	char model[PLATFORM_MAX_PATH] = "models/expert_zone/xmas/";

	if(StrEqual(type, "tree", false)) Format(model, PLATFORM_MAX_PATH, "%sxmastree_mini.mdl", model);
	else if(StrEqual(type, "tree_big", false)) Format(model, PLATFORM_MAX_PATH, "%sxmastree.mdl", model);
	else if(StrEqual(type, "snowman", false)) Format(model, PLATFORM_MAX_PATH, "%sxmas_snowman.mdl", model);
	else if(StrEqual(type, "teddybear", false)) Format(model, PLATFORM_MAX_PATH, "%sxmas_teddybear.mdl", model);
	else if(StrEqual(type, "gift", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_curly.mdl", model);
	else if(StrEqual(type, "gift2", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_speciala.mdl", model);
	else if(StrEqual(type, "gift3", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_octo_specialb.mdl", model);
	else if(StrEqual(type, "gift4", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_curly.mdl", model);
	else if(StrEqual(type, "gift5", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_speciala.mdl", model);
	else if(StrEqual(type, "gift6", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_quad_specialb.mdl", model);
	else if(StrEqual(type, "gift7", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_curly.mdl", model);
	else if(StrEqual(type, "gift8", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_speciala.mdl", model);
	else if(StrEqual(type, "gift9", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_mini_round_specialb.mdl", model);
	else if(StrEqual(type, "gift10", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox_nano.mdl", model);
	else if(StrEqual(type, "gift_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_butterfly.mdl", model);
	else if(StrEqual(type, "gift2_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_curly.mdl", model);
	else if(StrEqual(type, "gift3_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x64_ribbon_special.mdl", model);
	else if(StrEqual(type, "gift4_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x96h_diagonal.mdl", model);
	else if(StrEqual(type, "gift5_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x128h_ribbon_flower.mdl", model);
	else if(StrEqual(type, "gift6_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox64x128w_ribbon_special.mdl", model);
	else if(StrEqual(type, "gift7_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox96x96_ribbon_special.mdl", model);
	else if(StrEqual(type, "gift8_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_butterfly.mdl", model);
	else if(StrEqual(type, "gift9_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_curly.mdl", model);
	else if(StrEqual(type, "gift10_big", false)) Format(model, PLATFORM_MAX_PATH, "%sgiftbox128x128_ribbon_special.mdl", model);

	int entity = CreateEntityByName("prop_dynamic_override", -1);

	DispatchKeyValue(entity, "model", model);
	DispatchKeyValue(entity, "solid", "1");

	if(StrEqual(type, "tree_big", false) == true)
	{
		char anim[][] = {"windy1", "windy2"};
		int random = GetRandomInt(0, 1);

		DispatchKeyValue(entity, "DefaultAnim", anim[random]); //https://forums.alliedmods.net/showthread.php?t=313389
	}

	DispatchSpawn(entity); //first

	TeleportEntity(entity, origin, angles, NULL_VECTOR); //second

	SetEntProp(entity, Prop_Data, "m_nSkin", skin); //third

	return;
}

int XmasMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64] = "";
			menu.GetItem(param2, item, sizeof(item));

			if(StrEqual(item, "del", false) == true)
			{
				int entity = GetClientAimTarget(param1, false)

				if(IsValidEntity(entity) == true)
				{
					float origin[3] = {0.0, ...};

					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin);

					KeyValues kv = new KeyValues("xmas");

					if(kv.ImportFromFile(g_file) == true && kv.GotoFirstSubKey(true) == true)
					{
						char nameKey[64] = "";
						char nameKeyCurrent[64] = "";

						Format(nameKeyCurrent, sizeof(nameKeyCurrent), "%i,%i,%i", RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]));

						do
						{
							if(kv.GetSectionName(nameKey, sizeof(nameKey)) == true)
							{
								if(StrEqual(nameKey, nameKeyCurrent, false) == true)
								{
									char type[64] = "";
									kv.GetString("type", type, sizeof(type), "");

									char auth[32] = "";
									GetClientAuthId(param1, AuthId_SteamID64, auth, sizeof(auth), true);

									LogToFileEx("addons/sourcemod/logs/trueexpert-xmas.log", "SteamID64: [%s] Name: [%N] Removed: [%s] at [%i %i %i]", auth, param1, type, RoundToFloor(origin[0]), RoundToFloor(origin[1]), RoundToFloor(origin[2]));

									break;
								}
							}

							continue;
						}

						while(kv.GotoNextKey(true) == true);

						kv.Rewind();

						if(kv.GotoFirstSubKey(true) == true)
						{
							do
							{
								if(kv.GetSectionName(nameKey, sizeof(nameKey)) == true)
								{
									if(StrEqual(nameKey, nameKeyCurrent, false) == true)
									{
										RemoveEntity(entity);

										kv.DeleteThis();

										kv.Rewind();

										kv.ExportToFile(g_file);

										break;
									}
								}

								continue;
							}

							while(kv.GotoNextKey(true) == true);
						}
					}

					delete kv;
				}
			}

			else if(StrEqual(item, "del", false) == false)
			{
				Xmas(param1, item);
			}

			menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		}
	}

	return view_as<int>(action);
}

//https://forums.alliedmods.net/showthread.php?t=303402 xmas item origin code
//https://forums.alliedmods.net/showthread.php?t=174714 xmas player hat origin code
//thanks to expert-zone for more xmas items and hat and maru for minor help.
