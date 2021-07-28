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

int gI_partner[MAXPLAYERS + 1]
float gF_vecStartZone[2][3]
float gF_vecEndZone[2][3]
Database gD_mysql
float gF_TimeStart[MAXPLAYERS + 1]
float gF_Time[MAXPLAYERS + 1]
bool gB_state[MAXPLAYERS + 1]
char gS_map[192]
bool gB_mapfinished[MAXPLAYERS + 1]
bool gB_passDB
bool gB_passZone[MAXPLAYERS + 1]
float gF_vecStart[3]
float gF_boostTime[MAXPLAYERS + 1]
float gF_skyVel[MAXPLAYERS + 1][3]
bool gB_readyToStart[MAXPLAYERS + 1]

float gF_vecCP[2][11][3]
bool gB_cp[11][MAXPLAYERS + 1]
bool gB_cpLock[11][MAXPLAYERS + 1]
float gF_TimeCP[11][MAXPLAYERS + 1]
float gF_timeDiffCP[11][MAXPLAYERS + 1]
float gF_srCPTime[11][MAXPLAYERS + 1]

float gF_haveRecord[MAXPLAYERS + 1]
float gF_ServerRecord

ConVar gCV_steamid //https://wiki.alliedmods.net/ConVars_(SourceMod_Scripting)

bool gB_TrikzMenuIsOpen[MAXPLAYERS + 1]

float gF_vecVelBoostFix[MAXPLAYERS + 1][3]
bool gB_boost[MAXPLAYERS + 1]
int gI_skyStep[MAXPLAYERS + 1]
bool gB_bouncedOff[2048 + 1]
bool gB_groundBoost[MAXPLAYERS + 1]
int gI_flash[MAXPLAYERS + 1]
int gI_skyFrame[MAXPLAYERS + 1]
int gI_entityFlags[MAXPLAYERS + 1]
float gF_devmap[2]
bool gB_isDevmap
float gF_devmapTime

float gF_vec[MAXPLAYERS + 1][2][3]
float gF_angles[MAXPLAYERS + 1][2][3]
float gF_velocity[MAXPLAYERS +1][2][3]
bool gB_toggledCheckpoint[MAXPLAYERS + 1][2]

bool gB_haveZone

bool gB_isServerRecord
char gS_date[64]
char gS_time[64]

bool gB_silentKnife
float gF_mateRecord[MAXPLAYERS + 1]
bool gB_isTurnedOnSourceTV
bool gB_block[MAXPLAYERS + 1]
int gI_wModelThrown
int gI_class[MAXPLAYERS + 1]
bool gB_color[MAXPLAYERS + 1]
int gI_wModelPlayer[5]
int gI_wModelPlayerDef[5]
int gI_pingModel[MAXPLAYERS + 1]
int gI_pingTick[MAXPLAYERS + 1]
Handle gH_timerPing[MAXPLAYERS + 1]

bool gB_zoneFirst[2]
bool gB_firstZoneCP

char gS_color[][] = {"255,255,255", "255,0,0", "255,165,0", "255,255,0", "0,255,0", "0,255,255", "0,191,255", "0,0,255", "255,0,255"} //white, red, orange, yellow, lime, aqua, deep sky blue, blue, magenta //https://flaviocopes.com/rgb-color-codes/#:~:text=A%20table%20summarizing%20the%20RGB%20color%20codes%2C%20which,%20%20%28178%2C34%2C34%29%20%2053%20more%20rows%20
int gI_color[MAXPLAYERS + 1][3]
int gI_colorCount[MAXPLAYERS + 1]

int gI_zoneModel[3]
int gI_laserBeam

public Plugin myinfo =
{
	name = "trikz + timer",
	author = "Smesh(Nick Yurevich)",
	description = "Allows to able make trikz more comfortable",
	version = "3.0",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	gCV_steamid = CreateConVar("steamid", "", "Set steamid for control the plugin ex. 120192594. Use status to check your uniqueid, without 'U:1:'.")
	AutoExecConfig(true) //https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig
	RegConsoleCmd("sm_t", cmd_trikz)
	RegConsoleCmd("sm_trikz", cmd_trikz)
	RegConsoleCmd("sm_bl", cmd_block)
	RegConsoleCmd("sm_block", cmd_block)
	RegConsoleCmd("sm_p", cmd_partner)
	RegConsoleCmd("sm_partner", cmd_partner)
	RegConsoleCmd("sm_time", cmd_time)
	RegConsoleCmd("sm_cp", cmd_checkpoint)
	RegConsoleCmd("sm_devmap", cmd_devmap)
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			OnClientPutInServer(i)
	RegServerCmd("sm_createzones", cmd_createzones)
	RegServerCmd("sm_createusers", cmd_createusers)
	RegServerCmd("sm_createrecords", cmd_createrecords)
	RegServerCmd("sm_createcp", cmd_createcp)
	RegConsoleCmd("sm_startmins", cmd_startmins)
	RegConsoleCmd("sm_startmaxs", cmd_startmaxs)
	RegConsoleCmd("sm_endmins", cmd_endmins)
	RegConsoleCmd("sm_endmaxs", cmd_endmaxs)
	RegConsoleCmd("sm_cpmins", cmd_cpmins)
	RegConsoleCmd("sm_cpmaxs", cmd_cpmaxs)
	RegConsoleCmd("sm_maptier", cmd_maptier)
	RegConsoleCmd("sm_deleteallcp", cmd_deleteallcp)
	AddNormalSoundHook(SoundHook)
	AddCommandListener(specchat, "say") ////thanks to VerMon idea.
	HookEvent("player_spawn", event_playerspawn)
}

public void OnMapStart()
{
	GetCurrentMap(gS_map, 192)
	Database.Connect(SQLConnect, "fakeexpert")
	for(int i = 0; i <= 1; i++)
		gF_devmap[i] = 0.0
	gB_haveZone = false
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool isSourceTV = GetConVarBool(CV_sourcetv)
	if(isSourceTV)
	{
		PrintToServer("SourceTV start recording.")
		FormatTime(gS_date, 64, "%Y-%m-%d", GetTime())
		FormatTime(gS_time, 64, "%H-%M-%S", GetTime())
		ServerCommand("tv_record %s-%s-%s", gS_date, gS_time, gS_map) //https://www.youtube.com/watch?v=GeGd4KOXNb8 https://forums.alliedmods.net/showthread.php?t=59474 https://www.php.net/strftime
	}
	gB_isServerRecord = false
	if(!gB_isTurnedOnSourceTV)
	{
		gB_isTurnedOnSourceTV = true
		ForceChangeLevel(gS_map, "Turn on SourceTV")
	}
	gI_wModelThrown = PrecacheModel("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.mdl")
	gI_wModelPlayerDef[1] = PrecacheModel("models/player/ct_urban.mdl")
	gI_wModelPlayerDef[2] = PrecacheModel("models/player/ct_gsg9.mdl")
	gI_wModelPlayerDef[3] = PrecacheModel("models/player/ct_sas.mdl")
	gI_wModelPlayerDef[4] = PrecacheModel("models/player/ct_gign.mdl")
	gI_wModelPlayer[1] = PrecacheModel("models/fakeexpert/player/ct_urban.mdl")
	gI_wModelPlayer[2] = PrecacheModel("models/fakeexpert/player/ct_gsg9.mdl")
	gI_wModelPlayer[3] = PrecacheModel("models/fakeexpert/player/ct_sas.mdl")
	gI_wModelPlayer[4] = PrecacheModel("models/fakeexpert/player/ct_gign.mdl")
	PrecacheModel("models/fakeexpert/pingtool/pingtool.mdl")
	PrecacheSound("fakeexpert/pingtool/click.wav") //https://forums.alliedmods.net/showthread.php?t=333211
	gI_zoneModel[0] = PrecacheModel("materials/fakeexpert/zones/start.vmt")
	gI_zoneModel[1] = PrecacheModel("materials/fakeexpert/zones/finish.vmt")
	gI_zoneModel[2] = PrecacheModel("materials/fakeexpert/zones/check_point.vmt")
	gI_laserBeam = PrecacheModel("materials/sprites/laser.vmt")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.dx80.vtx")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.mdl")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.phy")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.vvd")
	
	AddFileToDownloadsTable("models/fakeexpert/pingtool/pingtool.dx80.vtx")
	AddFileToDownloadsTable("models/fakeexpert/pingtool/pingtool.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/pingtool/pingtool.mdl")
	AddFileToDownloadsTable("models/fakeexpert/pingtool/pingtool.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/pingtool/pingtool.vvd")
	
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.dx80.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.mdl")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.phy")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gign.vvd")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.mdl")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.phy")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_gsg9.vvd")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.dx80.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.mdl")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.phy")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_sas.vvd")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.dx80.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.dx90.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.mdl")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.phy")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.sw.vtx")
	AddFileToDownloadsTable("models/fakeexpert/player/ct_urban.vvd")
	
	AddFileToDownloadsTable("materials/fakeexpert/materials/models/weapons/w_models/w_eq_flashbang/noshadow.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/materials/models/weapons/w_models/w_eq_flashbang/shadow.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/materials/models/weapons/w_models/w_eq_flashbang/w_eq_flashbang.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/materials/models/weapons/w_models/w_eq_flashbang/wireframe.vmt")
	
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/circle_arrow.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/circle_arrow.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/circle_point.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/circle_point.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/grad.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/pingtool/grad.vtf")
	AddFileToDownloadsTable("sound/fakeexpert/pingtool/click.wav")
	
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gign/skin1.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gign/skin2.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gign/unlit_base.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gign/unlit_detail.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gign/vertex.vtf")
	
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gsg9/skin1.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gsg9/skin2.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gsg9/unlit_base.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gsg9/unlit_detail.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_gsg9/vertex.vtf")
	
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_sas/skin1.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_sas/skin2.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_sas/unlit_base.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_sas/unlit_detail.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_sas/vertex.vtf")
	
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_urban/skin1.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_urban/skin2.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_urban/unlit_base.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_urban/unlit_detail.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/player/ct_urban/vertex.vtf")
	
	AddFileToDownloadsTable("materials/fakeexpert/player/unlit_default.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/player/vertex_default.vmt")
	
	AddFileToDownloadsTable("materials/fakeexpert/zones/start.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/zones/start.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/zones/finish.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/zones/finish.vtf")
	AddFileToDownloadsTable("materials/fakeexpert/zones/check_point.vmt")
	AddFileToDownloadsTable("materials/fakeexpert/zones/check_point.vtf")
}

