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
#include <clientprefs>

int g_partner[MAXPLAYERS + 1]
float g_partnerInHold[MAXPLAYERS + 1]
bool g_partnerInHoldLock[MAXPLAYERS + 1]
float g_zoneStartOrigin[2][3]
float g_zoneEndOrigin[2][3]
Database g_mysql
float g_timerTimeStart[MAXPLAYERS + 1]
float g_timerTime[MAXPLAYERS + 1]
bool g_state[MAXPLAYERS + 1]
char g_map[192]
bool g_mapFinished[MAXPLAYERS + 1]
bool g_dbPassed
float g_originStart[3]
float g_boostTime[MAXPLAYERS + 1]
float g_skyVel[MAXPLAYERS + 1][3]
bool g_readyToStart[MAXPLAYERS + 1]

float g_cpPos[2][11][3]
bool g_cp[11][MAXPLAYERS + 1]
bool g_cpLock[11][MAXPLAYERS + 1]
float g_cpTimeClient[11][MAXPLAYERS + 1]
float gF_cpDiff[11][MAXPLAYERS + 1]
float g_cpTime[11]

float g_haveRecord[MAXPLAYERS + 1]
float g_ServerRecordTime

ConVar g_steamid //https://wiki.alliedmods.net/ConVars_(SourceMod_Scripting)
ConVar g_urlTop

bool g_menuOpened[MAXPLAYERS + 1]

int g_boost[MAXPLAYERS + 1]
int g_skyBoost[MAXPLAYERS + 1]
bool g_bouncedOff[2048 + 1]
bool g_groundBoost[MAXPLAYERS + 1]
int g_flash[MAXPLAYERS + 1]
int g_entityFlags[MAXPLAYERS + 1]
int g_devmapCount[2]
bool g_devmap
float g_devmapTime

float g_cpOrigin[MAXPLAYERS + 1][2][3]
float g_cpAng[MAXPLAYERS + 1][2][3]
float g_cpVel[MAXPLAYERS + 1][2][3]
bool g_cpToggled[MAXPLAYERS + 1][2]

bool g_zoneHave[3]

bool g_ServerRecord
char g_date[64]
char g_time[64]

bool g_silentKnife
float g_mateRecord[MAXPLAYERS + 1]
bool g_sourcetv
bool g_block[MAXPLAYERS + 1]
int g_wModelThrown
int g_class[MAXPLAYERS + 1]
bool g_color[MAXPLAYERS + 1]
int g_wModelPlayer[5]
int g_pingModel[MAXPLAYERS + 1]
int g_pingModelOwner[2048 + 1]
Handle g_pingTimer[MAXPLAYERS + 1]

bool g_zoneFirst[3]

char g_colorType[][] = {"255,255,255", "255,0,0", "255,165,0", "255,255,0", "0,255,0", "0,255,255", "0,191,255", "0,0,255", "255,0,255"} //white, red, orange, yellow, lime, aqua, deep sky blue, blue, magenta //https://flaviocopes.com/rgb-color-codes/#:~:text=A%20table%20summarizing%20the%20RGB%20color%20codes%2C%20which,%20%20%28178%2C34%2C34%29%20%2053%20more%20rows%20
int g_colorBuffer[MAXPLAYERS + 1][3]
int g_colorCount[MAXPLAYERS + 1]

int g_zoneModel[3]
int g_laserBeam
bool g_sourcetvchangedFileName = true
float g_entityVel[MAXPLAYERS + 1][3]
float g_clientVel[MAXPLAYERS + 1][3]
int g_cpCount
ConVar g_turbophysics
float g_afkTime
bool g_afk[MAXPLAYERS + 1]
float g_center[12][3]
bool g_zoneDraw[MAXPLAYERS + 1]
float g_engineTime
float g_pingTime[MAXPLAYERS + 1]
bool g_pingLock[MAXPLAYERS + 1]
bool g_msg[MAXPLAYERS + 1]
int g_voters
int g_afkClient
bool g_hudVel[MAXPLAYERS + 1]
float g_hudTime[MAXPLAYERS + 1]
char g_clantag[MAXPLAYERS + 1][2][256]
//Handle g_clantagTimer[MAXPLAYERS + 1]
float g_mlsVel[MAXPLAYERS + 1][2][2]
int g_mlsCount[MAXPLAYERS + 1]
char g_mlsPrint[MAXPLAYERS + 1][100][256]
int g_mlsBooster[MAXPLAYERS + 1]
bool g_mlstats[MAXPLAYERS + 1]
float g_mlsDistance[MAXPLAYERS + 1][2][3]
bool g_button[MAXPLAYERS + 1]
bool g_pbutton[MAXPLAYERS + 1]
float g_skyOrigin[MAXPLAYERS + 1]
int g_entityButtons[MAXPLAYERS + 1]
bool g_teleported[MAXPLAYERS + 1]
int g_points[MAXPLAYERS + 1]
Handle g_start
Handle g_record
int g_pointsMaxs = 1
int g_queryLast
Handle g_cookie[4]
float g_skyAble[MAXPLAYERS + 1]
native bool Trikz_GetEntityFilter(int client, int entity)
float g_restartInHold[MAXPLAYERS + 1]
bool g_restartInHoldLock[MAXPLAYERS + 1]
int g_smoke
bool g_clantagOnce[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "trikz + timer",
	author = "Smesh(Nick Yurevich)",
	description = "Allows to able make trikz more comfortable",
	version = "3.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	g_steamid = CreateConVar("steamid", "", "Set steamid for control the plugin ex. 120192594. Use status to check your uniqueid, without 'U:1:'.")
	g_urlTop = CreateConVar("topurl", "", "Set url for top for ex (http://www.fakeexpert.rf.gd/?start=0&map=). To open page, type in game chat !top")
	AutoExecConfig(true) //https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig
	RegConsoleCmd("sm_t", cmd_trikz)
	RegConsoleCmd("sm_trikz", cmd_trikz)
	RegConsoleCmd("sm_bl", cmd_block)
	RegConsoleCmd("sm_block", cmd_block)
	RegConsoleCmd("sm_p", cmd_partner)
	RegConsoleCmd("sm_partner", cmd_partner)
	RegConsoleCmd("sm_c", cmd_color)
	RegConsoleCmd("sm_color", cmd_color)
	RegConsoleCmd("sm_r", cmd_restart)
	RegConsoleCmd("sm_restart", cmd_restart)
	//RegConsoleCmd("sm_time", cmd_time)
	RegConsoleCmd("sm_cp", cmd_checkpoint)
	RegConsoleCmd("sm_devmap", cmd_devmap)
	RegConsoleCmd("sm_top", cmd_top)
	RegConsoleCmd("sm_afk", cmd_afk)
	RegConsoleCmd("sm_nc", cmd_noclip)
	RegConsoleCmd("sm_noclip", cmd_noclip)
	RegConsoleCmd("sm_sp", cmd_spec)
	RegConsoleCmd("sm_spec", cmd_spec)
	RegConsoleCmd("sm_hud", cmd_hud)
	RegConsoleCmd("sm_mls", cmd_mlstats)
	RegConsoleCmd("sm_button", cmd_button)
	RegConsoleCmd("sm_pbutton", cmd_pbutton)
	RegServerCmd("sm_createzones", cmd_createzones)
	RegServerCmd("sm_createusers", cmd_createusers)
	RegServerCmd("sm_createrecords", cmd_createrecords)
	RegServerCmd("sm_createcp", cmd_createcp)
	RegServerCmd("sm_createtier", cmd_createtier)
	RegConsoleCmd("sm_startmins", cmd_startmins)
	RegConsoleCmd("sm_startmaxs", cmd_startmaxs)
	RegConsoleCmd("sm_endmins", cmd_endmins)
	RegConsoleCmd("sm_endmaxs", cmd_endmaxs)
	RegConsoleCmd("sm_cpmins", cmd_cpmins)
	RegConsoleCmd("sm_cpmaxs", cmd_cpmaxs)
	RegConsoleCmd("sm_zones", cmd_zones)
	RegConsoleCmd("sm_maptier", cmd_maptier)
	RegConsoleCmd("sm_deleteallcp", cmd_deleteallcp)
	RegConsoleCmd("sm_test", cmd_test)
	AddNormalSoundHook(OnSound)
	HookUserMessage(GetUserMessageId("SayText2"), OnSayMessage, true) //thanks to VerMon idea. https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-chat.sp#L416
	HookEvent("player_spawn", OnSpawn)
	HookEntityOutput("func_button", "OnPressed", OnButton)
	HookEvent("player_jump", OnJump)
	HookEvent("player_death", OnDeath)
	AddCommandListener(joinclass, "joinclass")
	AddCommandListener(autobuy, "autobuy")
	AddCommandListener(rebuy, "rebuy")
	AddCommandListener(cheer, "cheer")
	AddCommandListener(showbriefing, "showbriefing")
	AddCommandListener(headtrack_reset_home_pos, "headtrack_reset_home_pos")
	char output[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger"}
	for(int i = 0; i < sizeof(output); i++)
	{
		HookEntityOutput("trigger_teleport", output[i], output_teleport) //https://developer.valvesoftware.com/wiki/Trigger_teleport
		HookEntityOutput("trigger_teleport_relative", output[i], output_teleport) //https://developer.valvesoftware.com/wiki/Trigger_teleport_relative
	}
	LoadTranslations("test.phrases") //https://wiki.alliedmods.net/Translations_(SourceMod_Scripting)
	g_start = CreateGlobalForward("Trikz_Start", ET_Hook, Param_Cell)
	g_record = CreateGlobalForward("Trikz_Record", ET_Hook, Param_Cell, Param_Float)
	RegPluginLibrary("fakeexpert")
	g_cookie[0] = RegClientCookie("vel", "velocity in hint", CookieAccess_Protected)
	g_cookie[1] = RegClientCookie("mls", "mega long stats", CookieAccess_Protected)
	g_cookie[2] = RegClientCookie("button", "button", CookieAccess_Protected)
	g_cookie[3] = RegClientCookie("pbutton", "partner button", CookieAccess_Protected)
	CreateTimer(60.0, timer_clearlag)
}

public void OnMapStart()
{
	GetCurrentMap(g_map, 192)
	Database.Connect(SQLConnect, "fakeexpert")
	for(int i = 0; i <= 2; i++)
	{
		g_zoneHave[i] = false
		if(g_devmap)
			g_zoneFirst[i] = false
	}
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool sourcetv = CV_sourcetv.BoolValue //https://github.com/alliedmodders/sourcemod/blob/master/plugins/funvotes.sp#L280
	if(sourcetv)
	{
		if(!g_sourcetvchangedFileName)
		{
			char filenameOld[256]
			Format(filenameOld, 256, "%s-%s-%s.dem", g_date, g_time, g_map)
			char filenameNew[256]
			Format(filenameNew, 256, "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map)
			RenameFile(filenameNew, filenameOld)
			g_sourcetvchangedFileName = true
		}
		if(!g_devmap)
		{
			PrintToServer("sourcetv start recording.")
			FormatTime(g_date, 64, "%Y-%m-%d", GetTime())
			FormatTime(g_time, 64, "%H-%M-%S", GetTime())
			ServerCommand("tv_record %s-%s-%s", g_date, g_time, g_map) //https://www.youtube.com/watch?v=GeGd4KOXNb8 https://forums.alliedmods.net/showthread.php?t=59474 https://www.php.net/strftime
		}
	}
	if(!g_sourcetv && !sourcetv)
	{
		g_sourcetv = true
		ForceChangeLevel(g_map, "Turn on sourcetv")
	}
	g_wModelThrown = PrecacheModel("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.mdl", true)
	g_wModelPlayer[1] = PrecacheModel("models/fakeexpert/player/ct_urban.mdl", true)
	g_wModelPlayer[2] = PrecacheModel("models/fakeexpert/player/ct_gsg9.mdl", true)
	g_wModelPlayer[3] = PrecacheModel("models/fakeexpert/player/ct_sas.mdl", true)
	g_wModelPlayer[4] = PrecacheModel("models/fakeexpert/player/ct_gign.mdl", true)
	PrecacheSound("fakeexpert/pingtool/click.wav", true) //https://forums.alliedmods.net/showthread.php?t=333211
	g_zoneModel[0] = PrecacheModel("materials/fakeexpert/zones/start.vmt", true)
	g_zoneModel[1] = PrecacheModel("materials/fakeexpert/zones/finish.vmt", true)
	g_zoneModel[2] = PrecacheModel("materials/fakeexpert/zones/check_point.vmt", true)
	g_laserBeam = PrecacheModel("materials/sprites/laser.vmt", true)
	g_smoke = PrecacheModel("materials/sprites/smoke.vmt", true)
	PrecacheSound("weapons/flashbang/flashbang_explode1.wav", true)
	PrecacheSound("weapons/flashbang/flashbang_explode2.wav", true)
	char path[12][PLATFORM_MAX_PATH] = {"models/fakeexpert/models/weapons/", "models/fakeexpert/pingtool/", "models/fakeexpert/player/", "materials/fakeexpert/materials/models/weapons/w_models/", "materials/fakeexpert/pingtool/", "sound/fakeexpert/pingtool/", "materials/fakeexpert/player/ct_gign/", "materials/fakeexpert/player/ct_gsg9/", "materials/fakeexpert/player/ct_sas/", "materials/fakeexpert/player/ct_urban/", "materials/fakeexpert/player/", "materials/fakeexpert/zones/"}
	for(int i = 0; i < sizeof(path); i++)
	{
		DirectoryListing dir = OpenDirectory(path[i])
		char filename[12][PLATFORM_MAX_PATH]
		FileType type
		char pathFull[12][PLATFORM_MAX_PATH]
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
	g_turbophysics = FindConVar("sv_turbophysics") //thnaks to maru.
	RecalculatePoints()
}

void RecalculatePoints()
{
	if(g_dbPassed)
		g_mysql.Query(SQLRecalculatePoints_GetMap, "SELECT map FROM tier")
}

void SQLRecalculatePoints_GetMap(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecalculatePoints_GetMap: %s", error)
	else
	{
		while(results.FetchRow())
		{
			char map[192]
			results.FetchString(0, map, 192)
			char query[512]
			Format(query, 512, "SELECT (SELECT COUNT(*) FROM records WHERE map = '%s'), (SELECT tier FROM tier WHERE map = '%s'), id FROM records WHERE map = '%s' ORDER BY time", map, map, map) //https://stackoverflow.com/questions/38104018/select-and-count-rows-in-the-same-query
			g_mysql.Query(SQLRecalculatePoints, query)
		}
	}
}

void SQLRecalculatePoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecalculatePoints: %s", error)
	else
	{
		int place
		char query[512]
		while(results.FetchRow())
		{
			int points = results.FetchInt(1) * results.FetchInt(0) / ++place //thanks to DeadSurfer
			Format(query, 512, "UPDATE records SET points = %i WHERE id = %i LIMIT 1", points, results.FetchInt(2))
			g_queryLast++
			g_mysql.Query(SQLRecalculatePoints2, query)
		}
	}
}

void SQLRecalculatePoints2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecalculatePoints2: %s", error)
	else
	{
		if(g_queryLast-- && !g_queryLast)
			g_mysql.Query(SQLRecalculatePoints3, "SELECT steamid FROM users")
	}
}

void SQLRecalculatePoints3(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecalculatePoints3: %s", error)
	else
	{
		while(results.FetchRow())
		{
			char query[512]
			Format(query, 512, "SELECT MAX(points) FROM records WHERE (playerid = %i OR partnerid = %i) GROUP BY map", results.FetchInt(0), results.FetchInt(0))
			g_mysql.Query(SQLRecalculateUserPoints, query, results.FetchInt(0))
		}
	}
}

void SQLRecalculateUserPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecalculateUserPoints: %s", error)
	else
	{
		int points
		while(results.FetchRow())
			points += results.FetchInt(0)
		char query[512]
		Format(query, 512, "UPDATE users SET points = %i WHERE steamid = %i LIMIT 1", points, data)
		g_queryLast++
		g_mysql.Query(SQLUpdateUserPoints, query)
	}
}

void SQLUpdateUserPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLUpdateUserPoints: %s", error)
	else
	{
		if(results.HasResults == false)
			if(g_queryLast-- && !g_queryLast)
				g_mysql.Query(SQLGetPointsMaxs, "SELECT points FROM users ORDER BY points DESC LIMIT 1")
	}
}

void SQLGetPointsMaxs(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetPointsMaxs: %s", error)
	else
	{
		if(results.FetchRow())
		{
			g_pointsMaxs = results.FetchInt(0)
			char query[512]
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i))
				{
					int steamid = GetSteamAccountID(i)
					Format(query, 512, "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid)
					g_mysql.Query(SQLGetPoints, query, GetClientSerial(i))
				}
			}
		}
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetClientButtons", Native_GetClientButtons)
	CreateNative("Trikz_GetClientPartner", Native_GetClientPartner)
	CreateNative("Trikz_GetTimerState", Native_GetTimerState)
	CreateNative("Trikz_SetPartner", Native_SetPartner)
	CreateNative("Trikz_Restart", Native_Restart)
	CreateNative("Trikz_GetDevmap", Native_GetDevmap)
	MarkNativeAsOptional("Trikz_GetEntityFilter")
	return APLRes_Success
}

