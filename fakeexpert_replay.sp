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

char gS_map[192]
ArrayList gA_frame[MAXPLAYERS + 1]
ArrayList gA_frameCache[2]
int gI_frameCount[MAXPLAYERS + 1]
enum struct eFrame
{
	float pos[3]
	float ang[2]
	int buttons
	int flags
	MoveType movetype
	int weapon
}
int gI_tick[2]
int gI_steam3[2]
Database gD_database
native bool Trikz_GetTimerStateTrikz(int client)
int gI_flagsLast[MAXPLAYERS + 1]
Handle gH_DoAnimationEvent
DynamicDetour gH_MaintainBotQuota
float gF_time
int gI_weapon[MAXPLAYERS + 1]
bool gB_switchPrevent
DynamicHook gH_UpdateStepSound
bool gB_Linux
native int Trikz_GetClientPartner(int client)
native int Trikz_SetTrikzPartner(int client, int partner)
int gI_bot[2]

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
	HookEvent("round_start", OnRoundStart, EventHookMode_Post)
	HookEvent("player_spawn", OnSpawn, EventHookMode_Post)
	GameData gamedata = new GameData("fakeexpert")
	gB_Linux = (gamedata.GetOffset("OS") == 2)
	StartPrepSDKCall(gB_Linux ? SDKCall_Static : SDKCall_Player)
	if(PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "Player::DoAnimationEvent"))
	{
		if(gB_Linux)
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_ByRef)
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue)
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue)
	}
	gH_DoAnimationEvent = EndPrepSDKCall()
	int offset
	if((offset = GameConfGetOffset(gamedata, "CBasePlayer::UpdateStepSound")) != -1)
	{
		gH_UpdateStepSound = new DynamicHook(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity)
		gH_UpdateStepSound.AddParam(HookParamType_ObjectPtr)
		gH_UpdateStepSound.AddParam(HookParamType_VectorPtr)
		gH_UpdateStepSound.AddParam(HookParamType_VectorPtr)
	}
	gH_MaintainBotQuota = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address)
	DHookSetFromConf(gH_MaintainBotQuota, gamedata, SDKConf_Signature, "BotManager::MaintainBotQuota")
	gH_MaintainBotQuota.Enable(Hook_Pre, Detour_MaintainBotQuota)
	delete gamedata
}

public void OnMapStart()
{
	GetCurrentMap(gS_map, 192)
	CreateTimer(3.0, timer_bot, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
	gI_bot[0] = 0
	gI_bot[1] = 0
}

Action timer_bot(Handle timer)
{
	int replayRunning
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
			replayRunning++
	if(replayRunning < 2)
		ServerCommand("bot_add")
	int botCount
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
			botCount++
	if(botCount > 2)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
			{
				ServerCommand("bot_kick %N", i)
				break
			}
		}
	}
	if(!replayRunning)
	{
		char sQuery[512]
		Format(sQuery, 512, "SELECT username FROM users WHERE steamid = %i", gI_steam3[0])
		gD_database.Query(SQLGetName, sQuery, 0)
		Format(sQuery, 512, "SELECT username FROM users WHERE steamid = %i", gI_steam3[1])
		gD_database.Query(SQLGetName, sQuery, 1)
	}
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsClientSourceTV(i) && IsFakeClient(i))
		{
			if(!gI_bot[0])
			{
				gI_bot[0] = i
				continue
			}
			if(!gI_bot[1])
			{
				if(gI_bot[0] != i)
				{
					gI_bot[1] = i
					break
				}
			}
			if(gI_bot[1])
			{
				if(!Trikz_GetClientPartner(gI_bot[1]))
				{
					Trikz_SetTrikzPartner(gI_bot[0], gI_bot[1])
					Trikz_SetTrikzPartner(gI_bot[1], gI_bot[0])
				}
			}
		}
	}
}