public void OnMapEnd()
{
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool isSourceTV = GetConVarBool(CV_sourcetv)
	if(isSourceTV)
	{
		ServerCommand("tv_stoprecord")
		char sOldFileName[256]
		Format(sOldFileName, 256, "%s-%s-%s.dem", gS_date, gS_time, gS_map)
		if(!gB_isServerRecord)
			DeleteFile(sOldFileName)
	}
}

Action specchat(int client, const char[] command, int argc)
{
	if(MaxClients >= client > 0 && GetClientTeam(client) == 1)
	{
		char sName[MAX_NAME_LENGTH]
		GetClientName(client, sName, MAX_NAME_LENGTH)
		char sChat[256]
		GetCmdArg(argc, sChat, 256)
		PrintToChatAll("*SPEC* %s :  %s", sName, sChat)
		PrintToServer("*SPEC* %s :  %s", sName, sChat)
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action event_playerspawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	char sModel[32]
	GetClientModel(client, sModel, 32)
	if(StrEqual(sModel, "models/player/ct_urban.mdl"))
		gI_class[client] = 1
	if(StrEqual(sModel, "models/player/ct_gsg9.mdl"))
		gI_class[client] = 2
	if(StrEqual(sModel, "models/player/ct_sas.mdl"))
		gI_class[client] = 3
	if(StrEqual(sModel, "models/player/ct_gign.mdl"))
		gI_class[client] = 4
}

Action cmd_checkpoint(int client, int args)
{
	if(gB_isDevmap)
		Checkpoint(client)
	return Plugin_Handled
}

void Checkpoint(int client)
{
	Menu menu = new Menu(checkpoint_handler)
	menu.SetTitle("Checkpoint")
	menu.AddItem("Save", "Save")
	menu.AddItem("Teleport", "Teleport", gB_toggledCheckpoint[client][0] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
	menu.AddItem("Save second", "Save second")
	menu.AddItem("Teleport second", "Teleport second", gB_toggledCheckpoint[client][1] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
	menu.ExitBackButton = true //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER)
}

int checkpoint_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					GetClientAbsOrigin(param1, gF_vec[param1][0])
					GetClientAbsAngles(param1, gF_angles[param1][0])
					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", gF_velocity[param1][0])
					gB_toggledCheckpoint[param1][0] = true
					Checkpoint(param1)
				}
				case 1:
				{
					TeleportEntity(param1, gF_vec[param1][0], gF_angles[param1][0], gF_velocity[param1][0])
					Checkpoint(param1)
				}
				case 2:
				{
					GetClientAbsOrigin(param1, gF_vec[param1][1])
					GetClientAbsAngles(param1, gF_angles[param1][1])
					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", gF_velocity[param1][1])
					gB_toggledCheckpoint[param1][1] = true
					Checkpoint(param1)
				}
				case 3:
				{
					TeleportEntity(param1, gF_vec[param1][1], gF_angles[param1][1], gF_velocity[param1][1])
					Checkpoint(param1)
				}
			}
		}
		case MenuAction_Cancel: // trikz redux menuaction end
			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
					Trikz(param1)
			}
		case MenuAction_End:
			delete menu
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SpawnPost, SDKPlayerSpawnPost)
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage)
	SDKHook(client, SDKHook_StartTouch, SDKSkyFix)
	SDKHook(client, SDKHook_PostThinkPost, SDKBoostFix) //idea by tengulawl/scripting/blob/master/boost-fix tengulawl github.com
	SDKHook(client, SDKHook_WeaponEquipPost, SDKWeaponEquipPost)
	char sQuery[512]
	if(IsClientInGame(client) && gB_passDB)
	{
		int steamid = GetSteamAccountID(client)
		Format(sQuery, 512, "SELECT * FROM users")
		gD_mysql.Query(SQLAddUser, sQuery, GetClientSerial(client))
		Format(sQuery, 512, "SELECT MIN(time) FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s'", steamid, steamid, gS_map)
		gD_mysql.Query(SQLGetPersonalRecord, sQuery, GetClientSerial(client))
	}
	gB_TrikzMenuIsOpen[client] = false
	for(int i = 0; i <= 1; i++)
	{
		gB_toggledCheckpoint[client][i] = false
		for(int j = 0; j <= 2; j++)
		{
			gF_vec[client][i][j] = 0.0
			gF_angles[client][i][j] = 0.0
			gF_velocity[client][i][j] = 0.0
		}
	}
	gF_boostTime[client] = 0.0
	CancelClientMenu(client)
	gB_block[client] = true
	gB_color[client] = false
	gI_pingTick[client] = 0
	gI_colorCount[client] = 0
}

public void OnClientDisconnect(int client)
{
	int partner = gI_partner[client]
	gI_partner[gI_partner[client]] = 0
	if(partner && gB_TrikzMenuIsOpen[partner])
		Trikz(partner)
	gI_partner[client] = 0
	CancelClientMenu(client)
	Color(partner, false)
	gI_colorCount[partner] = 0
}

void SQLGetServerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	gF_ServerRecord = 0.0
	if(results.FetchRow())
		gF_ServerRecord = results.FetchFloat(0)
}

void SQLGetPersonalRecord(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	gF_haveRecord[client] = 0.0
	if(results.FetchRow())
		gF_haveRecord[client] = results.FetchFloat(0)
}

void SQLUpdateUsername(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	if(client == 0)
		return
	if(IsClientInGame(client))
	{
		char sName[64]
		GetClientName(client, sName, 64)
		char sQuery[512]
		int steamid = GetSteamAccountID(client)
		if(results.FetchRow())
		{
			Format(sQuery, 512, "UPDATE users SET username = '%s', lastjoin = %i WHERE steamid = %i", sName, GetTime(), steamid)
			gD_mysql.Query(SQLUpdateUsernameSuccess, sQuery)
		}
		else
		{
			Format(sQuery, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%s', %i, %i, %i)", sName, steamid, GetTime(), GetTime())
			gD_mysql.Query(SQLUpdateUsernameSuccess, sQuery)
		}
	}
}

void SQLUpdateUsernameSuccess(Database db, DBResultSet results, const char[] error, any data)
{
}

void SQLAddUser(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	if(client == 0)
		return
	int steamid = GetSteamAccountID(client)
	if(IsClientInGame(client))
	{
		char sName[64]
		GetClientName(client, sName, 64)
		char sQuery[512] //https://forums.alliedmods.net/showthread.php?t=261378
		if(results.FetchRow())
		{
			Format(sQuery, 512, "SELECT steamid FROM users WHERE steamid = %i", steamid)
			gD_mysql.Query(SQLUpdateUsername, sQuery, GetClientSerial(client))
		}
		else
		{
			Format(sQuery, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%s', %i, %i, %i)", sName, steamid, GetTime(), GetTime())
			gD_mysql.Query(SQLUserAdded, sQuery)
		}
	}
}

void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
{
}

void SDKSkyFix(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(gI_entityFlags[other] & FL_ONGROUND) && GetGameTime() - gF_boostTime[client] > 0.15 && !gB_boost[client])
	{
		float vecAbsBooster[3]
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vecAbsBooster)
		float vecAbsFlyer[3]
		GetEntPropVector(other, Prop_Data, "m_vecOrigin", vecAbsFlyer)
		float vecMaxs[3]
		GetEntPropVector(client, Prop_Data, "m_vecMaxs", vecMaxs) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71
		float delta = vecAbsFlyer[2] - vecAbsBooster[2] - vecMaxs[2]
		if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		{
			if(!(GetEntityFlags(client) & FL_ONGROUND) && !(GetClientButtons(other) & IN_DUCK) && gI_skyStep[other] == 0)
			{
				float vecVelBooster[3]
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecVelBooster)
				if(vecVelBooster[2] > 0.0)
				{
					float vecVelFlyer[3]
					GetEntPropVector(other, Prop_Data, "m_vecVelocity", vecVelFlyer)
					gF_skyVel[other][0] = vecVelFlyer[0]
					gF_skyVel[other][1] = vecVelFlyer[1]				
					vecVelBooster[2] *= 3.0
					gF_skyVel[other][2] = vecVelBooster[2]
					if(vecVelBooster[2] > 800.0)
						gF_skyVel[other][2] = 800.0
					if(FloatAbs(vecVelFlyer[2]) > 118.006614) // -118.006614 in couch, in normal -106.006614
					{
						gI_skyStep[other] = 1
						gI_skyFrame[other] = 1 //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L121
					}
				}
			}
		}
	}
}

