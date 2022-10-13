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
Database g_database = null;
native bool Trikz_GetTimerState(int client);
int g_flagsLast[MAXPLAYER] = {0, ...};
Handle g_DoAnimationEvent = INVALID_HANDLE;
DynamicDetour g_MaintainBotQuota = null;
float g_timeToRestart[MAXPLAYER] = {0.0, ...};
int g_weapon[MAXPLAYER] = {0, ...};
bool g_switchPrevent[MAXPLAYER] = {false, ...};
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

public Plugin myinfo =
{
	name = "Replay",
	author = "Niks Smesh Jurēvičs",
	description = "Replay module for trueexpert.",
	version = "0.25",
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

		CreateTimer(3.0, timer_bot, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	else if(Trikz_GetDevmap() == true)
	{
		OnPluginEnd();
	}

	return;
}

public void OnClientPutInServer(int client)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		return;
	}

	if(Trikz_GetDevmap() == false)
	{
		SDKHook(client, SDKHook_SetTransmit, TransmitPlayer);
	}

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
		}
	}

	return;
}

public Action timer_bot(Handle timer)
{
	char record[PLATFORM_MAX_PATH] = "";
	BuildPath(Path_SM, record, sizeof(record), "data/trueexpert/%s.replay", g_map);

	char recordPartner[PLATFORM_MAX_PATH] = "";
	BuildPath(Path_SM, recordPartner, sizeof(recordPartner), "data/trueexpert/%s_partner.replay", g_map);

	if(FileExists(record) == true && FileExists(recordPartner) == true)
	{
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
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false && IsFakeClient(i) == true)
			{
				botShouldAdd--;
			}
		}

		if(botShouldAdd != 0)
		{
			for(int i = 1; i <= botShouldAdd; i++)
			{
				ServerCommand("bot_add");
			}
		}

		if(botShouldAdd == 0 && g_database != INVALID_HANDLE)
		{
			char query[512] = "";

			for(int i = 0; i <= 1; i++)
			{
				Format(query, sizeof(query), "SELECT username FROM users WHERE steamid = %i LIMIT 1", g_steamid3[i]);
				g_database.Query(SQLGetName, query, i);
			}
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false && IsFakeClient(i) == true)
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

				if(g_bot[0] != 0 && g_bot[1] != 0 && Trikz_GetClientPartner(i) == 0)
				{
					ServerCommand("bot_kick %N", i);
				}
			}
		}
	}

	return Plugin_Continue;
}

stock void SetupSave(int client, int partner, float time)
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

	char record[PLATFORM_MAX_PATH] = "";

	BuildPath(Path_SM, record, sizeof(record), "data/trueexpert/%s.replay", g_map);
	SaveRecord(client, record, time, false);

	//int partner = Trikz_GetClientPartner(client);
	BuildPath(Path_SM, record, sizeof(record), "data/trueexpert/%s_partner.replay", g_map);
	SaveRecord(partner, record, time, true);

	char recordBackup[PLATFORM_MAX_PATH] = "";
	char timeFormat[32] = "";

	FormatTime(timeFormat, sizeof(timeFormat), "%Y%b%d_%H_%M_%S", GetTime());

	BuildPath(Path_SM, recordBackup, sizeof(recordBackup), "data/trueexpert/backup/%s_%s.replay", g_map, timeFormat);
	SaveRecord(client, recordBackup, time, false);

	BuildPath(Path_SM, recordBackup, sizeof(recordBackup), "data/trueexpert/backup/%s_%s_partner.replay", g_map, timeFormat);
	SaveRecord(partner, recordBackup, time, false);

	return;
}

stock void SaveRecord(int client, const char[] path, float time, bool load)
{
	g_frame[client].Resize(g_tick[client]);

	File f = OpenFile(path, "wb");
	f.WriteInt32(g_tick[client]);
	f.WriteInt32(GetSteamAccountID(client));
	f.WriteInt32(view_as<int>(time));

	any data[sizeof(eFrame)];
	//any dataWrite[sizeof(eFrame) * 100];

	//int framesWritten = 0;

	for(int i = 0; i < g_tick[client]; i++)
	{
		g_frame[client].GetArray(i, data, sizeof(eFrame));

		//for(int j = 0; j < sizeof(eFrame); j++)
		//{
		//	dataWrite[(sizeof(eFrame) * framesWritten) + j] = data[j];
		//}

		//if(++framesWritten == 100 || i == g_tick[client] - 1)
		//{
		//	f.Write(dataWrite, sizeof(eFrame) * framesWritten, 4);
		//	framesWritten = 0;
		//}

		f.Write(data, sizeof(data), 4);
	}

	delete f;

	if(load == true)
	{
		LoadRecord();
	}

	return;
}