void SetupSave(int client, float time)
{
	char sDir[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, sDir, PLATFORM_MAX_PATH, "data/fakeexpert")
	if(!DirExists(sDir))
		CreateDirectory(sDir, 511)
	char sDirBackup[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, sDirBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup")
	if(!DirExists(sDirBackup))
		CreateDirectory(sDirBackup, 511)
	char sRecord[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, sRecord, PLATFORM_MAX_PATH, "data/fakeexpert/%s.replay", gS_map)
	SaveRecord(client, sRecord, time, 0)
	BuildPath(Path_SM, sRecord, PLATFORM_MAX_PATH, "data/fakeexpert/%s_partner.replay", gS_map)
	SaveRecord(Trikz_GetClientPartner(client), sRecord, time, 0)
	char sRecordBackup[PLATFORM_MAX_PATH]
	char sFormatTime[32]
	FormatTime(sFormatTime, 32, "%Y%b%d_%H_%M_%S", GetTime())
	BuildPath(Path_SM, sRecordBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup/%s_%s.replay", gS_map, sFormatTime)
	SaveRecord(client, sRecordBackup, time, 1)
	BuildPath(Path_SM, sRecordBackup, PLATFORM_MAX_PATH, "data/fakeexpert/backup/%s_%s_partner.replay", gS_map, sFormatTime)
	SaveRecord(Trikz_GetClientPartner(client), sRecordBackup, time, 1)
}

void SaveRecord(int client, char[] path, float time, int type)
{
	File f = OpenFile(path, "wb")
	f.WriteInt32(gI_frameCount[client])
	gI_steam3[type] = GetSteamAccountID(client)
	f.WriteInt32(gI_steam3[type])
	f.WriteInt32(view_as<int>(time))
	any aData[sizeof(eFrame)]
	any aDataWrite[sizeof(eFrame) * 100]
	int iFramesWritten
	for(int i = 0; i < gI_frameCount[client]; i++)
	{
		gA_frame[client].GetArray(i, aData, sizeof(eFrame))
		for(int j = 0; j < sizeof(eFrame); j++)
			aDataWrite[(sizeof(eFrame) * iFramesWritten) + j] = aData[j];
		if(++iFramesWritten == 100 || i == gI_frameCount[client] - 1)
		{
			f.Write(aDataWrite, sizeof(eFrame) * iFramesWritten, 4)
			iFramesWritten = 0
		}
	}
	delete f
	LoadRecord()
}

void SQLGetName(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		char sName[MAX_NAME_LENGTH]
		results.FetchString(0, sName, MAX_NAME_LENGTH)
		Format(sName, MAX_NAME_LENGTH, "RECORD %s", sName)
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i))
				if(gI_bot[data] == i && gI_steam3[data])
					SetClientName(i, sName)
	}
}

