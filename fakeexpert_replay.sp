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

char g_map[192]
ArrayList g_frame[MAXPLAYERS + 1]
ArrayList g_frameCache[MAXPLAYERS + 1]
enum struct eFrame
{
	float pos[3]
	float ang[2]
	int buttons
	int flags
	MoveType movetype
	int weapon
}
int g_tick[MAXPLAYERS + 1]
int g_steamid3[2]
Database g_database
native bool Trikz_GetTimerState(int client)
int g_flagsLast[MAXPLAYERS + 1]
Handle g_DoAnimationEvent
DynamicDetour g_MaintainBotQuota
float g_timeToRestart[MAXPLAYERS + 1]
int g_weapon[MAXPLAYERS + 1]
bool g_switchPrevent[MAXPLAYERS + 1]
DynamicHook g_UpdateStepSound
bool g_Linux
native int Trikz_GetClientPartner(int client)
native int Trikz_SetPartner(int client, int partner)
native int Trikz_Restart(int client)
int g_bot[2]
bool g_loaded[2]
float g_tickrate
int g_replayTickcount[MAXPLAYERS + 1]
char g_weaponName[][] = {"knife", "glock", "usp", "flashbang", "hegrenade", "smokegrenade", "p228", "deagle", "elite", "fiveseven", 
						"m3", "xm1014", "galil", "ak47", "scout", "sg552", 
						"awp", "g3sg1", "famas", "m4a1", "aug", "sg550", 
						"mac10", "tmp", "mp5navy", "ump45", "p90", "m249", "c4"}
native int Trikz_GetDevmap()

public Plugin myinfo =
{
	name = "Replay",
	author = "Smesh(Nick Yurevich)",
	description = "Replay module for fakeexpert.",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	Database.Connect(SQLConnect, "fakeexpert")
	HookEvent("player_spawn", OnSpawn, EventHookMode_Post)
	HookEvent("player_changename", OnChangeName, EventHookMode_Pre)
	GameData gamedata = new GameData("fakeexpert")
	g_Linux = (gamedata.GetOffset("OS") == 2)
	StartPrepSDKCall(g_Linux ? SDKCall_Static : SDKCall_Player)
	if(PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "Player::DoAnimationEvent"))
	{
		if(g_Linux)
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_ByRef)
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue)
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue)
	}
	g_DoAnimationEvent = EndPrepSDKCall()
	g_MaintainBotQuota = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address)
	DHookSetFromConf(g_MaintainBotQuota, gamedata, SDKConf_Signature, "BotManager::MaintainBotQuota")
	g_MaintainBotQuota.Enable(Hook_Pre, Detour_MaintainBotQuota)
	int offset
	if((offset = GameConfGetOffset(gamedata, "CBasePlayer::UpdateStepSound")) != -1)
	{
		g_UpdateStepSound = new DynamicHook(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity)
		g_UpdateStepSound.AddParam(HookParamType_ObjectPtr)
		g_UpdateStepSound.AddParam(HookParamType_VectorPtr)
		g_UpdateStepSound.AddParam(HookParamType_VectorPtr)
	}
	delete gamedata
	g_tickrate = 1.0 / GetTickInterval()
}

public void OnPluginEnd()
{
	SetConVarFlags(FindConVar("bot_quota"), GetConVarFlags(FindConVar("bot_quota")) | FCVAR_NOTIFY)
	ServerCommand("bot_kick")
}

public void OnMapStart()
{
	if(!Trikz_GetDevmap())
	{
		GetCurrentMap(g_map, 192)
		CreateTimer(3.0, timer_bot, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
	}
	else
		OnPluginEnd()
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))
	{
		for(int i = 0; i <= 1; i++)
		{
			g_bot[i] = 0
			g_loaded[i] = false
		}
	}
}