void SDKBoostFix(int client)
{
	if(gB_boost[client])
	{
		int entity = EntRefToEntIndex(gI_flash[client])
		if(entity != INVALID_ENT_REFERENCE)
		{
			float vecVelEntity[3]
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vecVelEntity)
			if(vecVelEntity[2] > 0.0)
			{
				vecVelEntity[0] *= 0.135
				vecVelEntity[1] *= 0.135
				vecVelEntity[2] *= -0.135
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecVelEntity)
			}
			if(gB_groundBoost[client])
			{
				gF_vecVelBoostFix[client][2] *= 3.0
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, gF_vecVelBoostFix[client])
			}
			else
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, gF_vecVelBoostFix[client])
			gB_boost[client] = false
		}
	}
}

Action cmd_trikz(int client, int args)
{
	Trikz(client)
	return Plugin_Handled
}

void Trikz(int client)
{
	gB_TrikzMenuIsOpen[client] = true
	Menu menu = new Menu(trikz_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel) //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	menu.SetTitle("Trikz")
	char sDisplay[32]
	Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
	menu.AddItem("block", sDisplay)
	Format(sDisplay, 32, gI_partner[client] ? "Breakup" : "Partner")
	menu.AddItem("partner", sDisplay, gB_isDevmap ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT)
	menu.AddItem("color", "Color", gI_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
	menu.AddItem("restart", "Restart", gI_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED) //shavit trikz githgub alliedmods net https://forums.alliedmods.net/showthread.php?p=2051806
	if(gB_isDevmap)
	{
		menu.AddItem("checkpoint", "Checkpoint")
		Format(sDisplay, 32, GetEntityMoveType(client) & MOVETYPE_NOCLIP ? "Noclip [v]" : "Noclip [x]")
		menu.AddItem("noclip", sDisplay)
	}
	menu.Display(client, MENU_TIME_FOREVER)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
			gB_TrikzMenuIsOpen[param1] = true
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
					Block(param1)
				case 1:
				{
					gB_TrikzMenuIsOpen[param1] = false
					Partner(param1)
				}
				case 2:
				{
					Color(param1, true)
					Trikz(param1)
				}
				case 3:
				{
					Restart(param1)
					Restart(gI_partner[param1])
				}
				case 4:
					Checkpoint(param1)
				case 5:
				{
					if(GetEntityMoveType(param1) & MOVETYPE_NOCLIP)
					{
						SetEntityMoveType(param1, MOVETYPE_WALK)
						PrintToChat(param1, "Noclip disabled.")
					}
					else
					{
						SetEntityMoveType(param1, MOVETYPE_NOCLIP)
						PrintToChat(param1, "Noclip enabled.")
					}
					Trikz(param1)
				}
			}
		}
		case MenuAction_Cancel:
			gB_TrikzMenuIsOpen[param1] = false //idea from expert zone.
		case MenuAction_Display:
			gB_TrikzMenuIsOpen[param1] = true
		case MenuAction_End:
			delete menu
	}
}

Action cmd_block(int client, int args)
{
	Block(client)
	return Plugin_Handled
}

Action Block(int client)
{
	gB_block[client] = !gB_block[client]
	if(gB_block[client])
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		if(gB_TrikzMenuIsOpen[client])
			Trikz(client)
		PrintToChat(client, "Block enabled.")
		return Plugin_Handled
	}
	else
	{

		SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
		if(gB_color[client])
			SetEntityRenderColor(client, gI_color[client][0], gI_color[client][1], gI_color[client][2], 125)
		else
			SetEntityRenderColor(client, 255, 255, 255, 125)
		if(gB_TrikzMenuIsOpen[client])
			Trikz(client)
		PrintToChat(client, "Block disabled.")
		return Plugin_Handled
	}
}

Action cmd_partner(int client, int args)
{
	Partner(client)
	return Plugin_Handled
}

void Partner(int client)
{
	if(!gI_partner[client])
	{
		Menu menu = new Menu(partner_handler)
		menu.SetTitle("Choose partner")
		char sName[MAX_NAME_LENGTH]
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && client != i && !gI_partner[i]) //https://github.com/Figawe2/trikz-plugin/blob/master/scripting/trikz.sp#L635
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
		menu.SetTitle("Cancel partnership with %N", gI_partner[client])
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
			char sParam1[32]
			IntToString(param1, sParam1, 32)
			menu2.AddItem(sParam1, "Yes")
			menu2.AddItem(sItem, "No")
			menu2.Display(partner, 20)
		}
		case MenuAction_End:
			delete menu
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
					if(!gI_partner[partner])
					{
						gI_partner[param1] = partner
						gI_partner[partner] = param1
						PrintToChat(param1, "Partnersheep agreed with %N.", partner) //reciever
						PrintToChat(partner, "You have %N as partner.", param1) //sender
						Restart(param1)
						Restart(partner) //Expert-Zone idea.
						if(gB_TrikzMenuIsOpen[partner])
							Trikz(partner)
						char sQuery[512]
						Format(sQuery, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s'", GetSteamAccountID(param1), GetSteamAccountID(partner), GetSteamAccountID(partner), GetSteamAccountID(param1), gS_map)
						gD_mysql.Query(SQLGetPartnerRecord, sQuery, GetClientSerial(param1))
					}
					else
						PrintToChat(param1, "A player already have a partner.")
				}
				case 1:
					PrintToChat(param1, "Partnersheep declined with %N.", partner)
			}
		}
		case MenuAction_End:
			delete menu
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
					Color(param1, false)
					gI_colorCount[param1] = 0
					gI_colorCount[partner] = 0
					gI_partner[param1] = 0
					gI_partner[partner] = 0
					PrintToChat(param1, "Partnership is canceled with %N", partner)
					PrintToChat(partner, "Partnership is canceled by %N", param1)
				}
			}
		}
		case MenuAction_End:
			delete menu
	}
}

void Color(int client, bool customSkin)
{
	if(customSkin)
	{
		gB_color[client] = true
		gB_color[gI_partner[client]] = true
		SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayer[gI_class[client]])
		SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayer[gI_class[client]])
		SetEntProp(client, Prop_Data, "m_nSkin", 1)
		SetEntProp(gI_partner[client], Prop_Data, "m_nSkin", 1)
		char gS_colorExploded[3][3]
		if(gI_colorCount[client] == 9)
		{
			gI_colorCount[client] = 0
			gI_colorCount[gI_partner[client]] = 0
		}
		ExplodeString(gS_color[gI_colorCount[client]], ",", gS_colorExploded, 16, 16)
		gI_color[client][0] = StringToInt(gS_colorExploded[0])
		gI_color[client][1] = StringToInt(gS_colorExploded[1])
		gI_color[client][2] = StringToInt(gS_colorExploded[2])
		gI_color[gI_partner[client]][0] = StringToInt(gS_colorExploded[0])
		gI_color[gI_partner[client]][1] = StringToInt(gS_colorExploded[1])
		gI_color[gI_partner[client]][2] = StringToInt(gS_colorExploded[2])
		SetEntityRenderColor(client, gI_color[client][0], gI_color[client][1], gI_color[client][2], 255)
		SetEntityRenderColor(gI_partner[client], gI_color[client][0], gI_color[client][1], gI_color[client][2], 255)
		gI_colorCount[client]++
		gI_colorCount[gI_partner[client]]++
	}
	else
	{
		gB_color[client] = false
		gB_color[gI_partner[client]] = false
		SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[gI_class[client]])
		SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[gI_class[client]])
		SetEntityRenderColor(client, 255, 255, 255, 255)
		SetEntityRenderColor(gI_partner[client], 255, 255, 255, 255)
	}
}

void SQLGetPartnerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	if(client == 0)
		return
	gF_mateRecord[client] = 0.0
	gF_mateRecord[gI_partner[client]] = 0.0
	if(results.FetchRow())
	{
		gF_mateRecord[client] = results.FetchFloat(0)
		gF_mateRecord[gI_partner[client]] = results.FetchFloat(0)
	}
		
}

void Restart(int client)
{
	if(!gB_isDevmap && gB_haveZone)
	{
		if(gI_partner[client])
		{
			if(IsPlayerAlive(client) && IsPlayerAlive(gI_partner[client]))
			{
				gB_readyToStart[client] = true
				gF_Time[client] = 0.0
				gB_state[client] = false
				float vecVel[3]
				TeleportEntity(client, gF_vecStart, NULL_VECTOR, vecVel)
				SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
				SetEntityRenderMode(client, RENDER_TRANSALPHA)
				if(gB_color[client])
					SetEntityRenderColor(client, gI_color[client][0], gI_color[client][1], gI_color[client][2], 125)
				else
					SetEntityRenderColor(client, 255, 255, 255, 125)
				gB_block[client] = false
				if(gB_TrikzMenuIsOpen[client])
				{
					gB_block[client] = false
					Trikz(client)
				}
				CreateTimer(3.0, Timer_BlockToggle, client)
			}
		}
		else
			PrintToChat(client, "You must have a partner.")
	}
}

