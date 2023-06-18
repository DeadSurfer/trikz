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
#include <dhooks>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define MAXPLAYER MAXPLAYERS + 1
#define IsValidClient(%1) (0 < %1 <= MaxClients && IsClientInGame(%1))

char g_map[192] = "";
ArrayList g_frame[MAXPLAYER] = {null, ...};
ArrayList g_frameCache[MAXPLAYER] = {null, ...};
Handle g_PassServerEntityFilter = INVALID_HANDLE;

enum struct eFrame
{
	float pos[3];
	float ang[2];
	int buttons;
	int flags;
	MoveType movetype;
	int weapon;
}

int g_tick[MAXPLAYER] = {0, ...};
int g_steamid3[2] = {0, ...};
Database g_sql = null;
native bool Trikz_GetTimerState(int client);
int g_flagsLast[MAXPLAYER] = {0, ...};
Handle g_DoAnimationEvent = INVALID_HANDLE;
DynamicDetour g_MaintainBotQuota = null;
float g_timeToRestart = 0.0;
float g_timeToStart = 0.0;
DynamicHook g_UpdateStepSound = null;
bool g_Linux = false;
native int Trikz_GetClientPartner(int client);
native int Trikz_SetPartner(int client, int partner);
native int Trikz_Restart(int client, bool instant);
int g_bot[2] = {0, ...};
bool g_loaded[2] = {false, ...};
float g_tickrate = 0.0;
int g_replayTickcount[MAXPLAYER] = {0, ...};
char g_weaponName[][] = {"knife", "glock", "usp", "flashbang", "hegrenade", "smokegrenade", "p228", "deagle", "elite", "fiveseven", 
						"m3", "xm1014", "galil", "ak47", "scout", "sg552", 
						"awp", "g3sg1", "famas", "m4a1", "aug", "sg550", 
						"mac10", "tmp", "mp5navy", "ump45", "p90", "m249", "c4"};
native bool Trikz_GetDevmap();
char g_replayType[][] = {"", "_partner"};
char g_query[256] = "";

public Plugin myinfo =
{
	name = "Replay",
	author = "Niks Smesh Jurēvičs",
	description = "Replay module for trueexpert.",
	version = "0.27",
	url = "http://www.sourcemod.net/"
};

//some logic i used from https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-replay-recorder.sp and https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-replay-playback.sp

public void OnPluginStart()
{
	Database.Connect(SQLConnect, "trueexpert");

	HookEvent("player_spawn", OnSpawn, EventHookMode_Post);
	HookEvent("player_changename", BotSilent, EventHookMode_Pre);
	HookEvent("player_team", BotSilent, EventHookMode_Pre);
	HookEvent("player_activate", BotSilent, EventHookMode_Pre);
	
	HookUserMessage(GetUserMessageId("SayText2"), Hook_SayText2, true);

	GameData gamedata = new GameData("trueexpert.games");

	g_Linux = (gamedata.GetOffset("OS") == 2);
	StartPrepSDKCall(g_Linux ? SDKCall_Static : SDKCall_Player);

	if(PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "Player::DoAnimationEvent"))
	{
		if(g_Linux == true)
		{
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_ByRef);
		}

		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	}

	g_DoAnimationEvent = EndPrepSDKCall();

	g_MaintainBotQuota = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address);
	DHookSetFromConf(g_MaintainBotQuota, gamedata, SDKConf_Signature, "BotManager::MaintainBotQuota");
	g_MaintainBotQuota.Enable(Hook_Pre, Detour_MaintainBotQuota);

	int offset = 0;

	if((offset = GameConfGetOffset(gamedata, "CBasePlayer::UpdateStepSound")) != -1)
	{
		g_UpdateStepSound = new DynamicHook(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity);
		g_UpdateStepSound.AddParam(HookParamType_ObjectPtr);
		g_UpdateStepSound.AddParam(HookParamType_VectorPtr);
		g_UpdateStepSound.AddParam(HookParamType_VectorPtr);
	}

	//delete gamedata;

	g_tickrate = 1.0 / GetTickInterval();
	
	/*if(gamedata == INVALID_HANDLE)
	{
		SetFailState("Failed to load \"trueexpert.games\" gamedata.");

		delete gamedata;
		delete g_PassServerEntityFilter;
	}*/

	if(LibraryExists("trueexpert-entityfilter") == false)
	{
		g_PassServerEntityFilter = DHookCreateFromConf(gamedata, "PassServerEntityFilter");

		if(g_PassServerEntityFilter == INVALID_HANDLE)
		{
			SetFailState("Failed to setup detour PassServerEntityFilter.");
		}

		if(DHookEnableDetour(g_PassServerEntityFilter, false, PassServerEntityFilter) == false)
		{
			SetFailState("Failed to load detour PassServerEntityFilter.");
		}
		
		delete g_PassServerEntityFilter;
	}

	delete gamedata;

	return;
}