public void OnMapEnd()
{
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool sourcetv = CV_sourcetv.BoolValue
	if(sourcetv)
	{
		ServerCommand("tv_stoprecord")
		char filenameOld[256]
		Format(filenameOld, 256, "%s-%s-%s.dem", g_date, g_time, g_map)
		if(g_ServerRecord)
		{
			char filenameNew[256]
			Format(filenameNew, 256, "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map)
			RenameFile(filenameNew, filenameOld)
			g_ServerRecord = false
		}
		else
			DeleteFile(filenameOld)
	}
}

Action OnSayMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	int client = msg.ReadByte()
	msg.ReadByte()
	char msgBuffer[32]
	msg.ReadString(msgBuffer, 32)
	char name[MAX_NAME_LENGTH]
	msg.ReadString(name, MAX_NAME_LENGTH)
	char text[256]
	msg.ReadString(text, 256)
	if(!g_msg[client])
		return Plugin_Handled
	g_msg[client] = false
	char msgFormated[32]
	Format(msgFormated, 32, "%s", msgBuffer)
	char points[32]
	int precentage = g_points[client] / g_pointsMaxs * 100
	char color[8]
	if(precentage >= 90)
		Format(color, 8, "FF8000")
	else if(precentage >= 70)
		Format(color, 8, "A335EE")
	else if(precentage >= 55)
		Format(color, 8, "0070DD")
	else if(precentage >= 40)
		Format(color, 8, "1EFF00")
	else if(precentage >= 15)
		Format(color, 8, "FFFFFF")
	else if(precentage >= 0)
		Format(color, 8, "9D9D9D") //https://wowpedia.fandom.com/wiki/Quality
	if(g_points[client] < 1000)
		Format(points, 32, "\x07%s%i\x01", color, g_points[client])
	else if(g_points[client] > 999)
		Format(points, 32, "\x07%s%iK\x01", color, g_points[client] / 1000)
	else if(g_points[client] > 999999)
		Format(points, 32, "\x07%s%iM\x01", color, g_points[client] / 1000000)
	if(StrEqual(msgBuffer, "Cstrike_Chat_AllSpec"))
		Format(text, 256, "\x01*SPEC* [%s] \x07CCCCCC%s \x01:  %s", points, name, text) //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L566
	else if(StrEqual(msgBuffer, "Cstrike_Chat_Spec"))
		Format(text, 256, "\x01(Spectator) [%s] \x07CCCCCC%s \x01:  %s", points, name, text)
	else if(StrEqual(msgBuffer, "Cstrike_Chat_All"))
	{
		if(GetClientTeam(client) == 2)
			Format(text, 256, "\x01[%s] \x07FF4040%s \x01:  %s", points, name, text) //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L638
		else if(GetClientTeam(client) == 3)
			Format(text, 256, "\x01[%s] \x0799CCFF%s \x01:  %s", points, name, text) //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L513
	}
	else if(StrEqual(msgBuffer, "Cstrike_Chat_AllDead"))
	{
		if(GetClientTeam(client) == 2)
			Format(text, 256, "\x01*DEAD* [%s] \x07FF4040%s \x01:  %s", points, name, text)
		else if(GetClientTeam(client) == 3)
			Format(text, 256, "\x01*DEAD* [%s] \x0799CCFF%s \x01:  %s", points, name, text)
	}
	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT"))
		Format(text, 256, "\x01(Counter-Terrorist) [%s] \x0799CCFF%s \x01:  %s", points, name, text)
	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT_Dead"))
		Format(text, 256, "\x01*DEAD*(Counter-Terrorist) [%s] \x0799CCFF%s \x01:  %s", points, name, text)
	else if(StrEqual(msgBuffer, "Cstrike_Chat_T"))
		Format(text, 256, "\x01(Terrorist) [%s] \x07FF4040%s \x01:  %s", points, name, text) //https://forums.alliedmods.net/showthread.php?t=185016
	else if(StrEqual(msgBuffer, "Cstrike_Chat_T_Dead"))
		Format(text, 256, "\x01*DEAD*(Terrorist) [%s] \x07FF4040%s \x01:  %s", points, name, text)
	DataPack dp = new DataPack()
	dp.WriteCell(GetClientSerial(client))
	dp.WriteCell(StrContains(msgBuffer, "_All") != -1)
	dp.WriteString(text)
	RequestFrame(frame_SayText2, dp)
	return Plugin_Handled
}

void frame_SayText2(DataPack dp)
{
	dp.Reset()
	int client = GetClientFromSerial(dp.ReadCell())
	bool allchat = dp.ReadCell()
	char text[256]
	dp.ReadString(text, 256)
	if(IsClientInGame(client))
	{
		int clients[MAXPLAYERS + 1]
		int count
		int team = GetClientTeam(client)
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i) && (allchat || GetClientTeam(i) == team))
				clients[count++] = i
		Handle SayText2 = StartMessage("SayText2", clients, count, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS)
		BfWrite bfmsg = UserMessageToBfWrite(SayText2)
		bfmsg.WriteByte(client)
		bfmsg.WriteByte(true)
		bfmsg.WriteString(text)
		EndMessage()
		g_msg[client] = true
	}
}

Action OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	char model[PLATFORM_MAX_PATH]
	GetClientModel(client, model, PLATFORM_MAX_PATH)
	if(StrEqual(model, "models/player/ct_urban.mdl"))
		g_class[client] = 1
	else if(StrEqual(model, "models/player/ct_gsg9.mdl"))
		g_class[client] = 2
	else if(StrEqual(model, "models/player/ct_sas.mdl"))
		g_class[client] = 3
	else if(StrEqual(model, "models/player/ct_gign.mdl"))
		g_class[client] = 4
	if(g_color[client])
	{
		SetEntProp(client, Prop_Data, "m_nModelIndex", g_wModelPlayer[g_class[client]])
		DispatchKeyValue(client, "skin", "2")
		SetEntityRenderColor(client, g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], 255)
	}
	else
		SetEntityRenderColor(client, 255, 255, 255, 255)
	SetEntityRenderMode(client, RENDER_TRANSALPHA) //maru is genius person who fix this bug. thanks maru for idea.
	if(!g_devmap && !g_clantagOnce[client])
	{
		CS_GetClientClanTag(client, g_clantag[client][0], 256)
		g_clantagOnce[client] = true
	}
}

void OnButton(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients && IsClientInGame(activator) && GetClientButtons(activator) & IN_USE)
	{
		if(g_button[activator])
			PrintToChat(activator, "You have pressed a button.")
		if(g_pbutton[g_partner[activator]])
			PrintToChat(g_partner[activator], "Your partner have pressed a button.")
	}
}

Action OnJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	g_skyOrigin[client] = GetGroundPos(client)
	g_skyAble[client] = GetGameTime()
}

Action OnDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll")
	RemoveEntity(ragdoll)
}

Action joinclass(int client, const char[] command, int argc)
{
	CreateTimer(1.0, timer_respawn, client, TIMER_FLAG_NO_MAPCHANGE)
}

Action timer_respawn(Handle timer, int client)
{
	if(IsClientInGame(client) && GetClientTeam(client) != CS_TEAM_SPECTATOR && !IsPlayerAlive(client))
		CS_RespawnPlayer(client)
}

Action autobuy(int client, const char[] command, int argc)
{
	Block(client)
}

Action rebuy(int client, const char[] command, int argc)
{
	Color(client, false, true)
}

Action cheer(int client, const char[] command, int argc)
{
	if(g_partner[client])
		Partner(client)
}

Action showbriefing(int client, const char[] command, int argc)
{
	Menu menu = new Menu(menu_info_handler)
	menu.SetTitle("Control")
	menu.AddItem("top", "!top")
	menu.AddItem("js", "!js")
	menu.AddItem("hud", "!hud")
	menu.AddItem("button", "!button")
	menu.AddItem("pbutton", "!pbutton")
	menu.AddItem("trikz", "!trikz")
	menu.AddItem("spec", "!spec")
	menu.Display(client, 20)
}

int menu_info_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
					cmd_top(param1, 0)
				case 1:
					FakeClientCommand(param1, "sm_js")
				case 2:
					cmd_hud(param1, 0)
				case 3:
					cmd_button(param1, 0)
				case 4:
					cmd_pbutton(param1, 0)
				case 5:
					Trikz(param1)
				case 6:
					cmd_spec(param1, 0)
			}
		}
	}
}

Action headtrack_reset_home_pos(int client, const char[] command, int argc)
{
	Color(client, true)
}

void output_teleport(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
		g_teleported[activator] = true
}

Action cmd_checkpoint(int client, int args)
{
	Checkpoint(client)
	return Plugin_Handled
}

void Checkpoint(int client)
{
	if(g_devmap)
	{
		Menu menu = new Menu(checkpoint_handler)
		menu.SetTitle("Checkpoint")
		menu.AddItem("Save", "Save")
		menu.AddItem("Teleport", "Teleport", g_cpToggled[client][0] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
		menu.AddItem("Save second", "Save second")
		menu.AddItem("Teleport second", "Teleport second", g_cpToggled[client][1] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
		menu.ExitBackButton = true //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
		menu.Display(client, MENU_TIME_FOREVER)
	}
	else
		PrintToChat(client, "Turn on devmap.")
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
					GetClientAbsOrigin(param1, g_cpOrigin[param1][0])
					GetClientEyeAngles(param1, g_cpAng[param1][0]) //https://github.com/Smesh292/trikz/blob/main/checkpoint.sp#L101
					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", g_cpVel[param1][0])
					if(!g_cpToggled[param1][0])
						g_cpToggled[param1][0] = true
				}
				case 1:
					TeleportEntity(param1, g_cpOrigin[param1][0], g_cpAng[param1][0], g_cpVel[param1][0])
				case 2:
				{
					GetClientAbsOrigin(param1, g_cpOrigin[param1][1])
					GetClientEyeAngles(param1, g_cpAng[param1][1])
					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", g_cpVel[param1][1])
					if(!g_cpToggled[param1][1])
						g_cpToggled[param1][1] = true
				}
				case 3:
					TeleportEntity(param1, g_cpOrigin[param1][1], g_cpAng[param1][1], g_cpVel[param1][1])
			}
			Checkpoint(param1)
		}
		case MenuAction_Cancel: // trikz redux menuaction end
		{
			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
					Trikz(param1)
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage)
	SDKHook(client, SDKHook_StartTouch, SDKSkyFix)
	SDKHook(client, SDKHook_PostThinkPost, SDKBoostFix) //idea by tengulawl/scripting/blob/master/boost-fix tengulawl github.com
	SDKHook(client, SDKHook_WeaponEquipPost, SDKWeaponEquip)
	SDKHook(client, SDKHook_WeaponDrop, SDKWeaponDrop)
	if(IsClientInGame(client) && g_dbPassed)
	{
		g_mysql.Query(SQLAddUser, "SELECT id FROM users LIMIT 1", GetClientSerial(client), DBPrio_High)
		char query[512]
		int steamid = GetSteamAccountID(client)
		Format(query, 512, "SELECT time FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s' ORDER BY time LIMIT 1", steamid, steamid, g_map)
		g_mysql.Query(SQLGetPersonalRecord, query, GetClientSerial(client))
	}
	g_menuOpened[client] = false
	for(int i = 0; i <= 1; i++)
	{
		g_cpToggled[client][i] = false
		for(int j = 0; j <= 2; j++)
		{
			g_cpOrigin[client][i][j] = 0.0
			g_cpAng[client][i][j] = 0.0
			g_cpVel[client][i][j] = 0.0
		}
	}
	g_block[client] = true
	//g_timerTime[client] = 0.0
	if(!g_devmap && g_zoneHave[2])
		DrawZone(client, 0.0)
	g_msg[client] = true
	if(!AreClientCookiesCached(client))
	{
		g_hudVel[client] = false
		g_mlstats[client] = false
		g_button[client] = false
		g_pbutton[client] = false
	}
	ResetFactory(client)
	g_points[client] = 0
	if(!g_zoneHave[2])
		CancelClientMenu(client)
	g_clantagOnce[client] = false
}

public void OnClientCookiesCached(int client)
{
	char value[16]
	GetClientCookie(client, g_cookie[0], value, 16)
	g_hudVel[client] = view_as<bool>(StringToInt(value))
	GetClientCookie(client, g_cookie[1], value, 16)
	g_mlstats[client] = view_as<bool>(StringToInt(value))
	GetClientCookie(client, g_cookie[2], value, 16)
	g_button[client] = view_as<bool>(StringToInt(value))
	GetClientCookie(client, g_cookie[3], value, 16)
	g_pbutton[client] = view_as<bool>(StringToInt(value))
}

public void OnClientDisconnect(int client)
{
	Color(client)
	g_color[client] = false
	int partner = g_partner[client]
	g_partner[g_partner[client]] = 0
	if(partner && g_menuOpened[partner])
		Trikz(partner)
	g_partner[client] = 0
	CancelClientMenu(client)
	int entity
	while((entity = FindEntityByClassname(entity, "weapon_*")) > 0) //https://github.com/shavitush/bhoptimer/blob/de1fa353ff10eb08c9c9239897fdc398d5ac73cc/addons/sourcemod/scripting/shavit-misc.sp#L1104-L1106
		if(GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") == client)
			RemoveEntity(entity)
	if(!g_devmap && partner && !IsFakeClient(client))
	{
		ResetFactory(partner)
		CS_SetClientClanTag(partner, g_clantag[partner][0])
	}
}

void SQLAddUser(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLAddUser: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(!client)
			return
		if(IsClientInGame(client))
		{
			char query[512] //https://forums.alliedmods.net/showthread.php?t=261378
			int steamid = GetSteamAccountID(client)
			if(results.FetchRow())
			{
				Format(query, 512, "SELECT steamid FROM users WHERE steamid = %i LIMIT 1", steamid)
				g_mysql.Query(SQLUpdateUsername, query, GetClientSerial(client), DBPrio_High)
			}
			else
			{
				Format(query, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%N', %i, %i, %i)", client, steamid, GetTime(), GetTime())
				g_mysql.Query(SQLUserAdded, query)
			}
		}
	}
}

void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLUserAdded: %s", error)
}

void SQLUpdateUsername(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLUpdateUsername: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(!client)
			return
		if(IsClientInGame(client))
		{
			char query[512]
			int steamid = GetSteamAccountID(client)
			if(results.FetchRow())
				Format(query, 512, "UPDATE users SET username = '%N', lastjoin = %i WHERE steamid = %i LIMIT 1", client, GetTime(), steamid)
			else
				Format(query, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%N', %i, %i, %i)", client, steamid, GetTime(), GetTime())
			g_mysql.Query(SQLUpdateUsernameSuccess, query, GetClientSerial(client), DBPrio_High)
		}
	}
}

void SQLUpdateUsernameSuccess(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLUpdateUsernameSuccess: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(!client)
			return
		if(IsClientInGame(client))
		{
			if(results.HasResults == false)
			{
				char query[512]
				int steamid = GetSteamAccountID(client)
				Format(query, 512, "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid)
				g_mysql.Query(SQLGetPoints, query, GetClientSerial(client), DBPrio_High)
			}
		}
	}
}

void SQLGetPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetPoints: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(!client)
			return
		if(results.FetchRow())
			g_points[client] = results.FetchInt(0)
	}
}

void SQLGetServerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetServerRecord: %s", error)
	else
	{
		if(results.FetchRow())
			g_ServerRecordTime = results.FetchFloat(0)
		else
			g_ServerRecordTime = 0.0
	}
}

void SQLGetPersonalRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetPersonalRecord: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(results.FetchRow())
			g_haveRecord[client] = results.FetchFloat(0)
		else
			g_haveRecord[client] = 0.0
	}
}

void SDKSkyFix(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(GetClientButtons(other) & IN_DUCK) && g_entityButtons[other] & IN_JUMP && GetEngineTime() - g_boostTime[client] > 0.15 && !g_skyBoost[other])
	{
		float originBooster[3]
		GetClientAbsOrigin(client, originBooster)
		float originFlyer[3]
		GetClientAbsOrigin(other, originFlyer)
		float maxsBooster[3]
		GetClientMaxs(client, maxsBooster) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71
		float delta = originFlyer[2] - originBooster[2] - maxsBooster[2]
		if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		{
			float velBooster[3]
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velBooster)
			if(velBooster[2] > 0.0)
			{
				float velFlyer[3]
				GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", velFlyer)
				g_skyVel[other][0] = velFlyer[0]
				g_skyVel[other][1] = velFlyer[1]				
				velBooster[2] *= 3.0
				g_skyVel[other][2] = velBooster[2]
				if(velFlyer[2] > -700.0)
				{
					if(velBooster[2] > 750.0)
						g_skyVel[other][2] = 750.0
				}
				else
					if(velBooster[2] > 800.0)
						g_skyVel[other][2] = 800.0
				if(g_entityFlags[client] & FL_INWATER ? !g_skyBoost[other] : FloatAbs(g_skyOrigin[client] - g_skyOrigin[other]) > 0.04 || GetGameTime() - g_skyAble[other] > 0.5)
					g_skyBoost[other] = 1
			}
		}
	}
}