public void SQLGetName(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetName: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			char name[MAX_NAME_LENGTH] = "";
			results.FetchString(0, name, sizeof(name));

			Format(name, sizeof(name), "RECORD %s", name);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsFakeClient(i) == true && IsPlayerAlive(i) == true)
				{
					if(g_bot[data] == i && g_steamid3[data] > 0)
					{
						SetClientName(i, name);
					}
				}
			}
		}
	}

	return;
}

public void LoadRecord()
{
	char type[][] = {"", "_partner"};

	for(int i = 0; i < sizeof(type); i++)
	{
		char filePath[PLATFORM_MAX_PATH] = "";
		BuildPath(Path_SM, filePath, sizeof(filePath), "data/trueexpert/%s%s.replay", g_map, type[i]);

		if(FileExists(filePath) == true)
		{
			File f = OpenFile(filePath, "rb");

			int tickcount = 0;
			int time = 0;
			
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
			}

			delete f;

			if(g_database != INVALID_HANDLE)
			{
				char query[512] = "";
				Format(query, sizeof(query), "SELECT username FROM users WHERE steamid = %i", g_steamid3[i]);
				g_database.Query(SQLGetName, query, i);
			}

			g_loaded[i] = true;
			g_tick[g_bot[i]] = 0;
		}
	}

	return;
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(Trikz_GetTimerState(client) == true && g_frame[client] != INVALID_HANDLE)
	{
		eFrame frame;
		GetClientAbsOrigin(client, frame.pos);

		float ang[3] = {0.0, ...};
		GetClientEyeAngles(client, ang);

		frame.ang[0] = ang[0];
		frame.ang[1] = ang[1];

		frame.buttons = buttons;

		frame.flags = GetEntityFlags(client);

		frame.movetype = GetEntityMoveType(client);

		if(g_weapon[client] > 0)
		{
			g_switchPrevent[client] = true;

			frame.weapon = g_weapon[client];

			g_weapon[client] = 0;
		}

		else if(g_weapon[client] == 0)
		{
			if(g_tick[client] == 0)
			{
				char weaponName[32] = "";
				GetClientWeapon(client, weaponName, sizeof(weaponName));

				for(int i = 0; i < sizeof(g_weaponName); i++)
				{
					if(frame.weapon == i + 1)
					{
						char format[32] = "";
						Format(format, sizeof(format), "weapon_%s", g_weaponName[i]);

						if(StrEqual(weaponName, g_weaponName[i], true) == true)
						{
							frame.weapon = i + 1;
							
							break;
						}
					}
				}
			}
		}

		int differ = g_tick[Trikz_GetClientPartner(client)] - g_tick[client];

		if(differ > 0)
		{
			for(int i = 1; i <= differ; i++) //life is good. client which start lags compare partner ticks. so just align by partner.
			{
				if(g_frame[client].Length <= g_tick[client])
				{
					g_frame[client].Resize(g_tick[client] + 1);
				}

				g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame));
			}
		}

		else if(differ == 0)
		{
			if(g_frame[client].Length <= g_tick[client])
			{
				g_frame[client].Resize(g_tick[client] + 1);
			}

			g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame));
		}
	}

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsFakeClient(client) == true && IsPlayerAlive(client) == true && g_tick[client] < g_replayTickcount[client] && g_loaded[0] == true && g_loaded[1] == true)
	{
		if(IsClientInGame(client) == true && g_tick[client] == 0)
		{
			Trikz_Restart(client, false);

			SetEntityCollisionGroup(client, 2);

			//int flags = GetEntityFlags(client);

			//if((flags & FL_ATCONTROLS) == 0)
			//{
			//	SetEntityFlags(client, (flags | FL_ATCONTROLS));
			//}
		}

		vel[0] = 0.0; //prevent shakes at flat surface.
		vel[1] = 0.0;

		eFrame frame;
		g_frameCache[client].GetArray(g_tick[client]++, frame, sizeof(eFrame));

		float posPrev[3] = {0.0, ...};
		//GetEntPropVector(client, Prop_Send, "m_vecOrigin", posPrev);
		GetClientAbsOrigin(client, posPrev);

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
			SDKCall(g_DoAnimationEvent, g_Linux ? EntIndexToEntRef(client) : client, 3, 0);
		}

		g_flagsLast[client] = frame.flags;

		MoveType movetype = MOVETYPE_NOCLIP;
		
		if(frame.movetype == MOVETYPE_LADDER)
		{
			movetype = frame.movetype;
		}

		SetEntityMoveType(client, movetype);

		if(frame.weapon > 0)
		{
			for(int i = 0; i < sizeof(g_weaponName); i++)
			{
				if(frame.weapon == i + 1)
				{
					FakeClientCommandEx(client, "use weapon_%s", g_weaponName[i]);

					break;
				}
			}
		}

		if(g_tick[client] == 1)
		{
			TeleportEntity(client, frame.pos, ang, view_as<float>({0.0, 0.0, 0.0}));
		}

		else if(1 < g_tick[client] < g_replayTickcount[client])
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
		}

		else if(g_tick[client] == g_replayTickcount[client]) //Do unstuck
		{
			TeleportEntity(client, frame.pos, ang, NULL_VECTOR);
		}

		g_timeToRestart[client] = GetGameTime();
	}

	else if(IsFakeClient(client) == true && IsPlayerAlive(client) == true && g_tick[client] == g_replayTickcount[client] && GetGameTime() - g_timeToRestart[client] >= 3.0)
	{
		g_tick[client] = 0;
		g_tick[Trikz_GetClientPartner(client)] = 0;
	}

	return Plugin_Continue;
}