public void OnPluginEnd()
{
	SetConVarFlags(FindConVar("bot_quota"), GetConVarFlags(FindConVar("bot_quota")) | FCVAR_NOTIFY);

	ServerCommand("bot_kick");

	return;
}

public void OnMapStart()
{
	if(Trikz_GetDevmap() == false)
	{
		GetCurrentMap(g_map, sizeof(g_map));

		CreateTimer(1.0, TimerBot, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if(Trikz_GetDevmap() == true)
	{
		OnPluginEnd();
	}

	return;
}

public void OnClientPutInServer(int client)
{
	if(LibraryExists("trueexpert-entityfilter") == false && Trikz_GetDevmap() == false)
	{
		SDKHook(client, SDKHook_SetTransmit, OnPlayerTransmit);
	}

	//SDKHook(client, SDKHook_WeaponSwitchPost, OnPlayerWeaponSwitchPost);

	return;
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client) == true)
	{
		for(int i = 0; i <= 1; i++)
		{
			g_bot[i] = 0;
			g_loaded[i] = false;

			continue;
		}
	}

	return;
}

Action TimerBot(Handle timer)
{
	if(LibraryExists("trueexpert") == false)
	{
		return Plugin_Continue;
	}

	char record[2][PLATFORM_MAX_PATH] = {"", ""};

	for(int i = 0; i < sizeof(g_replayType); i++)
	{
		BuildPath(Path_SM, record[i], PLATFORM_MAX_PATH, "data/trueexpert/%s%s.replay", g_map, g_replayType[i]);

		if(FileExists(record[i]) == false)
		{
			return Plugin_Continue;
		}

		continue;
	}

	ConVar cvForce = FindConVar("bot_stop");
	cvForce.SetInt(1);

	cvForce = FindConVar("bot_join_after_player");
	cvForce.SetInt(0);

	cvForce = FindConVar("bot_quota");
	cvForce.Flags = GetConVarFlags(FindConVar("bot_quota")) &~ FCVAR_NOTIFY;

	cvForce = FindConVar("bot_flipout");
	cvForce.SetInt(1);

	cvForce = FindConVar("bot_zombie");
	cvForce.SetInt(1);

	int botShouldAdd = 2;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true && IsFakeClient(i) == true && GetClientTeam(i) != CS_TEAM_SPECTATOR)
		{
			botShouldAdd--;
		}

		continue;
	}

	for(int i = 1; i <= botShouldAdd; i++)
	{
		ServerCommand("bot_add");

		continue;
	}

	if(botShouldAdd == 2 && g_sql != INVALID_HANDLE)
	{
		Format(g_query, sizeof(g_query), "SELECT username, (SELECT username FROM users WHERE steamid = %i LIMIT 1) FROM users WHERE steamid = %i LIMIT 1", g_steamid3[1], g_steamid3[0]);
		g_sql.Query(SQLGetReplayName, g_query, _, DBPrio_Normal);
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true && IsFakeClient(i) == true && GetClientTeam(i) != CS_TEAM_SPECTATOR)
		{
			if(g_bot[0] == 0)
			{
				g_bot[0] = i;
			}

			if(g_bot[0] != i)
			{
				g_bot[1] = i;
			}

			if(g_bot[1] > 0)
			{
				if(Trikz_GetClientPartner(g_bot[0]) == 0)
				{
					Trikz_SetPartner(g_bot[0], g_bot[1]);

					if(IsClientInGame(g_bot[0]) && IsPlayerAlive(g_bot[0]) == false)
					{
						CS_RespawnPlayer(g_bot[0]);
					}

					if(IsClientInGame(g_bot[1]) == true && IsPlayerAlive(g_bot[1]) == false)
					{
						CS_RespawnPlayer(g_bot[1]);
					}

					LoadRecord();
				}
			}
		}

		continue;
	}

	return Plugin_Continue;
}