void SDKBoostFix(int client)
{
	if(g_boost[client] == 1)
	{
		int entity = EntRefToEntIndex(g_flash[client])
		if(entity != INVALID_ENT_REFERENCE)
		{
			float velEntity[3]
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", velEntity)
			if(velEntity[2] > 0.0)
			{
				velEntity[0] *= 0.135
				velEntity[1] *= 0.135
				velEntity[2] *= -0.135
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, velEntity)
			}
			g_boost[client] = 2
		}
	}
}

Action cmd_trikz(int client, int args)
{
	if(!g_menuOpened[client])
		Trikz(client)
	return Plugin_Handled
}

void Trikz(int client)
{
	g_menuOpened[client] = true
	Menu menu = new Menu(trikz_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel) //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	menu.SetTitle("Trikz")
	menu.AddItem("block", g_block[client] ? "Block [v]" : "Block [x]")
	menu.AddItem("partner", g_partner[client] ? "Breakup" : "Partner", g_devmap ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT)
	if(g_devmap)
		menu.AddItem("color", "Color")
	else
		menu.AddItem("color", "Color", g_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
	menu.AddItem("restart", "Restart", g_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED) //shavit trikz githgub alliedmods net https://forums.alliedmods.net/showthread.php?p=2051806
	if(g_devmap)
	{
		menu.AddItem("checkpoint", "Checkpoint")
		menu.AddItem("noclip", GetEntityMoveType(client) & MOVETYPE_NOCLIP ? "Noclip [v]" : "Noclip [x]")
	}
	menu.Display(client, MENU_TIME_FOREVER)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
			g_menuOpened[param1] = true
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
					Block(param1)
				case 1:
				{
					g_menuOpened[param1] = false
					Partner(param1)
				}
				case 2:
				{
					Color(param1, false, true)
					Trikz(param1)
				}
				case 3:
				{
					Restart(param1)
					Restart(g_partner[param1])
				}
				case 4:
				{
					g_menuOpened[param1] = false
					Checkpoint(param1)
				}
				case 5:
				{
					Noclip(param1)
					Trikz(param1)
				}
			}
		}
		case MenuAction_Cancel:
			g_menuOpened[param1] = false //idea from expert zone.
		case MenuAction_Display:
			g_menuOpened[param1] = true
	}
}

Action cmd_block(int client, int args)
{
	Block(client)
	return Plugin_Handled
}

Action Block(int client) //thanks maru for optimization.
{
	g_block[client] = !g_block[client]
	SetEntProp(client, Prop_Data, "m_CollisionGroup", g_block[client] ? 5 : 2)
	if(g_color[client])
		SetEntityRenderColor(client, g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], g_block[client] ? 255 : 125)
	else
		SetEntityRenderColor(client, 255, 255, 255, g_block[client] ? 255 : 125)
	if(g_menuOpened[client])
		Trikz(client)
	PrintToChat(client, g_block[client] ? "Block enabled." : "Block disabled.")
	return Plugin_Handled
}

Action cmd_partner(int client, int args)
{
	Partner(client)
	return Plugin_Handled
}

void Partner(int client)
{
	if(g_devmap)
		PrintToChat(client, "Turn off devmap.")
	else
	{
		if(!g_partner[client])
		{
			Menu menu = new Menu(partner_handler)
			menu.SetTitle("Choose partner")
			char name[MAX_NAME_LENGTH]
			bool player
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i)) //https://github.com/Figawe2/trikz-plugin/blob/master/scripting/trikz.sp#L635
				{
					if(client != i && !g_partner[i])
					{
						GetClientName(i, name, MAX_NAME_LENGTH)
						char nameID[32]
						IntToString(i, nameID, 32)
						menu.AddItem(nameID, name)
						player = true
					}
				}
			}
			switch(player)
			{
				case false:
					PrintToChat(client, "No free player.")
				case true:
					menu.Display(client, 20)
			}
			
		}
		else
		{
			Menu menu = new Menu(cancelpartner_handler)
			menu.SetTitle("Cancel partnership with %N", g_partner[client])
			char partner[32]
			IntToString(g_partner[client], partner, 32)
			menu.AddItem(partner, "Yes")
			menu.AddItem("", "No")
			menu.Display(client, 20)
		}
	}
}

int partner_handler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32]
			menu.GetItem(param2, item, 32)
			int partner = StringToInt(item)
			Menu menu2 = new Menu(askpartner_handle)
			menu2.SetTitle("Agree partner with %N?", param1)
			char param1Buffer[32]
			IntToString(param1, param1Buffer, 32)
			menu2.AddItem(param1Buffer, "Yes")
			menu2.AddItem(item, "No")
			menu2.Display(partner, 20)
		}
	}
}

int askpartner_handle(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32]
			menu.GetItem(param2, item, 32)
			int partner = StringToInt(item)
			switch(param2)
			{
				case 0:
				{
					if(!g_partner[partner])
					{
						g_partner[param1] = partner
						g_partner[partner] = param1
						PrintToChat(param1, "Partnersheep agreed with %N.", partner) //reciever
						PrintToChat(partner, "You have %N as partner.", param1) //sender
						Restart(param1)
						Restart(partner) //Expert-Zone idea.
						if(g_menuOpened[partner])
							Trikz(partner)
						char query[512]
						Format(query, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", GetSteamAccountID(param1), GetSteamAccountID(partner), GetSteamAccountID(partner), GetSteamAccountID(param1), g_map)
						g_mysql.Query(SQLGetPartnerRecord, query, GetClientSerial(param1))
					}
					else
						PrintToChat(param1, "A player already have a partner.")
				}
				case 1:
					PrintToChat(param1, "Partnersheep declined with %N.", partner)
			}
		}
	}
}

int cancelpartner_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32]
			menu.GetItem(param2, item, 32)
			int partner = StringToInt(item)
			switch(param2)
			{
				case 0:
				{
					Color(param1)
					g_partner[param1] = 0
					g_partner[partner] = 0
					ResetFactory(param1)
					ResetFactory(partner)
					PrintToChat(param1, "Partnership is canceled with %N", partner)
					PrintToChat(partner, "Partnership is canceled by %N", param1)
				}
			}
		}
	}
}

Action cmd_color(int client, int args)
{
	char arg[512]
	GetCmdArgString(arg, 512) //https://www.sourcemod.net/new-api/console/GetCmdArgString
	int color = StringToInt(arg)
	if(StrEqual(arg, "white"))
		color = 0
	else if(StrEqual(arg, "red"))
		color = 1
	else if(StrEqual(arg, "orange"))
		color = 2
	else if(StrEqual(arg, "yellow"))
		color = 3
	else if(StrEqual(arg, "lime"))
		color = 4
	else if(StrEqual(arg, "aqua"))
		color = 5
	else if(StrEqual(arg, "deep sky blue"))
		color = 6
	else if(StrEqual(arg, "blue"))
		color = 7
	else if(StrEqual(arg, "magenta"))
		color = 8
	if(strlen(arg) && 0 <= color <= 8)
		Color(client, false, true, color)
	else if(!color)
		Color(client, false, true)
	return Plugin_Handled
}

void Color(int client, bool onlyFlashbang = false, bool customSkin = false, int color = -1)
{
	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		if(!g_devmap && !g_partner[client])
		{
			PrintToChat(client, "You must have a partner.")
			return
		}
		if(customSkin)
		{
			g_color[client] = true
			g_color[g_partner[client]] = true
			SetEntProp(client, Prop_Data, "m_nModelIndex", g_wModelPlayer[g_class[client]])
			SetEntProp(g_partner[client], Prop_Data, "m_nModelIndex", g_wModelPlayer[g_class[client]])
			DispatchKeyValue(client, "skin", "2")
			DispatchKeyValue(g_partner[client], "skin", "2")
			char g_colorTypeExploded[3][16]
			if(g_colorCount[client] == 9)
			{
				g_colorCount[client] = 0
				g_colorCount[g_partner[client]] = 0
			}
			else if(0 <= color <= 8)
			{
				g_colorCount[client] = color
				g_colorCount[g_partner[client]] = color
			}
			ExplodeString(g_colorType[g_colorCount[client]], ",", g_colorTypeExploded, 3, 16)
			for(int i = 0; i <= 2; i++)
			{
				g_colorBuffer[client][i] = StringToInt(g_colorTypeExploded[i])
				g_colorBuffer[g_partner[client]][i] = StringToInt(g_colorTypeExploded[i])
			}
			if(!onlyFlashbang)
			{
				SetEntityRenderColor(client, g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], g_block[client] ? 255 : 125)
				SetEntityRenderColor(g_partner[client], g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], g_block[g_partner[client]] ? 255 : 125)
			}
			g_colorCount[client]++
			g_colorCount[g_partner[client]]++
		}
		else
		{
			g_color[client] = false
			g_color[g_partner[client]] = false
			g_colorCount[client] = 0
			g_colorCount[g_partner[client]] = 0
			SetEntityRenderColor(client, 255, 255, 255, g_block[client] ? 255 : 125)
			SetEntityRenderColor(g_partner[client], 255, 255, 255, g_block[g_partner[client]] ? 255 : 125)
		}
	}
}

void SQLGetPartnerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLGetPartnerRecord: %s", error)
	else
	{
		int client = GetClientFromSerial(data)
		if(!client)
			return
		if(results.FetchRow())
		{
			g_mateRecord[client] = results.FetchFloat(0)
			g_mateRecord[g_partner[client]] = results.FetchFloat(0)
		}
		else
		{
			g_mateRecord[client] = 0.0
			g_mateRecord[g_partner[client]] = 0.0
		}
	}
}

Action cmd_restart(int client, int args)
{
	Restart(client)
	if(g_partner[client])
		Restart(g_partner[client])
	return Plugin_Handled
}

void Restart(int client)
{
	if(g_devmap)
		PrintToChat(client, "Turn off devmap.")
	else
	{
		if(g_zoneHave[0] && g_zoneHave[1])
		{
			if(g_partner[client])
			{
				if(IsPlayerAlive(client) && IsPlayerAlive(g_partner[client]))
				{
					CreateTimer(0.1, timer_resetfactory, client, TIMER_FLAG_NO_MAPCHANGE)
					Call_StartForward(g_start)
					Call_PushCell(client)
					Call_Finish()
					CS_RespawnPlayer(client)
					float velNull[3]
					TeleportEntity(client, g_originStart, NULL_VECTOR, velNull)
					if(g_menuOpened[client])
						Trikz(client)
				}
				else if(!IsPlayerAlive(client))
				{
					int entity
					bool ct
					bool t
					while((entity = FindEntityByClassname(entity, "info_player_counterterrorist")) > 0)
					{
						ct = true
						break
					}
					while((entity = FindEntityByClassname(entity, "info_player_terrorist")) > 0)
					{
						if(!ct)
							t = true
						break
					}
					if(ct)
					{
						CS_SwitchTeam(client, CS_TEAM_CT) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-misc.sp#L2066
						CS_RespawnPlayer(client)
						if(!IsPlayerAlive(g_partner[client]))
							CS_RespawnPlayer(g_partner[client])
						Restart(client)
						Restart(g_partner[client])
					}
					if(t)
					{
						CS_SwitchTeam(client, CS_TEAM_T)
						CS_RespawnPlayer(client)
						if(!IsPlayerAlive(g_partner[client]))
							CS_RespawnPlayer(g_partner[client])
						Restart(client)
						Restart(g_partner[client])
					}
				}
			}
			else
				PrintToChat(client, "You must have a partner.")
		}
	}
}

Action timer_resetfactory(Handle timer, int client)
{
	if(IsClientInGame(client))
		ResetFactory(client)
}

void CreateStart()
{
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_startzone")
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	g_center[0][0] = (g_zoneStartOrigin[0][0] + g_zoneStartOrigin[1][0]) / 2.0
	g_center[0][1] = (g_zoneStartOrigin[0][1] + g_zoneStartOrigin[1][1]) / 2.0
	g_center[0][2] = (g_zoneStartOrigin[0][2] + g_zoneStartOrigin[1][2]) / 2.0
	TeleportEntity(entity, g_center[0], NULL_VECTOR, NULL_VECTOR) //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	g_originStart[0] = g_center[0][0]
	g_originStart[1] = g_center[0][1]
	g_originStart[2] = g_center[0][2] + 1.0
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_zoneStartOrigin[0][i] - g_zoneStartOrigin[1][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (g_zoneStartOrigin[0][i] - g_zoneStartOrigin[1][i]) / 2.0
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
	g_zoneHave[0] = true
}

void CreateEnd()
{
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_endzone")
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	g_center[1][0] = (g_zoneEndOrigin[0][0] + g_zoneEndOrigin[1][0]) / 2.0
	g_center[1][1] = (g_zoneEndOrigin[0][1] + g_zoneEndOrigin[1][1]) / 2.0
	g_center[1][2] = (g_zoneEndOrigin[0][2] + g_zoneEndOrigin[1][2]) / 2.0
	TeleportEntity(entity, g_center[1], NULL_VECTOR, NULL_VECTOR) //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_zoneEndOrigin[0][i] - g_zoneEndOrigin[1][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (g_zoneEndOrigin[0][i] - g_zoneEndOrigin[1][i]) / 2.0
		if(maxs[i] < 0.0)
			maxs[i] *= -1.0
	}
	maxs[2] = 124.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	PrintToServer("End zone is successfuly setup.")
	CPSetup(0)
	g_zoneHave[1] = true
}

Action cmd_startmins(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent))
	{
		if(g_devmap)
		{
			GetClientAbsOrigin(client, g_zoneStartOrigin[0])
			g_zoneFirst[0] = true
		}
		else
			PrintToChat(client, "Turn on devmap.")
		return Plugin_Handled
	}
	return Plugin_Continue
}

void SQLDeleteStartZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLDeleteStartZone: %s", error)
	else
	{
		char query[512]
		Format(query, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 0, %i, %i, %i, %i, %i, %i)", g_map, RoundFloat(g_zoneStartOrigin[0][0]), RoundFloat(g_zoneStartOrigin[0][1]), RoundFloat(g_zoneStartOrigin[0][2]), RoundFloat(g_zoneStartOrigin[1][0]), RoundFloat(g_zoneStartOrigin[1][1]), RoundFloat(g_zoneStartOrigin[1][2]))
		g_mysql.Query(SQLSetStartZones, query)
	}
}

Action cmd_deleteallcp(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent)) //https://sm.alliedmods.net/new-api/
	{
		if(g_devmap)
		{
			char query[512]
			Format(query, 512, "DELETE FROM cp WHERE map = '%s'", g_map) //https://www.w3schools.com/sql/sql_delete.asp
			g_mysql.Query(SQLDeleteAllCP, query)
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
}

void SQLDeleteAllCP(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLDeleteAllCP: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("All checkpoints are deleted on current map.")
		else
			PrintToServer("No checkpoints to delete on current map.")
	}
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	if(!g_devmap)
	{
		char cmd[64] //https://forums.alliedmods.net/showthread.php?t=270684
		kv.GetSectionName(cmd, 64)
		if(StrEqual(cmd, "ClanTagChanged"))
			CS_GetClientClanTag(client, g_clantag[client][0], 256)
	}
}

Action cmd_test(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent)) //https://sm.alliedmods.net/new-api/
	{
		char text[256]
		char name[MAX_NAME_LENGTH]
		GetClientName(client, name, MAX_NAME_LENGTH)
		int team = GetClientTeam(client)
		char teamName[32]
		char teamColor[32]
		switch(team)
		{
			case 1:
			{
				Format(teamName, 32, "Spectator")
				Format(teamColor, 32, "\x07CCCCCC")
			}
			case 2:
			{
				Format(teamName, 32, "Terrorist")
				Format(teamColor, 32, "\x07FF4040")
			}
			case 3:
			{
				Format(teamName, 32, "Counter-Terrorist")
				Format(teamColor, 32, "\x0799CCFF")
			}
		}
		Format(text, 256, "\x01%T", "Hello", client, "FakeExpert", name, teamName)
		ReplaceString(text, 256, ";#", "\x07")
		ReplaceString(text, 256, "{default}", "\x01")
		ReplaceString(text, 256, "{teamcolor}", teamColor)
		PrintToChat(client, "%s", text)
		char arg[256]
		GetCmdArgString(arg, 256)
		int partner = StringToInt(arg)
		if(partner <= MaxClients && !g_partner[client])
		{
			g_partner[client] = partner
			Call_StartForward(g_start)
			Call_PushCell(client)
			Call_Finish()
			Restart(client)
		}
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				PrintToServer("(%i %N)", i, i)
				PrintToServer("CollisionGroup: %i %N", GetEntProp(i, Prop_Data, "m_CollisionGroup"), i)
				PrintToServer("%i %N", g_partner[i], i)
			}
		}
		PrintToServer("LibraryExists (fakeexpert-entityfilter): %i", LibraryExists("fakeexpert-entityfilter"))
		//https://forums.alliedmods.net/showthread.php?t=187746
		int color
		color |= (5 & 255) << 24 //5 red
		color |= (200 & 255) << 16 // 200 green
		color |= (255 & 255) << 8 // 255 blue
		color |= (50 & 255) << 0 // 50 alpha
		PrintToChat(client, "\x08%08XCOLOR", color)
		char auth64[64]
		GetClientAuthId(client, AuthId_SteamID64, auth64, 64)
		PrintToChat(client, "Your SteamID64 is: %s = 76561197960265728 + %i (SteamID3)", auth64, steamid) //https://forums.alliedmods.net/showthread.php?t=324112 120192594
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action cmd_endmins(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent))
	{
		if(g_devmap)
		{
			GetClientAbsOrigin(client, g_zoneEndOrigin[0])
			g_zoneFirst[1] = true
		}
		else
			PrintToChat(client, "Turn on devmap.")
		return Plugin_Handled
	}
	return Plugin_Continue
}

void SQLDeleteEndZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLDeleteEndZone: %s", error)
	else
	{
		char query[512]
		Format(query, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 1, %i, %i, %i, %i, %i, %i)", g_map, RoundFloat(g_zoneEndOrigin[0][0]), RoundFloat(g_zoneEndOrigin[0][1]), RoundFloat(g_zoneEndOrigin[0][2]), RoundFloat(g_zoneEndOrigin[1][0]), RoundFloat(g_zoneEndOrigin[1][1]), RoundFloat(g_zoneEndOrigin[1][2]))
		g_mysql.Query(SQLSetEndZones, query)
	}
}

Action cmd_maptier(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent))
	{
		if(g_devmap)
		{
			char arg[512]
			GetCmdArgString(arg, 512) //https://www.sourcemod.net/new-api/console/GetCmdArgString
			int tier = StringToInt(arg)
			if(tier > 0)
			{
				PrintToServer("[Args] Tier: %i", tier)
				char query[512]
				Format(query, 512, "DELETE FROM tier WHERE map = '%s' LIMIT 1", g_map)
				g_mysql.Query(SQLTierRemove, query, tier)
			}
		}
		else
			PrintToChat(client, "Turn on devmap.")
		return Plugin_Handled
	}
	return Plugin_Continue
}

void SQLTierRemove(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLTierRemove: %s", error)
	else
	{
		char query[512]
		Format(query, 512, "INSERT INTO tier (tier, map) VALUES (%i, '%s')", data, g_map)
		g_mysql.Query(SQLTierInsert, query, data)
	}
}

void SQLTierInsert(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLTierInsert: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("Tier %i is set for %s.", data, g_map)
	}
}

void SQLSetStartZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLSetStartZones: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("Start zone successfuly created.")
	}
}

void SQLSetEndZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLSetEndZones: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("End zone successfuly created.")
	}
}

Action cmd_startmaxs(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent) && g_zoneFirst[0])
	{
		GetClientAbsOrigin(client, g_zoneStartOrigin[1])
		char query[512]
		Format(query, 512, "DELETE FROM zones WHERE map = '%s' AND type = 0 LIMIT 1", g_map)
		g_mysql.Query(SQLDeleteStartZone, query)
		g_zoneFirst[0] = false
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action cmd_endmaxs(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent) && g_zoneFirst[1])
	{
		GetClientAbsOrigin(client, g_zoneEndOrigin[1])
		char query[512]
		Format(query, 512, "DELETE FROM zones WHERE map = '%s' AND type = 1 LIMIT 1", g_map)
		g_mysql.Query(SQLDeleteEndZone, query)
		g_zoneFirst[1] = false
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action cmd_cpmins(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent))
	{
		if(g_devmap)
		{
			char cmd[512]
			GetCmdArg(args, cmd, 512)
			int cpnum = StringToInt(cmd)
			if(cpnum > 0)
			{
				PrintToChat(client, "CP: No.%i", cpnum)
				GetClientAbsOrigin(client, g_cpPos[0][cpnum])
				g_zoneFirst[2] = true
			}
		}
		else
			PrintToChat(client, "Turn on devmap.")
		return Plugin_Handled
	}
	return Plugin_Continue
}

void SQLCPRemoved(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCPRemoved: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("Checkpoint zone no. %i successfuly deleted.", data)
		char query[512]
		Format(query, 512, "INSERT INTO cp (cpnum, cpx, cpy, cpz, cpx2, cpy2, cpz2, map) VALUES (%i, %i, %i, %i, %i, %i, %i, '%s')", data, RoundFloat(g_cpPos[0][data][0]), RoundFloat(g_cpPos[0][data][1]), RoundFloat(g_cpPos[0][data][2]), RoundFloat(g_cpPos[1][data][0]), RoundFloat(g_cpPos[1][data][1]), RoundFloat(g_cpPos[1][data][2]), g_map)
		g_mysql.Query(SQLCPInserted, query, data)
	}
}

Action cmd_cpmaxs(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent) && g_zoneFirst[2])
	{
		char cmd[512]
		GetCmdArg(args, cmd, 512)
		int cpnum = StringToInt(cmd)
		if(cpnum > 0)
		{
			GetClientAbsOrigin(client, g_cpPos[1][cpnum])
			char query[512]
			Format(query, 512, "DELETE FROM cp WHERE cpnum = %i AND map = '%s'", cpnum, g_map)
			g_mysql.Query(SQLCPRemoved, query, cpnum)
			g_zoneFirst[2] = false
		}
		return Plugin_Handled
	}
	return Plugin_Continue
}

void SQLCPInserted(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCPInserted: %s", error)
	else
	{
		if(results.HasResults == false)
			PrintToServer("Checkpoint zone no. %i successfuly created.", data)
	}
}

Action cmd_zones(int client, int args)
{
	char steamidCurrent[64]
	IntToString(GetSteamAccountID(client), steamidCurrent, 64)
	char steamid[64]
	GetConVarString(g_steamid, steamid, 64)
	if(StrEqual(steamid, steamidCurrent))
	{
		if(g_devmap)
			ZoneEditor(client)
		else
			PrintToChat(client, "Turn on devmap.")
	}
}

void ZoneEditor(int client)
{
	CPSetup(client)
}

void ZoneEditor2(int client)
{
	Menu menu = new Menu(zones_handler)
	menu.SetTitle("Zone editor")
	if(g_zoneHave[0])
		menu.AddItem("start", "Start zone")
	if(g_zoneHave[1])
		menu.AddItem("end", "End zone")
	char format[32]
	if(g_cpCount)
	{
		for(int i = 1; i <= g_cpCount; i++)
		{
			Format(format, 32, "CP nr. %i zone", i)
			char cp[16]
			Format(cp, 16, "%i", i)
			menu.AddItem(cp, format)
		}
	}
	else if(!g_zoneHave[0] && !g_zoneHave[1] && !g_cpCount)
		menu.AddItem("-1", "No zones are setup.", ITEMDRAW_DISABLED)
	menu.Display(client, MENU_TIME_FOREVER)
}

int zones_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16]
			menu.GetItem(param2, item, 16)
			Menu menu2 = new Menu(zones2_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel)
			if(StrEqual(item, "start"))
			{
				menu2.SetTitle("Zone editor - Start zone")
				menu2.AddItem("starttp", "Teleport to start zone")
				menu2.AddItem("start+xmins", "+x/mins")
				menu2.AddItem("start-xmins", "-x/mins")
				menu2.AddItem("start+ymins", "+y/mins")
				menu2.AddItem("start-ymins", "-y/mins")
				menu2.AddItem("start+xmaxs", "+x/maxs")
				menu2.AddItem("start-xmaxs", "-x/maxs")
				menu2.AddItem("start+ymaxs", "+y/maxs")
				menu2.AddItem("start-ymaxs", "-y/maxs")
				menu2.AddItem("startupdate", "Update start zone")
			}
			else if(StrEqual(item, "end"))
			{
				menu2.SetTitle("Zone editor - End zone")
				menu2.AddItem("endtp", "Teleport to end zone")
				menu2.AddItem("end+xmins", "+x/mins")
				menu2.AddItem("end-xmins", "-x/mins")
				menu2.AddItem("end+ymins", "+y/mins")
				menu2.AddItem("end-ymins", "-y/mins")
				menu2.AddItem("end+xmaxs", "+x/maxs")
				menu2.AddItem("end-xmaxs", "-x/maxs")
				menu2.AddItem("end+ymaxs", "+y/maxs")
				menu2.AddItem("end-ymaxs", "-y/maxs")
				menu2.AddItem("endupdate", "Update start zone")
			}
			for(int i = 1; i <= g_cpCount; i++)
			{
				char cp[16]
				IntToString(i, cp, 16)
				Format(cp, 16, "%i", i)
				if(StrEqual(item, cp))
				{
					menu2.SetTitle("Zone editor - CP nr. %i zone", i)
					char sButton[32]
					Format(sButton, 32, "Teleport to CP nr. %i zone", i)
					char itemCP[16]
					Format(itemCP, 16, "%i;tp", i)
					menu2.AddItem(itemCP, sButton)
					Format(itemCP, 16, "%i;1", i)
					menu2.AddItem(itemCP, "+x/mins")
					Format(itemCP, 16, "%i;2", i)
					menu2.AddItem(itemCP, "-x/mins")
					Format(itemCP, 16, "%i;3", i)
					menu2.AddItem(itemCP, "+y/mins")
					Format(itemCP, 16, "%i;4", i)
					menu2.AddItem(itemCP, "-y/mins")
					Format(itemCP, 16, "%i;5", i)
					menu2.AddItem(itemCP, "+x/maxs")
					Format(itemCP, 16, "%i;6", i)
					menu2.AddItem(itemCP, "-x/maxs")
					Format(itemCP, 16, "%i;7", i)
					menu2.AddItem(itemCP, "+y/maxs")
					Format(itemCP, 16, "%i;8", i)
					menu2.AddItem(itemCP, "-y/maxs")
					Format(sButton, 32, "Update CP nr. %i zone", i)
					menu2.AddItem("cpupdate", sButton)
				}
			}
			menu2.ExitBackButton = true //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
			menu2.Display(param1, MENU_TIME_FOREVER)
		}
	}
}

int zones2_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
			g_zoneDraw[param1] = true
		case MenuAction_Select:
		{
			char item[16]
			menu.GetItem(param2, item, 16)
			if(StrEqual(item, "starttp"))
				TeleportEntity(param1, g_center[0], NULL_VECTOR, NULL_VECTOR)
			else if(StrEqual(item, "start+xmins"))
				g_zoneStartOrigin[0][0] += 16.0
			else if(StrEqual(item, "start-xmins"))
				g_zoneStartOrigin[0][0] -= 16.0
			else if(StrEqual(item, "start+ymins"))
				g_zoneStartOrigin[0][1] += 16.0
			else if(StrEqual(item, "start-ymins"))
				g_zoneStartOrigin[0][1] -= 16.0
			else if(StrEqual(item, "start+xmaxs"))
				g_zoneStartOrigin[1][0] += 16.0
			else if(StrEqual(item, "start-xmaxs"))
				g_zoneStartOrigin[1][0] -= 16.0
			else if(StrEqual(item, "start+ymaxs"))
				g_zoneStartOrigin[1][1] += 16.0
			else if(StrEqual(item, "start-ymaxs"))
				g_zoneStartOrigin[1][1] -= 16.0
			else if(StrEqual(item, "endtp"))
				TeleportEntity(param1, g_center[1], NULL_VECTOR, NULL_VECTOR)
			else if(StrEqual(item, "end+xmins"))
				g_zoneEndOrigin[0][0] += 16.0
			else if(StrEqual(item, "end-xmins"))
				g_zoneEndOrigin[0][0] -= 16.0
			else if(StrEqual(item, "end+ymins"))
				g_zoneEndOrigin[0][1] += 16.0
			else if(StrEqual(item, "end-ymins"))
				g_zoneEndOrigin[0][1] -= 16.0
			else if(StrEqual(item, "end+xmaxs"))
				g_zoneEndOrigin[1][0] += 16.0
			else if(StrEqual(item, "end-xmaxs"))
				g_zoneEndOrigin[1][0] -= 16.0
			else if(StrEqual(item, "end+ymaxs"))
				g_zoneEndOrigin[1][1] += 16.0
			else if(StrEqual(item, "end-ymaxs"))
				g_zoneEndOrigin[1][1] -= 16.0
			char exploded[16][16]
			ExplodeString(item, ";", exploded, 16, 16)
			int cpnum = StringToInt(exploded[0])
			char cpFormated[16]
			Format(cpFormated, 16, "%i;tp", cpnum)
			if(StrEqual(item, cpFormated))
				TeleportEntity(param1, g_center[cpnum + 1], NULL_VECTOR, NULL_VECTOR)
			Format(cpFormated, 16, "%i;1", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[0][cpnum][0] += 16.0
			Format(cpFormated, 16, "%i;2", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[0][cpnum][0] -= 16.0
			Format(cpFormated, 16, "%i;3", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[0][cpnum][1] += 16.0
			Format(cpFormated, 16, "%i;4", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[0][cpnum][1] -= 16.0
			Format(cpFormated, 16, "%i;5", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[1][cpnum][0] += 16.0
			Format(cpFormated, 16, "%i;6", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[1][cpnum][0] -= 16.0
			Format(cpFormated, 16, "%i;7", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[1][cpnum][1] += 16.0
			Format(cpFormated, 16, "%i;8", cpnum)
			if(StrEqual(item, cpFormated))
				g_cpPos[1][cpnum][1] -= 16.0
			char query[512]
			if(StrEqual(item, "startupdate"))
			{
				Format(query, 512, "UPDATE zones SET possition_x = %i, possition_y = %i, possition_z = %i, possition_x2 = %i, possition_y2 = %i, possition_z2 = %i WHERE type = 0 AND map = '%s'", RoundFloat(g_zoneStartOrigin[0][0]), RoundFloat(g_zoneStartOrigin[0][1]), RoundFloat(g_zoneStartOrigin[0][2]), RoundFloat(g_zoneStartOrigin[1][0]), RoundFloat(g_zoneStartOrigin[1][1]), RoundFloat(g_zoneStartOrigin[1][2]), g_map)
				g_mysql.Query(SQLUpdateZone, query, 0)
			}
			else if(StrEqual(item, "endupdate"))
			{
				Format(query, 512, "UPDATE zones SET possition_x = %i, possition_y = %i, possition_z = %i, possition_x2 = %i, possition_y2 = %i, possition_z2 = %i WHERE type = 1 AND map = '%s'", RoundFloat(g_zoneEndOrigin[0][0]), RoundFloat(g_zoneEndOrigin[0][1]), RoundFloat(g_zoneEndOrigin[0][2]), RoundFloat(g_zoneEndOrigin[1][0]), RoundFloat(g_zoneEndOrigin[1][1]), RoundFloat(g_zoneEndOrigin[1][2]), g_map)
				g_mysql.Query(SQLUpdateZone, query, 1)
			}
			else if(StrEqual(item, "cpupdate"))
			{
				Format(query, 512, "UPDATE cp SET cpx = %i, cpy = %i, cpz = %i, cpx2 = %i, cpy2 = %i, cpz2 = %i WHERE cpnum = %i AND map = '%s'", RoundFloat(g_cpPos[0][cpnum][0]), RoundFloat(g_cpPos[0][cpnum][1]), RoundFloat(g_cpPos[0][cpnum][2]), RoundFloat(g_cpPos[1][cpnum][0]), RoundFloat(g_cpPos[1][cpnum][1]), RoundFloat(g_cpPos[1][cpnum][2]), cpnum, g_map)
				g_mysql.Query(SQLUpdateZone, query, cpnum + 1)
			}
			menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER) //https://forums.alliedmods.net/showthread.php?p=2091775
		}
		case MenuAction_Cancel: // trikz redux menuaction end
		{
			g_zoneDraw[param1] = false //idea from expert zone.
			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
					ZoneEditor(param1)
			}
		}
		case MenuAction_Display:
			g_zoneDraw[param1] = true
	}
}

void SQLUpdateZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLUpdateZone: %s", error)
	else
	{
		if(results.HasResults == false)
		{
			if(data == 1)
				PrintToServer("End zone successfuly updated.")
			else if(!data)
				PrintToServer("Start zone successfuly updated.")
			else if(data > 1)
				PrintToServer("CP zone nr. %i successfuly updated.", data - 1)
		}
	}
}

//https://forums.alliedmods.net/showthread.php?t=261378

Action cmd_createcp(int args)
{
	g_mysql.Query(SQLCreateCPTable, "CREATE TABLE IF NOT EXISTS cp (id INT AUTO_INCREMENT, cpnum INT, cpx INT, cpy INT, cpz INT, cpx2 INT, cpy2 INT, cpz2 INT, map VARCHAR(192), PRIMARY KEY(id))")
}

void SQLCreateCPTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCreateCPTable: %s", error)
	else
	{
		PrintToServer("CP table successfuly created.")
	}
}

Action cmd_createtier(int args)
{
	g_mysql.Query(SQLCreateTierTable, "CREATE TABLE IF NOT EXISTS tier (id INT AUTO_INCREMENT, tier INT, map VARCHAR(192), PRIMARY KEY(id))")
}

void SQLCreateTierTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCreateTierTable: %s", error)
	else
	{
		PrintToServer("Tier table successfuly created.")
	}
}