Action timer_bot(Handle timer)
{
	char record[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, record, PLATFORM_MAX_PATH, "data/fakeexpert/%s.replay", g_map)
	char recordPartner[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, recordPartner, PLATFORM_MAX_PATH, "data/fakeexpert/%s_partner.replay", g_map)
	if(FileExists(record) && FileExists(recordPartner))
	{
		ConVar cvForce = FindConVar("bot_stop")
		cvForce.SetInt(1)
		cvForce = FindConVar("bot_join_after_player")
		cvForce.SetInt(0)
		cvForce = FindConVar("bot_quota")
		cvForce.Flags = GetConVarFlags(FindConVar("bot_quota")) &~ FCVAR_NOTIFY
		cvForce = FindConVar("bot_flipout")
		cvForce.SetInt(1)
		cvForce = FindConVar("bot_zombie")
		cvForce.SetInt(1)
		int botShouldAdd = 2
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
				botShouldAdd--
		if(botShouldAdd != 0)
			for(int i = 1; i <= botShouldAdd; i++)
				ServerCommand("bot_add")
		if(!botShouldAdd && g_database)
		{
			char query[512]
			for(int i = 0; i <= 1; i++)
			{
				Format(query, 512, "SELECT username FROM users WHERE steamid = %i LIMIT 1", g_steamid3[i])
				g_database.Query(SQLGetName, query, i)
			}
		}
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
			{
				if(!g_bot[0])
					g_bot[0] = i
				if(g_bot[0] != i)
					g_bot[1] = i
				if(g_bot[1])
				{
					if(!Trikz_GetClientPartner(g_bot[0]))
					{
						Trikz_SetPartner(g_bot[0], g_bot[1])
						if(IsClientInGame(g_bot[0]) && !IsPlayerAlive(g_bot[0]))
							CS_RespawnPlayer(g_bot[0])
						if(IsClientInGame(g_bot[1]) && !IsPlayerAlive(g_bot[1]))
							CS_RespawnPlayer(g_bot[1])
						LoadRecord()
					}
				}
			}
		}
	}
}