void SetupSave(int client, int partner, float time)
{
	char dir[PLATFORM_MAX_PATH] = "";
	BuildPath(Path_SM, dir, sizeof(dir), "data/trueexpert");

	if(DirExists(dir) == false)
	{
		CreateDirectory(dir, 511);
	}

	char dirBackup[PLATFORM_MAX_PATH] = "";
	BuildPath(Path_SM, dirBackup, sizeof(dirBackup), "data/trueexpert/backup");

	if(DirExists(dirBackup) == false)
	{
		CreateDirectory(dirBackup, 511);
	}

	int team[2] = {0, ...};
	team[0] = client, team[1] = partner;

	for(int i = 0; i <= 1; i++)
	{
		char record[PLATFORM_MAX_PATH] = "";
		BuildPath(Path_SM, record, sizeof(record), "data/trueexpert/%s%s.replay", g_map, g_replayType[i]);
		SaveRecord(team[i], record, time, false);

		char recordBackup[PLATFORM_MAX_PATH] = "";
		char buffer[32] = "";
		FormatTime(buffer, sizeof(buffer), "%Y%b%d_%H_%M_%S", GetTime());
		BuildPath(Path_SM, recordBackup, sizeof(recordBackup), "data/trueexpert/backup/%s_%s%s.replay", g_map, buffer, g_replayType[i]);
		SaveRecord(team[i], recordBackup, time, team[i] == partner ? true : false);

		continue;
	}

	return;
}

void SaveRecord(int client, const char[] path, float time, bool load)
{
	g_frame[client].Resize(g_tick[client]);

	File f = OpenFile(path, "wb");
	f.WriteInt32(g_tick[client]);
	f.WriteInt32(GetSteamAccountID(client));
	f.WriteInt32(view_as<int>(time));
	
	LogToFileEx("addons/sourcemod/logs/trueexpert.log", "Replay tick: %i (%N)", g_tick[client], client);

	any data[sizeof(eFrame)];

	for(int i = 0; i < g_tick[client]; i++)
	{
		g_frame[client].GetArray(i, data, sizeof(eFrame));

		f.Write(data, sizeof(data), 4);

		continue;
	}

	delete f;

	if(load == true)
	{
		LoadRecord();
	}

	return;
}

void SQLGetReplayName(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetReplayName: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			char name[2][MAX_NAME_LENGTH] = {"", ""};

			for(int i = 0; i < sizeof(g_replayType); i++)
			{
				results.FetchString(i, name[i], MAX_NAME_LENGTH);
				Format(name[i], MAX_NAME_LENGTH, "RECORD %s", name[i]);

				for(int j = 1; j <= MaxClients; j++)
				{
					if(IsClientInGame(j) == true && IsFakeClient(j) == true && GetClientTeam(j) != CS_TEAM_SPECTATOR)
					{
						if(g_bot[i] == j && g_steamid3[i] > 0)
						{
							SetClientName(j, name[i]);
						}
					}
					
					continue;
				}

				continue;
			}
		}
	}

	return;
}