void CPSetup(int client)
{
	g_cpCount = 0
	char query[512]
	for(int i = 1; i <= 10; i++)
	{
		Format(query, 512, "SELECT cpx, cpy, cpz, cpx2, cpy2, cpz2 FROM cp WHERE cpnum = %i AND map = '%s' LIMIT 1", i, g_map)
		DataPack dp = new DataPack()
		dp.WriteCell(client ? GetClientSerial(client) : 0)
		dp.WriteCell(i)
		g_mysql.Query(SQLCPSetup, query, dp)
	}
}

void SQLCPSetup(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	if(strlen(error))
		PrintToServer("SQLCPSetup: %s", error)
	else
	{
		dp.Reset()
		int client = GetClientFromSerial(dp.ReadCell())
		int cp = dp.ReadCell()
		if(results.FetchRow())
		{
			g_cpPos[0][cp][0] = results.FetchFloat(0)
			g_cpPos[0][cp][1] = results.FetchFloat(1)
			g_cpPos[0][cp][2] = results.FetchFloat(2)
			g_cpPos[1][cp][0] = results.FetchFloat(3)
			g_cpPos[1][cp][1] = results.FetchFloat(4)
			g_cpPos[1][cp][2] = results.FetchFloat(5)
			if(!g_devmap)
				createcp(cp)
			g_cpCount++
		}
		if(cp == 10)
		{
			if(client)
				ZoneEditor2(client)
			if(!g_zoneHave[2])
				g_zoneHave[2] = true
			if(!g_devmap)
				for(int i = 1; i <= MaxClients; i++)
					if(IsClientInGame(i))
						OnClientPutInServer(i)
		}
	}
}

void createcp(int cpnum)
{
	char trigger[64]
	Format(trigger, 64, "fakeexpert_cp%i", cpnum)
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", trigger)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	g_center[cpnum + 1][0] = (g_cpPos[1][cpnum][0] + g_cpPos[0][cpnum][0]) / 2.0
	g_center[cpnum + 1][1] = (g_cpPos[1][cpnum][1] + g_cpPos[0][cpnum][1]) / 2.0
	g_center[cpnum + 1][2] = (g_cpPos[1][cpnum][2] + g_cpPos[0][cpnum][2]) / 2.0
	TeleportEntity(entity, g_center[cpnum + 1], NULL_VECTOR, NULL_VECTOR) //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	float mins[3]
	float maxs[3]
	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_cpPos[0][cpnum][i] - g_cpPos[1][cpnum][i]) / 2.0
		if(mins[i] > 0.0)
			mins[i] *= -1.0
		maxs[i] = (g_cpPos[0][cpnum][i] - g_cpPos[1][cpnum][i]) / 2.0
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
	g_mysql.Query(SQLCreateUserTable, "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT, username VARCHAR(64), steamid INT, firstjoin INT, lastjoin INT, points INT, PRIMARY KEY(id))")
}

void SQLCreateUserTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCreateUserTable: %s", error)
	else
	{
		PrintToServer("Successfuly created user table.")
	}
}

Action cmd_createrecords(int args)
{
	g_mysql.Query(SQLRecordsTable, "CREATE TABLE IF NOT EXISTS records (id INT AUTO_INCREMENT, playerid INT, partnerid INT, time FLOAT, finishes INT, tries INT, cp1 FLOAT, cp2 FLOAT, cp3 FLOAT, cp4 FLOAT, cp5 FLOAT, cp6 FLOAT, cp7 FLOAT, cp8 FLOAT, cp9 FLOAT, cp10 FLOAT, points INT, map VARCHAR(192), date INT, PRIMARY KEY(id))")
}

void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLRecordsTable: %s", error)
	else
	{
		PrintToServer("Successfuly created records table.")
	}
}

Action SDKEndTouch(int entity, int other)
{
	if(0 < other <= MaxClients && g_readyToStart[other] && g_partner[other] && !IsFakeClient(other))
	{
		g_state[other] = true
		g_state[g_partner[other]] = true
		g_mapFinished[other] = false
		g_mapFinished[g_partner[other]] = false
		g_timerTimeStart[other] = GetEngineTime()
		g_timerTimeStart[g_partner[other]] = GetEngineTime()
		g_readyToStart[other] = false
		g_readyToStart[g_partner[other]] = false
		//g_clantagTimer[other] = CreateTimer(0.1, timer_clantag, other, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
		//g_clantagTimer[g_partner[other]] = CreateTimer(0.1, timer_clantag, g_partner[other], TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
		CreateTimer(0.1, timer_clantag, other, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
		CreateTimer(0.1, timer_clantag, g_partner[other], TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
		for(int i = 1; i <= g_cpCount; i++)
		{
			g_cp[i][other] = false
			g_cp[i][g_partner[other]] = false
			g_cpLock[i][other] = false
			g_cpLock[i][g_partner[other]] = false
		}
	}
}

Action SDKStartTouch(int entity, int other)
{
	if(0 < other <= MaxClients && !g_devmap && !IsFakeClient(other))
	{
		char trigger[32]
		GetEntPropString(entity, Prop_Data, "m_iName", trigger, 32)
		if(StrEqual(trigger, "fakeexpert_startzone") && g_mapFinished[g_partner[other]])
		{
			Restart(other) //expert zone idea.
			Restart(g_partner[other])
		}
		if(StrEqual(trigger, "fakeexpert_endzone"))
		{
			g_mapFinished[other] = true
			if(g_mapFinished[g_partner[other]] && g_state[other])
			{
				char query[512]
				int playerid = GetSteamAccountID(other)
				int partnerid = GetSteamAccountID(g_partner[other])
				int personalHour = (RoundToFloor(g_timerTime[other]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
				int personalMinute = (RoundToFloor(g_timerTime[other]) / 60) % 60
				int personalSecond = RoundToFloor(g_timerTime[other]) % 60
				if(g_ServerRecordTime)
				{
					if(g_mateRecord[other])
					{
						if(g_ServerRecordTime > g_timerTime[other])
						{
							float timeDiff = g_ServerRecordTime - g_timerTime[other]
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("\x077CFC00New server record!")
							PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x077CFC00-%02.i:%02.i:%02.i\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(other, false, true, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(g_partner[other], false, true, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(query, 512, "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' ORDER BY time LIMIT 1", g_timerTime[other], g_cpTimeClient[1][other], g_cpTimeClient[2][other], g_cpTimeClient[3][other], g_cpTimeClient[4][other], g_cpTimeClient[5][other], g_cpTimeClient[6][other], g_cpTimeClient[7][other], g_cpTimeClient[8][other], g_cpTimeClient[9][other], g_cpTimeClient[10][other], GetTime(), playerid, partnerid, partnerid, playerid, g_map)
							g_mysql.Query(SQLUpdateRecord, query)
							g_haveRecord[other] = g_timerTime[other]
							g_haveRecord[g_partner[other]] = g_timerTime[other]
							g_mateRecord[other] = g_timerTime[other]
							g_mateRecord[g_partner[other]] = g_timerTime[other]
							g_ServerRecord = true
							g_ServerRecordTime = g_timerTime[other]
							CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE)
							Call_StartForward(g_record)
							Call_PushCell(other)
							Call_PushFloat(g_timerTime[other])
							Call_Finish()
						}
						else if(g_ServerRecordTime < g_timerTime[other] > g_mateRecord[other])
						{
							float timeDiff = g_timerTime[other] - g_ServerRecordTime
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x07FF0000+%02.i:%02.i:%02.i\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(other, false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(g_partner[other], false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(query, 512, "UPDATE records SET finishes = finishes + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map)
							g_mysql.Query(SQLUpdateRecord, query)
						}
						else if(g_ServerRecordTime < g_timerTime[other] < g_mateRecord[other])
						{
							float timeDiff = g_timerTime[other] - g_ServerRecordTime
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x07FF0000+%02.i:%02.i:%02.i\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(other, false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(g_partner[other], false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(query, 512, "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTimeClient[1][other], g_cpTimeClient[2][other], g_cpTimeClient[3][other], g_cpTimeClient[4][other], g_cpTimeClient[5][other], g_cpTimeClient[6][other], g_cpTimeClient[7][other], g_cpTimeClient[8][other], g_cpTimeClient[9][other], g_cpTimeClient[10][other], GetTime(), playerid, partnerid, partnerid, playerid, g_map)
							g_mysql.Query(SQLUpdateRecord, query)
							if(g_haveRecord[other] > g_timerTime[other])
								g_haveRecord[other] = g_timerTime[other]
							if(g_haveRecord[g_partner[other]] > g_timerTime[other])
								g_haveRecord[g_partner[other]] = g_timerTime[other]
							if(g_mateRecord[other] > g_timerTime[other])
							{
								g_mateRecord[other] = g_timerTime[other]
								g_mateRecord[g_partner[other]] = g_timerTime[other]
							}					
						}
					}
					else
					{
						if(g_ServerRecordTime > g_timerTime[other])
						{
							float timeDiff = g_ServerRecordTime - g_timerTime[other]
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("\x077CFC00New server record!")
							PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x077CFC00-%02.i:%02.i:%02.i\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(other, false, true, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(g_partner[other], false, true, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(query, 512, "INSERT INTO records (playerid, partnerid, time, finishes, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, g_timerTime[other], g_cpTimeClient[1][other], g_cpTimeClient[2][other], g_cpTimeClient[3][other], g_cpTimeClient[4][other], g_cpTimeClient[5][other], g_cpTimeClient[6][other], g_cpTimeClient[7][other], g_cpTimeClient[8][other], g_cpTimeClient[9][other], g_cpTimeClient[10][other], g_map, GetTime())
							g_mysql.Query(SQLInsertRecord, query)
							g_haveRecord[other] = g_timerTime[other]
							g_haveRecord[g_partner[other]] = g_timerTime[other]
							g_mateRecord[other] = g_timerTime[other]
							g_mateRecord[g_partner[other]] = g_timerTime[other]
							g_ServerRecord = true
							g_ServerRecordTime = g_timerTime[other]
							CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE)
							Call_StartForward(g_record)
							Call_PushCell(other)
							Call_PushFloat(g_timerTime[other])
							Call_Finish()
						}
						else
						{
							float timeDiff = g_timerTime[other] - g_ServerRecordTime
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x07FF0000+%02.i:%02.i:%02.i\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(other, false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							FinishMSG(g_partner[other], false, false, false, false, false, 0, personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(query, 512, "INSERT INTO records (playerid, partnerid, time, finishes, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, g_timerTime[other], g_cpTimeClient[1][other], g_cpTimeClient[2][other], g_cpTimeClient[3][other], g_cpTimeClient[4][other], g_cpTimeClient[5][other], g_cpTimeClient[6][other], g_cpTimeClient[7][other], g_cpTimeClient[8][other], g_cpTimeClient[9][other], g_cpTimeClient[10][other], g_map, GetTime())
							g_mysql.Query(SQLInsertRecord, query)
							if(!g_haveRecord[other])
								g_haveRecord[other] = g_timerTime[other]
							if(!g_haveRecord[g_partner[other]])
								g_haveRecord[g_partner[other]] = g_timerTime[other]
							g_mateRecord[other] = g_timerTime[other]
							g_mateRecord[g_partner[other]] = g_timerTime[other]
						}
					}
					for(int i = 1; i <= g_cpCount; i++)
					{
						if(g_cp[i][other])
						{
							int srCPHour = (RoundToFloor(gF_cpDiff[i][other]) / 3600) % 24
							int srCPMinute = (RoundToFloor(gF_cpDiff[i][other]) / 60) % 60
							int srCPSecond = RoundToFloor(gF_cpDiff[i][other]) % 60
							if(g_cpTimeClient[i][other] < g_cpTime[i])
								PrintToChatAll("\x01%i. Checkpoint: \x077CFC00-%02.i:%02.i:%02.i", i, srCPHour, srCPMinute, srCPSecond)
							else
								PrintToChatAll("\x01%i. Checkpoint: \x07FF0000+%02.i:%02.i:%02.i", i, srCPHour, srCPMinute, srCPSecond)
						}
					}
				}
				else
				{
					g_ServerRecordTime = g_timerTime[other]
					g_haveRecord[other] = g_timerTime[other]
					g_haveRecord[g_partner[other]] = g_timerTime[other]
					g_mateRecord[other] = g_timerTime[other]
					g_mateRecord[g_partner[other]] = g_timerTime[other]
					PrintToChatAll("\x077CFC00New server record!")
					PrintToChatAll("\x01%N and %N finished map in \x077CFC00%02.i:%02.i:%02.i \x01(SR \x07FF0000+00:00:00\x01)", other, g_partner[other], personalHour, personalMinute, personalSecond)
					FinishMSG(other, true, false, false, false, false, 0, personalHour, personalMinute, personalSecond)
					FinishMSG(g_partner[other], true, false, false, false, false, 0, personalHour, personalMinute, personalSecond)
					for(int i = 1; i <= g_cpCount; i++)
						if(g_cp[i][other])
							PrintToChatAll("\x01%i. Checkpoint: \x07FF0000+00:00:00", i)
					g_ServerRecord = true
					CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE) //https://forums.alliedmods.net/showthread.php?t=191615
					Format(query, 512, "INSERT INTO records (playerid, partnerid, time, finishes, tries, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, g_timerTime[other], g_cpTimeClient[1][other], g_cpTimeClient[2][other], g_cpTimeClient[3][other], g_cpTimeClient[4][other], g_cpTimeClient[5][other], g_cpTimeClient[6][other], g_cpTimeClient[7][other], g_cpTimeClient[8][other], g_cpTimeClient[9][other], g_cpTimeClient[10][other], g_map, GetTime())
					g_mysql.Query(SQLInsertRecord, query)
					Call_StartForward(g_record)
					Call_PushCell(other)
					Call_PushFloat(g_timerTime[other])
					Call_Finish()
				}
				g_state[other] = false
				g_state[g_partner[other]] = false
			}
		}
		for(int i = 1; i <= g_cpCount; i++)
		{
			char triggerCP[64]
			Format(triggerCP, 64, "fakeexpert_cp%i", i)
			if(StrEqual(trigger, triggerCP))
			{
				g_cp[i][other] = true
				if(g_cp[i][other] && g_cp[i][g_partner[other]] && !g_cpLock[i][other])
				{
					char query[512] //https://stackoverflow.com/questions/9617453 https://www.w3schools.com/sql/sql_ref_order_by.asp#:~:text=%20SQL%20ORDER%20BY%20Keyword%20%201%20ORDER,data%20returned%20in%20descending%20order.%20%20More%20
					int playerid = GetSteamAccountID(other)
					int partnerid = GetSteamAccountID(g_partner[other])
					if(!g_cpLock[1][other] && g_mateRecord[other])
					{
						Format(query, 512, "UPDATE records SET tries = tries + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map)
						g_mysql.Query(SQLSetTries, query)
					}
					g_cpLock[i][other] = true
					g_cpLock[i][g_partner[other]] = true
					g_cpTimeClient[i][other] = g_timerTime[other]
					g_cpTimeClient[i][g_partner[other]] = g_timerTime[other]
					Format(query, 512, "SELECT cp%i FROM records LIMIT 1", i)
					DataPack dp = new DataPack()
					dp.WriteCell(GetClientSerial(other))
					dp.WriteCell(i)
					g_mysql.Query(SQLCPSelect, query, dp)
				}
			}
		}
	}
}

void FinishMSG(int client, bool firstServerRecord, bool serverRecord, bool onlyCP, bool firstCPRecord, bool cpRecord, int cpnum, int personalHour, int personalMinute, personalSecond, int srHour = 0, int srMinute = 0, int srSecond = 0)
{
	if(onlyCP)
	{
		if(firstCPRecord)
		{
			SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255) //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			ShowHudText(client, 1, "%i. CHECKPOINT RECORD!", cpnum) //https://sm.alliedmods.net/new-api/halflife/ShowHudText
			SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
			ShowHudText(client, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
			SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
			ShowHudText(client, 3, "+00:00:00")
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientObserver(i))
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
					if(observerMode < 7 && observerTarget == client)
					{
						SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
						ShowHudText(i, 1, "%i. CHECKPOINT RECORD!", cpnum)
						SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
						ShowHudText(i, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
						SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
						ShowHudText(i, 3, "+00:00:00")
					}
				}
			}
		}
		else
		{
			if(cpRecord)
			{
				SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
				ShowHudText(client, 1, "%i. CHECKPOINT RECORD!", cpnum) //https://steamuserimages-a.akamaihd.net/ugc/1788470716362427548/185302157B3F4CBF4557D0C47842C6BBD705380A/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false
				SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
				ShowHudText(client, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
				SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255)
				ShowHudText(client, 3, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && IsClientObserver(i))
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
						if(observerMode < 7 && observerTarget == client)
						{
							SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
							ShowHudText(i, 1, "%i. CHECKPOINT RECORD!", cpnum)
							SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
							ShowHudText(i, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
							SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255)
							ShowHudText(i, 3, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
						}
					}
				}
			}
			else
			{
				SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
				ShowHudText(client, 1, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond) //https://steamuserimages-a.akamaihd.net/ugc/1788470716362384940/4DD466582BD1CF04366BBE6D383DD55A079936DC/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false
				SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
				ShowHudText(client, 2, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && IsClientObserver(i))
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
						if(observerMode < 7 && observerTarget == client)
						{
							SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
							ShowHudText(i, 1, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
							SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
							ShowHudText(i, 2, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
						}
					}
				}
			}
		}
	}
	else
	{
		if(firstServerRecord)
		{
			SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255) //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			ShowHudText(client, 1, "MAP FINISHED!") //https://sm.alliedmods.net/new-api/halflife/ShowHudText
			SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
			ShowHudText(client, 2, "NEW SERVER RECORD!")
			SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
			ShowHudText(client, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
			SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
			ShowHudText(client, 4, "+00:00:00")
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientObserver(i))
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
					if(IsClientSourceTV(i) || (observerMode < 7 && observerTarget == client))
					{
						SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255)
						ShowHudText(i, 1, "MAP FINISHED!")
						SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
						ShowHudText(i, 2, "NEW SERVER RECORD!")
						SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
						ShowHudText(i, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
						SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
						ShowHudText(i, 4, "+00:00:00")
					}
				}
			}
		}
		else
		{
			if(serverRecord)
			{
				SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255)
				ShowHudText(client, 1, "MAP FINISHED!")
				SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
				ShowHudText(client, 2, "NEW SERVER RECORD!")
				SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
				ShowHudText(client, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
				SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255)
				ShowHudText(client, 4, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond) //https://youtu.be/j4L3YvHowv8?t=45
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && IsClientObserver(i))
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
						if(IsClientSourceTV(i) || (observerMode < 7 && observerTarget == client))
						{
							SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255)
							ShowHudText(i, 1, "MAP FINISHED!")
							SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255)
							ShowHudText(i, 2, "NEW SERVER RECORD!")
							SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
							ShowHudText(i, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
							SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255)
							ShowHudText(i, 4, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
						}
					}
				}
			}
			else
			{
				SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255)
				ShowHudText(client, 1, "MAP FINISHED!")
				SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
				ShowHudText(client, 2, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
				SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
				ShowHudText(client, 3, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && IsClientObserver(i))
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
						if(observerMode < 7 && observerTarget == client)
						{
							SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255)
							ShowHudText(i, 1, "MAP FINISHED!")
							SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255)
							ShowHudText(i, 2, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond)
							SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255)
							ShowHudText(i, 3, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond)
						}
					}
				}
			}
		}
	}
}

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	if(strlen(error))
		PrintToServer("SQLUpdateRecord: %s", error)
}

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLInsertRecord: %s", error)
}