Action Timer_BlockToggle(Handle timer, int client)
{
	if(IsValidEntity(client) && IsValidEntity(gI_partner[client]))
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		gB_block[client] = true
		if(gB_TrikzMenuIsOpen[client])
		{
			gB_block[client] = true
			Trikz(client)
		}
	}
	return Plugin_Stop
}

void createstart()
{
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_startzone")
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vecStartZone[0][0] + gF_vecStartZone[1][0]) / 2.0
	center[1] = (gF_vecStartZone[0][1] + gF_vecStartZone[1][1]) / 2.0
	center[2] = (gF_vecStartZone[0][2] + gF_vecStartZone[1][2]) / 2.0
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	gF_vecStart[0] = center[0]
	gF_vecStart[1] = center[1]
	gF_vecStart[2] = center[2]
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (gF_vecStartZone[0][i] - gF_vecStartZone[1][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (gF_vecStartZone[0][i] - gF_vecStartZone[1][i]) / 2.0
		if(maxs[i] < 0.0)
			maxs[i] *= -1.0
	}
	maxs[2] = 124.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins)
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	SDKHook(entity, SDKHook_EndTouch, SDKEndTouch)
	PrintToServer("Start zone is successfuly setup.")
}

void createend()
{
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_endzone")
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vecEndZone[0][0] + gF_vecEndZone[1][0]) / 2
	center[1] = (gF_vecEndZone[0][1] + gF_vecEndZone[1][1]) / 2
	center[2] = (gF_vecEndZone[0][2] + gF_vecEndZone[1][2]) / 2
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (gF_vecEndZone[0][i] - gF_vecEndZone[1][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (gF_vecEndZone[0][i] - gF_vecEndZone[1][i]) / 2.0
		if(maxs[i] < 0.0)
			maxs[i] *= -1.0
	}
	maxs[2] = 124.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	PrintToServer("End zone is successfuly setup.")
	CPSetup()
}

Action cmd_startmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		if(gB_isDevmap)
		{
			GetClientAbsOrigin(client, gF_vecStartZone[0])
			gB_zoneFirst[0] = true
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
	return Plugin_Handled
}

void SQLDeleteStartZone(Database db, DBResultSet results, const char[] error, any data)
{
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 0, %f, %f, %f, %f, %f, %f)", gS_map, gF_vecStartZone[0][0], gF_vecStartZone[0][1], gF_vecStartZone[0][2], gF_vecStartZone[1][0], gF_vecStartZone[1][1], gF_vecStartZone[1][2])
	gD_mysql.Query(SQLSetStartZones, sQuery)
}

Action cmd_deleteallcp(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID)) //https://sm.alliedmods.net/new-api/
	{
		if(gB_isDevmap)
		{
			char sQuery[512]
			Format(sQuery, 512, "DELETE FROM cp WHERE map = '%s'", gS_map) //https://www.w3schools.com/sql/sql_delete.asp
			gD_mysql.Query(SQLDeleteAllCP, sQuery)
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
}

void SQLDeleteAllCP(Database db, DBResultSet results, const char[] error, any data)
{
}

Action cmd_endmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		if(gB_isDevmap)
		{
			GetClientAbsOrigin(client, gF_vecEndZone[0])
			gB_zoneFirst[1] = true
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
	return Plugin_Handled
}

void SQLDeleteEndZone(Database db, DBResultSet results, const char[] error, any data)
{
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 1, %f, %f, %f, %f, %f, %f)", gS_map, gF_vecEndZone[0][0], gF_vecEndZone[0][1], gF_vecEndZone[0][2], gF_vecEndZone[1][0], gF_vecEndZone[1][1], gF_vecEndZone[1][2])
	gD_mysql.Query(SQLSetEndZones, sQuery)
}

Action cmd_maptier(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		if(gB_isDevmap)
		{
			char sArgString[512]
			GetCmdArgString(sArgString, 512) //https://www.sourcemod.net/new-api/console/GetCmdArgString
			int tier = StringToInt(sArgString)
			PrintToServer("[Args] Tier: %i", tier)
			char sQuery[512]
			Format(sQuery, 512, "UPDATE zones SET tier = %i WHERE map = '%s' AND type = 0", tier, gS_map)
			gD_mysql.Query(SQLTier, sQuery)
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
	return Plugin_Handled
}

void SQLTier(Database db, DBResultSet results, const char[] error, any data)
{
}

void SQLSetStartZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
		PrintToServer("Start zone successfuly created.")
}

void SQLSetEndZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
		PrintToServer("End zone successfuly created.")
}

Action cmd_startmaxs(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID) && gB_zoneFirst[0])
	{
		GetClientAbsOrigin(client, gF_vecStartZone[1])
		char sQuery[512]
		Format(sQuery, 512, "DELETE FROM zones WHERE map = '%s' AND type = 0", gS_map)
		gD_mysql.Query(SQLDeleteStartZone, sQuery)
		gB_zoneFirst[0] = false
	}
	return Plugin_Handled
}

Action cmd_endmaxs(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID) && gB_zoneFirst[1])
	{
		GetClientAbsOrigin(client, gF_vecEndZone[1])
		char sQuery[512]
		Format(sQuery, 512, "DELETE FROM zones WHERE map = '%s' AND type = 1", gS_map)
		gD_mysql.Query(SQLDeleteEndZone, sQuery)
		gB_zoneFirst[1] = false
	}
	return Plugin_Handled
}

Action cmd_cpmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		if(gB_isDevmap)
		{
			char sCmd[512]
			GetCmdArg(args, sCmd, 512)
			int cpnum = StringToInt(sCmd)
			PrintToChat(client, "CP: No.%i", cpnum)
			GetClientAbsOrigin(client, gF_vecCP[0][cpnum])
			char sQuery[512]
			Format(sQuery, 512, "DELETE FROM cp WHERE cpnum = %i AND map = '%s'", cpnum, gS_map)
			gD_mysql.Query(SQLCPRemoved, sQuery, cpnum)
			gB_firstZoneCP = true
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
	return Plugin_Handled
}

void SQLCPRemoved(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
		PrintToServer("Checkpoint zone no. %i successfuly deleted.")
}

Action cmd_cpmaxs(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID) && gB_firstZoneCP)
	{
		char sCmd[512]
		GetCmdArg(args, sCmd, 512)
		int cpnum = StringToInt(sCmd)
		GetClientAbsOrigin(client, gF_vecCP[1][cpnum])
		char sQuery[512]
		Format(sQuery, 512, "INSERT INTO cp (cpnum, cpx, cpy, cpz, cpx2, cpy2, cpz2, map) VALUES (%i, %f, %f, %f, %f, %f, %f, '%s')", cpnum, gF_vecCP[0][cpnum][0], gF_vecCP[0][cpnum][1], gF_vecCP[0][cpnum][2], gF_vecCP[1][cpnum][0], gF_vecCP[1][cpnum][1], gF_vecCP[1][cpnum][2], gS_map)
		gD_mysql.Query(SQLCPInserted, sQuery, cpnum)
		gB_firstZoneCP = false
	}
	return Plugin_Handled
}

void SQLCPInserted(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
		PrintToServer("Checkpoint zone no. %i successfuly created.", data)
}

//https://forums.alliedmods.net/showthread.php?t=261378

Action cmd_createcp(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS cp (id INT AUTO_INCREMENT, cpnum INT, cpx FLOAT, cpy FLOAT, cpz FLOAT, cpx2 FLOAT, cpy2 FLOAT, cpz2 FLOAT, map VARCHAR(192),  PRIMARY KEY(id))")
	gD_mysql.Query(SQLCreateCPTable, sQuery)
}

void SQLCreateCPTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("CP table successfuly created.")
}

void CPSetup()
{
	for(int i = 1; i <= 10; i++)
	{
		char sQuery[512]
		Format(sQuery, 512, "SELECT cpx, cpy, cpz, cpx2, cpy2, cpz2 FROM cp WHERE cpnum = %i AND map = '%s'", i, gS_map)
		gD_mysql.Query(SQLCPSetup, sQuery, i)
	}
}

void SQLCPSetup(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vecCP[0][data][0] = results.FetchFloat(0)
		gF_vecCP[0][data][1] = results.FetchFloat(1)
		gF_vecCP[0][data][2] = results.FetchFloat(2)
		gF_vecCP[1][data][0] = results.FetchFloat(3)
		gF_vecCP[1][data][1] = results.FetchFloat(4)
		gF_vecCP[1][data][2] = results.FetchFloat(5)
		createcp(data)
		if(!gB_haveZone)
		{
			if(!gB_isDevmap)
				CreateTimer(2.0, timer_draw, 0, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
			gB_haveZone = true
		}
	}
}

void createcp(int cpnum)
{
	char sTriggerName[64]
	Format(sTriggerName, 64, "fakeexpert_cp%i", cpnum)
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", sTriggerName)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vecCP[1][cpnum][0] + gF_vecCP[0][cpnum][0]) / 2.0
	center[1] = (gF_vecCP[1][cpnum][1] + gF_vecCP[0][cpnum][1]) / 2.0
	center[2] = (gF_vecCP[1][cpnum][2] + gF_vecCP[0][cpnum][2]) / 2.0
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (gF_vecCP[0][cpnum][i] - gF_vecCP[1][cpnum][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (gF_vecCP[0][cpnum][i] - gF_vecCP[1][cpnum][i]) / 2.0
		if(maxs[i] < 0.0)
			maxs[i] *= -1.0
	}
	maxs[2] = 124.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	PrintToServer("Checkpoint number %i is successfuly setup.", cpnum)
}

Action cmd_createusers(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT, username VARCHAR(64), steamid INT, firstjoin INT, lastjoin INT, points INT, PRIMARY KEY(id))")
	gD_mysql.Query(SQLCreateUserTable, sQuery)
}

void SQLCreateUserTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successfuly created user table.")
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO user (points) VALUES (0)")
	gD_mysql.Query(SQLAddFakePoints, sQuery)
}

void SQLAddFakePoints(Database db, DBResultSet results, const char[] error, any data)
{
}

Action cmd_createrecords(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS records (id INT AUTO_INCREMENT, playerid INT, partnerid INT, time FLOAT, completions INT, tries INT, cp1 FLOAT, cp2 FLOAT, cp3 FLOAT, cp4 FLOAT, cp5 FLOAT, cp6 FLOAT, cp7 FLOAT, cp8 FLOAT, cp9 FLOAT, cp10 FLOAT, map VARCHAR(192), date INT, PRIMARY KEY(id))")
	gD_mysql.Query(SQLRecordsTable, sQuery)
}

void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successfuly created records table.")
}

Action SDKEndTouch(int entity, int other)
{
	if(0 < other <= MaxClients && gB_readyToStart[other])
	{
		gB_state[other] = true
		gB_state[gI_partner[other]] = true
		gB_mapfinished[other] = false
		gB_mapfinished[gI_partner[other]] = false
		gF_TimeStart[other] = GetEngineTime()
		gF_TimeStart[gI_partner[other]] = GetEngineTime()
		gB_passZone[other] = true
		gB_passZone[gI_partner[other]] = true
		gB_readyToStart[other] = false
		gB_readyToStart[gI_partner[other]] = false
		for(int i = 1; i <= 10; i++)
		{
			gB_cp[i][other] = false
			gB_cp[i][gI_partner[other]] = false
			gB_cpLock[i][other] = false
			gB_cpLock[i][gI_partner[other]] = false
		}
	}
}

Action SDKStartTouch(int entity, int other)
{
	if(0 < other <= MaxClients && gB_passZone[other])
	{
		char sTrigger[32]
		GetEntPropString(entity, Prop_Data, "m_iName", sTrigger, 32)
		if(StrEqual(sTrigger, "fakeexpert_startzone") && gB_mapfinished[other])
		{
			//gB_readyToStart[other] = true //expert zone idea.
			//gB_readyToStart[gI_partner[other]] = true
		}
		if(StrEqual(sTrigger, "fakeexpert_endzone"))
		{
			gB_mapfinished[other] = true
			gB_passZone[other] = false
			if(gB_mapfinished[other] && gB_mapfinished[gI_partner[other]])
			{
				char sQuery[512]
				int playerid = GetSteamAccountID(other)
				int partnerid = GetSteamAccountID(gI_partner[other])
				char sCPnum[32]
				int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
				int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
				int personalSecond = RoundToFloor(gF_Time[other]) % 60
				if(gF_ServerRecord != 0.0)
				{
					if(gF_mateRecord[other] != 0.0)
					{
						if(gF_ServerRecord > gF_Time[other])
						{
							float timeDiff = gF_ServerRecord - gF_Time[other]
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET time = %f, completions = completions + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s'", gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], GetTime(), playerid, partnerid, partnerid, playerid, gS_map)
							gD_mysql.Query(SQLUpdateRecord, sQuery)
							gF_haveRecord[other] = gF_Time[other]
							gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
							gB_isServerRecord = true
							CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE)
						}
						else if(gF_ServerRecord < gF_Time[other] > gF_mateRecord[other])
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET completions = completions + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s'", playerid, partnerid, partnerid, playerid, gS_map)
							gD_mysql.Query(SQLUpdateRecord, sQuery)
						}
						else if(gF_ServerRecord < gF_Time[other] < gF_mateRecord[other])
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET time = %f, completions = completions + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s'", gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], GetTime(), playerid, partnerid, partnerid, playerid, gS_map)
							gD_mysql.Query(SQLUpdateRecord, sQuery)
							if(gF_haveRecord[other] > gF_Time[other])
								gF_haveRecord[other] = gF_Time[other]
							if(gF_haveRecord[gI_partner[other]] > gF_Time[other])
								gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
						}
					}
					else
					{
						if(gF_ServerRecord > gF_Time[other])
						{
							float timeDiff = gF_ServerRecord - gF_Time[other]
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, completions, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
							gD_mysql.Query(SQLInsertRecord, sQuery)
							gF_haveRecord[other] = gF_Time[other]
							gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
							gB_isServerRecord = true
							CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE)
						}
						else
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, completions, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
							gD_mysql.Query(SQLInsertRecord, sQuery)
							if(gF_haveRecord[other] == 0.0)
								gF_haveRecord[other] = gF_Time[other]
							if(gF_haveRecord[gI_partner[other]] == 0.0)
								gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
						}
					}
					for(int i = 1; i <= 10; i++)
					{
						IntToString(i, sCPnum, 32)
						if(gB_cp[i][other])
						{
							int srCPHour = (RoundToFloor(gF_timeDiffCP[i][other]) / 3600) % 24
							int srCPMinute = (RoundToFloor(gF_timeDiffCP[i][other]) / 60) % 60
							int srCPSecond = RoundToFloor(gF_timeDiffCP[i][other]) % 60
							if(gF_TimeCP[i][other] < gF_srCPTime[i][other])
								PrintToChatAll("%s. Checkpoint: -%02.i:%02.i:%02.i", sCPnum, srCPHour, srCPMinute, srCPSecond)
							else
								PrintToChatAll("%s. Checkpoint: +%02.i:%02.i:%02.i", sCPnum, srCPHour, srCPMinute, srCPSecond)
						}
					}
				}
				else
				{
					gF_ServerRecord = gF_Time[other]
					gF_haveRecord[other] = gF_Time[other]
					gF_haveRecord[gI_partner[other]] = gF_Time[other]
					PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +00:00:00)", other, gI_partner[other], personalHour, personalMinute, personalSecond)
					for(int i = 1; i <= 10; i++)
					{
						IntToString(i, sCPnum, 32)
						if(gB_cp[i][other])
							PrintToChatAll("%s. Checkpoint: +00:00:00", sCPnum)
					}
					gB_isServerRecord = true
					Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, completions, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
					gD_mysql.Query(SQLInsertRecord, sQuery)
				}
				
				Format(sQuery, 512, "SELECT tier FROM zones WHERE map = '%s' AND type = 0", gS_map)
				gD_mysql.Query(SQLGetMapTier, sQuery, GetClientSerial(other))
			}
			gB_state[other] = false
			gB_state[gI_partner[other]] = false
		}
		for(int i = 1; i <= 10; i++)
		{
			char sTrigger2[64]
			Format(sTrigger2, 64, "fakeexpert_cp%i", i)
			if(StrEqual(sTrigger, sTrigger2))
			{
				gB_cp[i][other] = true
				if(gB_cp[i][other] && gB_cp[i][gI_partner[other]] && !gB_cpLock[i][other])
				{
					char sQuery[512] //https://stackoverflow.com/questions/9617453 //https://www.w3schools.com/sql/sql_ref_order_by.asp#:~:text=%20SQL%20ORDER%20BY%20Keyword%20%201%20ORDER,data%20returned%20in%20descending%20order.%20%20More%20
					int playerid = GetSteamAccountID(other)
					int partnerid = GetSteamAccountID(gI_partner[other])
					if(!gB_cpLock[1][other] && gF_mateRecord[other])
					{
						Format(sQuery, 512, "UPDATE records SET tries = tries + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s'", playerid, partnerid, partnerid, playerid, gS_map)
						gD_mysql.Query(SQLSetTries, sQuery)
					}
					gB_cpLock[i][other] = true
					gB_cpLock[i][gI_partner[other]] = true
					gF_TimeCP[i][other] = gF_Time[other]
					gF_TimeCP[i][gI_partner[other]] = gF_Time[other]
					Format(sQuery, 512, "SELECT cp%i FROM records", i)
					DataPack dp = new DataPack()
					dp.WriteCell(GetClientSerial(other))
					dp.WriteCell(i)
					gD_mysql.Query(SQLCPSelect, sQuery, dp)
				}
			}
		}
	}
}

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	PrintToServer("Record updated.")
}

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Record inserted.")
}

Action timer_sourcetv(Handle timer)
{
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool isSourceTV = GetConVarBool(CV_sourcetv)
	if(isSourceTV)
	{
		ServerCommand("tv_stoprecord")
		char sOldFileName[256]
		Format(sOldFileName, 256, "%s-%s-%s.dem", gS_date, gS_time, gS_map)
		char sNewFileName[256]
		Format(sNewFileName, 256, "%s-%s-%s-ServerRecord.dem", gS_date, gS_time, gS_map)
		RenameFile(sNewFileName, sOldFileName)
		PrintToServer("SourceTV start recording.")
		FormatTime(gS_date, 64, "%Y-%m-%d", GetTime())
		FormatTime(gS_time, 64, "%H-%M-%S", GetTime())
		ServerCommand("tv_record %s-%s-%s", gS_date, gS_time, gS_map)
		gB_isServerRecord = false
	}
}