void LoadRecord()
{
	char filePath[2][PLATFORM_MAX_PATH] = {"", ""};

	for(int i = 0; i < sizeof(g_replayType); i++)
	{
		BuildPath(Path_SM, filePath[i], PLATFORM_MAX_PATH, "data/trueexpert/%s%s.replay", g_map, g_replayType[i]);

		if(FileExists(filePath[i]) == false)
		{
			return;
		}

		continue;
	}

	File f = null;
	int tickcount = 0;
	int time = 0;

	for(int i = 0; i < sizeof(g_replayType); i++)
	{
		f = OpenFile(filePath[i], "rb", false, "GAME");
		f.ReadInt32(tickcount);
		f.ReadInt32(g_steamid3[i]);
		f.ReadInt32(time);

		g_replayTickcount[g_bot[i]] = tickcount;

		any data[sizeof(eFrame)];

		delete g_frameCache[g_bot[i]];
		g_frameCache[g_bot[i]] = new ArrayList(sizeof(eFrame), tickcount);

		for(int j = 0; j < tickcount; j++)
		{
			if(f.Read(data, sizeof(eFrame), 4) >= 0)
			{
				g_frameCache[g_bot[i]].SetArray(j, data, sizeof(eFrame));
			}

			continue;
		}

		delete f;

		if(g_sql != INVALID_HANDLE)
		{
			Format(g_query, sizeof(g_query), "SELECT username, (SELECT username FROM users WHERE steamid = %i LIMIT 1) FROM users WHERE steamid = %i LIMIT 1", g_steamid3[1], g_steamid3[0]);
			g_sql.Query(SQLGetReplayName, g_query, _, DBPrio_Normal);
		}

		g_loaded[i] = true;
		g_tick[g_bot[i]] = 0;

		continue;
	}

	return;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(Trikz_GetTimerState(client) == true && g_frame[client] != INVALID_HANDLE)
	{
		eFrame frame;
		//GetClientAbsOrigin(client, frame.pos);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", frame.pos);
		float ang[3] = {0.0, ...};
		GetClientEyeAngles(client, ang);
		frame.ang[0] = ang[0];
		frame.ang[1] = ang[1];
		frame.buttons = buttons;
		frame.flags = GetEntityFlags(client);
		frame.movetype = GetEntityMoveType(client);

		char weaponCurrent[32] = "", weaponName[32] = "";
		GetClientWeapon(client, weaponCurrent, sizeof(weaponCurrent));

		for(int i = 0; i < sizeof(g_weaponName); i++)
		{
			FormatEx(weaponName, sizeof(weaponName), "weapon_%s", g_weaponName[i]);

			if(StrEqual(weaponCurrent, weaponName, true) == true)
			{
				frame.weapon = i + 1;

				break;
			}

			continue;
		}

		int partner = Trikz_GetClientPartner(client);
		int differ = g_tick[partner] - g_tick[client];

		if(differ > 6)
		{
			g_frame[client].Resize(g_tick[client] + differ);

			for(int i = 1; i <= differ; i++) //life is good. client which start lags compare partner ticks. so just align by partner.
			{
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", frame.pos);
				GetClientEyeAngles(client, ang);
				frame.ang[0] = ang[0];
				frame.ang[1] = ang[1];
				frame.buttons = buttons;
				frame.flags = GetEntityFlags(client);
				frame.movetype = GetEntityMoveType(client);
				g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame));

				continue;
			}
		}

		g_frame[client].Resize(++g_tick[client]);
		g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame));
	}

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsFakeClient(client) == true && IsPlayerAlive(client) == true)
	{
		for(int i = 0; i <= 2; i++)
		{
			vel[i] = 0.0; //prevent shakes at flat surface.

			continue;
		}

		if(g_tick[client] < g_replayTickcount[client] && g_loaded[0] == true && g_loaded[1] == true)
		{
			//if(IsClientInGame(client) == true && g_tick[client] == 0)
			//{
				//Trikz_Restart(client, false);

				//SetEntityCollisionGroup(client, 2);

				/*int flags = GetEntityFlags(client);

				if((flags & FL_ATCONTROLS) == 0)
				{
					SetEntityFlags(client, (flags | FL_ATCONTROLS));
				}*/
			//}

			eFrame frame;
			g_frameCache[client].GetArray(g_tick[client], frame, sizeof(eFrame));

			float posPrev[3] = {0.0, ...};
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", posPrev);
			//GetClientAbsOrigin(client, posPrev);

			float velNew[3] = {0.0, ...};
			MakeVectorFromPoints(posPrev, frame.pos, velNew);
			ScaleVector(velNew, g_tickrate);
			
			float ang[3] = {0.0, ...};
			ang[0] = frame.ang[0];
			ang[1] = frame.ang[1];

			buttons = frame.buttons;

			int flags = GetEntityFlags(client);
			ApplyFlags(flags, frame.flags, FL_ONGROUND);
			ApplyFlags(flags, frame.flags, FL_PARTIALGROUND);
			ApplyFlags(flags, frame.flags, FL_INWATER);
			ApplyFlags(flags, frame.flags, FL_SWIM);
			SetEntityFlags(client, flags);

			if(g_flagsLast[client] & FL_ONGROUND && !(frame.flags & FL_ONGROUND) && g_DoAnimationEvent != INVALID_HANDLE)
			{
				SDKCall(g_DoAnimationEvent, g_Linux == true ? EntIndexToEntRef(client) : client, 3, 0);
			}

			g_flagsLast[client] = frame.flags;

			MoveType movetype = MOVETYPE_NOCLIP;
			
			if(frame.movetype == MOVETYPE_LADDER)
			{
				movetype = frame.movetype;
			}

			SetEntityMoveType(client, movetype);

			char weaponCurrent[32] = "";
			GetClientWeapon(client, weaponCurrent, sizeof(weaponCurrent));

			char weaponName[32] = "";
			FormatEx(weaponName, sizeof(weaponName), "weapon_%s", g_weaponName[frame.weapon]);

			if(StrEqual(weaponCurrent, weaponName, true) == false)
			{
				for(int i = 0; i <= 4; i++)
				{
					int index = GetPlayerWeaponSlot(client, i);

					if(index != INVALID_ENT_REFERENCE)
					{
						char clsname[32] = "";
						GetEntityClassname(index, clsname, sizeof(clsname));

						if(StrEqual(clsname, weaponName, true) == true)
						{
							FakeClientCommandEx(client, "use %s", weaponName);

							break;
						}
					}
				}
			}

			if(g_tick[client] == 0)
			{
				Trikz_Restart(client, false);

				SetEntityCollisionGroup(client, 2);

				TeleportEntity(client, frame.pos, ang, view_as<float>({0.0, 0.0, 0.0}));

				g_tick[client]++;

				g_timeToStart = GetGameTime();
			}

			else if(0 < g_tick[client] < g_replayTickcount[client] && GetGameTime() - g_timeToStart >= 3.0)
			{
				float fix = GetVectorLength(velNew); //DataTable warning: (class player): Out-of-range value (-36931.695313 / -4096.000000) in SendPropFloat 'm_flFallVelocity', clamping.

				if(fix > 4096.000000)
				{
					TeleportEntity(client, frame.pos, ang, NULL_VECTOR);
				}

				else if(fix <= 4096.000000)
				{
					TeleportEntity(client, NULL_VECTOR, ang, velNew);
				}

				g_tick[client]++;

				g_timeToRestart = GetGameTime();
			}
		}

		else if(g_tick[client] == g_replayTickcount[client] && GetGameTime() - g_timeToRestart >= 3.0)
		{
			g_tick[client] = 0;
		}
	}

	return Plugin_Continue;
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(db == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect to database");

		return;
	}

	PrintToServer("Successfuly connected to database."); //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/

	g_sql = db;
	g_sql.SetCharset("utf8");

	return;
}