Action timer_sourcetv(Handle timer)
{
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool sourcetv = CV_sourcetv.BoolValue //https://sm.alliedmods.net/new-api/convars/__raw
	if(sourcetv)
	{
		ServerCommand("tv_stoprecord")
		g_sourcetvchangedFileName = false
		CreateTimer(5.0, timer_runsourcetv, _, TIMER_FLAG_NO_MAPCHANGE)
		g_ServerRecord = false
	}
}

Action timer_runsourcetv(Handle timer)
{
	char filenameOld[256]
	Format(filenameOld, 256, "%s-%s-%s.dem", g_date, g_time, g_map)
	char filenameNew[256]
	Format(filenameNew, 256, "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map)
	RenameFile(filenameNew, filenameOld)
	ConVar CV_sourcetv = FindConVar("tv_enable")
	bool sourcetv = CV_sourcetv.BoolValue //https://sm.alliedmods.net/new-api/convars/__raw
	if(sourcetv)
	{
		PrintToServer("sourcetv start recording.")
		FormatTime(g_date, 64, "%Y-%m-%d", GetTime())
		FormatTime(g_time, 64, "%H-%M-%S", GetTime())
		ServerCommand("tv_record %s-%s-%s", g_date, g_time, g_map)
		g_sourcetvchangedFileName = true
	}
}

void SQLCPSelect(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error))
		PrintToServer("SQLCPSelect: %s", error)
	else
	{
		data.Reset()
		int other = GetClientFromSerial(data.ReadCell())
		int cpnum = data.ReadCell()
		char query[512]
		if(results.FetchRow())
		{
			Format(query, 512, "SELECT cp%i FROM records WHERE map = '%s' ORDER BY time LIMIT 1", cpnum, g_map) //log help me alot with this stuff
			DataPack dp = new DataPack()
			dp.WriteCell(GetClientSerial(other))
			dp.WriteCell(cpnum)
			g_mysql.Query(SQLCPSelect2, query, dp)
		}
		else
		{
			int personalHour = (RoundToFloor(g_timerTime[other]) / 3600) % 24
			int personalMinute = (RoundToFloor(g_timerTime[other]) / 60) % 60
			int personalSecond = RoundToFloor(g_timerTime[other]) % 60
			FinishMSG(other, false, false, true, true, false, cpnum, personalHour, personalMinute, personalSecond)
			FinishMSG(g_partner[other], false, false, true, true, false, cpnum, personalHour, personalMinute, personalSecond)
		}
	}
}

void SQLCPSelect2(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error))
		PrintToServer("SQLCPSelect2: %s", error)
	else
	{
		data.Reset()
		int other = GetClientFromSerial(data.ReadCell())
		int cpnum = data.ReadCell()
		int personalHour = (RoundToFloor(g_timerTime[other]) / 3600) % 24
		int personalMinute = (RoundToFloor(g_timerTime[other]) / 60) % 60
		int personalSecond = RoundToFloor(g_timerTime[other]) % 60
		if(results.FetchRow())
		{
			g_cpTime[cpnum] = results.FetchFloat(0)
			if(g_cpTimeClient[cpnum][other] < g_cpTime[cpnum])
			{
				gF_cpDiff[cpnum][other] = g_cpTime[cpnum] - g_cpTimeClient[cpnum][other]
				gF_cpDiff[cpnum][g_partner[other]] = g_cpTime[cpnum] - g_cpTimeClient[cpnum][other]
				int srCPHour = (RoundToFloor(gF_cpDiff[cpnum][other]) / 3600) % 24
				int srCPMinute = (RoundToFloor(gF_cpDiff[cpnum][other]) / 60) % 60
				int srCPSecond = RoundToFloor(gF_cpDiff[cpnum][other]) % 60
				FinishMSG(other, false, false, true, false, true, cpnum, personalHour, personalMinute, personalSecond, srCPHour, srCPMinute, srCPSecond)
				FinishMSG(g_partner[other], false, false, true, false, true, cpnum, personalHour, personalMinute, personalSecond, srCPHour, srCPMinute, srCPSecond)
			}
			else
			{
				gF_cpDiff[cpnum][other] = g_cpTimeClient[cpnum][other] - g_cpTime[cpnum]
				gF_cpDiff[cpnum][g_partner[other]] = g_cpTimeClient[cpnum][other] - g_cpTime[cpnum]
				int srCPHour = (RoundToFloor(gF_cpDiff[cpnum][other]) / 3600) % 24
				int srCPMinute = (RoundToFloor(gF_cpDiff[cpnum][other]) / 60) % 60
				int srCPSecond = RoundToFloor(gF_cpDiff[cpnum][other]) % 60
				FinishMSG(other, false, false, true, false, false, cpnum, personalHour, personalMinute, personalSecond, srCPHour, srCPMinute, srCPSecond)
				FinishMSG(g_partner[other], false, false, true, false, false, cpnum, personalHour, personalMinute, personalSecond, srCPHour, srCPMinute, srCPSecond)
			}
		}
		else
		{
			FinishMSG(other, false, false, true, true, false, cpnum, personalHour, personalMinute, personalSecond)
			FinishMSG(g_partner[other], false, false, true, true, false, cpnum, personalHour, personalMinute, personalSecond)
		}
	}
}

void SQLSetTries(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLSetTries: %s", error)
}

Action cmd_createzones(int args)
{
	g_mysql.Query(SQLCreateZonesTable, "CREATE TABLE IF NOT EXISTS zones (id INT AUTO_INCREMENT, map VARCHAR(128), type INT, possition_x INT, possition_y INT, possition_z INT, possition_x2 INT, possition_y2 INT, possition_z2 INT, PRIMARY KEY (id))") //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(db)
	{
		PrintToServer("Successfuly connected to database.") //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/
		g_mysql = db
		g_mysql.SetCharset("utf8") //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-core.sp#L2883
		ForceZonesSetup() //https://sm.alliedmods.net/new-api/dbi/__raw
		g_dbPassed = true //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-stats.sp#L199
		char query[512]
		Format(query, 512, "SELECT time FROM records WHERE map = '%s' ORDER BY time LIMIT 1", g_map)
		g_mysql.Query(SQLGetServerRecord, query)
		RecalculatePoints()
	}
	else
		PrintToServer("Failed to connect to database. (%s)", error)
}

void ForceZonesSetup()
{
	char query[512]
	Format(query, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0 LIMIT 1", g_map)
	g_mysql.Query(SQLSetZoneStart, query)
}

void SQLSetZoneStart(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLSetZoneStart: %s", error)
	else
	{
		if(results.FetchRow())
		{
			g_zoneStartOrigin[0][0] = results.FetchFloat(0)
			g_zoneStartOrigin[0][1] = results.FetchFloat(1)
			g_zoneStartOrigin[0][2] = results.FetchFloat(2)
			g_zoneStartOrigin[1][0] = results.FetchFloat(3)
			g_zoneStartOrigin[1][1] = results.FetchFloat(4)
			g_zoneStartOrigin[1][2] = results.FetchFloat(5)
			CreateStart()
			char query[512]
			Format(query, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1 LIMIT 1", g_map)
			g_mysql.Query(SQLSetZoneEnd, query)
		}
	}
}

void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLSetZoneEnd: %s", error)
	else
	{
		if(results.FetchRow())
		{
			g_zoneEndOrigin[0][0] = results.FetchFloat(0)
			g_zoneEndOrigin[0][1] = results.FetchFloat(1)
			g_zoneEndOrigin[0][2] = results.FetchFloat(2)
			g_zoneEndOrigin[1][0] = results.FetchFloat(3)
			g_zoneEndOrigin[1][1] = results.FetchFloat(4)
			g_zoneEndOrigin[1][2] = results.FetchFloat(5)
			CreateEnd()
		}
	}
}

void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error))
		PrintToServer("SQLCreateZonesTable: %s", error)
	else
	{
		PrintToServer("Zones table is successfuly created.")
	}
}

void DrawZone(int client, float life)
{
	float start[12][3]
	float end[12][3]
	start[0][0] = (g_zoneStartOrigin[0][0] < g_zoneStartOrigin[1][0]) ? g_zoneStartOrigin[0][0] : g_zoneStartOrigin[1][0]
	start[0][1] = (g_zoneStartOrigin[0][1] < g_zoneStartOrigin[1][1]) ? g_zoneStartOrigin[0][1] : g_zoneStartOrigin[1][1]
	start[0][2] = (g_zoneStartOrigin[0][2] < g_zoneStartOrigin[1][2]) ? g_zoneStartOrigin[0][2] : g_zoneStartOrigin[1][2]
	start[0][2] += 3.0
	end[0][0] = (g_zoneStartOrigin[0][0] > g_zoneStartOrigin[1][0]) ? g_zoneStartOrigin[0][0] : g_zoneStartOrigin[1][0]
	end[0][1] = (g_zoneStartOrigin[0][1] > g_zoneStartOrigin[1][1]) ? g_zoneStartOrigin[0][1] : g_zoneStartOrigin[1][1]
	end[0][2] = (g_zoneStartOrigin[0][2] > g_zoneStartOrigin[1][2]) ? g_zoneStartOrigin[0][2] : g_zoneStartOrigin[1][2]
	end[0][2] += 3.0
	start[1][0] = (g_zoneEndOrigin[0][0] < g_zoneEndOrigin[1][0]) ? g_zoneEndOrigin[0][0] : g_zoneEndOrigin[1][0]
	start[1][1] = (g_zoneEndOrigin[0][1] < g_zoneEndOrigin[1][1]) ? g_zoneEndOrigin[0][1] : g_zoneEndOrigin[1][1]
	start[1][2] = (g_zoneEndOrigin[0][2] < g_zoneEndOrigin[1][2]) ? g_zoneEndOrigin[0][2] : g_zoneEndOrigin[1][2]
	start[1][2] += 3.0
	end[1][0] = (g_zoneEndOrigin[0][0] > g_zoneEndOrigin[1][0]) ? g_zoneEndOrigin[0][0] : g_zoneEndOrigin[1][0]
	end[1][1] = (g_zoneEndOrigin[0][1] > g_zoneEndOrigin[1][1]) ? g_zoneEndOrigin[0][1] : g_zoneEndOrigin[1][1]
	end[1][2] = (g_zoneEndOrigin[0][2] > g_zoneEndOrigin[1][2]) ? g_zoneEndOrigin[0][2] : g_zoneEndOrigin[1][2]
	end[1][2] += 3.0
	int zones = 1
	if(g_cpCount)
	{
		zones += g_cpCount
		for(int i = 2; i <= zones; i++)
		{
			int cpnum = i - 1
			start[i][0] = (g_cpPos[0][cpnum][0] < g_cpPos[1][cpnum][0]) ? g_cpPos[0][cpnum][0] : g_cpPos[1][cpnum][0]
			start[i][1] = (g_cpPos[0][cpnum][1] < g_cpPos[1][cpnum][1]) ? g_cpPos[0][cpnum][1] : g_cpPos[1][cpnum][1]
			start[i][2] = (g_cpPos[0][cpnum][2] < g_cpPos[1][cpnum][2]) ? g_cpPos[0][cpnum][2] : g_cpPos[1][cpnum][2]
			start[i][2] += 3.0
			end[i][0] = (g_cpPos[0][cpnum][0] > g_cpPos[1][cpnum][0]) ? g_cpPos[0][cpnum][0] : g_cpPos[1][cpnum][0]
			end[i][1] = (g_cpPos[0][cpnum][1] > g_cpPos[1][cpnum][1]) ? g_cpPos[0][cpnum][1] : g_cpPos[1][cpnum][1]
			end[i][2] = (g_cpPos[0][cpnum][2] > g_cpPos[1][cpnum][2]) ? g_cpPos[0][cpnum][2] : g_cpPos[1][cpnum][2]
			end[i][2] += 3.0
		}
	}
	float corners[12][8][3] //https://github.com/tengulawl/scripting/blob/master/include/tengu_stocks.inc
	for(int i = 0; i <= zones; i++)
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
		int modelType
		if(i == 1)
			modelType = 1
		else if(i > 1)
			modelType = 2
		for(int j = 0; j <= 3; j++)
		{
			int k = j + 1
			if(j == 3)
				k = 0
			TE_SetupBeamPoints(corners[i][j], corners[i][k], g_zoneModel[modelType], 0, 0, 0, life, 3.0, 3.0, 0, 0.0, {0, 0, 0, 0}, 10) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3050
			TE_SendToClient(client)
		}
	}
}