void SetupSave(int client, float time)
{
	char dir[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, dir, PLATFORM_MAX_PATH, "data/fakeexpert")
	if(!DirExists(dir))
		CreateDirectory(dir, 511)
	char dirBackup[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, dirBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup")
	if(!DirExists(dirBackup))
		CreateDirectory(dirBackup, 511)
	char record[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, record, PLATFORM_MAX_PATH, "data/fakeexpert/%s.replay", g_map)
	SaveRecord(client, record, time)
	BuildPath(Path_SM, record, PLATFORM_MAX_PATH, "data/fakeexpert/%s_partner.replay", g_map)
	SaveRecord(Trikz_GetClientPartner(client), record, time)
	char recordBackup[PLATFORM_MAX_PATH]
	char timeFormat[32]
	FormatTime(timeFormat, 32, "%Y%b%d_%H_%M_%S", GetTime())
	BuildPath(Path_SM, recordBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup/%s_%s.replay", g_map, timeFormat)
	SaveRecord(client, recordBackup, time)
	BuildPath(Path_SM, recordBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup/%s_%s_partner.replay", g_map, timeFormat)
	SaveRecord(Trikz_GetClientPartner(client), recordBackup, time, true)
}

void SaveRecord(int client, char[] path, float time, bool load = false)
{
	g_frame[client].Resize(g_tick[client])
	File f = OpenFile(path, "wb")
	f.WriteInt32(g_tick[client])
	f.WriteInt32(GetSteamAccountID(client))
	f.WriteInt32(view_as<int>(time))
	any data[sizeof(eFrame)]
	any dataWrite[sizeof(eFrame) * 100]
	int framesWritten
	for(int i = 0; i < g_tick[client]; i++)
	{
		g_frame[client].GetArray(i, data, sizeof(eFrame))
		for(int j = 0; j < sizeof(eFrame); j++)
			dataWrite[(sizeof(eFrame) * framesWritten) + j] = data[j]
		if(++framesWritten == 100 || i == g_tick[client] - 1)
		{
			f.Write(dataWrite, sizeof(eFrame) * framesWritten, 4)
			framesWritten = 0
		}
	}
	delete f
	if(load)
		LoadRecord()
}

void SQLGetName(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetName: %s", error)
	else
	{
		if(results.FetchRow())
		{
			char name[MAX_NAME_LENGTH]
			results.FetchString(0, name, MAX_NAME_LENGTH)
			Format(name, MAX_NAME_LENGTH, "RECORD %s", name)
			for(int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i))
					if(g_bot[data] == i && g_steamid3[data])
						SetClientName(i, name)
		}
	}
}

void LoadRecord()
{
	char filePath[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, filePath, PLATFORM_MAX_PATH, "data/fakeexpert/%s.replay", g_map)
	if(FileExists(filePath))
	{
		File f = OpenFile(filePath, "rb")
		int tickcount
		int time
		f.ReadInt32(tickcount)
		f.ReadInt32(g_steamid3[0])
		f.ReadInt32(time)
		g_replayTickcount[g_bot[0]] = tickcount
		any data[sizeof(eFrame)]
		delete g_frameCache[g_bot[0]]
		g_frameCache[g_bot[0]] = new ArrayList(sizeof(eFrame), tickcount)
		for(int i = 0; i < tickcount; i++)
			if(f.Read(data, sizeof(eFrame), 4) >= 0)
				g_frameCache[g_bot[0]].SetArray(i, data, sizeof(eFrame))
		delete f
		if(g_database)
		{
			char query[512]
			Format(query, 512, "SELECT username FROM users WHERE steamid = %i", g_steamid3[0])
			g_database.Query(SQLGetName, query, 0)
		}
		g_loaded[0] = true
		g_tick[g_bot[0]] = 0
	}
	BuildPath(Path_SM, filePath, PLATFORM_MAX_PATH, "data/fakeexpert/%s_partner.replay", g_map)
	if(FileExists(filePath))
	{
		File f = OpenFile(filePath, "rb")
		int tickcount
		int time
		f.ReadInt32(tickcount)
		f.ReadInt32(g_steamid3[1])
		f.ReadInt32(time)
		g_replayTickcount[g_bot[1]] = tickcount
		any data[sizeof(eFrame)]
		delete g_frameCache[g_bot[1]]
		g_frameCache[g_bot[1]] = new ArrayList(sizeof(eFrame), tickcount)
		for(int i = 0; i < tickcount; i++)
			if(f.Read(data, sizeof(eFrame), 4) >= 0)
				g_frameCache[g_bot[1]].SetArray(i, data, sizeof(eFrame))
		delete f
		if(g_database)
		{
			char query[512]
			Format(query, 512, "SELECT username FROM users WHERE steamid = %i", g_steamid3[1])
			g_database.Query(SQLGetName, query, 1)
		}
		g_loaded[1] = true
		g_tick[g_bot[1]] = 0
	}
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(Trikz_GetTimerState(client) && g_frame[client])
	{
		eFrame frame
		GetClientAbsOrigin(client, frame.pos)
		float ang[3]
		GetClientEyeAngles(client, ang)
		frame.ang[0] = ang[0]
		frame.ang[1] = ang[1]
		frame.buttons = buttons
		frame.flags = GetEntityFlags(client)
		frame.movetype = GetEntityMoveType(client)
		if(g_weapon[client])
		{
			g_switchPrevent[client] = true
			frame.weapon = g_weapon[client]
			g_weapon[client] = 0
		}
		else
		{
			if(!g_tick[client])
			{
				char weaponName[32]
				GetClientWeapon(client, weaponName, 32)
				for(int i = 0; i < sizeof(g_weaponName); i++)
				{
					if(frame.weapon == i + 1)
					{
						char format[32]
						Format(format, 32, "weapon_%s", g_weaponName[i])
						if(StrEqual(weaponName, g_weaponName[i]))
						{
							frame.weapon = i + 1
							break
						}
					}
				}
			}
		}
		int differ = g_tick[Trikz_GetClientPartner(client)] - g_tick[client]
		if(differ)
		{
			for(int i = 1; i <= differ; i++) //life is good. client which start lags compare partner ticks. so just align by partner.
			{
				if(g_frame[client].Length <= g_tick[client])
					g_frame[client].Resize(g_tick[client] + (RoundToCeil(g_tickrate) * 2))
				g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame))
			}
		}
		else
		{
			if(g_frame[client].Length <= g_tick[client])
				g_frame[client].Resize(g_tick[client] + (RoundToCeil(g_tickrate) * 2))
			g_frame[client].SetArray(g_tick[client]++, frame, sizeof(eFrame))
		}
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsFakeClient(client) && IsPlayerAlive(client) && g_tick[client] < g_replayTickcount[client] && g_loaded[0] && g_loaded[1])
	{
		if(IsClientInGame(client) && !g_tick[client])
			Trikz_Restart(client)
		vel[0] = 0.0 //prevent shakes at flat surface.
		vel[1] = 0.0
		vel[2] = 0.0
		eFrame frame
		g_frameCache[client].GetArray(g_tick[client]++, frame, sizeof(eFrame))
		float posPrev[3]
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", posPrev)
		float velPos[3]
		MakeVectorFromPoints(posPrev, frame.pos, velPos)
		ScaleVector(velPos, g_tickrate)
		float ang[3]
		ang[0] = frame.ang[0]
		ang[1] = frame.ang[1]
		int flags = GetEntityFlags(client)
		ApplyFlags(flags, frame.flags, FL_ONGROUND)
		ApplyFlags(flags, frame.flags, FL_PARTIALGROUND)
		ApplyFlags(flags, frame.flags, FL_INWATER)
		ApplyFlags(flags, frame.flags, FL_SWIM)
		SetEntityFlags(client, flags)
		if(g_flagsLast[client] & FL_ONGROUND && !(frame.flags & FL_ONGROUND) && g_DoAnimationEvent != INVALID_HANDLE)
			SDKCall(g_DoAnimationEvent, g_Linux ? EntIndexToEntRef(client) : client, 3, 0)
		g_flagsLast[client] = frame.flags
		MoveType movetype = MOVETYPE_NOCLIP
		if(frame.movetype == MOVETYPE_LADDER)
			movetype = frame.movetype
		SetEntityMoveType(client, movetype)
		if(frame.weapon)
		{
			//char classname[32]
			//char weaponName[32]
			for(int i = 0; i < sizeof(g_weaponName); i++)
			{
				if(frame.weapon == i + 1)
				{
					/*for(int j = 0; j <= 4; j++)
					{
						for(int k = 0; k <= 3; k++)
						{
							if(IsValidEntity(GetPlayerWeaponSlot(client, j)))
							{
								GetEntityClassname(GetPlayerWeaponSlot(client, j), classname, 32)
								Format(weaponName, 32, "weapon_%s", g_weaponName[i])
								if(StrEqual(classname, weaponName))
									SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, j))
							}
						}
					}*/
					FakeClientCommandEx(client, "use weapon_%s", g_weaponName[i])
					break
				}
			}
		}
		if(g_tick[client] == 1)
			TeleportEntity(client, frame.pos, ang, view_as<float>({0.0, 0.0, 0.0}))
		else if(1 < g_tick[client] < g_replayTickcount[client])
			TeleportEntity(client, NULL_VECTOR, ang, velPos)
		else if(g_tick[client] == g_replayTickcount[client])
			TeleportEntity(client, frame.pos, ang, NULL_VECTOR)
		buttons = frame.buttons
		g_timeToRestart[client] = GetGameTime()
	}
	else if(IsFakeClient(client) && IsPlayerAlive(client) && g_tick[client] == g_replayTickcount[client] && GetGameTime() - g_timeToRestart[client] >= 3.0)
	{
		g_tick[client] = 0
		g_tick[Trikz_GetClientPartner(client)] = 0
	}
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(!db)
	{
		PrintToServer("Failed to connect to database")
		return
	}
	PrintToServer("Successfuly connected to database.") //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/
	g_database = db
}