public void Trikz_OnTimerStart(int client, int partner)
{
	if(IsFakeClient(client) == false && IsFakeClient(partner) == false)
	{
		delete g_frame[client];
		g_frame[client] = new ArrayList((sizeof(eFrame)));
		g_tick[client] = 0;

		delete g_frame[partner];
		g_frame[partner] = new ArrayList((sizeof(eFrame)));
		g_tick[partner] = 0;
	}

	return;
}

public void Trikz_OnRecord(int client, int partner, float time)
{
	SetupSave(client, partner, time);

	return;
}

void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		if(IsFakeClient(client) == true)
		{
			//g_UpdateStepSound.HookEntity(Hook_Pre, client, Hook_UpdateStepSound_Pre);
			//g_UpdateStepSound.HookEntity(Hook_Post, client, Hook_UpdateStepSound_Post);

			SetEntityCollisionGroup(client, 2);
		}
	}

	return;
}

Action BotSilent(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(IsFakeClient(client) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

void ApplyFlags(int &flags1, int flags2, int flag)
{
	if((flags2 & flag) != 0)
	{
		flags1 |= flag;
	}

	else if((flags2 & flag) == 0)
	{
		flags1 &= ~flag;
	}

	return;
}

// Stops bot_quota from doing anything.
MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede;
}

// Remove flags from replay bots that cause CBasePlayer::UpdateStepSound to return without playing a footstep.
/*MRESReturn Hook_UpdateStepSound_Pre(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(pThis, MOVETYPE_WALK);
	}

	SetEntityFlags(pThis, GetEntityFlags(pThis) & ~FL_ATCONTROLS);

	return MRES_Ignored;
}*/

// Readd flags to replay bots now that CBasePlayer::UpdateStepSound is done.
/*MRESReturn Hook_UpdateStepSound_Post(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_WALK)
	{
		SetEntityMoveType(pThis, MOVETYPE_NOCLIP);
	}

	SetEntityFlags(pThis, GetEntityFlags(pThis) | FL_ATCONTROLS);

	return MRES_Ignored;
}*/

Action Hook_SayText2(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-replay-playback.sp#L2830
{
	int client = msg.ReadByte();
	msg.ReadByte();
	
	char message[24] = "";
	msg.ReadString(message, 24);

	if(IsFakeClient(client) == true && StrEqual(message, "#Cstrike_Name_Change", true) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

//https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-replay-playback.sp#L2130-L2151
public void OnEntityCreated(int entity, const char[] classname)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		return;
	}

	// trigger_once | trigger_multiple.. etc
	// func_door | func_door_rotating
	char name[3][8 + 1] = {"trigger_", "_door", "_button"};

	for(int i = 0; i < sizeof(name); i++)
	{
		if(StrContains(classname, name[i], true) != -1)
		{
			SDKHook(entity, SDKHook_StartTouch, HookTriggers);
			SDKHook(entity, SDKHook_EndTouch, HookTriggers);
			SDKHook(entity, SDKHook_Touch, HookTriggers);
			SDKHook(entity, SDKHook_Use, HookTriggers);
		}
	}

	if(StrContains(classname, "projectile", true) != -1)
	{
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade);
	}
}

Action HookTriggers(int entity, int other)
{
	if(IsValidClient(other) == true && IsFakeClient(other) == true)
	{
		return Plugin_Handled;
	}

	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);
	
	if(IsValidClient(owner) == true && IsFakeClient(owner) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action OnPlayerTransmit(int entity, int client) //entity - me, client - loop all clients
{
	//hide replay
	if(client != entity && IsValidClient(entity) == true && IsPlayerAlive(client) == true)
	{
		if(IsFakeClient(entity) == true)
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

Action TransmitNade(int entity, int client) //entity - nade, client - loop all clients
{
	//hide replay nades
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

	if(owner < 0)
	{
		owner = 0;
	}

	if(IsPlayerAlive(client) == true && IsValidEntity(entity) && owner != client && IsFakeClient(owner) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) == true || DHookIsNullParam(hParams, 2) == true || Trikz_GetDevmap() == true)
	{
		return MRES_Ignored;
	}

	int ent1 = DHookGetParam(hParams, 1); //touch reciever
	int ent2 = DHookGetParam(hParams, 2); //touch sender

	char classname[32] = "";
	GetEntityClassname(ent2, classname, sizeof(classname));

	if(StrContains(classname, "projectile", true) != -1)
	{
		if(IsValidClient(ent1) == true)
		{
			int owner = GetEntPropEnt(ent2, Prop_Data, "m_hOwnerEntity", 0);

			if(owner < 0)
			{
				owner = 0;
			}

			//if(Trikz_GetClientPartner(owner) != Trikz_GetClientPartner((Trikz_GetClientPartner(ent1))))
			if((IsFakeClient(ent1) == true && IsFakeClient(owner) == true) || (IsFakeClient(ent1) == false && IsFakeClient(owner) == false))
			{
				return MRES_Ignored;
			}

			DHookSetReturn(hReturn, false);

			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}