void ResetFactory(int client)
{
	g_readyToStart[client] = true
	//g_timerTime[client] = 0.0
	g_state[client] = false
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(!IsFakeClient(client))
	{
		g_entityFlags[client] = GetEntityFlags(client)
		g_entityButtons[client] = buttons
		if(buttons & IN_JUMP && IsPlayerAlive(client) && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel") <= 1 && !(GetEntityMoveType(client) & MOVETYPE_LADDER)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
			buttons &= ~IN_JUMP //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
		//Timer
		if(g_state[client] && g_partner[client])
		{
			g_timerTime[client] = GetEngineTime() - g_timerTimeStart[client]
			//https://forums.alliedmods.net/archive/index.php/t-23912.html ShAyA format OneEyed format second
			int hour = (RoundToFloor(g_timerTime[client]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
			int minute = (RoundToFloor(g_timerTime[client]) / 60) % 60
			int second = RoundToFloor(g_timerTime[client]) % 60
			Format(g_clantag[client][1], 256, "%02.i:%02.i:%02.i", hour, minute, second)
			if(!IsPlayerAlive(client))
			{
				ResetFactory(client)
				ResetFactory(g_partner[client])
			}
		}
		if(g_skyBoost[client])
		{
			if(g_skyBoost[client] == 2)
			{
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, g_skyVel[client])
				g_skyBoost[client] = 0
			}
			else
				g_skyBoost[client] = 2
		}
		if(g_boost[client])
		{
			float velocity[3]
			if(g_boost[client] == 2)
			{
				velocity[0] = g_clientVel[client][0] - g_entityVel[client][0]
				velocity[1] = g_clientVel[client][1] - g_entityVel[client][1]
				velocity[2] = g_entityVel[client][2]
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity)
				g_boost[client] = 3
			}
			else if(g_boost[client] == 3) //Let make loop finish and come back to here.
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity)
				if(g_groundBoost[client])
				{
					velocity[0] += g_entityVel[client][0]
					velocity[1] += g_entityVel[client][1]
					velocity[2] += g_entityVel[client][2]
				}
				else
				{
					velocity[0] += g_entityVel[client][0] * 0.135
					velocity[1] += g_entityVel[client][1] * 0.135
				}
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L171-L192
				g_boost[client] = 0
				g_mlsVel[client][1][0] = velocity[0]
				g_mlsVel[client][1][1] = velocity[1]
				MLStats(client)
			}
		}
		if(IsPlayerAlive(client) && (g_partner[client] || g_devmap))
		{
			if(buttons & IN_USE)
			{
				if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_USE)
				{
					g_pingTime[client] = GetEngineTime()
					g_pingLock[client] = false
				}
			}
			else
				if(!g_pingLock[client])
					g_pingLock[client] = true
			if(!g_pingLock[client] && GetEngineTime() - g_pingTime[client] > 0.7)
			{
				g_pingLock[client] = true
				if(g_pingModel[client])
				{
					if(IsValidEntity(g_pingModel[client]))
						RemoveEntity(g_pingModel[client])
					g_pingModel[client] = 0
					KillTimer(g_pingTimer[client])
				}
				g_pingModel[client] = CreateEntityByName("prop_dynamic_override") //https://www.bing.com/search?q=prop_dynamic_override&cvid=0babe0a3c6cd43aa9340fa9c3c2e0f78&aqs=edge..69i57.409j0j1&pglt=299&FORM=ANNTA1&PC=U531
				SetEntityModel(g_pingModel[client], "models/fakeexpert/pingtool/pingtool.mdl")
				DispatchSpawn(g_pingModel[client])
				SetEntProp(g_pingModel[client], Prop_Data, "m_fEffects", 16) //https://pastebin.com/SdNC88Ma https://developer.valvesoftware.com/wiki/Effect_flags
				float start[3]
				float angle[3]
				float end[3]
				GetClientEyePosition(client, start)
				GetClientEyeAngles(client, angle)
				GetAngleVectors(angle, angle, NULL_VECTOR, NULL_VECTOR)
				for(int i = 0; i <= 2; i++)
				{
					angle[i] *= 8192.0
					end[i] = start[i] + angle[i] //Thanks to rumour for pingtool original code.
				}
				TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint, TraceEntityFilterPlayer, client)
				if(TR_DidHit())
				{
					TR_GetEndPosition(end)
					float normal[3]
					TR_GetPlaneNormal(null, normal) //https://github.com/alliedmodders/sourcemod/commit/1328984e0b4cb2ca0ee85eaf9326ab97df910483
					GetVectorAngles(normal, normal)
					GetAngleVectors(normal, angle, NULL_VECTOR, NULL_VECTOR)
					for(int i = 0; i <= 2; i++)
						end[i] += angle[i]
					normal[0] -= 270.0
					SetEntPropVector(g_pingModel[client], Prop_Data, "m_angRotation", normal)
				}
				if(g_color[client])
					SetEntityRenderColor(g_pingModel[client], g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], 255)
				TeleportEntity(g_pingModel[client], end, NULL_VECTOR, NULL_VECTOR)
				//https://forums.alliedmods.net/showthread.php?p=1080444
				if(g_color[client])
				{
					int color[4]
					for(int i = 0; i <= 2; i++)
						color[i] = g_colorBuffer[client][i]
					color[3] = 255
					TE_SetupBeamPoints(start, end, g_laserBeam, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, color, 0)
				}
				else
					TE_SetupBeamPoints(start, end, g_laserBeam, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, {255, 255, 255, 255}, 0)
				if(LibraryExists("fakeexpert-entityfilter"))
				{
					SDKHook(g_pingModel[client], SDKHook_SetTransmit, SDKSetTransmitPing)
					g_pingModelOwner[g_pingModel[client]] = client
					int clients[MAXPLAYERS + 1]
					int count
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i))
						{
							int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
							if(g_partner[client] == g_partner[g_partner[i]] || i == client || observerTarget == client)
								clients[count++] = i
						}
					}
					TE_Send(clients, count)
					EmitSound(clients, count, "fakeexpert/pingtool/click.wav", client)
				}
				else
				{
					TE_SendToAll()
					EmitSoundToAll("fakeexpert/pingtool/click.wav", client)
				}
				g_pingTimer[client] = CreateTimer(3.0, timer_removePing, client, TIMER_FLAG_NO_MAPCHANGE)
			}
		}
		if(!g_turbophysics.BoolValue)
		{
			if(IsPlayerAlive(client))
			{
				if(g_block[client] && GetEntProp(client, Prop_Data, "m_CollisionGroup") != 5)
					SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
				else if(!g_block[client] && GetEntProp(client, Prop_Data, "m_CollisionGroup") != 2)
					SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
			}
		}
		if(g_zoneDraw[client])
		{
			if(GetEngineTime() - g_engineTime >= 0.1)
			{
				g_engineTime = GetEngineTime()
				for(int i = 1; i <= MaxClients; i++)
					if(IsClientInGame(i))
						DrawZone(i, 0.1)
			}
		}
		if(IsClientObserver(client) && GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_USE) //Make able to swtich wtih E to the partner via spectate.
		{
			int observerTarget = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")
			int observerMode = GetEntProp(client, Prop_Data, "m_iObserverMode")
			if(0 < observerTarget <= MaxClients && g_partner[observerTarget] && IsPlayerAlive(g_partner[observerTarget]) && observerMode < 7)
				SetEntPropEnt(client, Prop_Data, "m_hObserverTarget", g_partner[observerTarget])
		}
		if(GetEngineTime() - g_hudTime[client] >= 0.1)
		{
			g_hudTime[client] = GetEngineTime()
			Hud(client)
		}
		if(GetEntityFlags(client) & FL_ONGROUND)
		{
			if(g_mlsCount[client])
			{
				int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity")
				char class[32]
				if(IsValidEntity(groundEntity))
					GetEntityClassname(groundEntity, class, 32)
				if(!(StrEqual(class, "flashbang_projectile")))
				{
					GetClientAbsOrigin(client, g_mlsDistance[client][1])
					MLStats(client, true)
					g_mlsCount[client] = 0
				}
			}
		}
		int other = Stuck(client)
		if(0 < other <= MaxClients && IsPlayerAlive(client) && g_block[other])
		{
			if(GetEntProp(other, Prop_Data, "m_CollisionGroup") == 5)
			{
				SetEntProp(other, Prop_Data, "m_CollisionGroup", 2)
				if(g_color[other])
					SetEntityRenderColor(other, g_colorBuffer[other][0], g_colorBuffer[other][1], g_colorBuffer[other][2], 125)
				else
					SetEntityRenderColor(other, 255, 255, 255, 125)
			}
		}
		else if(IsPlayerAlive(client) && other == -1 && g_block[client])
		{
			if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
			{
				SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
				if(g_color[client])
					SetEntityRenderColor(client, g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], 255)
				else
					SetEntityRenderColor(client, 255, 255, 255, 255)
			}
		}
		if(!g_devmap)
		{
			if(IsPlayerAlive(client) && !g_partner[client])
			{
				if(buttons & IN_USE)
				{
					if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_USE)
					{
						g_partnerInHold[client] = GetEngineTime()
						g_partnerInHoldLock[client] = false
					}
				}
				else
					if(!g_partnerInHoldLock[client])
						g_partnerInHoldLock[client] = true
				if(!g_partnerInHoldLock[client] && GetEngineTime() - g_partnerInHold[client] > 0.7)
				{
					g_partnerInHoldLock[client] = true
					Partner(client)
				}
			}
			if(buttons & IN_RELOAD)
			{
				if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_RELOAD)
				{
					g_restartInHold[client] = GetEngineTime()
					g_restartInHoldLock[client] = false
				}
			}
			else
				if(!g_restartInHoldLock[client])
					g_restartInHoldLock[client] = true
			if(!g_restartInHoldLock[client] && GetEngineTime() - g_restartInHold[client] > 0.7)
			{
				g_restartInHoldLock[client] = true
				if(g_partner[client])
				{
					Restart(client)
					Restart(g_partner[client])
				}
				else
					Partner(client)
			}
		}
	}
}

bool TraceEntityFilterPlayer(int entity, int contentMask, int client)
{
	if(LibraryExists("fakeexpert-entityfilter"))
		return entity > MaxClients && !Trikz_GetEntityFilter(client, entity)
	else
		return entity > MaxClients
}

Action timer_removePing(Handle timer, int client)
{
	if(g_pingModel[client])
	{
		RemoveEntity(g_pingModel[client])
		g_pingModel[client] = 0
	}
}

Action ProjectileBoostFix(int entity, int other)
{
	if(0 < other <= MaxClients && IsClientInGame(other) && !g_boost[other] && !(g_entityFlags[other] & FL_ONGROUND))
	{
		float originOther[3]
		GetClientAbsOrigin(other, originOther)
		float originEntity[3]
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", originEntity)
		float maxsEntity[3]
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxsEntity)
		float delta = originOther[2] - originEntity[2] - maxsEntity[2]
		//Thanks to extremix/hornet for idea from 2019 year summer. Extremix version (if(!(clientOrigin[2] - 5 <= entityOrigin[2] <= clientOrigin[2])) //Calculate for Client/Flash - Thanks to extrem)/tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231 //https://forums.alliedmods.net/showthread.php?t=146241
		if(0.0 < delta < 2.0) //Tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", g_entityVel[other])
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", g_clientVel[other])
			g_boostTime[other] = GetEngineTime()
			g_groundBoost[other] = g_bouncedOff[entity]
			SetEntProp(entity, Prop_Send, "m_nSolidType", 0) //https://forums.alliedmods.net/showthread.php?t=286568 non model no solid model Gray83 author of solid model types.
			g_flash[other] = EntIndexToEntRef(entity) //Thats should never happen.
			g_boost[other] = 1
			float vel[3]
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", vel)
			g_mlsVel[other][0][0] = vel[0]
			g_mlsVel[other][0][1] = vel[1]
			g_mlsCount[other]++
			if(g_mlsCount[other] == 1)
				GetClientAbsOrigin(other, g_mlsDistance[other][0])
			g_mlsBooster[other] = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
		}
	}
}

Action cmd_devmap(int client, int args)
{
	if(GetEngineTime() - g_devmapTime > 35.0 && GetEngineTime() - g_afkTime > 30.0)
	{
		g_voters = 0
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsFakeClient(i))
			{
				g_voters++
				if(g_devmap)
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
		}
		g_devmapTime = GetEngineTime()
		CreateTimer(20.0, timer_devmap, TIMER_FLAG_NO_MAPCHANGE)
		PrintToChatAll("Devmap vote started by %N", client)
	}
	else if(GetEngineTime() - g_devmapTime <= 35.0 || GetEngineTime() - g_afkTime <= 30.0)
		PrintToChat(client, "Devmap vote is not allowed yet.")
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
					g_devmapCount[1]++
					g_voters--
					Devmap()
				}
				case 1:
				{
					g_devmapCount[0]++
					g_voters--
					Devmap()
				}
			}
		}
	}
}

Action timer_devmap(Handle timer)
{
	//devmap idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	Devmap(true)
}

void Devmap(bool force = false)
{
	if(force || !g_voters)
	{
		if((g_devmapCount[1] || g_devmapCount[0]) && g_devmapCount[1] >= g_devmapCount[0])
		{
			if(g_devmap)
				PrintToChatAll("Devmap will be disabled. \"Yes\" %i%%% or %i of %i players.", (g_devmapCount[1] / (g_devmapCount[0] + g_devmapCount[1])) * 100, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1])
			else
				PrintToChatAll("Devmap will be enabled. \"Yes\" %i%%% or %i of %i players.", (g_devmapCount[1] / (g_devmapCount[0] + g_devmapCount[1])) * 100, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1])
			CreateTimer(5.0, timer_changelevel, g_devmap ? false : true)
		}
		else if((g_devmapCount[1] || g_devmapCount[0]) && g_devmapCount[1] <= g_devmapCount[0])
		{
			if(g_devmap)
				PrintToChatAll("Devmap will be continue. \"No\" chose %i%%% or %i of %i players.", (g_devmapCount[0] / (g_devmapCount[0] + g_devmapCount[1])) * 100, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1]) //google translate russian to english.
			else
				PrintToChatAll("Devmap will not be enabled. \"No\" chose %i%%% or %i of %i players.", (g_devmapCount[0] / (g_devmapCount[0] + g_devmapCount[1])) * 100, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1])
		}
		for(int i = 0; i <= 1; i++)
			g_devmapCount[i] = 0
	}
}

Action timer_changelevel(Handle timer, bool value)
{
	g_devmap = value
	ForceChangeLevel(g_map, "Reason: Devmap")
}

Action cmd_top(int client, int args)
{
	CreateTimer(0.1, timer_motd, client, TIMER_FLAG_NO_MAPCHANGE) //OnMapStart() is not work from first try.
	return Plugin_Handled
}

Action timer_motd(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		ConVar hostname = FindConVar("hostname")
		char hostnameBuffer[256]
		hostname.GetString(hostnameBuffer, 256)
		char url[192]
		g_urlTop.GetString(url, 192)
		Format(url, 256, "%s%s", url, g_map)
		ShowMOTDPanel(client, hostnameBuffer, url, MOTDPANEL_TYPE_URL) //https://forums.alliedmods.net/showthread.php?t=232476
	}
}

Action cmd_afk(int client, int args)
{
	if(GetEngineTime() - g_afkTime > 30.0 && GetEngineTime() - g_devmapTime > 35.0)
	{
		g_voters = 0
		g_afkClient = client
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsClientSourceTV(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && client != i)
			{
				g_afk[i] = false
				g_voters++
				Menu menu = new Menu(afk_handler)
				menu.SetTitle("Are you here?")
				menu.AddItem("yes", "Yes")
				menu.AddItem("no", "No")
				menu.Display(i, 20)
			}
		}
		g_afkTime = GetEngineTime()
		CreateTimer(20.0, timer_afk, client, TIMER_FLAG_NO_MAPCHANGE)
		PrintToChatAll("Afk check - vote started by %N", client)
	}
	else if(GetEngineTime() - g_afkTime <= 30.0 || GetEngineTime() - g_devmapTime <= 35.0)
		PrintToChat(client, "Afk vote is not allowed yet.")
	return Plugin_Handled
}

int afk_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					g_afk[param1] = true
					g_voters--
					AFK(g_afkClient)
				}
				case 1:
				{
					g_voters--
					AFK(g_afkClient)
				}
			}
		}
	}
}

Action timer_afk(Handle timer, int client)
{
	//afk idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	AFK(client, true)
}

void AFK(int client, bool force = false)
{
	if(force || !g_voters)
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i) && !IsPlayerAlive(i) && !IsClientSourceTV(i) && !g_afk[i] && client != i)
				KickClient(i, "Away from keyboard")
}

Action cmd_noclip(int client, int args)
{
	Noclip(client)
	return Plugin_Handled
}

void Noclip(int client)
{
	if(client)
	{
		if(g_devmap)
		{
			SetEntityMoveType(client, GetEntityMoveType(client) & MOVETYPE_NOCLIP ? MOVETYPE_WALK : MOVETYPE_NOCLIP)
			PrintToChat(client, GetEntityMoveType(client) & MOVETYPE_NOCLIP ? "Noclip enabled." : "Noclip disabled.")
		}
		else
			PrintToChat(client, "Turn on devmap.")
	}
}

Action cmd_spec(int client, int args)
{
	ChangeClientTeam(client, CS_TEAM_SPECTATOR)
	return Plugin_Handled
}

Action cmd_hud(int client, int args)
{
	Menu menu = new Menu(hud_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel)
	menu.SetTitle("Hud")
	menu.AddItem("vel", g_hudVel[client] ? "Velocity [v]" : "Velocity [x]")
	menu.AddItem("mls", g_mlstats[client] ? "ML stats [v]" : "ML stats [x]")
	menu.Display(client, 20)
	return Plugin_Handled
}