public void SQLConnect(Database db, const char[] error, any data)
{
	if(db == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect to database");

		return;
	}

	PrintToServer("Successfuly connected to database."); //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/

	g_database = db;

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

public void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		SDKHook(client, SDKHook_WeaponSwitchPost, SDKWeaponSwitch);
		
		if(IsFakeClient(client) == true)
		{
			g_UpdateStepSound.HookEntity(Hook_Pre, client, Hook_UpdateStepSound_Pre);
			g_UpdateStepSound.HookEntity(Hook_Post, client, Hook_UpdateStepSound_Post);

			SetEntityCollisionGroup(client, 2);
		}
	}

	return;
}

public Action BotSilent(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(IsFakeClient(client) == true)
	{
		event.BroadcastDisabled = true;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock void ApplyFlags(int &flags1, int flags2, int flag)
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

public void SDKWeaponSwitch(int client, int weapon)
{
	if(Trikz_GetTimerState(client) == true)
	{
		if(g_switchPrevent[client] == true)
		{
			g_switchPrevent[client] = false;
		}

		else if(g_switchPrevent[client] == false)
		{
			char classname[32] = "";
			GetEntityClassname(weapon, classname, sizeof(classname));

			char weaponName[32] = "";

			for(int i = 0; i < sizeof(g_weaponName); i++)
			{
				Format(weaponName, sizeof(weaponName), "weapon_%s", g_weaponName[i]);

				if(StrEqual(classname, weaponName, true))
				{
					g_weapon[client] = i + 1;

					break;
				}
			}
		}
	}

	return;
}

// Stops bot_quota from doing anything.
stock MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede;
}

// Remove flags from replay bots that cause CBasePlayer::UpdateStepSound to return without playing a footstep.
stock MRESReturn Hook_UpdateStepSound_Pre(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(pThis, MOVETYPE_WALK);
	}

	SetEntityFlags(pThis, GetEntityFlags(pThis) & ~FL_ATCONTROLS);

	return MRES_Ignored;
}

// Readd flags to replay bots now that CBasePlayer::UpdateStepSound is done.
stock MRESReturn Hook_UpdateStepSound_Post(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_WALK)
	{
		SetEntityMoveType(pThis, MOVETYPE_NOCLIP);
	}

	SetEntityFlags(pThis, GetEntityFlags(pThis) | FL_ATCONTROLS);

	return MRES_Ignored;
}

public Action Hook_SayText2(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-replay-playback.sp#L2830
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
	if(StrContains(classname, "trigger_") != -1 || StrContains(classname, "_door") != -1 || StrContains(classname, "_button") != -1)
	{
		SDKHook(entity, SDKHook_StartTouch, HookTriggers);
		SDKHook(entity, SDKHook_EndTouch, HookTriggers);
		SDKHook(entity, SDKHook_Touch, HookTriggers);
		SDKHook(entity, SDKHook_Use, HookTriggers);
	}

	if(StrContains(classname, "projectile", false) != -1)
	{
		SDKHook(entity, SDKHook_SetTransmit, TransmitNade);
	}
}

public Action HookTriggers(int entity, int other)
{
	if(0 < other <= MaxClients && IsFakeClient(other) == true)
	{
		return Plugin_Handled;
	}

	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);
	
	if(0 < owner <= MaxClients && IsFakeClient(owner) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action TransmitPlayer(int entity, int client) //entity - me, client - loop all clients
{
	//hide replay
	if(client != entity && 0 < entity <= MaxClients && IsPlayerAlive(client) == true)
	{
		if(IsFakeClient(entity) == true)
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action TransmitNade(int entity, int client) //entity - nade, client - loop all clients
{
	//hide replay nades
	int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

	if(owner < 0)
	{
		owner = 0;
	}

	if(IsPlayerAlive(client) == true && entity > 0 && owner != client && IsFakeClient(owner) == true)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) == true || DHookIsNullParam(hParams, 2) == true || Trikz_GetDevmap() == true)
	{
		return MRES_Ignored;
	}

	int ent1 = DHookGetParam(hParams, 1); //touch reciever
	int ent2 = DHookGetParam(hParams, 2); //touch sender

	char classname[32] = "";
	GetEntityClassname(ent2, classname, sizeof(classname));

	if(StrContains(classname, "projectile", false) != -1)
	{
		if(0 < ent1 <= MaxClients)
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