void SQLGetMapTier(Database db, DBResultSet results, const char[] error, any data)
{
	int other = GetClientFromSerial(data)
	if(!other)
		return
	int clientid = GetSteamAccountID(other)
	int partnerid = GetSteamAccountID(gI_partner[other])
	if(results.FetchRow())
	{
		int tier = results.FetchInt(0)
		int points = tier * 20
		DataPack dp = new DataPack()
		dp.WriteCell(points)
		dp.WriteCell(clientid)
		dp.WriteCell(other)
		char sQuery[512]
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", clientid)
		gD_mysql.Query(SQLGetPoints, sQuery, dp)
		DataPack dp2 = new DataPack()
		dp2.WriteCell(points)
		dp2.WriteCell(partnerid)
		dp2.WriteCell(other)
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", partnerid)
		gD_mysql.Query(SQLGetPointsPartner, sQuery, dp2)
	}
}

void SQLGetPoints(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	int earnedpoints = dp.ReadCell()
	int clientid = dp.ReadCell()
	//int other = dp.ReadCell()
	if(results.FetchRow())
	{
		int points = results.FetchInt(0)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE users SET points = %i + %i WHERE steamid = %i", points, earnedpoints, clientid)
		gD_mysql.Query(SQLEarnedPoints, sQuery)
		//PrintToChat(other, "You recived %i points. You have %i points.", earnedpoints, points + earnedpoints)
	}
}

void SQLGetPointsPartner(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	int earnedpoints = dp.ReadCell()
	int partnerid = dp.ReadCell()
	//int other = dp.ReadCell()
	if(results.FetchRow())
	{
		int points = results.FetchInt(0)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE users SET points = %i + %i WHERE steamid = %i", points, earnedpoints, partnerid)
		gD_mysql.Query(SQLEarnedPoints, sQuery)
		//PrintToChat(other, "You recived %i points. You have %i points.", earnedpoints, points + earnedpoints)
	}
}

void SQLEarnedPoints(Database db, DBResultSet results, const char[] error, any data)
{
}

void SQLCPSelect(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset()
	int other = GetClientFromSerial(data.ReadCell())
	int cpnum = data.ReadCell()
	char sQuery[512]
	if(results.FetchRow())
	{
		Format(sQuery, 512, "SELECT cp%i FROM records WHERE map = '%s' ORDER BY time LIMIT 1", cpnum, gS_map) //log help me alot with this stuff
		DataPack dp = new DataPack()
		dp.WriteCell(GetClientSerial(other))
		dp.WriteCell(cpnum)
		gD_mysql.Query(SQLCPSelect_2, sQuery, dp)
	}
	else
	{
		PrintToChat(other, "%i. Checkpoint: +00:00:00", cpnum)
		PrintToChat(gI_partner[other], "%i. Checkpoint: +00:00:00", cpnum)
	}
}

void SQLCPSelect_2(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset()
	int other = GetClientFromSerial(data.ReadCell())
	int cpnum = data.ReadCell()
	if(results.FetchRow())
	{
		gF_srCPTime[cpnum][other] = results.FetchFloat(0)
		if(gF_TimeCP[cpnum][other] < gF_srCPTime[cpnum][other])
		{
			gF_timeDiffCP[cpnum][other] = gF_srCPTime[cpnum][other] - gF_TimeCP[cpnum][other]
			gF_timeDiffCP[cpnum][gI_partner[other]] = gF_srCPTime[cpnum][other] - gF_TimeCP[cpnum][other]
			int srCPHour = (RoundToFloor(gF_timeDiffCP[cpnum][other]) / 3600) % 24
			int srCPMinute = (RoundToFloor(gF_timeDiffCP[cpnum][other]) / 60) % 60
			int srCPSecond = RoundToFloor(gF_timeDiffCP[cpnum][other]) % 60
			PrintToChat(other, "%i. Checkpoint: -%02.i:%02.i:%02.i", cpnum, srCPHour, srCPMinute, srCPSecond)
			PrintToChat(gI_partner[other], "%i. Checkpoint: -%02.i:%02.i:%02.i", cpnum, srCPHour, srCPMinute, srCPSecond)
		}
		else
		{
			gF_timeDiffCP[cpnum][other] = gF_TimeCP[cpnum][other] - gF_srCPTime[cpnum][other]
			gF_timeDiffCP[cpnum][gI_partner[other]] = gF_TimeCP[cpnum][other] - gF_srCPTime[cpnum][other]
			int srCPHour = (RoundToFloor(gF_timeDiffCP[cpnum][other]) / 3600) % 24
			int srCPMinute = (RoundToFloor(gF_timeDiffCP[cpnum][other]) / 60) % 60
			int srCPSecond = RoundToFloor(gF_timeDiffCP[cpnum][other]) % 60
			PrintToChat(other, "%i. Checkpoint: +%02.i:%02.i:%02.i", cpnum, srCPHour, srCPMinute, srCPSecond)
			PrintToChat(gI_partner[other], "%i. Checkpoint: +%02.i:%02.i:%02.i", cpnum, srCPHour, srCPMinute, srCPSecond)
		}
	}
	else
	{
		PrintToChat(other, "%i. Checkpoint: +00:00:00", cpnum)
		PrintToChat(gI_partner[other], "%i. Checkpoint: +00:00:00", cpnum)
	}
}

void SQLSetTries(Database db, DBResultSet results, const char[] error, any data)
{
}

Action cmd_createzones(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS zones (id INT AUTO_INCREMENT, map VARCHAR(128), type INT, possition_x FLOAT, possition_y FLOAT, possition_z FLOAT, possition_x2 FLOAT, possition_y2 FLOAT, possition_z2 FLOAT, tier INT, PRIMARY KEY (id))") //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key
	gD_mysql.Query(SQLCreateZonesTable, sQuery)
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(!db)
	{
		PrintToServer("Failed to connect to database")
		return
	}
	PrintToServer("Successfuly connected to database.") //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/
	gD_mysql = db
	gD_mysql.SetCharset("utf8") //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-core.sp#L2883
	ForceZonesSetup() //https://sm.alliedmods.net/new-api/dbi/__raw
	gB_passDB = true //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-stats.sp#L199
	char sQuery[512]
	Format(sQuery, 512, "SELECT MIN(time) FROM records WHERE map = '%s'", gS_map)
	gD_mysql.Query(SQLGetServerRecord, sQuery)
}

void ForceZonesSetup()
{
	char sQuery[512]
	Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0", gS_map)
	gD_mysql.Query(SQLSetZoneStart, sQuery)
}

void SQLSetZoneStart(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vecStartZone[0][0] = results.FetchFloat(0)
		gF_vecStartZone[0][1] = results.FetchFloat(1)
		gF_vecStartZone[0][2] = results.FetchFloat(2)
		gF_vecStartZone[1][0] = results.FetchFloat(3)
		gF_vecStartZone[1][1] = results.FetchFloat(4)
		gF_vecStartZone[1][2] = results.FetchFloat(5)
		createstart()
		char sQuery[512]
		Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1", gS_map)
		gD_mysql.Query(SQLSetZoneEnd, sQuery)
	}
}

void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vecEndZone[0][0] = results.FetchFloat(0)
		gF_vecEndZone[0][1] = results.FetchFloat(1)
		gF_vecEndZone[0][2] = results.FetchFloat(2)
		gF_vecEndZone[1][0] = results.FetchFloat(3)
		gF_vecEndZone[1][1] = results.FetchFloat(4)
		gF_vecEndZone[1][2] = results.FetchFloat(5)
		createend()
	}
}

void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Zones table is successfuly created.")
}