void LoadRecord()
{
	ConVar cvForce = FindConVar("bot_stop")
	cvForce.SetInt(1)
	cvForce = FindConVar("bot_join_after_player")
	cvForce.SetInt(0)
	cvForce = FindConVar("bot_quota")
	cvForce.SetInt(0)
	cvForce = FindConVar("bot_flipout")
	cvForce.SetInt(1)
	cvForce = FindConVar("bot_zombie")
	cvForce.SetInt(1)
	char sFile[PLATFORM_MAX_PATH]
	BuildPath(Path_SM, sFile, PLATFORM_MAX_PATH, "data/fakeexpert/%s.replay", gS_map)
	File f = OpenFile(sFile, "rb")
	int frameCount
	int time
	f.ReadInt32(frameCount)
	f.ReadInt32(gI_steam3[0])
	f.ReadInt32(time)
	gI_tick[1] = frameCount
	any aData[sizeof(eFrame)]
	delete gA_frameCache[0]
	gA_frameCache[0] = new ArrayList(sizeof(eFrame), frameCount)
	for(int i = 0; i < frameCount; i++)
	{
			if(f.Read(aData, sizeof(eFrame), 4) >= 0)
				gA_frameCache[0].SetArray(i, aData, sizeof(eFrame))
	}
	delete f
	char sQuery[512]
	Format(sQuery, 512, "SELECT username FROM users WHERE steamid = %i", gI_steam3[0])
	gD_database.Query(SQLGetName, sQuery, 0)
	BuildPath(Path_SM, sFile, PLATFORM_MAX_PATH, "data/fakeexpert/%s_replay.replay", gS_map)
	f = OpenFile(sFile, "rb")
	f.ReadInt32(frameCount)
	f.ReadInt32(gI_steam3[1])
	f.ReadInt32(time)
	gI_tick[1] = frameCount
	delete gA_frameCache[1]
	gA_frameCache[1] = new ArrayList(sizeof(eFrame), frameCount)
	for(int i = 0; i < frameCount; i++)
	{
			if(f.Read(aData, sizeof(eFrame), 4) >= 0)
				gA_frameCache[1].SetArray(i, aData, sizeof(eFrame))
	}
	delete f
	gI_tick[0] = 0
	Format(sQuery, 512, "SELECT username FROM users WHERE steamid = %i", gI_steam3[1])
	gD_database.Query(SQLGetName, sQuery, 1)
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if(Trikz_GetTimerStateTrikz(client))
	{
		if(gA_frame[client].Length <= gI_frameCount[client])
			gA_frame[client].Resize(gI_frameCount[client] + (100 * 2))
		eFrame frame
		GetClientAbsOrigin(client, frame.pos)
		float ang[3]
		GetClientEyeAngles(client, ang)
		frame.ang[0] = ang[0]
		frame.ang[1] = ang[1]
		frame.buttons = buttons
		frame.flags = GetEntityFlags(client)
		frame.movetype = GetEntityMoveType(client)
		if(gI_weapon[client])
		{
			gB_switchPrevent = true
			frame.weapon = gI_weapon[client]
			gI_weapon[client] = 0
		}
		gA_frame[client].SetArray(gI_frameCount[client]++, frame, sizeof(eFrame))
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsFakeClient(client) && IsPlayerAlive(client) && gI_tick[0] < gI_tick[1] && gI_bot[0] && gI_bot[1])
	{
		buttons = 0
		vel[0] = 0.0 //Prevent bot shaking.
		vel[1] = 0.0
		//vel[2] = 0.0
		eFrame frame
		if(gI_bot[0] == client)
		{
			gA_frameCache[0].GetArray(gI_tick[0]++, frame, sizeof(eFrame))
			float posPrev[3]
			GetClientAbsOrigin(client, posPrev)
			float velPos[3]
			MakeVectorFromPoints(posPrev, frame.pos, velPos)
			ScaleVector(velPos, 100.0)
			buttons = frame.buttons
			float ang[3]
			ang[0] = frame.ang[0]
			ang[1] = frame.ang[1]
			if(gI_tick[0] == 1)
			{
				TeleportEntity(client, frame.pos, ang, view_as<float>({0.0, 0.0, 0.0}))
				return Plugin_Changed
			}
			MoveType movetype = MOVETYPE_NOCLIP
			int flags = GetEntityFlags(client)
			ApplyFlags(flags, frame.flags, FL_ONGROUND)
			ApplyFlags(flags, frame.flags, FL_PARTIALGROUND)
			ApplyFlags(flags, frame.flags, FL_INWATER)
			ApplyFlags(flags, frame.flags, FL_SWIM)
			SetEntityFlags(client, flags)
			if(gI_flagsLast[client] & FL_ONGROUND && !(frame.flags & FL_ONGROUND) && gH_DoAnimationEvent != INVALID_HANDLE)
				SDKCall(gH_DoAnimationEvent, gB_Linux ? EntIndexToEntRef(client) : client, 3, 0)
			if(frame.movetype == MOVETYPE_LADDER)
				movetype = frame.movetype
			gI_flagsLast[client] = frame.flags
			SetEntityMoveType(client, movetype)
			switch(frame.weapon)
			{
				case 1:
					FakeClientCommand(client, "use weapon_knife")
				case 2:
					FakeClientCommand(client, "use weapon_glock")
				case 3:
					FakeClientCommand(client, "use weapon_usp")
				case 4:
					FakeClientCommand(client, "use weapon_flashbang")
			}
			TeleportEntity(client, NULL_VECTOR, ang, velPos)
		}
		if(gI_bot[1] == client)
		{
			gA_frameCache[1].GetArray(gI_tick[0], frame, sizeof(eFrame))
			float posPrev[3]
			GetClientAbsOrigin(client, posPrev)
			float velPos[3]
			MakeVectorFromPoints(posPrev, frame.pos, velPos)
			ScaleVector(velPos, 100.0)
			buttons = frame.buttons
			float ang[3]
			ang[0] = frame.ang[0]
			ang[1] = frame.ang[1]
			if(gI_tick[0] == 1)
			{
				TeleportEntity(client, frame.pos, ang, view_as<float>({0.0, 0.0, 0.0}))
				return Plugin_Changed
			}
			MoveType movetype = MOVETYPE_NOCLIP
			int flags = GetEntityFlags(client)
			ApplyFlags(flags, frame.flags, FL_ONGROUND)
			ApplyFlags(flags, frame.flags, FL_PARTIALGROUND)
			ApplyFlags(flags, frame.flags, FL_INWATER)
			ApplyFlags(flags, frame.flags, FL_SWIM)
			SetEntityFlags(client, flags)
			if(gI_flagsLast[client] & FL_ONGROUND && !(frame.flags & FL_ONGROUND) && gH_DoAnimationEvent != INVALID_HANDLE)
				SDKCall(gH_DoAnimationEvent, gB_Linux ? EntIndexToEntRef(client) : client, 3, 0)
			if(frame.movetype == MOVETYPE_LADDER)
				movetype = frame.movetype
			gI_flagsLast[client] = frame.flags
			SetEntityMoveType(client, movetype)
			switch(frame.weapon)
			{
				case 1:
					FakeClientCommand(client, "use weapon_knife")
				case 2:
					FakeClientCommand(client, "use weapon_glock")
				case 3:
					FakeClientCommand(client, "use weapon_usp")
				case 4:
					FakeClientCommand(client, "use weapon_flashbang")
			}
			TeleportEntity(client, NULL_VECTOR, ang, velPos)

		}
		//gF_time = GetGameTime()
		return Plugin_Changed
	}
	else if(IsFakeClient(client) && IsPlayerAlive(client) && GetGameTime() - gF_time > 3.0 && gF_time != 0.0)
	{
		CS_RespawnPlayer(client)
		CS_RespawnPlayer(Trikz_GetClientPartner(client))
		gI_tick[0] = 0
		vel[0] = 0.0 //Prevent bot shaking.
		vel[1] = 0.0
		vel[2] = 0.0
		return Plugin_Changed
	}
	return Plugin_Continue
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(!db)
	{
		PrintToServer("Failed to connect to database")
		return
	}
	PrintToServer("Successfuly connected to database.") //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/
	gD_database = db
	LoadRecord()
}