int hud_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
			g_menuOpened[param1] = true
		case MenuAction_Select:
		{
			char value[16]
			switch(param2)
			{
				case 0:
				{
					g_hudVel[param1] = !g_hudVel[param1]
					IntToString(g_hudVel[param1], value, 16)
					SetClientCookie(param1, g_cookie[0], value)
				}
				case 1:
				{
					g_mlstats[param1] = !g_mlstats[param1]
					IntToString(g_mlstats[param1], value, 16)
					SetClientCookie(param1, g_cookie[1], value)
				}
			}
			cmd_hud(param1, 0)
		}
		case MenuAction_Cancel:
			g_menuOpened[param1] = false //Idea from expert zone.
		case MenuAction_Display:
			g_menuOpened[param1] = true
	}
}

void Hud(int client)
{
	float vel[3]
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel)
	float velXY = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0))
	if(g_hudVel[client])
		PrintHintText(client, "%.0f", velXY)
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsPlayerAlive(i))
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
			if(observerMode < 7 && observerTarget == client && g_hudVel[i])
				PrintHintText(i, "%.0f", velXY)
		}
	}
}

Action cmd_mlstats(int client, int args)
{
	g_mlstats[client] = !g_mlstats[client]
	char value[16]
	IntToString(g_mlstats[client], value, 16)
	SetClientCookie(client, g_cookie[1], value)
	PrintToChat(client, g_mlstats[client] ? "ML stats is on." : "ML stats is off.")
	return Plugin_Handled
}

Action cmd_button(int client, int args)
{
	g_button[client] = !g_button[client]
	char value[16]
	IntToString(g_button[client], value, 16)
	SetClientCookie(client, g_cookie[2], value)
	PrintToChat(client, g_button[client] ? "Button announcer is on." : "Button announcer is off.")
	return Plugin_Handled
}

Action cmd_pbutton(int client, int args)
{
	g_pbutton[client] = !g_pbutton[client]
	char value[16]
	IntToString(g_pbutton[client], value, 16)
	SetClientCookie(client, g_cookie[3], value)
	PrintToChat(client, g_pbutton[client] ? "Partner button announcer is on." : "Partner button announcer is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
	{
		if(StrEqual(sArgs, "t") || StrEqual(sArgs, "trikz"))
		{
			if(!g_menuOpened[client])
				Trikz(client)
		}
		else if(StrEqual(sArgs, "bl") || StrEqual(sArgs, "block"))
			Block(client)
		else if(StrEqual(sArgs, "p") || StrEqual(sArgs, "partner"))
			Partner(client)
		else if(StrEqual(sArgs, "c") || StrEqual(sArgs, "color")) //white, red, orange, yellow, lime, aqua, deep sky blue, blue, magenta
			Color(client, false, true)
		else if(StrEqual(sArgs, "c 0") || StrEqual(sArgs, "c white") || StrEqual(sArgs, "color 0") || StrEqual(sArgs, "color white"))
			Color(client, false, true, 0)
		else if(StrEqual(sArgs, "c 1") || StrEqual(sArgs, "c red") || StrEqual(sArgs, "color 1") || StrEqual(sArgs, "color red"))
			Color(client, false, true, 1)
		else if(StrEqual(sArgs, "c 2") || StrEqual(sArgs, "c orange") || StrEqual(sArgs, "color 2") || StrEqual(sArgs, "color orange"))
			Color(client, false, true, 2)
		else if(StrEqual(sArgs, "c 3") || StrEqual(sArgs, "c yellow") || StrEqual(sArgs, "color 3") || StrEqual(sArgs, "color yellow"))
			Color(client, false, true, 3)
		else if(StrEqual(sArgs, "c 4") || StrEqual(sArgs, "c lime") || StrEqual(sArgs, "color 4") || StrEqual(sArgs, "color lime"))
			Color(client, false, true, 4)
		else if(StrEqual(sArgs, "c 5") || StrEqual(sArgs, "c aqua") || StrEqual(sArgs, "color 5") || StrEqual(sArgs, "color aqua"))
			Color(client, false, true, 5)
		else if(StrEqual(sArgs, "c 6") || StrEqual(sArgs, "c deep sky blue") || StrEqual(sArgs, "color 6") || StrEqual(sArgs, "color deep sky blue"))
			Color(client, false, true, 6)
		else if(StrEqual(sArgs, "c 7") || StrEqual(sArgs, "c blue") || StrEqual(sArgs, "color 7") || StrEqual(sArgs, "color blue"))
			Color(client, false, true, 7)
		else if(StrEqual(sArgs, "c 8") || StrEqual(sArgs, "c magenta") || StrEqual(sArgs, "color 8") || StrEqual(sArgs, "color magenta"))
			Color(client, false, true, 8)
		else if(StrEqual(sArgs, "r") || StrEqual(sArgs, "restart"))
		{
			Restart(client)
			if(g_partner[client])
				Restart(g_partner[client])
		}
		//else if(StrEqual(sArgs, "time"))
		//	cmd_time(client, 0)
		else if(StrEqual(sArgs, "devmap"))
			cmd_devmap(client, 0)
		else if(StrEqual(sArgs, "top"))
			cmd_top(client, 0)
		else if(StrEqual(sArgs, "cp"))
			Checkpoint(client)
		else if(StrEqual(sArgs, "afk"))
			cmd_afk(client, 0)
		else if(StrEqual(sArgs, "nc") || StrEqual(sArgs, "noclip"))
			Noclip(client)
		else if(StrEqual(sArgs, "sp") || StrEqual(sArgs, "spec"))
			cmd_spec(client, 0)
		else if(StrEqual(sArgs, "hud"))
			cmd_hud(client, 0)
		else if(StrEqual(sArgs, "mls"))
			cmd_mlstats(client, 0)
		else if(StrEqual(sArgs, "button"))
			cmd_button(client, 0)
		else if(StrEqual(sArgs, "pbutton"))
			cmd_pbutton(client, 0)
	}
}

Action ProjectileBoostFixEndTouch(int entity, int other)
{
	if(!other)
		g_bouncedOff[entity] = true //Get from Tengu github "tengulawl" scriptig "boost-fix.sp".
}

/*Action cmd_time(int client, int args)
{
	if(IsPlayerAlive(client))
	{
		//https://forums.alliedmods.net/archive/index.php/t-23912.html //ShAyA format OneEyed format second
		int hour = (RoundToFloor(g_timerTime[client]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
		int minute = (RoundToFloor(g_timerTime[client]) / 60) % 60
		int second = RoundToFloor(g_timerTime[client]) % 60
		PrintToChat(client, "Time: %02.i:%02.i:%02.i", hour, minute, second)
		if(g_partner[client])
			PrintToChat(g_partner[client], "Time: %02.i:%02.i:%02.i", hour, minute, second)
	}
	else
	{
		int observerTarget = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget")
		int observerMode = GetEntProp(client, Prop_Data, "m_iObserverMode")
		if(observerMode < 7)
		{
			//https://forums.alliedmods.net/archive/index.php/t-23912.html //ShAyA format OneEyed format second
			int hour = (RoundToFloor(g_timerTime[observerTarget]) / 3600) % 24 //https://forums.alliedmods.net/archive/index.php/t-187536.html
			int minute = (RoundToFloor(g_timerTime[observerTarget]) / 60) % 60
			int second = RoundToFloor(g_timerTime[observerTarget]) % 60
			PrintToChat(client, "Time: %02.i:%02.i:%02.i", hour, minute, second)
		}
	}
	return Plugin_Handled
}*/

public void OnEntityCreated(int entity, const char[] clasname)
{
	if(StrEqual(clasname, "flashbang_projectile"))
	{
		g_bouncedOff[entity] = false //"Tengulawl" "boost-fix.sp".
		SDKHook(entity, SDKHook_StartTouch, ProjectileBoostFix)
		SDKHook(entity, SDKHook_EndTouch, ProjectileBoostFixEndTouch)
		SDKHook(entity, SDKHook_SpawnPost, SDKProjectile)
	}
}

void SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	if(IsValidEntity(entity) && IsValidEntity(client))
	{
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2) //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
		g_silentKnife = true
		FakeClientCommand(client, "use weapon_knife")
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", false) //Thanks to "Alliedmodders". (2019 year https://forums.alliedmods.net/archive/index.php/t-287052.html)
		ClientCommand(client, "lastinv") //Hornet, Log idea, main idea Nick Yurevich since 2019, Hornet found ClientCommand - lastinv.
		RequestFrame(frame_blockExplosion, entity)
		CreateTimer(IsFakeClient(client) ? 0.1 : GetClientAvgLatency(client, NetFlow_Both), timer_hideSwtich, client, TIMER_FLAG_NO_MAPCHANGE)
		CreateTimer(1.5, timer_deleteProjectile, entity, TIMER_FLAG_NO_MAPCHANGE)
		if(g_color[client])
		{
			SetEntProp(entity, Prop_Data, "m_nModelIndex", g_wModelThrown)
			SetEntProp(entity, Prop_Data, "m_nSkin", 1)
			SetEntityRenderColor(entity, g_colorBuffer[client][0], g_colorBuffer[client][1], g_colorBuffer[client][2], 255)
		}
	}
}

void frame_blockExplosion(int entity)
{
	if(IsValidEntity(entity))
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", 0) //https://forums.alliedmods.net/showthread.php?t=301667 avoid random blinds.
}

Action timer_hideSwtich(Handle timer, int client)
{
	if(IsClientInGame(client))
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", true)
}

Action timer_deleteProjectile(Handle timer, int entity)
{
	if(IsValidEntity(entity))
	{
		FlashbangEffect(entity)
		RemoveEntity(entity)
	}
}

void FlashbangEffect(int entity)
{
	bool filter = LibraryExists("fakeexpert-entityfilter")
	float origin[3]
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin)
	TE_SetupSmoke(origin, g_smoke, GetRandomFloat(0.5, 1.5), 100) //https://forums.alliedmods.net/showpost.php?p=2552543&postcount=5
	int clients[MAXPLAYERS + 1]
	int count
	if(filter)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
		if(owner == -1)
			owner = 0
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
				if(g_partner[owner] == g_partner[g_partner[i]] || i == owner || observerTarget == owner)
					clients[count++] = i
			}
		}
		TE_Send(clients, count)
	}
	else
		TE_SendToAll()
	float dir[3] //https://forums.alliedmods.net/showthread.php?t=274452
	dir[0] = GetRandomFloat(-1.0, 1.0)
	dir[1] = GetRandomFloat(-1.0, 1.0)
	dir[2] = GetRandomFloat(-1.0, 1.0)
	TE_SetupSparks(origin, dir, 1, GetRandomInt(1, 2))
	if(filter)
		TE_Send(clients, count)
	else
		TE_SendToAll() //Idea from "Expert-Zone". So, we just made non empty event.
	char sample[2][PLATFORM_MAX_PATH] = {"weapons/flashbang/flashbang_explode1.wav", "weapons/flashbang/flashbang_explode2.wav"}
	if(filter)
		EmitSound(clients, count, sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL)
	else
		EmitSoundToAll(sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL) //https://www.youtube.com/watch?v=0Dep7RXhetI&list=PL_2MB6_9kLAHnA4mS_byUpgpjPgETJpsV&index=171 https://github.com/Smesh292/Public-SourcePawn-Plugins/blob/master/trikz.sp#L23 So via "GCFScape" we can found "sound/weapons/flashbang", there we can use 2 sounds as random. flashbang_explode1.wav and flashbang_explode2.wav. These sound are similar, so, better to mix via random. https://forums.alliedmods.net/showthread.php?t=167638 https://world-source.ru/forum/100-2357-1 https://sm.alliedmods.net/new-api/sdktools_sound/__raw
}

Action SDKOnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR) //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR)
	return Plugin_Handled //Full god-mode.
}

void SDKWeaponEquip(int client, int weapon) //https://sm.alliedmods.net/new-api/sdkhooks/__raw Thanks to Lon for gave this idea. (aka trikz_failtime)
{
	if(!GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
	{
		GivePlayerItem(client, "weapon_flashbang")
		GivePlayerItem(client, "weapon_flashbang")
	}
}

Action SDKWeaponDrop(int client, int weapon)
{
	if(IsValidEntity(weapon))
		RemoveEntity(weapon)
}

Action SDKSetTransmitPing(int entity, int client)
{
	if(IsPlayerAlive(client) && g_pingModelOwner[entity] != client && g_partner[g_pingModelOwner[entity]] != g_partner[g_partner[client]])
		return Plugin_Handled
	return Plugin_Continue
}

Action OnSound(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
{
	if(StrEqual(sample, "weapons/knife/knife_deploy1.wav") && g_silentKnife)
	{
		g_silentKnife = false
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action timer_clantag(Handle timer, int client)
{
	if(0 < client <= MaxClients && IsClientInGame(client))
	{
		if(g_state[client])
		{
			CS_SetClientClanTag(client, g_clantag[client][1])
			return Plugin_Continue
		}
		else
			CS_SetClientClanTag(client, g_clantag[client][0])
	}
	return Plugin_Stop
}

void MLStats(int client, bool ground = false)
{
	float velPre = SquareRoot(Pow(g_mlsVel[client][0][0], 2.0) + Pow(g_mlsVel[client][0][1], 2.0))
	float velPost = SquareRoot(Pow(g_mlsVel[client][1][0], 2.0) + Pow(g_mlsVel[client][1][1], 2.0))
	Format(g_mlsPrint[client][g_mlsCount[client]], 256, "%i. %.1f - %.1f\n", g_mlsCount[client], velPre, velPost)
	char print[256]
	for(int i = 1; i <= g_mlsCount[client] <= 10; i++)
		Format(print, 256, "%s%s", print, g_mlsPrint[client][i])
	if(g_mlsCount[client] > 10)
		Format(print, 256, "%s...\n%s", print, g_mlsPrint[client][g_mlsCount[client]])
	if(ground)
	{
		float x = g_mlsDistance[client][1][0] - g_mlsDistance[client][0][0]
		float y = g_mlsDistance[client][1][1] - g_mlsDistance[client][0][1]
		Format(print, 256, "%s\nDistance: %.1f units%s", print, SquareRoot(Pow(x, 2.0) + Pow(y, 2.0)) + 32.0, g_teleported[client] ? " [TP]" : "")
		g_teleported[client] = false
	}
	if(g_mlstats[g_mlsBooster[client]])
	{
		Handle KeyHintText = StartMessageOne("KeyHintText", g_mlsBooster[client])
		BfWrite bfmsg = UserMessageToBfWrite(KeyHintText)
		bfmsg.WriteByte(true)
		bfmsg.WriteString(print)
		EndMessage()
	}
	if(g_mlstats[client])
	{
		Handle KeyHintText = StartMessageOne("KeyHintText", client)
		BfWrite bfmsg = UserMessageToBfWrite(KeyHintText)
		bfmsg.WriteByte(true)
		bfmsg.WriteString(print)
		EndMessage()
	}
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsClientObserver(i))
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
			if(observerMode < 7 && observerTarget == client && g_mlstats[i])
			{
				Handle KeyHintText = StartMessageOne("KeyHintText", i)
				BfWrite bfmsg = UserMessageToBfWrite(KeyHintText)
				bfmsg.WriteByte(true)
				bfmsg.WriteString(print)
				EndMessage()
			}
		}
	}
}

int Stuck(int client)
{
	float mins[3]
	float maxs[3]
	float origin[3]
	GetClientMins(client, mins)
	GetClientMaxs(client, maxs)
	GetClientAbsOrigin(client, origin)
	TR_TraceHullFilter(origin, origin, mins, maxs, MASK_PLAYERSOLID, TR_donthitself, client) //Skiper, Gurman idea, plugin 2020 year.
	return TR_GetEntityIndex()
}

bool TR_donthitself(int entity, int mask, int client)
{
	if(LibraryExists("fakeexpert-entityfilter"))
		return entity != client && 0 < entity <= MaxClients && g_partner[entity] == g_partner[g_partner[client]]
	else
		return entity != client && 0 < entity <= MaxClients
}

int Native_GetClientButtons(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return g_entityButtons[client]
}

int Native_GetClientPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return g_partner[client]
}

int Native_GetTimerState(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	if(!IsFakeClient(client))
		return g_state[client]
	else
		return false
}

int Native_SetPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int partner = GetNativeCell(2)
	g_partner[client] = partner
	g_partner[partner] = client
}

int Native_Restart(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	Restart(client)
	Restart(g_partner[client])
}

int Native_GetDevmap(Handle plugin, int numParams)
{
	return g_devmap
}

Action timer_clearlag(Handle timer)
{
	ServerCommand("mat_texture_list_txlod_sync reset")
}

float GetGroundPos(int client) //https://forums.alliedmods.net/showpost.php?p=1042515&postcount=4
{
	float origin[3]
	GetClientAbsOrigin(client, origin)
	float originDir[3]
	GetClientAbsOrigin(client, originDir)
	originDir[2] -= 90.0
	float mins[3]
	GetClientMins(client, mins)
	float maxs[3]
	GetClientMaxs(client, maxs)
	TR_TraceHullFilter(origin, originDir, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client)
	float pos[3]
	if(TR_DidHit())
		TR_GetEndPosition(pos)
	return pos[2]
}