Action timer_draw(Handle timer)
{
	float start[13][3]
	float end[13][3]
	start[11][0] = (gF_vecStartZone[0][0] < gF_vecStartZone[1][0]) ? gF_vecStartZone[0][0] : gF_vecStartZone[1][0]
	start[11][1] = (gF_vecStartZone[0][1] < gF_vecStartZone[1][1]) ? gF_vecStartZone[0][1] : gF_vecStartZone[1][1]
	start[11][2] = (gF_vecStartZone[0][2] < gF_vecStartZone[1][2]) ? gF_vecStartZone[0][2] : gF_vecStartZone[1][2]
	start[11][2] += 5.0
	end[11][0] = (gF_vecStartZone[0][0] > gF_vecStartZone[1][0]) ? gF_vecStartZone[0][0] : gF_vecStartZone[1][0]
	end[11][1] = (gF_vecStartZone[0][1] > gF_vecStartZone[1][1]) ? gF_vecStartZone[0][1] : gF_vecStartZone[1][1]
	end[11][2] = (gF_vecStartZone[0][2] > gF_vecStartZone[1][2]) ? gF_vecStartZone[0][2] : gF_vecStartZone[1][2]
	end[11][2] += 5.0
	start[12][0] = (gF_vecEndZone[0][0] < gF_vecEndZone[1][0]) ? gF_vecEndZone[0][0] : gF_vecEndZone[1][0]
	start[12][1] = (gF_vecEndZone[0][1] < gF_vecEndZone[1][1]) ? gF_vecEndZone[0][1] : gF_vecEndZone[1][1]
	start[12][2] = (gF_vecEndZone[0][2] < gF_vecEndZone[1][2]) ? gF_vecEndZone[0][2] : gF_vecEndZone[1][2]
	start[12][2] += 5.0
	end[12][0] = (gF_vecEndZone[0][0] > gF_vecEndZone[1][0]) ? gF_vecEndZone[0][0] : gF_vecEndZone[1][0]
	end[12][1] = (gF_vecEndZone[0][1] > gF_vecEndZone[1][1]) ? gF_vecEndZone[0][1] : gF_vecEndZone[1][1]
	end[12][2] = (gF_vecEndZone[0][2] > gF_vecEndZone[1][2]) ? gF_vecEndZone[0][2] : gF_vecEndZone[1][2]
	end[12][2] += 5.0
	for(int i = 1; i <= 10; i++)
	{
		start[i][0] = (gF_vecCP[0][i][0] < gF_vecCP[1][i][0]) ? gF_vecCP[0][i][0] : gF_vecCP[1][i][0]
		start[i][1] = (gF_vecCP[0][i][1] < gF_vecCP[1][i][1]) ? gF_vecCP[0][i][1] : gF_vecCP[1][i][1]
		start[i][2] = (gF_vecCP[0][i][2] < gF_vecCP[1][i][2]) ? gF_vecCP[0][i][2] : gF_vecCP[1][i][2]
		start[i][2] += 5.0
		end[i][0] = (gF_vecCP[0][i][0] > gF_vecCP[1][i][0]) ? gF_vecCP[0][i][0] : gF_vecCP[1][i][0]
		end[i][1] = (gF_vecCP[0][i][1] > gF_vecCP[1][i][1]) ? gF_vecCP[0][i][1] : gF_vecCP[1][i][1]
		end[i][2] = (gF_vecCP[0][i][2] > gF_vecCP[1][i][2]) ? gF_vecCP[0][i][2] : gF_vecCP[1][i][2]
		end[i][2] += 5.0
	}
	float corners[13][8][3] //https://github.com/tengulawl/scripting/blob/master/include/tengu_stocks.inc
	for(int i = 1; i <= 10; i++)
	{
		//bottom left front
		corners[i][0][0] = start[i][0]
		corners[i][0][1] = start[i][1]
		corners[i][0][2] = start[i][2]
		//bottom right front
		corners[i][1][0] = end[i][0]
		corners[i][1][1] = start[i][1]
		corners[i][1][2] = start[i][2]
		//bottom right back
		corners[i][2][0] = end[i][0]
		corners[i][2][1] = end[i][1]
		corners[i][2][2] = start[i][2]
		//bottom left back
		corners[i][3][0] = start[i][0]
		corners[i][3][1] = end[i][1]
		corners[i][3][2] = start[i][2]
		TE_SetupBeamPoints(corners[i][0], corners[i][1], gI_zoneModel[2], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3050
		TE_SendToAll()
		TE_SetupBeamPoints(corners[i][1], corners[i][2], gI_zoneModel[2], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
		TE_SendToAll()
		TE_SetupBeamPoints(corners[i][2], corners[i][3], gI_zoneModel[2], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
		TE_SendToAll()
		TE_SetupBeamPoints(corners[i][3], corners[i][0], gI_zoneModel[2], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
		TE_SendToAll()
	}
	for(int i = 11; i <= 12; i++)
	{
		//bottom left front
		corners[i][0][0] = start[i][0]
		corners[i][0][1] = start[i][1]
		corners[i][0][2] = start[i][2]
		//bottom right front
		corners[i][1][0] = end[i][0]
		corners[i][1][1] = start[i][1]
		corners[i][1][2] = start[i][2]
		//bottom right back
		corners[i][2][0] = end[i][0]
		corners[i][2][1] = end[i][1]
		corners[i][2][2] = start[i][2]
		//bottom left back
		corners[i][3][0] = start[i][0]
		corners[i][3][1] = end[i][1]
		corners[i][3][2] = start[i][2]
	}
	TE_SetupBeamPoints(corners[11][0], corners[11][1], gI_zoneModel[0], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[11][1], corners[11][2], gI_zoneModel[0], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[11][2], corners[11][3], gI_zoneModel[0], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[11][3], corners[11][0], gI_zoneModel[0], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[12][0], corners[12][1], gI_zoneModel[1], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[12][1], corners[12][2], gI_zoneModel[1], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[12][2], corners[12][3], gI_zoneModel[1], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
	TE_SetupBeamPoints(corners[12][3], corners[12][0], gI_zoneModel[1], 0, 0, 0, 2.0, 5.0, 5.0, 0, 0.0, {0, 0, 0, 0}, 5)
	TE_SendToAll()
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	gI_entityFlags[client] = GetEntityFlags(client)
	if(buttons & IN_JUMP && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1 && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && IsPlayerAlive(client)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
		buttons &= ~IN_JUMP //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
	if(buttons & IN_LEFT || buttons & IN_RIGHT)//https://sm.alliedmods.net/new-api/entity_prop_stocks/__raw Expert-Zone idea.
		KickClient(client, "Don't use joystick") //https://sm.alliedmods.net/new-api/clients/KickClient
	//Timer
	if(gB_state[client])
	{
		gF_Time[client] = GetEngineTime() - gF_TimeStart[client]
		if(!IsPlayerAlive(client))
		{
			gB_readyToStart[client] = true
			gB_readyToStart[gI_partner[client]] = true
			gF_Time[client] = 0.0
			gF_Time[gI_partner[client]] = 0.0
			gB_state[client] = false
			gB_state[gI_partner[client]] = false
		}
	}
	if(1 <= gI_skyFrame[client])
		gI_skyFrame[client]++
	if(gI_skyFrame[client] == 5)
	{
		gI_skyFrame[client] = 0
		gI_skyStep[client] = 0
	}
	if(gB_boost[client] && gI_skyStep[client])
	{
		gI_skyFrame[client] = 0
		gI_skyStep[client] = 0
	}
	if(gI_skyStep[client] == 1 && GetEntityFlags(client) & FL_ONGROUND && GetGameTime() - gF_boostTime[client] > 0.15)
	{
		if(buttons & IN_JUMP)
		{
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, gF_skyVel[client])
			gI_skyStep[client] = 0
			gI_skyFrame[client] = 0
		}
	}
	if(IsPlayerAlive(client) && gI_partner[client])
	{
		if(buttons & IN_USE)
		{
			if(GetEntProp(client, Prop_Data, "m_afButtonPressed"))
				gI_pingTick[client] = 1
			if(gI_pingTick[client] > 0)
				gI_pingTick[client]++
		}
		else
			if(gI_pingTick[client] > 0)
				gI_pingTick[client] = 0
		if(gI_pingTick[client] == 50)
		{
			if(gI_pingModel[client])
			{
				RemoveEntity(gI_pingModel[client])
				gI_pingModel[client] = 0
				KillTimer(gH_timerPing[client])
			}
			gI_pingTick[client] = 0
			gI_pingModel[client] = CreateEntityByName("prop_dynamic_override") //https://www.bing.com/search?q=prop_dynamic_override&cvid=0babe0a3c6cd43aa9340fa9c3c2e0f78&aqs=edge..69i57.409j0j1&pglt=299&FORM=ANNTA1&PC=U531
			SetEntityModel(gI_pingModel[client], "models/fakeexpert/pingtool/pingtool.mdl")
			DispatchSpawn(gI_pingModel[client])
			float start[3]
			float angle[3]
			float end[3]
			GetClientEyePosition(client, start)
			GetClientEyeAngles(client, angle)
			GetAngleVectors(angle, angle, NULL_VECTOR, NULL_VECTOR)
			for(int i = 0; i <= 2; i++)
			{
				angle[i] *= 8192.0
				end[i] = start[i] + angle[i] //thanks to rumour for pingtool original code.
			}
			TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint, TraceEntityFilterPlayer, client)
			if(TR_DidHit(INVALID_HANDLE))
			{
				TR_GetEndPosition(end, INVALID_HANDLE)
				float normal[3]
				TR_GetPlaneNormal(INVALID_HANDLE, normal)
				GetVectorAngles(normal, normal)
				float vecAngle[3]
				GetAngleVectors(normal, vecAngle, NULL_VECTOR, NULL_VECTOR)
				for(int i = 0; i <= 2; i++)
					end[i] += vecAngle[i] * 1.0
				normal[0] -= 270.0
				SetEntPropVector(gI_pingModel[client], Prop_Data, "m_angRotation", normal)
			}
			if(gB_color[client])
				SetEntityRenderColor(gI_pingModel[client], gI_color[client][0], gI_color[client][1], gI_color[client][2], 255)
			TeleportEntity(gI_pingModel[client], end, NULL_VECTOR, NULL_VECTOR)
			//https://forums.alliedmods.net/showthread.php?p=1080444
			if(gB_color[client])
			{
				int color[4]
				for(int i = 0; i <= 2; i++)
					color[i] = gI_color[client][i]
				color[3] = 255
				TE_SetupBeamPoints(start, end, gI_laserBeam, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, color, 0)
			}
			else
				TE_SetupBeamPoints(start, end, gI_laserBeam, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, {255, 255, 255, 255}, 0)
			TE_SendToAll()
			EmitSoundToAll("fakeexpert/pingtool/click.wav", client)
			gH_timerPing[client] = CreateTimer(3.0, timer_removePing, client, TIMER_FLAG_NO_MAPCHANGE)
		}
	}
	if(IsPlayerAlive(client))
	{
		if(gB_block[client] && GetEntProp(client, Prop_Data, "m_CollisionGroup") != 5)
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
			SetEntityRenderMode(client, RENDER_NORMAL)
			gB_block[client] = true
			if(gB_TrikzMenuIsOpen[client])
				Trikz(client)
		}
		else if(!gB_block[client] && GetEntProp(client, Prop_Data, "m_CollisionGroup") != 2)
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
			SetEntityRenderMode(client, RENDER_TRANSALPHA)
			if(gB_color[client])
				SetEntityRenderColor(client, gI_color[client][0], gI_color[client][1], gI_color[client][2], 125)
			else
				SetEntityRenderColor(client, 255, 255, 255, 125)
			gB_block[client] = false
			if(gB_TrikzMenuIsOpen[client])
				Trikz(client)
		}
	}
}

bool TraceEntityFilterPlayer(int entity, int contentMask, any data)
{
	return entity > MaxClients
}

Action timer_removePing(Handle timer, int client)
{
	if(gI_pingModel[client])
	{
		RemoveEntity(gI_pingModel[client])
		gI_pingModel[client] = 0
	}
	return Plugin_Stop
}

Action ProjectileBoostFix(int entity, int other)
{
	if(0 < other <= MaxClients && IsClientInGame(other) && !gB_boost[other] && !(gI_entityFlags[other] & FL_ONGROUND))
	{
		float vecOriginOther[3]
		GetClientAbsOrigin(other, vecOriginOther)
		float vecOriginEntity[3]
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOriginEntity)
		//float vecMaxsEntity[3]
		//GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxsEntity)
		//float delta = vecOriginOther[2] - vecOriginEntity[2] - vecMaxsEntity[2]
		//Thanks to extremix/hornet for idea from 2019 year summer. Extremix version (if(!(clientOrigin[2] - 5 <= entityOrigin[2] <= clientOrigin[2])) //Calculate for Client/Flash - Thanks to extrem)/tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231//https://forums.alliedmods.net/showthread.php?t=146241
		//if(0.0 < delta < 2.0) //tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231
		if(vecOriginOther[2] >= vecOriginEntity[2])
		{
			float vecVelClient[3]
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", vecVelClient)
			float vecVelEntity[3]
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vecVelEntity)
			vecVelClient[0] -= vecVelEntity[0] * 0.9964619
			vecVelClient[1] -= vecVelEntity[1] * 0.9964619
			gF_vecVelBoostFix[other][0] = vecVelClient[0]
			gF_vecVelBoostFix[other][1] = vecVelClient[1]
			gF_vecVelBoostFix[other][2] = FloatAbs(vecVelEntity[2])
			gF_boostTime[other] = GetGameTime()
			gB_groundBoost[other] = gB_bouncedOff[entity]
			SetEntProp(entity, Prop_Send, "m_nSolidType", 0) //https://forums.alliedmods.net/showthread.php?t=286568 non model no solid model Gray83 author of solid model types.
			gI_flash[other] = EntIndexToEntRef(entity) //check this for postthink post to correct set first telelportentity speed. starttouch have some outputs only one of them is coorect wich gives correct other(player) id.
			gB_boost[other] = true
		}
	}
}