public void Trikz_Start(int client)
{
	delete gA_frame[client]
	gA_frame[client] = new ArrayList((sizeof(eFrame)))
	gI_frameCount[client] = 0
}

public void Trikz_Record(int client, float time)
{
	SetupSave(client, time)
	gF_time = GetGameTime()
}

void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	LoadRecord()
}

void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		//GivePlayerItem(client, "weapon_flashbang")
		SDKHook(client, SDKHook_WeaponSwitch, SDKWeaponSwitch)
		if(IsFakeClient(client))
		{
			gH_UpdateStepSound.HookEntity(Hook_Pre, client, Hook_UpdateStepSound_Pre)
			gH_UpdateStepSound.HookEntity(Hook_Post, client, Hook_UpdateStepSound_Post)
		}
	}
}

void ApplyFlags(int &flags1, int flags2, int flag)
{
	if((flags2 & flag) != 0)
	{
		flags1 |= flag
	}
	else
	{
		flags1 &= ~flag
	}
}

Action SDKWeaponSwitch(int client, int weapon)
{
	if(Trikz_GetTimerStateTrikz(client))
	{
		if(gB_switchPrevent)
		{
			gB_switchPrevent = false
		}
		else
		{
			char sClassname[32]
			GetEntityClassname(weapon, sClassname, 32)
			if(StrEqual(sClassname, "weapon_knife"))
				gI_weapon[client] = 1
			else if(StrEqual(sClassname, "weapon_glock"))
				gI_weapon[client] = 2
			else if(StrEqual(sClassname, "weapon_usp"))
				gI_weapon[client] = 3
			else if(StrEqual(sClassname, "weapon_flashbang"))
				gI_weapon[client] = 4
		}
	}
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

// Stops bot_quota from doing anything.
MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede
}