public void Trikz_Start(int client)
{
	if(!IsFakeClient(client))
	{
		delete g_frame[client]
		g_frame[client] = new ArrayList((sizeof(eFrame)))
		g_tick[client] = 0
	}
}

public void Trikz_Record(int client, float time)
{
	SetupSave(client, time)
}

void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		SDKHook(client, SDKHook_WeaponSwitchPost, SDKWeaponSwitch)
		if(IsFakeClient(client))
		{
			g_UpdateStepSound.HookEntity(Hook_Pre, client, Hook_UpdateStepSound_Pre)
			g_UpdateStepSound.HookEntity(Hook_Post, client, Hook_UpdateStepSound_Post)
		}
	}
}

Action OnChangeName(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(IsFakeClient(client))
		SetEventBroadcast(event, true)
}

void ApplyFlags(int &flags1, int flags2, int flag)
{
	if((flags2 & flag) != 0)
		flags1 |= flag
	else
		flags1 &= ~flag
}

void SDKWeaponSwitch(int client, int weapon)
{
	if(Trikz_GetTimerState(client))
	{
		if(g_switchPrevent[client])
			g_switchPrevent[client] = false
		else
		{
			char classname[32]
			GetEntityClassname(weapon, classname, 32)
			char weaponName[32]
			for(int i = 0; i < sizeof(g_weaponName); i++)
			{
				Format(weaponName, 32, "weapon_%s", g_weaponName[i])
				if(StrEqual(classname, weaponName))
				{
					g_weapon[client] = i + 1
					break
				}
			}
		}
	}
}

// Stops bot_quota from doing anything.
MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede
}

// Remove flags from replay bots that cause CBasePlayer::UpdateStepSound to return without playing a footstep.
MRESReturn Hook_UpdateStepSound_Pre(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_NOCLIP)
		SetEntityMoveType(pThis, MOVETYPE_WALK)
	SetEntityFlags(pThis, GetEntityFlags(pThis) & ~FL_ATCONTROLS)
	return MRES_Ignored
}

// Readd flags to replay bots now that CBasePlayer::UpdateStepSound is done.
MRESReturn Hook_UpdateStepSound_Post(int pThis, DHookParam hParams)
{
	if(GetEntityMoveType(pThis) == MOVETYPE_WALK)
		SetEntityMoveType(pThis, MOVETYPE_NOCLIP)
	SetEntityFlags(pThis, GetEntityFlags(pThis) | FL_ATCONTROLS)
	return MRES_Ignored
}