Action cmd_devmap(int client, int args)
{
	if(GetEngineTime() - gF_devmapTime > 25.0 )
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(gB_isDevmap)
			{
				Menu menu = new Menu(devmap_handler)
				menu.SetTitle("Turn off dev map?")
				menu.AddItem("yes", "Yes")
				menu.AddItem("no", "No")
				menu.Display(i, 20)
			}
			else
			{
				Menu menu = new Menu(devmap_handler)
				menu.SetTitle("Turn on dev map?")
				menu.AddItem("yes", "Yes")
				menu.AddItem("no", "No")
				menu.Display(i, 20)
			}
		}
		gF_devmapTime = GetEngineTime()
		CreateTimer(20.0, timer_devmap, _, TIMER_FLAG_NO_MAPCHANGE)
	}
	return Plugin_Handled
}

int devmap_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					if(gB_isDevmap)
						gF_devmap[0]++
					else
						gF_devmap[1]++
				}
				case 1:
				{
					if(gB_isDevmap)
						gF_devmap[1]++
					else
						gF_devmap[0]++
				}
			}
		}
		case MenuAction_End:
			delete menu
	}
}

Action timer_devmap(Handle timer)
{
	//devmap idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] >= gF_devmap[0] && !gB_isDevmap)
	{
		PrintToChatAll("Devmap will be enabled. \"Yes\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[1] / (gF_devmap[0] + gF_devmap[1])) * 100.0, gF_devmap[1], gF_devmap[0] + gF_devmap[1])
		gB_isDevmap = true
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		CreateTimer(5.0, timer_changelevel)
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] >= gF_devmap[0] && gB_isDevmap)
	{
		PrintToChatAll("Devmap will be continue. \"No\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[1] / (gF_devmap[0] + gF_devmap[1])) * 100.0, gF_devmap[1], gF_devmap[0] + gF_devmap[1])
		//google translate russian to english.
		gB_isDevmap = true
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] <= gF_devmap[0] && gB_isDevmap)
	{
		PrintToChatAll("Devmap will be disabled. \"Yes\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[0] / (gF_devmap[0] + gF_devmap[1])) * 100.0, gF_devmap[0], gF_devmap[0] + gF_devmap[1])
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gB_isDevmap = false
		CreateTimer(5.0, timer_changelevel)
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] <= gF_devmap[0] && !gB_isDevmap)
	{
		PrintToChatAll("Devmap will not be enabled. \"No\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[0] / (gF_devmap[0] + gF_devmap[1])) * 100.0, gF_devmap[0], gF_devmap[0] + gF_devmap[1])
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gB_isDevmap = false
	}
	for(int i = 0; i <= 1; i++)
		gF_devmap[i] = 0.0
	return Plugin_Stop
}

Action timer_changelevel(Handle timer)
{
	ForceChangeLevel(gS_map, "Reason: Devmap")
}

Action ProjectileBoostFixEndTouch(int entity, int other)
{
	if(!other)
		gB_bouncedOff[entity] = true //get from tengu github tengulawl scriptig boost-fix.sp
}

Action cmd_time(int client, int args)
{
	//https://forums.alliedmods.net/archive/index.php/t-23912.html //ShAyA format OneEyed format second
	int hour = (RoundToFloor(gF_Time[client]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
	int minute = (RoundToFloor(gF_Time[client]) / 60) % 60
	int second = RoundToFloor(gF_Time[client]) % 60
	PrintToChat(client, "Time: %f [%02.i:%02.i:%02.i]", gF_Time[client], hour, minute, second)
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
	{
		gB_bouncedOff[entity] = false //tengu lawl boost fix .sp
		SDKHook(entity, SDKHook_Spawn, SDKProjectile)
		SDKHook(entity, SDKHook_StartTouch, ProjectileBoostFix)
		SDKHook(entity, SDKHook_EndTouch, ProjectileBoostFixEndTouch)
		SDKHook(entity, SDKHook_SpawnPost, SDKProjectilePost)
	}
}

Action SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	if(IsValidEntity(entity) || IsPlayerAlive(client))
	{
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2) //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
		gB_silentKnife = true
		FakeClientCommand(client, "use weapon_knife")
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", 0) //thanks to alliedmodders. 2019 //https://forums.alliedmods.net/archive/index.php/t-287052.html
		ClientCommand(client, "lastinv") //hornet, log idea, main idea Nick Yurevich since 2019, hornet found ClientCommand - lastinv
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", 1)
		CreateTimer(1.49, timer_deleteProjectile, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE) //sometimes flashbang going to flash, entindextoentref must fix it.
	}
}

void SDKProjectilePost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	if(IsValidEntity(entity) || IsPlayerAlive(client))
	{
		if(gB_color[client])
		{
			SetEntProp(entity, Prop_Data, "m_nModelIndex", gI_wModelThrown)
			SetEntProp(entity, Prop_Data, "m_nSkin", 1)
			SetEntityRenderColor(entity, gI_color[client][0], gI_color[client][1], gI_color[client][2], 255)
		}
	}
}

Action timer_deleteProjectile(Handle timer, int entRef)
{
	int entity = EntRefToEntIndex(entRef)
	if(IsValidEntity(entity))
		RemoveEntity(entity)
	return Plugin_Stop
}

void SDKPlayerSpawnPost(int client)
{
	if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	{
		GivePlayerItem(client, "weapon_flashbang")
		GivePlayerItem(client, "weapon_flashbang") 
	}
}

Action SDKOnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR) //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR)
	return Plugin_Handled
}

void SDKWeaponEquipPost(int client, int weapon) //https://sm.alliedmods.net/new-api/sdkhooks/__raw thanks to lon to give this idea. aka trikz_failtime
{
	if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	{
		GivePlayerItem(client, "weapon_flashbang")
		GivePlayerItem(client, "weapon_flashbang")
	}
}

Action SoundHook(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
{
	if(StrEqual(sample, "weapons/knife/knife_deploy1.wav") && gB_silentKnife)
	{
		gB_silentKnife = false
		return Plugin_Handled
	}
	return Plugin_Continue
}
