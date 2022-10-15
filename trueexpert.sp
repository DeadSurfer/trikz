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
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define MAXPLAYER MAXPLAYERS + 1
#define MAXENTITY 2048 + 1
#define IsValidClient(%1) (0 < %1 <= MaxClients && IsClientInGame(%1))
#define IsValidPartner(%1) 0 < g_partner[%1] <= MaxClients
#define debug false

int g_partner[MAXPLAYER] = {0, ...};
float g_zoneStartOrigin[2][3]; //start zone mins and maxs
float g_zoneEndOrigin[2][3]; //end zone mins and maxs
Database g_mysql = null;
float g_timerTimeStart[MAXPLAYER] = {0.0, ...};
float g_timerTime[MAXPLAYER] = {0.0, ...};
bool g_timerState[MAXPLAYER] = {false, ...};
char g_map[192] = "";
bool g_mapFinished[MAXPLAYER] = {false, ...};
bool g_dbPassed = false;
float g_timerStartPos[3] = {0.0, ...};
float g_boostTime[MAXPLAYER] = {0.0, ...};
float g_skyVel[MAXPLAYER][3];
bool g_timerReadyToStart[MAXPLAYER] = {false, ...};

float g_cpPos[11][2][3];
bool g_cp[MAXPLAYER][11];
bool g_cpLock[MAXPLAYER][11];
float g_cpTime[MAXPLAYER][11];
float g_cpDiffSR[MAXPLAYER][11];
float g_cpTimeSR[11] = {0.0, ...};

float g_haveRecord[MAXPLAYER] = {0.0, ...};
float g_ServerRecordTime = 0.0;

ConVar gCV_urlTop = null;
ConVar gCV_trikz = null;
ConVar gCV_block = null;
ConVar gCV_partner = null;
ConVar gCV_color = null;
ConVar gCV_restart = null;
ConVar gCV_checkpoint = null;
ConVar gCV_afk = null;
ConVar gCV_noclip = null;
ConVar gCV_spec = null;
ConVar gCV_button = null;
ConVar gCV_pbutton = null;
ConVar gCV_bhop = null;
ConVar gCV_autoswitch = null;
ConVar gCV_autoflashbang = null;
ConVar gCV_macro = null;
ConVar gCV_pingtool = null;
ConVar gCV_boostfix = null;
ConVar gCV_devmap = null;
ConVar gCV_hud = null;
ConVar gCV_endmsg = null;
ConVar gCV_top10 = null;
ConVar gCV_control = null;
ConVar gCV_skin = null;
ConVar gCV_top = null;
ConVar gCV_mlstats = null;
ConVar gCV_vel = null;
ConVar gCV_sourceTV = null;

bool g_menuOpened[MAXPLAYER] = {false, ...};
bool g_menuOpenedHud[MAXPLAYER] = {false, ...};

int g_boost[MAXPLAYER] = {0, ...};
int g_skyBoost[MAXPLAYER] = {0, ...};
bool g_bouncedOff[MAXENTITY] = {false, ...};
bool g_groundBoost[MAXPLAYER] = {false, ...};
int g_flash[MAXPLAYER] = {0, ...};
int g_entityFlags[MAXPLAYER] = {0, ...};
int g_devmapCount[2] = {0, ...};
bool g_devmap = false;
float g_devmapTime = 0.0;

float g_cpOrigin[MAXPLAYER][2][3];
float g_cpAng[MAXPLAYER][2][3];
float g_cpVel[MAXPLAYER][2][3];
bool g_cpToggled[MAXPLAYER][2];

bool g_zoneHave[3] = {false, ...};

bool g_ServerRecord = false;
char g_date[64] = "";
char g_time[64] = "";

bool g_silentKnife = false;
float g_teamRecord[MAXPLAYER] = {0.0, ...};
bool g_sourcetv = false;
bool g_block[MAXPLAYER] = {false, ...};
int g_wModelThrown = 0;
int g_class[MAXPLAYER] = {0, ...};
int g_wModelPlayer[5] = {0, ...};
int g_pingModel[MAXPLAYER] = {0, ...};
int g_pingModelOwner[MAXENTITY] = {0, ...};
Handle g_pingTimer[MAXPLAYER] = {INVALID_HANDLE, ...};
Handle g_cookie[12] = {INVALID_HANDLE, ...};

char g_colorType[][] = {"255,255,255,white", "255,0,0,red", "255,165,0,orange", "255,255,0,yellow", "0,255,0,lime", "0,255,255,aqua", "0,191,255,deep sky blue", "0,0,255,blue", "255,0,255,magenta"}; //https://flaviocopes.com/rgb-color-codes/#:~:text=A%20table%20summarizing%20the%20RGB%20color%20codes%2C%20which,%20%20%28178%2C34%2C34%29%20%2053%20more%20rows%20
int g_colorBuffer[MAXPLAYER][2][3];
int g_colorCount[MAXPLAYER][2];

int g_zoneModel[3] = {0, ...};
int g_laserBeam = 0;
bool g_sourcetvchangedFileName = true;
float g_nadeVel[MAXPLAYER][3];
float g_clientVel[MAXPLAYER][3];
int g_cpCount = 0;
//ConVar g_turbophysics;
float g_afkTime = 0.0;
bool g_afk[MAXPLAYER] = {false, ...};
float g_center[12][3];
bool g_zoneDraw[MAXPLAYER] = {false, ...};
float g_engineTime = 0.0;
float g_pingTime[MAXPLAYER] = {0.0, ...};
bool g_pingLock[MAXPLAYER] = {false, ...};
bool g_msg[MAXPLAYER] = {false, ...};
int g_voters = 0;
int g_afkClient = 0;
bool g_hudVel[MAXPLAYER] = {false, ...};
float g_hudTime[MAXPLAYER] = {0.0, ...};
char g_clantag[MAXPLAYER][2][256];
float g_mlsVel[MAXPLAYER][2][3];
int g_mlsCount[MAXPLAYER] = {0, ...};
char g_mlsPrint[MAXPLAYER][100][256];
int g_mlsFlyer[MAXPLAYER] = {0, ...};
bool g_mlstats[MAXPLAYER] = {false, ...};
float g_mlsDistance[MAXPLAYER][2][3];
bool g_button[MAXPLAYER] = {false, ...};
bool g_pbutton[MAXPLAYER] = {false, ...};
float g_skyOrigin[MAXPLAYER] = {0.0, ...};
int g_entityButtons[MAXPLAYER] = {0, ...};
bool g_teleported[MAXPLAYER] = {false, ...};
int g_points[MAXPLAYER] = {0, ...};
int g_pointsMaxs = 1;
int g_queryLast = 0;
float g_skyAble[MAXPLAYER] = {0.0, ...};
native bool Trikz_GetEntityFilter(int client, int entity);
float g_restartHoldTime[MAXPLAYER] = {0.0, ...};
bool g_restartLock[MAXPLAYER][2];
int g_smoke = 0;
bool g_clantagOnce[MAXPLAYER] = {false, ...};
bool g_autoflash[MAXPLAYER] = {false, ...};
bool g_autoswitch[MAXPLAYER] = {false, ...};
bool g_bhop[MAXPLAYER] = {false, ...};
bool g_macroDisabled[MAXPLAYER] = {false, ...};
int g_macroTick[MAXPLAYER] = {0, ...};
bool g_macroOpened[MAXPLAYER] = {false, ...};
bool g_endMessage[MAXPLAYER] = {false, ...};
float g_flashbangTime[MAXPLAYER] = {0.0, ...};
bool g_flashbangDoor[MAXPLAYER][2];
int g_top10Count = 0;
DynamicHook g_teleport = null;
float g_top10ac = 0.0;
int g_step = 1;
int g_ZoneEditor = 0;
int g_ZoneEditorCP = 0;
int g_skinFlashbang[MAXPLAYER] = {0, ...};
int g_skinPlayer[MAXPLAYER] = {0, ...};
float g_top10SR = 0.0;
bool g_silentF1F2 = false;
KeyValues g_kv = null;
bool g_zoneDrawed[MAXPLAYER] = {false, ...};

public Plugin myinfo =
{
	name = "TrueExpert",
	author = "Niks Smesh Jurēvičs",
	description = "Allows to able make trikz more comfortable.",
	version = "4.59",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	gCV_urlTop = CreateConVar("sm_te_topurl", "typeURLaddress", "Set url for top, for ex (http://www.trueexpert.rf.gd/?start=0&map=). To open web page, type to in-game chat !top", FCVAR_NOTIFY, false, 0.0, false, 1.0);
	gCV_trikz = CreateConVar("sm_te_trikz", "0.0", "Allow to use trikz menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_block = CreateConVar("sm_te_block", "0.0", "Allow to toggling block state.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_partner = CreateConVar("sm_te_partner", "0.0", "Allow to use partner system.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_color = CreateConVar("sm_te_color", "0.0", "Toggling color menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_restart = CreateConVar("sm_te_restart", "0.0", "Allow player to restart timer.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_checkpoint = CreateConVar("sm_te_checkpoint", "0.0", "Allow to use checkpoint in devmap.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_afk = CreateConVar("sm_te_afk", "0.0", "Allow to use !afk command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_noclip = CreateConVar("sm_te_noclip", "0.0", "Allow to use noclip for players in devmap.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_spec = CreateConVar("sm_te_spec", "0.0", "Allow to use spectator command to swtich to the spectator team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_button = CreateConVar("sm_te_button", "0.0", "Allow to use text message for button announcments.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_pbutton = CreateConVar("sm_te_pbutton", "0.0", "Allow to use text message for partner button announcments.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_bhop = CreateConVar("sm_te_bhop", "0.0", "Allow to use autobhop.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_autoswitch = CreateConVar("sm_te_autoswitch", "0.0", "Allow to switch to the flashbang automaticly.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_autoflashbang = CreateConVar("sm_te_autoflashbang", "0.0", "Allow to give auto flashbangs.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_macro = CreateConVar("sm_te_macro", "0.0", "Allow to use macro for each player.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_pingtool = CreateConVar("sm_te_pingtool", "0.0", "Allow to use ping tool on E button or +use.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_boostfix = CreateConVar("sm_te_boostfix", "0.0", "Artifacial boost for nade and stack boost.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_devmap = CreateConVar("sm_te_devmap", "0.0", "Allow to use devmap.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_hud = CreateConVar("sm_te_hud", "0.0", "Allow to use !hud command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_endmsg = CreateConVar("sm_te_endmsg", "0.0", "Allow to use !endmsg command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_top10 = CreateConVar("sm_te_top10", "0.0", "Allow to use !top10 command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_control = CreateConVar("sm_te_control", "0.0", "Allow to use control menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_skin = CreateConVar("sm_te_skin", "0.0", "Allow to use skin menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_top = CreateConVar("sm_te_top", "0.0", "Allow to use !top command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_mlstats = CreateConVar("sm_te_mlstats", "0.0", "Allow to use !mlstats command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_vel = CreateConVar("sm_te_vel", "0.0", "Allow to use velocity in hint.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_sourceTV = CreateConVar("sm_te_sourcetv", "0.0,", "Save demo only when server record.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "plugin.trueexpert", "sourcemod"); //https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig

	RegConsoleCmd("sm_t", cmd_trikz);
	RegConsoleCmd("sm_trikz", cmd_trikz);
	RegConsoleCmd("sm_bl", cmd_block);
	RegConsoleCmd("sm_block", cmd_block);
	RegConsoleCmd("sm_p", cmd_partner);
	RegConsoleCmd("sm_partner", cmd_partner);
	RegConsoleCmd("sm_c", cmd_color);
	RegConsoleCmd("sm_color", cmd_color);
	RegConsoleCmd("sm_r", cmd_restart);
	RegConsoleCmd("sm_restart", cmd_restart);
	RegConsoleCmd("sm_autoflash", cmd_autoflash);
	RegConsoleCmd("sm_flash", cmd_autoflash);
	RegConsoleCmd("sm_autoswitch", cmd_autoswitch);
	RegConsoleCmd("sm_switch", cmd_autoswitch);
	//RegConsoleCmd("sm_time", cmd_time);
	RegConsoleCmd("sm_cp", cmd_checkpoint);
	RegConsoleCmd("sm_devmap", cmd_devmap);
	RegConsoleCmd("sm_top", cmd_top);
	RegConsoleCmd("sm_afk", cmd_afk);
	RegConsoleCmd("sm_nc", cmd_noclip);
	RegConsoleCmd("sm_noclip", cmd_noclip);
	RegConsoleCmd("sm_sp", cmd_spec);
	RegConsoleCmd("sm_spec", cmd_spec);
	RegConsoleCmd("sm_hud", cmd_hud);
	RegConsoleCmd("sm_mls", cmd_mlstats);
	RegConsoleCmd("sm_button", cmd_button);
	RegConsoleCmd("sm_pbutton", cmd_pbutton);
	RegConsoleCmd("sm_macro", cmd_macro);
	RegConsoleCmd("sm_bhop", cmd_bhop);
	RegConsoleCmd("sm_endmsg", cmd_endmsg);
	RegConsoleCmd("sm_top10", cmd_top10);
	RegConsoleCmd("sm_help", cmd_control);
	RegConsoleCmd("sm_control", cmd_control);
	RegConsoleCmd("sm_skin", cmd_skin);
	RegConsoleCmd("sm_vel", cmd_vel);

	RegServerCmd("sm_createzones", cmd_createzones);
	RegServerCmd("sm_createusers", cmd_createusers);
	RegServerCmd("sm_createrecords", cmd_createrecords);
	RegServerCmd("sm_createcp", cmd_createcp);
	RegServerCmd("sm_createtier", cmd_createtier);

	RegConsoleCmd("sm_startmins", cmd_startmins);
	RegConsoleCmd("sm_startmaxs", cmd_startmaxs);
	RegConsoleCmd("sm_endmins", cmd_endmins);
	RegConsoleCmd("sm_endmaxs", cmd_endmaxs);
	RegConsoleCmd("sm_cpmins", cmd_cpmins);
	RegConsoleCmd("sm_cpmaxs", cmd_cpmaxs);
	RegConsoleCmd("sm_zones", cmd_zones);
	RegConsoleCmd("sm_maptier", cmd_maptier);
	RegConsoleCmd("sm_deleteallcp", cmd_deleteallcp);
	RegConsoleCmd("sm_test", cmd_test);

	AddNormalSoundHook(OnSound);

	HookUserMessage(GetUserMessageId("SayText2"), OnSayMessage, true); //thanks to VerMon idea. https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-chat.sp#L416
	HookUserMessage(GetUserMessageId("RadioText"), OnRadioMessage, true);

	HookEvent("player_spawn", OnSpawn, EventHookMode_Post);
	HookEvent("player_jump", OnJump, EventHookMode_Post);
	HookEvent("player_death", OnDeath, EventHookMode_Post);
	HookEvent("player_team", OnTeam, EventHookMode_Post);

	HookEntityOutput("func_button", "OnPressed", OnButton);

	AddCommandListener(joinclass, "joinclass");
	AddCommandListener(autobuy, "autobuy");
	AddCommandListener(rebuy, "rebuy");
	AddCommandListener(cheer, "cheer");
	AddCommandListener(showbriefing, "showbriefing");
	AddCommandListener(headtrack_reset_home_pos, "headtrack_reset_home_pos");

	//char output[5][16] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger"};

	//for(int i = 0; i < sizeof(output); i++)
	//{
	//	HookEntityOutput("trigger_teleport", output[i], output_teleport); //https://developer.valvesoftware.com/wiki/Trigger_teleport
	//	HookEntityOutput("trigger_teleport_relative", output[i], output_teleport); //https://developer.valvesoftware.com/wiki/Trigger_teleport_relative
	//}

	LoadTranslations("trueexpert.phrases"); //https://wiki.alliedmods.net/Translations_(SourceMod_Scripting)

	RegPluginLibrary("trueexpert");

	g_cookie[0] = RegClientCookie("te_vel", "velocity in hint", CookieAccess_Protected);
	g_cookie[1] = RegClientCookie("te_mls", "mega long stats", CookieAccess_Protected);
	g_cookie[2] = RegClientCookie("te_button", "button", CookieAccess_Protected);
	g_cookie[3] = RegClientCookie("te_pbutton", "partner button", CookieAccess_Protected);
	g_cookie[4] = RegClientCookie("te_autoflash", "autoflash", CookieAccess_Protected);
	g_cookie[5] = RegClientCookie("te_autoswitch", "autoswitch", CookieAccess_Protected);
	g_cookie[6] = RegClientCookie("te_bhop", "bhop", CookieAccess_Protected);
	g_cookie[7] = RegClientCookie("te_macro", "macro", CookieAccess_Protected);
	g_cookie[8] = RegClientCookie("te_endmsg", "End message.", CookieAccess_Protected);
	g_cookie[9] = RegClientCookie("te_flashbangskin", "Flashbang skin.", CookieAccess_Protected);
	g_cookie[10] = RegClientCookie("te_flashbangcolor", "Flashbang color.", CookieAccess_Protected);
	g_cookie[11] = RegClientCookie("te_playerskin", "Player skin.", CookieAccess_Protected);

	Handle gamedata = LoadGameConfigFile("sdktools.games");

	int offset = GameConfGetOffset(gamedata, "Teleport");

	delete gamedata;
	
	if(offset == -1)
	{
		SetFailState("[DHooks] Offset for Teleport function is not found!");

		return;
	}
	
	g_teleport = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooksOnTeleport);

	if(g_teleport == null)
	{
		SetFailState("[DHooks] Could not create Teleport hook function!");

		return;
	}
	
	g_teleport.AddParam(HookParamType_VectorPtr);
	g_teleport.AddParam(HookParamType_ObjectPtr);
	g_teleport.AddParam(HookParamType_VectorPtr);

	delete g_kv;
	g_kv = new KeyValues("TrueExpertHud");
	g_kv.ImportFromFile("addons/sourcemod/configs/trueexpert_hud.cfg");

	if(g_devmap == false)
	{
		ServerCommand("sv_nostats 0");
	}

	return;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetClientButtons", Native_GetClientButtons);
	CreateNative("Trikz_GetClientPartner", Native_GetClientPartner);
	CreateNative("Trikz_GetTimerState", Native_GetTimerState);
	CreateNative("Trikz_SetPartner", Native_SetPartner);
	CreateNative("Trikz_Restart", Native_Restart);
	CreateNative("Trikz_GetDevmap", Native_GetDevmap);

	MarkNativeAsOptional("Trikz_GetEntityFilter");

	return APLRes_Success;
}

public void OnMapStart()
{
	GetCurrentMap(g_map, sizeof(g_map));

	Database.Connect(SQLConnect, "trueexpert");

	for(int i = 0; i <= 2; i++)
	{
		g_zoneHave[i] = false;
	}

	float sourcetvCV = gCV_sourceTV.FloatValue;

	if(sourcetvCV == 1.0)
	{
		ConVar CV_sourcetv = FindConVar("tv_enable");

		bool sourcetv = CV_sourcetv.BoolValue; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/funvotes.sp#L280

		if(sourcetv == true)
		{
			if(g_sourcetvchangedFileName == false)
			{
				char filenameOld[256] = "";
				Format(filenameOld, sizeof(filenameOld), "%s-%s-%s.dem", g_date, g_time, g_map);

				char filenameNew[256] = "";
				Format(filenameNew, sizeof(filenameNew), "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map);

				RenameFile(filenameNew, filenameOld);

				g_sourcetvchangedFileName = true;
			}

			if(g_devmap == false)
			{
				PrintToServer("SourceTV start recording.");

				FormatTime(g_date, sizeof(g_date), "%Y-%m-%d", GetTime());
				FormatTime(g_time, sizeof(g_time), "%H-%M-%S", GetTime());

				ServerCommand("tv_record %s-%s-%s", g_date, g_time, g_map); //https://www.youtube.com/watch?v=GeGd4KOXNb8 https://forums.alliedmods.net/showthread.php?t=59474 https://www.php.net/strftime
			}
		}

		if(g_sourcetv == false && sourcetv == false)
		{
			g_sourcetv = true;

			ForceChangeLevel(g_map, "Turning on SourceTV");

			//this should provides a crash if reload plugin (DHookEntity). https://issuehint.com/issue/alliedmodders/sourcemod/1688
			ServerCommand("tv_delay 0");
			ServerCommand("tv_transmitall 1");
		}
	}

	g_wModelThrown = PrecacheModel("models/trueexpert/flashbang/flashbang.mdl", true);

	g_wModelPlayer[1] = PrecacheModel("models/trueexpert/player/ct_urban.mdl", true);
	g_wModelPlayer[2] = PrecacheModel("models/trueexpert/player/ct_gsg9.mdl", true);
	g_wModelPlayer[3] = PrecacheModel("models/trueexpert/player/ct_sas.mdl", true);
	g_wModelPlayer[4] = PrecacheModel("models/trueexpert/player/ct_gign.mdl", true);

	//PrecacheSound("trueexpert/pingtool/click.wav", true); //https://forums.alliedmods.net/showthread.php?t=333211
	PrecacheSound("items/gift_drop.wav", true);

	//g_zoneModel[0] = PrecacheModel("materials/trueexpert/zones/start.vmt", true);
	//g_zoneModel[1] = PrecacheModel("materials/trueexpert/zones/finish.vmt", true);
	//g_zoneModel[2] = PrecacheModel("materials/trueexpert/zones/check_point.vmt", true);

	g_zoneModel[0] = PrecacheModel("materials/expert_zone/zone_editor/zones/start.vmt", true);
	g_zoneModel[1] = PrecacheModel("materials/expert_zone/zone_editor/zones/finish.vmt", true);
	g_zoneModel[2] = PrecacheModel("materials/expert_zone/zone_editor/zones/check_point.vmt", true);

	g_laserBeam = PrecacheModel("materials/sprites/laser.vmt", true);
	g_smoke = PrecacheModel("materials/sprites/smoke.vmt", true);

	PrecacheSound("weapons/flashbang/flashbang_explode1.wav", true);
	PrecacheSound("weapons/flashbang/flashbang_explode2.wav", true);

	//char path[12][PLATFORM_MAX_PATH] = {"models/trueexpert/flashbang/", "models/trueexpert/pingtool/", "models/trueexpert/player/", "materials/trueexpert/flashbang/", "materials/trueexpert/pingtool/", "sound/trueexpert/pingtool/", "materials/trueexpert/player/ct_gign/", "materials/trueexpert/player/ct_gsg9/", "materials/trueexpert/player/ct_sas/", "materials/trueexpert/player/ct_urban/", "materials/trueexpert/player/", "materials/trueexpert/zones/"};
	char path[8][PLATFORM_MAX_PATH] = {"models/trueexpert/flashbang/", "models/trueexpert/player/", "materials/trueexpert/flashbang/", "materials/trueexpert/player/ct_gign/", "materials/trueexpert/player/ct_gsg9/", "materials/trueexpert/player/ct_sas/", "materials/trueexpert/player/ct_urban/", "materials/trueexpert/player/"};

	for(int i = 0; i < sizeof(path); i++)
	{
		//PrintToServer("%i %i %i", i, PLATFORM_MAX_PATH, sizeof(path));
		DirectoryListing dir = OpenDirectory(path[i]);
		//PrintToServer("01: %s", path[i]);

		//char filename[12][PLATFORM_MAX_PATH];
		//char filename[PLATFORM_MAX_PATH][12];
		//char filename[12][PLATFORM_MAX_PATH];
		char filename[8][PLATFORM_MAX_PATH];

		FileType type = FileType_Unknown;
		//char pathFull[12][PLATFORM_MAX_PATH];
		char pathFull[8][PLATFORM_MAX_PATH];
		//char pathFull[PLATFORM_MAX_PATH][2];

		while(dir.GetNext(filename[i], PLATFORM_MAX_PATH, type))
		{
			if(type == FileType_File)
			{
				Format(pathFull[i], PLATFORM_MAX_PATH, "%s%s", path[i], filename[i]);

				if(StrContains(pathFull[i], ".mdl", false) != -1)
				{
					PrecacheModel(pathFull[i], true);
				}

				AddFileToDownloadsTable(pathFull[i]);

				//PrintToServer("%s", pathFull[i]);
			}
		}

		delete dir;
	}

	PrecacheModel("models/effects/combineball.mdl", true);

	//g_turbophysics = FindConVar("sv_turbophysics"); //thnaks to maru.

	//RecalculatePoints();

	for(int i = 1; i <= MAXPLAYERS; i++)
	{
		g_pingTimer[i] = INVALID_HANDLE;
	}

	g_top10ac = 0.0;

	delete g_kv;
	g_kv = new KeyValues("TrueExpertHud");
	g_kv.ImportFromFile("addons/sourcemod/configs/trueexpert_hud.cfg");

	return;
}

public void SQLRecalculatePoints_GetMap(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints_GetMap: %s", error);
	}

	else if(strlen(error) == 0)
	{
		while(results.FetchRow() == true)
		{
			char map[192] = "";
			results.FetchString(0, map, sizeof(map));

			char query[512] = "";
			Format(query, sizeof(query), "SELECT (SELECT COUNT(*) FROM records WHERE map = '%s' AND time != 0), (SELECT tier FROM tier WHERE map = '%s'), id FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC", map, map, map); //https://stackoverflow.com/questions/38104018/select-and-count-rows-in-the-same-query
			g_mysql.Query(SQLRecalculatePoints, query, _, DBPrio_Normal);
		}
	}

	return;
}

public void SQLRecalculatePoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int place = 0;

		char query[512] = "";

		while(results.FetchRow() == true)
		{
			int points = results.FetchInt(1) * results.FetchInt(0) / ++place; //thanks to DeadSurfer //https://1drv.ms/u/s!Aq4KvqCyYZmHgpM9uKBA-74lYr2L3Q
			Format(query, sizeof(query), "UPDATE records SET points = %i WHERE id = %i LIMIT 1", points, results.FetchInt(2));
			g_queryLast++;
			g_mysql.Query(SQLRecalculatePoints2, query, _, DBPrio_Normal);
		}
	}

	return;
}

public void SQLRecalculatePoints2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(g_queryLast-- && g_queryLast == 0)
		{
			g_mysql.Query(SQLRecalculatePoints3, "SELECT steamid FROM users", _, DBPrio_Normal);
		}
	}

	return;
}

public void SQLRecalculatePoints3(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints3: %s", error);
	}

	else if(strlen(error) == 0)
	{
		while(results.FetchRow() == true)
		{
			char query[512] = "";
			Format(query, sizeof(query), "SELECT MAX(points) FROM records WHERE (playerid = %i OR partnerid = %i) GROUP BY map", results.FetchInt(0), results.FetchInt(0)); //https://1drv.ms/u/s!Aq4KvqCyYZmHgpFWHdgkvSKx0wAi0w?e=7eShgc
			g_mysql.Query(SQLRecalculateUserPoints, query, results.FetchInt(0), DBPrio_Normal);
		}
	}

	return;
}

public void SQLRecalculateUserPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculateUserPoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int points = 0;

		while(results.FetchRow() == true)
		{
			points += results.FetchInt(0);
		}

		char query[512] = "";
		Format(query, sizeof(query), "UPDATE users SET points = %i WHERE steamid = %i LIMIT 1", points, data);
		g_queryLast++;
		g_mysql.Query(SQLUpdateUserPoints, query, _, DBPrio_Normal);
	}

	return;
}

public void SQLUpdateUserPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUpdateUserPoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			if(g_queryLast-- && g_queryLast == 0)
			{
				g_mysql.Query(SQLGetPointsMaxs, "SELECT points FROM users ORDER BY points DESC LIMIT 1", _, DBPrio_Normal);
			}
		}
	}

	return;
}

public void SQLGetPointsMaxs(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetPointsMaxs: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			g_pointsMaxs = results.FetchInt(0);

			char query[512] = "";

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsFakeClient(i) == false)
				{
					int steamid = GetSteamAccountID(i);
					Format(query, sizeof(query), "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid);
					g_mysql.Query(SQLGetPoints, query, GetClientSerial(i), DBPrio_Normal);
				}
			}
		}
	}

	return;
}

public void OnMapEnd()
{
	float sourcetvCV = gCV_sourceTV.FloatValue;

	if(sourcetvCV == 1.0)
	{
		ConVar CV_sourcetv = FindConVar("tv_enable");

		bool sourcetv = CV_sourcetv.BoolValue;

		if(sourcetv == true)
		{
			ServerCommand("tv_stoprecord");

			char filenameOld[256] = "";
			Format(filenameOld, sizeof(filenameOld), "%s-%s-%s.dem", g_date, g_time, g_map);

			if(g_ServerRecord == true)
			{
				char filenameNew[256] = "";
				Format(filenameNew, sizeof(filenameNew), "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map);

				RenameFile(filenameNew, filenameOld);

				g_ServerRecord = false;
			}

			else if(g_ServerRecord == false)
			{
				DeleteFile(filenameOld);
			}
		}
	}

	return;
}

public Action OnSayMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	int client = msg.ReadByte();

	msg.ReadByte();

	char msgBuffer[32] = "";
	msg.ReadString(msgBuffer, sizeof(msgBuffer));

	char name[MAX_NAME_LENGTH] = "";
	msg.ReadString(name, sizeof(name));

	char text[256] = "";
	msg.ReadString(text, sizeof(text));

	if(g_msg[client] == false)
	{
		return Plugin_Handled;
	}

	g_msg[client] = false;

	char msgFormated[32] = "";
	Format(msgFormated, sizeof(msgFormated), "%s", msgBuffer);

	char points[32] = "";
	GetPoints(client, points);

	int team = GetClientTeam(client);

	if(StrEqual(msgBuffer, "Cstrike_Chat_AllSpec", false) == true)
	{
		Format(text, sizeof(text), "\x01*%T* [%s] \x07CCCCCC%s \x01:  %s", "Spec", client, points, name, text); //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L566
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_AllSpec", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_Spec", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x07CCCCCC%s \x01:  %s", "Spectator", client, points, name, text);
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_Spec", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_All", false) == true)
	{
		if(team == CS_TEAM_T)
		{
			Format(text, sizeof(text), "\x01[%s] \x07FF4040%s \x01:  %s", points, name, text); //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L638
			//Format(text, sizeof(text), "%T", "Cstrike_Chat_All", client, points, name, text);
		}

		else if(team == CS_TEAM_CT)
		{
			Format(text, sizeof(text), "\x01[%s] \x0799CCFF%s \x01:  %s", points, name, text); //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L513
			//Format(text, sizeof(text), "%T", "Cstrike_Chat_All2", client, points, name, text);
		}
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_AllDead", false) == true)
	{
		if(team == CS_TEAM_T)
		{
			Format(text, sizeof(text), "\x01*%T* [%s] \x07FF4040%s \x01:  %s", "Dead", client, points, name, text);
			//Format(text, sizeof(text), "%T", "Cstrike_Chat_AllDead", client, points, name, text);
		}

		else if(team == CS_TEAM_CT)
		{
			Format(text, sizeof(text), "\x01*%T* [%s] \x0799CCFF%s \x01:  %s", "Dead", client, points, name, text);
			//Format(text, sizeof(text), "%T", "Cstrike_Chat_AllDead2", client, points, name, text);
		}
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x0799CCFF%s \x01:  %s", "Counter-Terrorist", client, points, name, text);
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_CT", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT_Dead", false) == true)
	{
		Format(text, sizeof(text), "\x01*%T*(%T) [%s] \x0799CCFF%s \x01:  %s", "Dead", client, "Counter-Terrorist", client, points, name, text);
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_CT_Dead", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_T", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x07FF4040%s \x01:  %s", "Terrorist", client, points, name, text); //https://forums.alliedmods.net/showthread.php?t=185016
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_T", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_T_Dead", false) == true)
	{
		Format(text, sizeof(text), "\x01*%T*(%T) [%s] \x07FF4040%s \x01:  %s", "Dead", client, "Terrorist", client, points, name, text);
		//Format(text, sizeof(text), "%T", "Cstrike_Chat_T_Dead", client, points, name, text);
	}

	DataPack dp = new DataPack();
	dp.WriteCell(GetClientSerial(client));
	dp.WriteCell(StrContains(msgBuffer, "_All") != -1);
	dp.WriteString(text);
	RequestFrame(frame_SayText2, dp);

	return Plugin_Handled;
}

public void frame_SayText2(DataPack dp)
{
	dp.Reset();

	int client = GetClientFromSerial(dp.ReadCell());

	bool allchat = dp.ReadCell();

	char text[256] = "";
	dp.ReadString(text, sizeof(text));

	delete dp;

	if(IsValidClient(client) == true)
	{
		int clients[MAXPLAYER] = {0, ...};
		int count = 0;
		int team = GetClientTeam(client);

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && (allchat == true || GetClientTeam(i) == team))
			{
				clients[count++] = i;
			}
		}

		Handle SayText2 = StartMessage("SayText2", clients, count, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		BfWrite bfmsg = UserMessageToBfWrite(SayText2);
		bfmsg.WriteByte(client);
		bfmsg.WriteByte(true);
		bfmsg.WriteString(text);
		EndMessage();

		g_msg[client] = true;
	}

	return;
}

public Action OnRadioMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) //RadioText https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/server/cstrike/cs_player.cpp#L3944
{
	int dest = msg.ReadByte();
	int client = msg.ReadByte();

	char message[256] = "";
	msg.ReadString(message, sizeof(message), false);

	char param1[256] = "";
	msg.ReadString(param1, sizeof(param1), false);

	char param2[256] = "";
	msg.ReadString(param2, sizeof(param2), false);

	char param3[256] = "";
	msg.ReadString(param3, sizeof(param3), false);

	char param4[256] = "";
	msg.ReadString(param4, sizeof(param4), false);

	DataPack dp = new DataPack();
	dp.WriteCell(dest);
	dp.WriteCell(client);
	dp.WriteString(message);
	dp.WriteString(param1);
	dp.WriteString(param2);
	dp.WriteString(param3);
	dp.WriteString(param4);
	RequestFrame(rf_radiotxt, dp);

	return Plugin_Handled;
}

public void rf_radiotxt(DataPack dp)
{
	dp.Reset();

	int dest = dp.ReadCell();
	int client = dp.ReadCell();

	char message[256] = "";
	dp.ReadString(message, sizeof(message));

	char param1[256] = "";
	dp.ReadString(param1, sizeof(param1));

	char param2[256] = "";
	dp.ReadString(param2, sizeof(param2));

	char param3[256] = "";
	dp.ReadString(param3, sizeof(param3));

	char param4[256] = "";
	dp.ReadString(param4, sizeof(param4));

	delete dp;

	char points[32] = "";
	GetPoints(client, points);

	ReplaceString(message, sizeof(message), "#", "", true);
	ReplaceString(param2, sizeof(param2), "#Cstrike_TitlesTXT_", "", true);

	Format(message, sizeof(message), "\x01[%s] \x03%s\x01 %T: %T", points, param1, message, client, param2, client);

	if(client > 0 && IsClientInGame(client) == true)
	{
		int clients[MAXPLAYER] = {0, ...};
		int count = 0;

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsFakeClient(i) == false)
			{
				clients[count++] = i;
			}
		}

		Handle RadioText = StartMessage("RadioText", clients, count, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		BfWrite bfmsg = UserMessageToBfWrite(RadioText);
		bfmsg.WriteByte(dest);
		bfmsg.WriteByte(client);
		bfmsg.WriteString(message);
		bfmsg.WriteString(param1);
		bfmsg.WriteString(param2);
		bfmsg.WriteString(param3);
		bfmsg.WriteString(param4);
		EndMessage();
	}

	return;
}

public void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	char model[PLATFORM_MAX_PATH] = "";
	GetClientModel(client, model, PLATFORM_MAX_PATH);

	if(StrEqual(model, "models/player/ct_urban.mdl", false) == true)
	{
		g_class[client] = 1;
	}

	else if(StrEqual(model, "models/player/ct_gsg9.mdl", false) == true)
	{
		g_class[client] = 2;
	}

	else if(StrEqual(model, "models/player/ct_sas.mdl", false) == true)
	{
		g_class[client] = 3;
	}

	else if(StrEqual(model, "models/player/ct_gign.mdl", false) == true)
	{
		g_class[client] = 4;
	}

	SetEntProp(client, Prop_Data, "m_nModelIndex", g_wModelPlayer[g_class[client]], 4, 0);
	SetEntProp(client, Prop_Data, "m_nSkin", g_skinPlayer[client], 4, 0);

	SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], 255);

	SetEntityRenderMode(client, RENDER_TRANSALPHA); //maru is genius person who fix this bug. thanks maru for idea.

	if(g_devmap == false && g_clantagOnce[client] == false)
	{
		CS_GetClientClanTag(client, g_clantag[client][0], 256);
		g_clantagOnce[client] = true;
	}

	return;
}

public void OnButton(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator) == true && GetClientButtons(activator) & IN_USE)
	{
		bool button = gCV_button.BoolValue;

		if(g_button[activator] == true && button == true)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "YouPressedButton", activator);
			SendMessage(activator, format);
		}

		bool pbutton = gCV_pbutton.BoolValue;

		if(g_pbutton[g_partner[activator]] == true && pbutton == true)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "YourPartnerPressedButton", g_partner[activator]);
			SendMessage(g_partner[activator], format);
		}
	}

	return;
}

public void OnJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	g_skyOrigin[client] = GetGroundPos(client);
	g_skyAble[client] = GetGameTime();

	GetClientAbsOrigin(client, g_mlsDistance[client][0]);

	return;
}

public void OnDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll", 0);

	char log[256] = "";
	GetEntityClassname(ragdoll, log, sizeof(log));

	if(StrEqual(log, "cs_ragdoll", false) == false)
	{
		LogMessage("OnDeath: %s", log);
	}

	RemoveEntity(ragdoll);

	if(IsValidPartner(client) == true)
	{
		int partner = g_partner[client];

		g_partner[partner] = 0;
		g_partner[client] = 0;

		if(g_menuOpened[client] == true)
		{
			Trikz(client);
		}

		if(g_menuOpened[partner] == true)
		{
			Trikz(partner);
		}

		ResetFactory(client);
		ResetFactory(partner);
	}

	return;
}

public void OnTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int team = event.GetInt("team");

	if(team == CS_TEAM_SPECTATOR && IsValidPartner(client) == true)
	{
		int partner = g_partner[client];

		g_partner[partner] = 0;
		g_partner[client] = 0;

		if(g_menuOpened[client] == true)
		{
			Trikz(client);
		}

		if(g_menuOpened[partner] == true)
		{
			Trikz(partner);
		}

		ResetFactory(client);
		ResetFactory(partner);
	}

	return;
}

public Action joinclass(int client, const char[] command, int argc)
{
	CreateTimer(1.0, timer_respawn, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action timer_respawn(Handle timer, int client)
{
	if(IsClientInGame(client) == true && GetClientTeam(client) != CS_TEAM_SPECTATOR && IsPlayerAlive(client) == false)
	{
		CS_RespawnPlayer(client);
	}

	return Plugin_Stop;
}

public Action autobuy(int client, const char[] command, int argc)
{
	Block(client);

	g_silentF1F2 = true;

	return Plugin_Continue;
}

public Action rebuy(int client, const char[] command, int argc)
{	
	if(g_menuOpened[client] == false)
	{
		Trikz(client);
	}

	g_silentF1F2 = true;

	return Plugin_Continue;
}

public Action cheer(int client, const char[] command, int argc)
{
	if(IsValidPartner(client) == true)
	{
		Partner(client);
	}

	return Plugin_Continue; //happy holliday.
}

public Action showbriefing(int client, const char[] command, int argc)
{
	Control(client);

	return Plugin_Continue;
}

public void Control(int client)
{
	Menu menu = new Menu(menu_info_handler);

	menu.SetTitle("Control");

	menu.AddItem("top", "!top", gCV_top.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("top10", "!top10", gCV_top10.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("js", "!js", LibraryExists("trueexpert-jumpstats") == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("bs", "!bs", LibraryExists("trueexpert-booststats") == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("hud", "!hud", gCV_hud.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("button", "!button", gCV_button.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("pbutton", "!pbutton", gCV_pbutton.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("spec", "!spec", gCV_spec.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("color", "!color", gCV_color.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("afk", "!afk", gCV_afk.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.AddItem("trikz", "!trikz", gCV_trikz.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	menu.Display(client, 20);

	return;
}

public int menu_info_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					cmd_top(param1, 0);
				}

				case 1:
				{
					Top10(param1);
				}

				case 2:
				{
					FakeClientCommandEx(param1, "sm_js"); //faster cooamnd respond
				}

				case 3:
				{
					FakeClientCommandEx(param1, "sm_bs"); //faster command respond
				}

				case 4:
				{
					cmd_hud(param1, 0);
				}

				case 5:
				{
					cmd_button(param1, 0);
				}

				case 6:
				{
					cmd_pbutton(param1, 0);
				}

				case 7:
				{
					cmd_spec(param1, 0);
				}

				case 8:
				{
					ColorSelect(param1);
				}

				case 9:
				{
					cmd_afk(param1, 0);
				}

				case 10:
				{
					Trikz(param1);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action headtrack_reset_home_pos(int client, const char[] command, int argc)
{
	bool color = gCV_color.BoolValue;
	
	if(color == true)
	{
		Partner(client);
	}

	return Plugin_Continue;
}

/*public void output_teleport(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
	{
		g_teleported[activator] = true;
	}
}*/

public Action cmd_checkpoint(int client, int args)
{
	bool checkpoint = gCV_checkpoint.BoolValue;

	if(checkpoint == false)
	{
		return Plugin_Continue;
	}

	Checkpoint(client);

	return Plugin_Handled;
}

public void Checkpoint(int client)
{
	if(g_devmap == true)
	{
		Menu menu = new Menu(checkpoint_handler);
		menu.SetTitle("%T", "Checkpoint", client);

		char format[256] = "";
		Format(format, sizeof(format), "%T", "CP-save", client);
		menu.AddItem("Save", format);
		Format(format, sizeof(format), "%T", "CP-teleport", client);
		menu.AddItem("Teleport", format, g_cpToggled[client][0] == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		Format(format, sizeof(format), "%T", "CP-saveSecond", client);
		menu.AddItem("Save second", format);
		Format(format, sizeof(format), "%T", "CP-teleportSecond", client);
		menu.AddItem("Teleport second", format, g_cpToggled[client][1] == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
		menu.Display(client, MENU_TIME_FOREVER);
	}

	else if(g_devmap == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
		SendMessage(client, format);
	}

	return;
}

public int checkpoint_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					GetClientAbsOrigin(param1, g_cpOrigin[param1][0]);

					GetClientEyeAngles(param1, g_cpAng[param1][0]); //https://github.com/Smesh292/trikz/blob/main/checkpoint.sp#L101

					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", g_cpVel[param1][0], 0);

					if(g_cpToggled[param1][0] == false)
					{
						g_cpToggled[param1][0] = true;
					}
				}

				case 1:
				{
					TeleportEntity(param1, g_cpOrigin[param1][0], g_cpAng[param1][0], g_cpVel[param1][0]);
				}

				case 2:
				{
					GetClientAbsOrigin(param1, g_cpOrigin[param1][1]);

					GetClientEyeAngles(param1, g_cpAng[param1][1]);

					GetEntPropVector(param1, Prop_Data, "m_vecAbsVelocity", g_cpVel[param1][1], 0);

					if(g_cpToggled[param1][1] == false)
					{
						g_cpToggled[param1][1] = true;
					}
				}

				case 3:
				{
					TeleportEntity(param1, g_cpOrigin[param1][1], g_cpAng[param1][1], g_cpVel[param1][1]);
				}
			}

			Checkpoint(param1);
		}

		case MenuAction_Cancel: // trikz redux menuaction end
		{
			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
				{
					Trikz(param1);
				}
			}
		}
	}

	return view_as<int>(action);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage);
	SDKHook(client, SDKHook_StartTouch, SDKSkyFix);
	SDKHook(client, SDKHook_PostThinkPost, SDKBoostFix); //idea by tengulawl/scripting/blob/master/boost-fix tengulawl github.com
	SDKHook(client, SDKHook_WeaponEquipPost, SDKWeaponEquip);
	SDKHook(client, SDKHook_WeaponDrop, SDKWeaponDrop);

	if(IsClientInGame(client) == true && g_dbPassed == true)
	{
		g_mysql.Query(SQLAddUser, "SELECT id FROM users LIMIT 1", GetClientSerial(client), DBPrio_High);

		char query[512] = "";
		int steamid = GetSteamAccountID(client);
		Format(query, sizeof(query), "SELECT time FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s' ORDER BY time ASC LIMIT 1", steamid, steamid, g_map);
		g_mysql.Query(SQLGetPersonalRecord, query, GetClientSerial(client), DBPrio_Normal);
	}

	g_menuOpened[client] = false;
	g_menuOpenedHud[client] = false;

	for(int i = 0; i <= 1; i++)
	{
		g_cpToggled[client][i] = false;

		for(int j = 0; j <= 2; j++)
		{
			g_cpOrigin[client][i][j] = 0.0;

			g_cpAng[client][i][j] = 0.0;

			g_cpVel[client][i][j] = 0.0;
		}
	}

	g_block[client] = true;
	//g_timerTime[client] = 0.0;

	if(g_devmap == false && g_zoneHave[0] == true && g_zoneHave[1] == true && g_zoneDrawed[client] == false)
	{
		DrawZone(client, 0.0, 3.0, 10);

		g_zoneDrawed[client] = true;
	}

	g_msg[client] = true;

	if(AreClientCookiesCached(client) == false)
	{
		g_hudVel[client] = false;
		g_mlstats[client] = false;
		g_button[client] = false;
		g_pbutton[client] = false;
		g_autoflash[client] = false;
		g_autoswitch[client] = false;
		g_bhop[client] = false;
		g_macroDisabled[client] = true;
		g_endMessage[client] = true;
		g_skinFlashbang[client] = 0;
	}

	ResetFactory(client);
	g_points[client] = 0;

	g_clantagOnce[client] = false;
	g_macroOpened[client] = false;

	if(IsClientSourceTV(client) == false) //this should provides a crash if reload plugin (DHookEntity). https://issuehint.com/issue/alliedmodders/sourcemod/1688
	{
		if(g_teleport != null)
		{
			DHookEntity(g_teleport, true, client);
		}
	}

	if(g_colorBuffer[client][0][0] == 0 && g_colorBuffer[client][0][1] == 0 && g_colorBuffer[client][0][2] == 0)
	{
		for(int i = 0; i <= 2; i++)
		{
			g_colorBuffer[client][0][i] = 255;
		}
	}

	return;
}

public void OnClientCookiesCached(int client)
{
	char value[16] = "";

	GetClientCookie(client, g_cookie[0], value, sizeof(value));
	g_hudVel[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[1], value, sizeof(value));
	g_mlstats[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[2], value, sizeof(value));
	g_button[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[3], value, sizeof(value));
	g_pbutton[client] = view_as<bool>(StringToInt(value));
	
	GetClientCookie(client, g_cookie[4], value, sizeof(value));
	g_autoflash[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[5], value, sizeof(value));
	g_autoswitch[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[6], value, sizeof(value));
	g_bhop[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[7], value, sizeof(value));
	g_macroDisabled[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[8], value, sizeof(value));
	g_endMessage[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[9], value, sizeof(value));
	g_skinFlashbang[client] = view_as<bool>(StringToInt(value));

	GetClientCookie(client, g_cookie[10], value, sizeof(value));

	char exploded[4][16];
	ExplodeString(value, ";", exploded, 4, 16);

	for(int i = 0; i <= 2; i++)
	{
		g_colorBuffer[client][1][i] = StringToInt(exploded[i]);
	}

	g_colorCount[client][1] = StringToInt(exploded[3]);

	if(g_colorBuffer[client][1][0] == 0 && g_colorBuffer[client][1][1] == 0 && g_colorBuffer[client][1][2] == 0)
	{
		for(int i = 0; i <= 2; i++)
		{
			g_colorBuffer[client][1][i] = 255;
		}
	}

	GetClientCookie(client, g_cookie[11], value, sizeof(value));
	g_skinPlayer[client] = view_as<bool>(StringToInt(value));

	GiveFlashbang(client);

	if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return;
}

public void OnClientDisconnect(int client)
{
	ColorTeam(client, false);

	int partner = g_partner[client];
	g_partner[partner] = 0;

	if(IsValidPartner(client) == true && g_menuOpened[partner] == true)
	{
		Trikz(partner);
	}

	g_partner[client] = 0;

	int entity = 0;

	while((entity = FindEntityByClassname(entity, "weapon_*")) != INVALID_ENT_REFERENCE) //https://github.com/shavitush/bhoptimer/blob/de1fa353ff10eb08c9c9239897fdc398d5ac73cc/addons/sourcemod/scripting/shavit-misc.sp#L1104-L1106
	{
		if(GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0) == client)
		{
			RemoveEntity(entity);
		}
	}

	if(g_devmap == false && IsValidPartner(client) == true && IsFakeClient(client) == false)
	{
		ResetFactory(partner);
	}

	for(int i = 0; i <= 1; i++)
	{
		g_flashbangDoor[client][i] = false;
	}

	g_zoneDrawed[client] = false;

	return;
}

public void SQLAddUser(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLAddUser: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			char query[512] = ""; //https://forums.alliedmods.net/showthread.php?t=261378
			int steamid = GetSteamAccountID(client);

			if(results.FetchRow() == false)
			{
				Format(query, sizeof(query), "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES (\"%N\", %i, %i, %i)", client, steamid, GetTime(), GetTime());
				g_mysql.Query(SQLUserAdded, query, _, DBPrio_Normal);

				#if debug == true
				PrintToServer("SQLAddUser: User (%N) trying to add to database...", client);
				#endif

				return;
			}

			results.Rewind();

			if(results.FetchRow() == true)
			{
				Format(query, sizeof(query), "SELECT steamid FROM users WHERE steamid = %i LIMIT 1", steamid);
				g_mysql.Query(SQLUpdateUser, query, GetClientSerial(client), DBPrio_High);

				#if debug == true
				PrintToServer("SQLAddUser: User (%N) selecting...", client);
				#endif
			}
		}
	}

	return;
}

public void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUserAdded: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug == true
		PrintToServer("SQLUserAdded: Successfuly added user.");
		#endif
	}

	return; //void function return nothing. Here code will be escape and below code will be skiped in this function part.
}

public void SQLUpdateUser(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUpdateUser: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			char query[512] = "";
			int steamid = GetSteamAccountID(client);

			if(results.FetchRow() == false)
			{
				Format(query, sizeof(query), "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES (\"%N\", %i, %i, %i)", client, steamid, GetTime(), GetTime());
			}

			results.Rewind();

			if(results.FetchRow() == true)
			{
				Format(query, sizeof(query), "UPDATE users SET username = \"%N\", lastjoin = %i WHERE steamid = %i LIMIT 1", client, GetTime(), steamid);
			}

			g_mysql.Query(SQLUpdateUserSuccess, query, GetClientSerial(client), DBPrio_High);

			#if debug == true
			//PrintToServer("SQLUpdateUser: Successfuly updated user");
			PrintToServer("SQLUpdateUser: User (%N) updating...", client);
			#endif
		}
	}

	return; //void return nothing
}

public void SQLUpdateUserSuccess(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUpdateUserSuccess: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			if(results.HasResults == false)
			{
				char query[512] = "";
				int steamid = GetSteamAccountID(client);
				Format(query, sizeof(query), "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid);
				g_mysql.Query(SQLGetPoints, query, GetClientSerial(client), DBPrio_High);

				#if debug == true
				PrintToServer("SQLUpdateUserSuccess: Successfuly updated user");
				#endif
			}
		}
	}

	return;
}

public void SQLGetPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetPoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true && results.FetchRow() == true)
		{
			g_points[client] = results.FetchInt(0);
		}
	}

	return;
}

public void SQLGetServerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetServerRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == false)
		{
			g_ServerRecordTime = 0.0;

			return;
		}

		results.Rewind();

		if(results.FetchRow() == true)
		{
			g_ServerRecordTime = results.FetchFloat(0);
		}
	}

	return;
}

public void SQLGetPersonalRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetPersonalRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			if(results.FetchRow() == false)
			{
				g_haveRecord[client] = 0.0;

				return;
			}

			results.Rewind();

			if(results.FetchRow() == true)
			{
				g_haveRecord[client] = results.FetchFloat(0);
			}
		}
	}

	return;
}

public Action SDKSkyFix(int client, int other) //client = booster; other = flyer
{
	bool boostfix = gCV_boostfix.BoolValue;

	if(boostfix == true)
	{
		if(IsValidClient(client) == true && IsValidClient(other) == true && !(GetClientButtons(other) & IN_DUCK) && g_entityButtons[other] & IN_JUMP && GetEngineTime() - g_boostTime[client] > 0.15 && g_skyBoost[other] == 0)
		{
			float originBooster[3] = {0.0, ...};
			GetClientAbsOrigin(client, originBooster);

			float originFlyer[3] = {0.0, ...};
			GetClientAbsOrigin(other, originFlyer);

			float maxsBooster[3] = {0.0, ...};
			GetClientMaxs(client, maxsBooster); //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71

			float delta = originFlyer[2] - originBooster[2] - maxsBooster[2];

			if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
			{
				float velBooster[3] = {0.0, ...};
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velBooster, 0);

				if(velBooster[2] > 0.0)
				{
					float velFlyer[3] = {0.0, ...};
					GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", velFlyer, 0);

					g_skyVel[other][0] = velFlyer[0];
					g_skyVel[other][1] = velFlyer[1];
					g_skyVel[other][2] = velBooster[2] * 3.572;

					//PrintToServer("b: %f f: %f", velBooster[2], velFlyer[2]);

					if(g_entityFlags[client] & FL_INWATER)
					{
						g_skyVel[other][2] = velBooster[2] * 5.0;
					}
					
					else if(!(g_entityFlags[client] & FL_INWATER))
					{
						if(velFlyer[2] > -470.0)
						{
							if(g_skyVel[other][2] >= 770.0)
							{
								g_skyVel[other][2] = 770.0;
							}
						}

						else if(velFlyer[2] <= -470.0)
						{
							if(g_skyVel[other][2] >= 800.0)
							{
								g_skyVel[other][2] = 800.0;
							}
						}
					}

					#if debug == true
					PrintToServer("b: %f f: %f", velBooster[2], velFlyer[2]);
					#endif

					if(FloatAbs(g_skyOrigin[client] - g_skyOrigin[other]) > 0.0 || GetGameTime() - g_skyAble[other] > 0.5)
					{
						g_skyBoost[other] = 1;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void SDKBoostFix(int client)
{
	bool boostfix = gCV_boostfix.BoolValue;

	if(boostfix == true)
	{
		if(g_boost[client] == 1)
		{
			int entity = EntRefToEntIndex(g_flash[client]);

			#if debug == true
			PrintToServer("%i", entity);
			#endif

			if(entity != INVALID_ENT_REFERENCE)
			{
				float velEntity[3] = {0.0, ...};
				GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", velEntity, 0);

				if(velEntity[2] > 0.0)
				{
					velEntity[0] *= 0.135;
					velEntity[1] *= 0.135;
					velEntity[2] *= -0.135;

					TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, velEntity);
				}

				g_boost[client] = 2; //Trijās vietās kodā atrodas paātrināšana pēc Antona vārdiem.

				#if debug == true
				PrintToServer("1x");
				#endif
			}
		}
	}

	return;
}

public Action cmd_trikz(int client, int args)
{
	bool trikz = gCV_trikz.BoolValue;

	if(trikz == false)
	{
		return Plugin_Continue;
	}

	if(g_menuOpened[client] == false)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

public void Trikz(int client)
{
	g_menuOpened[client] = true;

	Menu menu = new Menu(trikz_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End); //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	menu.SetTitle("%T", "Trikz", client);

	char format[256] = "";
	Format(format, sizeof(format), "%T", g_block[client] == true ? "BlockMenuON" : "BlockMenuOFF", client);
	menu.AddItem("block", format);
	Format(format, sizeof(format), "%T", g_autoflash[client] == true ? "AutoflashMenuON" : "AutoflashMenuOFF", client);
	menu.AddItem("autoflash", format);
	Format(format, sizeof(format), "%T", g_autoswitch[client] == true ? "AutoswitchMenuON" : "AutoswitchMenuOFF", client);
	menu.AddItem("autoswitch", format);
	Format(format, sizeof(format), "%T", g_bhop[client] == true ? "BhopMenuON" : "BhopMenuOFF", client);
	menu.AddItem("bhop", format);

	if(g_devmap == false)
	{
		Format(format, sizeof(format), "%T", IsValidPartner(client) == true ? "Breakup" : "Partner", client);
		menu.AddItem(IsValidPartner(client) == true ? "breakup" : "partner", format, ITEMDRAW_DEFAULT);
	}

	Format(format, sizeof(format), "%T", "Color", client);
	menu.AddItem("color", format);

	if(g_devmap == false)
	{
		Format(format, sizeof(format), "%T", "Restart", client);
		menu.AddItem("restart", format, IsValidPartner(client) == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	if(g_devmap == true)
	{
		Format(format, sizeof(format), "%T", GetEntityMoveType(client) == MOVETYPE_NOCLIP ? "NoclipMenuON" : "NoclipMenuOFF", client);
		menu.AddItem("noclip", format);
		Format(format, sizeof(format), "%T", "Checkpoint", client);
		menu.AddItem("checkpoint", format);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

public int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
		{
			g_menuOpened[param1] = true;
		}

		case MenuAction_Select:
		{
			char item[64] = "";
			menu.GetItem(param2, item, sizeof(item));

			if(StrEqual(item, "block", true) == true)
			{
				Block(param1);
			}

			else if(StrEqual(item, "autoflash", true) == true)
			{
				cmd_autoflash(param1, 0);
			}

			else if(StrEqual(item, "autoswitch", true) == true)
			{
				cmd_autoswitch(param1, 0);
			}

			else if(StrEqual(item, "bhop", true) == true)
			{
				cmd_bhop(param1, 0);
			}

			else if(StrEqual(item, "breakup", true) == true || StrEqual(item, "partner", true) == true)
			{
				g_menuOpened[param1] = false;
				Partner(param1);
			}

			else if(StrEqual(item, "color", true) == true)
			{
				g_menuOpened[param1] = false;
				ColorSelect(param1);
			}

			else if(StrEqual(item, "restart", true) == true)
			{
				g_menuOpened[param1] = false;
				Restart(param1, true);
			}

			else if(StrEqual(item, "noclip", true) == true)
			{
				Noclip(param1);
			}

			else if(StrEqual(item, "checkpoint", true) == true)
			{
				g_menuOpened[param1] = false;
				Checkpoint(param1);
			}
		}

		case MenuAction_Cancel:
		{
			g_menuOpened[param1] = false; //idea from expert zone.
		}

		case MenuAction_Display:
		{
			g_menuOpened[param1] = true;
		}

		case MenuAction_End:
		{
			delete menu; //https://forums.alliedmods.net/showpost.php?p=2293089&postcount=8
		}
	}

	return view_as<int>(action);
}

public Action cmd_block(int client, int args)
{
	bool block = gCV_block.BoolValue;

	if(block == false)
	{
		return Plugin_Continue;
	}

	Block(client);

	return Plugin_Handled;
}

public Action Block(int client) //thanks maru for optimization.
{
	g_block[client] = !g_block[client];

	SetEntityCollisionGroup(client, g_block[client] == true ? 5 : 2);

	SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[client] == true ? 255 : 125);

	if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	else if(g_menuOpened[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_block[client] == true ? "BlockChatON" : "BlockChatOFF", client);
		SendMessage(client, format);
	}

	return Plugin_Handled;
}

public Action cmd_partner(int client, int args)
{
	bool partner = gCV_partner.BoolValue;

	if(partner == false)
	{
		return Plugin_Continue;
	}

	Partner(client);

	return Plugin_Handled;
}

stock void Partner(int client)
{
	if(g_devmap == true)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
		SendMessage(client, format);
	}

	else if(g_devmap == false)
	{
		if(IsPlayerAlive(client) == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "YouAreDead", client);
			SendMessage(client, format);

			return;
		}

		if(g_dbPassed == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "Wait for database loading...");
			SendMessage(client, format);

			return;
		}

		if(IsValidPartner(client) == false)
		{
			Menu menu = new Menu(partner_handler);
			menu.SetTitle("%T", "ChoosePartner", client);

			char name[MAX_NAME_LENGTH] = "";
			bool player = false;

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsFakeClient(i) == false && IsPlayerAlive(i) == true) //https://github.com/Figawe2/trikz-plugin/blob/master/scripting/trikz.sp#L635 i copy it from denwo and save in github sorry denwo i lost password.
				{
					if(client != i && g_partner[i] == 0)
					{
						GetClientName(i, name, sizeof(name));

						char nameID[8] = "";
						IntToString(i, nameID, sizeof(nameID));
						menu.AddItem(nameID, name);

						player = true;
					}
				}
			}

			switch(player)
			{
				case false:
				{
					char format[256] = "";
					Format(format, sizeof(format), "%T", "NoFreePlayer", client);
					SendMessage(client, format);
				}

				case true:
				{
					menu.Display(client, 20);
				}
			}
			
		}

		else if(IsValidPartner(client) == true)
		{			
			Menu menu = new Menu(cancelpartner_handler);

			char name[MAX_NAME_LENGTH] = "";
			GetClientName(g_partner[client], name, sizeof(name));
			menu.SetTitle("%T", "CancelPartnership", client, name);

			char partner[8] = "";
			IntToString(g_partner[client], partner, sizeof(partner)); //do global integer to string.
			char format[256] = "";
			Format(format, sizeof(format), "%T", "Yes", client);
			menu.AddItem(partner, format);
			Format(format, sizeof(format), "%T", "No", client);
			menu.AddItem("", format);

			menu.Display(client, 20);
		}
	}

	return;
}

public int partner_handler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[8] = "";
			menu.GetItem(param2, item, sizeof(item));
			
			Menu menu2 = new Menu(askpartner_handle);

			char name[MAX_NAME_LENGTH] = "";
			GetClientName(param1, name, sizeof(name));

			int partner = StringToInt(item);
			menu2.SetTitle("%T", "AgreePartner", partner, name);
			
			char buffer[8] = "";
			IntToString(param1, buffer, sizeof(buffer));

			char format[256] = "";
			Format(format, sizeof(format), "%T", "Yes", partner);
			menu2.AddItem(buffer, format);
			Format(format, sizeof(format), "%T", "No", partner);
			menu2.AddItem(item, format);

			menu2.Display(partner, 20);
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public int askpartner_handle(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[8] = "";
			menu.GetItem(param2, item, sizeof(item));

			int partner = StringToInt(item);

			char format[256] = "";

			switch(param2)
			{
				case 0:
				{
					if(IsPlayerAlive(param1) == true)
					{
						if(IsValidPartner(partner) == false)
						{
							g_partner[param1] = partner;
							g_partner[partner] = param1;

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_OnPartner", ET_Hook, Param_Cell, Param_Cell);
							Call_StartForward(hForward);
							Call_PushCell(param1);
							Call_PushCell(partner);
							Call_Finish();
							delete hForward;

							char name[MAX_NAME_LENGTH] = "";
							GetClientName(partner, name, sizeof(name));
							Format(format, sizeof(format), "%T", "TeamConfirming", param1, name); //reciever
							PrintToConsole(param1, "%s", format);

							GetClientName(param1, name, sizeof(name));
							Format(format, sizeof(format), "%T", "GetConfirmed", partner, name); //sender
							SendMessage(partner, format);

							Restart(param1, false); //Expert-Zone idea.

							char query[512] = "";
							Format(query, sizeof(query), "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", GetSteamAccountID(param1), GetSteamAccountID(partner), GetSteamAccountID(partner), GetSteamAccountID(param1), g_map);
							g_mysql.Query(SQLGetPartnerRecord, query, GetClientSerial(param1), DBPrio_Normal);
						}

						else if(IsValidPartner(partner) == true)
						{
							Format(format, sizeof(format), "%T", "AlreadyHavePartner", param1);
							SendMessage(param1, format);
						}
					}

					else if(IsPlayerAlive(param1) == false)
					{
						Format(format, sizeof(format), "%T", "YouAreDead", param1);
						SendMessage(param1, format);
					}
				}

				case 1:
				{
					char name[MAX_NAME_LENGTH] = "";
					GetClientName(param1, name, sizeof(name));
					Format(format, sizeof(format), "%T", "PartnerDeclined", param1, name);
					PrintToConsole(param1, "%s", format);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public int cancelpartner_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[8] = "";
			menu.GetItem(param2, item, sizeof(item));

			int partner = StringToInt(item);

			switch(param2)
			{
				case 0:
				{
					ColorTeam(param1, false);

					g_partner[param1] = 0;
					g_partner[partner] = 0;

					static GlobalForward hForward = null;
					hForward = new GlobalForward("Trikz_OnBreakup", ET_Hook, Param_Cell, Param_Cell);
					Call_StartForward(hForward);
					Call_PushCell(param1);
					Call_PushCell(partner);
					Call_Finish();
					delete hForward;

					ResetFactory(param1);
					ResetFactory(partner);

					char name[MAX_NAME_LENGTH] = "";
					GetClientName(partner, name, sizeof(name));

					char format[256] = "";
					Format(format, sizeof(format), "%T", "PartnerCanceled", param1, name);
					PrintToConsole(param1, "%s", format);

					GetClientName(param1, name, sizeof(name));
					Format(format, sizeof(format), "%T", "PartnerCanceledBy", partner, name);
					SendMessage(partner, format);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action cmd_color(int client, int args)
{
	bool color = gCV_color.BoolValue;

	if(color == false)
	{
		return Plugin_Handled;
	}

	ColorSelect(client);

	return Plugin_Handled;
}

stock void ColorSelect(int client)
{
	Menu menu = new Menu(handler_menuColor);
	menu.SetTitle("%T", "Color", client);

	char format[256] = "";
	Format(format, sizeof(format), "%T", "ColorTeam", client);
	menu.AddItem("team_color", format);
	Format(format, sizeof(format), "%T", "PlayerSkin", client);
	menu.AddItem("player_skin", format);
	Format(format, sizeof(format), "%T", "ColorPingFL", client);
	menu.AddItem("object_color", format);
	Format(format, sizeof(format), "%T", "FlashbangSkin", client);
	menu.AddItem("flashbang_skin", format);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

public int handler_menuColor(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					ColorTeam(param1, true);
					ColorSelect(param1);
				}

				case 1:
				{
					PlayerSkin(param1);
				}

				case 2:
				{
					ColorFlashbang(param1);
					ColorSelect(param1);
				}

				case 3:
				{
					FlashbangSkin(param1);
				}
			}
		}

		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					Trikz(param1);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

stock void ColorTeam(int client, bool allowColor)
{
	if(IsClientInGame(client) == true && IsFakeClient(client) == false)
	{
		bool colorCV = gCV_color.BoolValue;

		if(colorCV == false)
		{
			return;
		}

		char format[256] = "";
		
		if(g_devmap == false && IsValidPartner(client) == false)
		{
			Format(format, sizeof(format), "%T", "DontHavePartner", client);
			SendMessage(client, format);

			return;
		}

		else if(g_devmap == true)
		{
			Format(format, sizeof(format), "%T", "DevmapIsON", client);
			SendMessage(client, format);

			return;
		}

		int partner = g_partner[client];

		if(allowColor == true)
		{
			g_colorCount[client][0]++;
			g_colorCount[partner][0]++;

			if(g_colorCount[client][0] == 9)
			{
				g_colorCount[client][0] = 0;
				g_colorCount[partner][0] = 0;
			}

			char colorTypeExploded[32][4];
			ExplodeString(g_colorType[g_colorCount[client][0]], ",", colorTypeExploded, 4, sizeof(colorTypeExploded));

			for(int i = 0; i <= 2; i++)
			{
				g_colorBuffer[client][0][i] = StringToInt(colorTypeExploded[i]);
				g_colorBuffer[partner][0][i] = StringToInt(colorTypeExploded[i]);
			}

			SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[client] == true ? 255 : 125);
			SetEntityRenderColor(partner, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[partner] == true ? 255 : 125);

			static GlobalForward hForward = null; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp
			hForward = new GlobalForward("Trikz_OnColorTeam", ET_Ignore, Param_Cell, Param_Cell, Param_Array);
			Call_StartForward(hForward);
			Call_PushCell(client);
			Call_PushCell(partner);
			Call_PushArray(g_colorBuffer[client][0], 3);
			Call_Finish();
			delete hForward;

			SetHudTextParams(-1.0, -0.3, 3.0, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], 255);

			ShowHudText(client, 5, "%s (TM)", colorTypeExploded[3]);
			ShowHudText(partner, 5, "%s (TM)", colorTypeExploded[3]);
		}

		else if(allowColor == false)
		{
			g_colorCount[client][0] = 0;
			g_colorCount[partner][0] = 0;
		
			for(int i = 0; i <= 2; i++)
			{
				g_colorBuffer[client][0][i] = 255;
				g_colorBuffer[partner][0][i] = 255;
			}

			SetEntityRenderColor(client, 255, 255, 255, g_block[client] == true ? 255 : 125);
			SetEntityRenderColor(partner, 255, 255, 255, g_block[partner] == true ? 255 : 125);
		}
	}

	return;
}

stock void ColorFlashbang(int client)
{
	if(IsClientInGame(client) == true && IsFakeClient(client) == false)
	{
		bool colorCV = gCV_color.BoolValue;

		if(colorCV == false)
		{
			return;
		}

		g_colorCount[client][1]++;

		if(g_colorCount[client][1] == 9)
		{
			g_colorCount[client][1] = 0;
		}

		char colorTypeExploded[32][4];
		ExplodeString(g_colorType[g_colorCount[client][1]], ",", colorTypeExploded, 4, sizeof(colorTypeExploded));

		for(int i = 0; i <= 2; i++)
		{
			g_colorBuffer[client][1][i] = StringToInt(colorTypeExploded[i]);
		}

		char value[16] = "";
		Format(value, sizeof(value), "%s;%s;%s;%i", colorTypeExploded[0], colorTypeExploded[1], colorTypeExploded[2], g_colorCount[client][1]);
		SetClientCookie(client, g_cookie[10], value);

		static GlobalForward hForward = null; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp
		hForward = new GlobalForward("Trikz_OnColorFlashbang", ET_Ignore, Param_Cell, Param_Array); //public void Trikz_OnColorFlashbang(int client, int red, int green, int blue)
		Call_StartForward(hForward);
		Call_PushCell(client);
		Call_PushArray(g_colorBuffer[client][1], 3);
		Call_Finish();
		delete hForward;

		SetHudTextParams(-1.0, -0.3, 3.0, g_colorBuffer[client][1][0], g_colorBuffer[client][1][1], g_colorBuffer[client][1][2], 255);

		ShowHudText(client, 5, "%s (FL)", colorTypeExploded[3]);
	}

	return;
}

public void SQLGetPartnerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetPartnerRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			if(results.FetchRow() == false)
			{
				g_teamRecord[client] = 0.0;
				g_teamRecord[g_partner[client]] = 0.0;

				return;
			}

			results.Rewind();

			if(results.FetchRow() == true)
			{
				g_teamRecord[client] = results.FetchFloat(0);
				g_teamRecord[g_partner[client]] = results.FetchFloat(0);
			}
		}
	}

	return;
}

public Action cmd_restart(int client, int args)
{
	bool restart = gCV_restart.BoolValue;

	if(restart == false)
	{
		return Plugin_Continue;
	}

	Restart(client, true);

	return Plugin_Handled;
}

stock void Restart(int client, bool ask)
{
	char format[256] = "";

	if(g_devmap == true)
	{
		Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
		SendMessage(client, format);
	}

	else if(g_devmap == false)
	{
		if(g_zoneHave[0] == true && g_zoneHave[1] == true)
		{
			if(IsValidPartner(client) == true)
			{
				if(ask == false)
				{
					DoRestart(client);
				}

				else if(ask == true)
				{
					Menu menu = new Menu(handler_askforrestart);
					menu.SetTitle("%T", "AskForRestart", client);

					Format(format, sizeof(format), "%T", "Yes", client);
					menu.AddItem("yes", format);
					Format(format, sizeof(format), "%T", "No", client);
					menu.AddItem("no", format);

					menu.Display(client, 20);
				}
			}

			else if(IsValidPartner(client) == false)
			{
				Format(format, sizeof(format), "%T", "DontHavePartner", client);
				SendMessage(client, format);
			}
		}
	}

	return;
}

stock void DoRestart(int client)
{
	if(IsValidPartner(client) == true)
	{
		int partner = g_partner[client];

		CreateTimer(0.1, timer_resetfactory, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, timer_resetfactory, partner, TIMER_FLAG_NO_MAPCHANGE);

		static GlobalForward hForward = null;
		hForward = new GlobalForward("Trikz_OnRestart", ET_Hook, Param_Cell, Param_Cell);
		Call_StartForward(hForward);
		Call_PushCell(client);
		Call_PushCell(partner);
		Call_Finish();
		delete hForward;

		CS_RespawnPlayer(client);
		CS_RespawnPlayer(partner);

		float vel[3] = {0.0, ...};
		TeleportEntity(client, g_timerStartPos, NULL_VECTOR, vel);
		TeleportEntity(partner, g_timerStartPos, NULL_VECTOR, vel);

		g_block[client] = true;
		g_block[partner] = true;
	}
}

public int handler_askforrestart(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					DoRestart(param1);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action cmd_autoflash(int client, int args)
{
	bool autoflashbang = gCV_autoflashbang.BoolValue;
	
	if(autoflashbang == false)
	{
		return Plugin_Continue;
	}

	g_autoflash[client] = !g_autoflash[client];

	GiveFlashbang(client);

	char value[8] = "";
	IntToString(g_autoflash[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[4], value);

	if(g_menuOpened[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_autoflash[client] == true ? "AutoflashChatON" : "AutoflashChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

public Action cmd_autoswitch(int client, int args)
{
	bool autoswitch = gCV_autoswitch.BoolValue;
	
	if(autoswitch == false)
	{
		return Plugin_Continue;
	}
	
	g_autoswitch[client] = !g_autoswitch[client];

	char value[8] = "";
	IntToString(g_autoswitch[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[5], value);

	if(g_menuOpened[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_autoswitch[client] == true ? "AutoswitchChatON" : "AutoswitchChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

public Action cmd_bhop(int client, int args)
{
	bool bhop = gCV_bhop.BoolValue;
	
	if(bhop == false)
	{
		return Plugin_Continue;
	}

	g_bhop[client] = !g_bhop[client];
	
	char value[8] = "";
	IntToString(g_bhop[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[6], value);

	if(g_menuOpened[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_bhop[client] == true ? "BhopChatON" : "BhopChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

public Action cmd_endmsg(int client, int args)
{
	bool endmsg = gCV_endmsg.BoolValue;

	if(endmsg == false)
	{
		return Plugin_Continue;
	}

	g_endMessage[client] = !g_endMessage[client];

	char value[8] = "";
	IntToString(g_bhop[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[8], value);

	if(g_menuOpenedHud[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_endMessage[client] == true ? "EndMessageChatON" : "EndMessageChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

public Action cmd_top10(int client, int args)
{
	bool top10 = gCV_top10.BoolValue;

	if(top10 == false)
	{
		return Plugin_Continue;
	}

	Top10(client);

	return Plugin_Handled;
}

public void Top10(int client)
{
	if(g_top10ac <= GetGameTime())
	{
		if(g_dbPassed == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "Wait for database loading...");
			SendMessage(client, format);

			return;
		}

		g_top10ac = GetGameTime() + 10.0;

		char query[512] = "";
		Format(query, sizeof(query), "SELECT * FROM records LIMIT 1");
		g_mysql.Query(SQLTop10, query, _, DBPrio_Normal);
	}

	else if(g_top10ac > GetGameTime())
	{
		char format[256] = "";
		char time[8] = "";
		Format(time, sizeof(time), "%.0f", g_top10ac - GetGameTime());
		Format(format, sizeof(format), "%T", "Top10ac", client, time);
		SendMessage(client, format);
	}

	return;
}

public void SQLTop10(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10: %s", error);
	}

	else if(strlen(error) == 0)
	{
		bool bResults = results.FetchRow();

		if(bResults == false)
		{
			char format[256] = "";

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					Format(format, sizeof(format), "%T", "Top10details", i);
					SendMessage(i, format);

					Format(format, sizeof(format), "%T", "NoRecords", i);
					SendMessage(i, format);
				}
			}
		}

		else if(bResults == true)
		{
			char query[512] = "";
			Format(query, sizeof(query), "SELECT playerid, partnerid, time FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 10", g_map);
			g_mysql.Query(SQLTop10_2, query, _, DBPrio_Normal);
		}
	}

	return;
}

public void SQLTop10_2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10_2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == false)
		{
			char format[256] = "";

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					Format(format, sizeof(format), "%T", "Top10details", i);
					SendMessage(i, format);

					Format(format, sizeof(format), "%T", "NoRecords", i);
					SendMessage(i, format);
				}
			}

			return;
		}

		g_top10Count = 0;

		results.Rewind();

		while(results.FetchRow() == true)
		{
			int playerid = results.FetchInt(0);
			int partnerid = results.FetchInt(1);

			float time = results.FetchFloat(2);

			char query[512] = "";
			Format(query, sizeof(query), "SELECT username, (SELECT username FROM users WHERE steamid = %i) FROM users WHERE steamid = %i", partnerid, playerid);
			g_mysql.Query(SQLTop10_3, query, time, DBPrio_Normal);
		}
	}

	return;
}

public void SQLTop10_3(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10_3: %s", error);
	}

	else if(strlen(error) == 0)
	{
		float time = data;

		if(results.FetchRow() == true)
		{
			char format[256] = "";

			char name1[MAX_NAME_LENGTH] = "";
			char name2[MAX_NAME_LENGTH] = "";

			results.FetchString(0, name1, sizeof(name1));
			results.FetchString(1, name2, sizeof(name2));
			
			char formatTime[24] = "";
			FormatSeconds(time, formatTime);

			int count = ++g_top10Count;

			if(count == 1)
			{
				g_top10SR = time;
			}

			float timeDiff = time - g_top10SR;

			char formatTimeDiff[24] = "";
			FormatSeconds(timeDiff, formatTimeDiff);
			Format(formatTimeDiff, sizeof(formatTimeDiff), "+%s", formatTimeDiff);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					if(count == 1)
					{
						Format(format, sizeof(format), "%T", "Top10details", i);
						SendMessage(i, format);
					}
					
					if(count < 10)
					{
						Format(format, sizeof(format), "%T", "Top10source1-9", i, count, formatTime, formatTimeDiff, name1, name2);
						SendMessage(i, format);
					}

					else if(count == 10)
					{
						Format(format, sizeof(format), "%T", "Top10source10", i, count, formatTime, formatTimeDiff, name1, name2);
						SendMessage(i, format);
					}
				}
			}
		}
	}

	return;
}

public Action cmd_control(int client, int args)
{
	bool control = gCV_control.BoolValue;

	if(control == false)
	{
		return Plugin_Continue;
	}

	Control(client);

	return Plugin_Handled;
}

public Action cmd_skin(int client, int args)
{
	bool skin = gCV_skin.BoolValue;

	if(skin == false)
	{
		return Plugin_Continue;
	}

	Skin(client);

	return Plugin_Handled;
}

stock void Skin(int client)
{
	Menu menu = new Menu(skinmenu_hanlder);
	menu.SetTitle("Skin");

	menu.AddItem("player_skin", "Player Skin");
	menu.AddItem("flashbang_skin", "Flashbang Skin");

	menu.Display(client, 20);

	return;
}

public int skinmenu_hanlder(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					PlayerSkin(param1);
				}

				case 1:
				{
					FlashbangSkin(param1);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

stock void PlayerSkin(int client)
{
	Menu menu = new Menu(menuskinchoose_handler);

	char format[256] = "";
	Format(format, sizeof(format), "%T", "PlayerSkin", client);
	menu.SetTitle(format);

	Format(format, sizeof(format), "%T", "Default", client);
	menu.AddItem("default_ps", format, g_skinPlayer[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(format, sizeof(format), "%T", "Shadow", client);
	menu.AddItem("shadow_ps", format, g_skinPlayer[client] == 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(format, sizeof(format), "%T", "Bright", client);
	menu.AddItem("bright_ps", format, g_skinPlayer[client] == 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

stock void FlashbangSkin(int client)
{
	Menu menu = new Menu(menuskinchoose_handler);

	char format[256] = "";
	Format(format, sizeof(format), "%T", "FlashbangSkin", client);
	menu.SetTitle(format);

	Format(format, sizeof(format), "%T", "Default", client);
	menu.AddItem("default_fs", format, g_skinFlashbang[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(format, sizeof(format), "%T", "Shadow", client);
	menu.AddItem("shadow_fs", format, g_skinFlashbang[client] == 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(format, sizeof(format), "%T", "Bright", client);
	menu.AddItem("bright_fs", format, g_skinFlashbang[client] == 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(format, sizeof(format), "%T", "Wireframe", client);
	menu.AddItem("wireframe_fs", format, g_skinFlashbang[client] == 3 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

public int menuskinchoose_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			char value[8] = "";

			if(StrContains(item, "ps", false) != -1)
			{
				if(StrEqual(item, "default_ps", false) == true)
				{
					g_skinPlayer[param1] = 0;
					SetEntProp(param1, Prop_Data, "m_nSkin", 0, 4, 0);
				}

				else if(StrEqual(item, "shadow_ps", false) == true)
				{
					g_skinPlayer[param1] = 2;
					SetEntProp(param1, Prop_Data, "m_nSkin", 2, 4, 0);
				}

				else if(StrEqual(item, "bright_ps", false) == true)
				{
					g_skinPlayer[param1] = 1;
					SetEntProp(param1, Prop_Data, "m_nSkin", 1, 4, 0);
				}

				IntToString(g_skinPlayer[param1], value, sizeof(value));
				SetClientCookie(param1, g_cookie[11], value);

				PlayerSkin(param1);
			}

			else if(StrContains(item, "fs", false) != -1)
			{
				if(StrEqual(item, "default_fs", false))
				{
					g_skinFlashbang[param1] = 0;
				}

				else if(StrEqual(item, "shadow_fs", false) == true)
				{
					g_skinFlashbang[param1] = 2;
				}

				else if(StrEqual(item, "bright_fs", false) == true)
				{
					g_skinFlashbang[param1] = 1;
				}

				else if(StrEqual(item, "wireframe_fs", false) == true)
				{
					g_skinFlashbang[param1] = 3;
				}

				IntToString(g_skinFlashbang[param1], value, sizeof(value));
				SetClientCookie(param1, g_cookie[9], value);

				FlashbangSkin(param1);
			}
		}

		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					ColorSelect(param1);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action cmd_macro(int client, int args)
{
	bool macro = gCV_macro.BoolValue;
	
	if(macro == false)
	{
		return Plugin_Continue;
	}

	g_macroDisabled[client] = !g_macroDisabled[client];
	
	char value[8] = "";
	IntToString(g_macroDisabled[client], value, sizeof(value));

	char format[256] = "";
	Format(format, sizeof(format), "%T", g_macroDisabled[client] == false ? "MacroON" : "MacroOFF", client);
	SendMessage(client, format);

	return Plugin_Handled;
}

public Action timer_resetfactory(Handle timer, int client)
{
	if(IsClientInGame(client) == true)
	{
		ResetFactory(client);
	}

	return Plugin_Stop;
}

stock void CreateStart()
{
	int entity = CreateEntityByName("trigger_multiple", -1);

	DispatchKeyValue(entity, "spawnflags", "1"); //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0");
	DispatchKeyValue(entity, "targetname", "trueexpert_startzone");

	DispatchSpawn(entity);

	SetEntityModel(entity, "models/player/t_arctic.mdl");

	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	for(int i = 0; i <= 2; i++)
	{
		g_center[0][i] = (g_zoneStartOrigin[0][i] + g_zoneStartOrigin[1][i]) / 2.0;
	}

	TeleportEntity(entity, g_center[0], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	g_timerStartPos[0] = g_center[0][0];
	g_timerStartPos[1] = g_center[0][1];
	g_timerStartPos[2] = g_center[0][2] + 1.0;

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_zoneStartOrigin[0][i] - g_zoneStartOrigin[1][i]) / 2.0;

		if(mins[i] > 0.0)
		{
			mins[i] *= -1.0;
		}

		maxs[i] = (g_zoneStartOrigin[0][i] - g_zoneStartOrigin[1][i]) / 2.0;

		if(maxs[i] < 0.0)
		{
			maxs[i] *= -1.0;
		}
	}

	maxs[2] = 124.0; // 62.0 * 2.0 - player hitbox is 62.0 units height. so make 2 player together.

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch);
	SDKHook(entity, SDKHook_EndTouch, SDKEndTouch);
	SDKHook(entity, SDKHook_Touch, SDKTouch);

	PrintToServer("Start zone is successfuly setup.");

	g_zoneHave[0] = true;

	return;
}

public void CreateEnd()
{
	int entity = CreateEntityByName("trigger_multiple", -1);

	DispatchKeyValue(entity, "spawnflags", "1"); //https://github.com/shavitush/bhoptimer //from developer valvesoftware it means make able to work with client
	DispatchKeyValue(entity, "wait", "0"); //this point makes refresh time so its refreshing by server tickrate. or its going 0.2 seconds by developer valvesoftware, second one will be correct.
	DispatchKeyValue(entity, "targetname", "trueexpert_endzone");

	DispatchSpawn(entity);

	SetEntityModel(entity, "models/player/t_arctic.mdl");

	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python

	for(int i = 0; i <= 2; i++)
	{
		g_center[1][i] = (g_zoneEndOrigin[0][i] + g_zoneEndOrigin[1][i]) / 2.0; // so its mins and maxs in cube devide to two.
	}

	TeleportEntity(entity, g_center[1], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_zoneEndOrigin[0][i] - g_zoneEndOrigin[1][i]) / 2.0;

		if(mins[i] > 0.0)
		{
			mins[i] *= -1.0;
		}

		maxs[i] = (g_zoneEndOrigin[0][i] - g_zoneEndOrigin[1][i]) / 2.0;

		if(maxs[i] < 0.0)
		{
			maxs[i] *= -1.0;
		}
	}

	maxs[2] = 124.0;

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0); //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch);

	PrintToServer("End zone is successfuly setup.");

	CPSetup(0);

	g_zoneHave[1] = true;

	return;
}

public Action cmd_startmins(int client, int args)
{
	int flags = GetUserFlagBits(client);
	
	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			GetClientAbsOrigin(client, g_zoneStartOrigin[0]);
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void SQLDeleteStartZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLDeleteStartZone: %s", error);
	}

	else if(strlen(error) == 0)
	{
		char query[512] = "";
		Format(query, sizeof(query), "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 0, %i, %i, %i, %i, %i, %i)", g_map, RoundFloat(g_zoneStartOrigin[0][0]), RoundFloat(g_zoneStartOrigin[0][1]), RoundFloat(g_zoneStartOrigin[0][2]), RoundFloat(g_zoneStartOrigin[1][0]), RoundFloat(g_zoneStartOrigin[1][1]), RoundFloat(g_zoneStartOrigin[1][2]));
		g_mysql.Query(SQLSetStartZones, query, _, DBPrio_Normal);
	}

	return;
}

public Action cmd_deleteallcp(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			char query[512] = "";
			Format(query, sizeof(query), "DELETE FROM cp WHERE map = '%s'", g_map); //https://www.w3schools.com/sql/sql_delete.asp
			g_mysql.Query(SQLDeleteAllCP, query, _, DBPrio_Normal);
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}
	}

	return Plugin_Continue;
}

public void SQLDeleteAllCP(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLDeleteAllCP: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("All checkpoints are deleted on current map.");
		}

		else if(results.HasResults == true)
		{
			PrintToServer("No checkpoints to delete on current map.");
		}
	}

	return;
}

public Action OnClientCommandKeyValues(int client, KeyValues kv)
{
	if(g_devmap == false)
	{
		char cmd[64] = ""; //https://forums.alliedmods.net/showthread.php?t=270684
		kv.GetSectionName(cmd, sizeof(cmd));

		if(StrEqual(cmd, "ClanTagChanged", false) == true)
		{
			CS_GetClientClanTag(client, g_clantag[client][0], 256);
		}
	}

	return Plugin_Continue;
}

public Action cmd_test(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		char arg[256] = "";
		GetCmdArgString(arg, sizeof(arg));

		int partner = StringToInt(arg);

		if(IsValidClient(partner) == true && IsValidPartner(client) == false)
		{
			g_partner[client] = partner;
			g_partner[partner] = client;

			Restart(client, false);
		}

		PrintToServer("LibraryExists (trueexpert-entityfilter): %s", LibraryExists("trueexpert-entityfilter") == true ? "true" : "false");

		//https://forums.alliedmods.net/showthread.php?t=187746
		int color = 0;
		color |= (5 & 255) << 24; //5 red
		color |= (200 & 255) << 16; // 200 green
		color |= (255 & 255) << 8; // 255 blue
		color |= (50 & 255) << 0; // 50 alpha

		PrintToChat(client, "\x08%08XRGBA \x0805C8FF30HEX", color, color); //https://rgbacolorpicker.com/rgba-to-hex https://gist.github.com/lopspower/03fb1cc0ac9f32ef38f4?permalink_comment_id=3769893#gistcomment-3769893

		char auth64[64] = "";
		GetClientAuthId(client, AuthId_SteamID64, auth64, sizeof(auth64));

		char authid3[64] = "";
		GetClientAuthId(client, AuthId_Steam3, authid3, sizeof(authid3));

		PrintToChat(client, "Your SteamID64 is: %s = 76561197960265728 + %i (SteamID64 = First SteamID3 + Your SteamID3)", auth64, authid3); //https://forums.alliedmods.net/showthread.php?t=324112 120192594

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock void SendMessage(int client, const char[] text)
{
	char name[MAX_NAME_LENGTH] = "";
	GetClientName(client, name, sizeof(name));

	int team = GetClientTeam(client);

	char teamColor[32] = "";

	switch(team)
	{
		case CS_TEAM_SPECTATOR:
		{
			Format(teamColor, sizeof(teamColor), "\x07CCCCCC");
		}

		case CS_TEAM_T:
		{
			Format(teamColor, sizeof(teamColor), "\x07FF4040");
		}

		case CS_TEAM_CT:
		{
			Format(teamColor, sizeof(teamColor), "\x0799CCFF");
		}
	}

	char textReplaced[256] = "";
	Format(textReplaced, sizeof(textReplaced), "\x01%s", text);

	ReplaceString(textReplaced, sizeof(textReplaced), ";#", "\x07");
	ReplaceString(textReplaced, sizeof(textReplaced), "{default}", "\x01");
	ReplaceString(textReplaced, sizeof(textReplaced), "{teamcolor}", teamColor);

	if(IsValidClient(client) == true)
	{
		Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS); //https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/morecolors.inc#L195
		BfWrite bf = UserMessageToBfWrite(buf); //dont show color codes in console.
		bf.WriteByte(client); //Message author
		bf.WriteByte(true); //Chat message
		bf.WriteString(textReplaced); //Message text
		EndMessage();
	}

	return;
}

public Action cmd_endmins(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			GetClientAbsOrigin(client, g_zoneEndOrigin[0]);
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void SQLDeleteEndZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLDeleteEndZone: %s", error);
	}

	else if(strlen(error) == 0)
	{
		char query[512] = "";
		Format(query, sizeof(query), "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', 1, %i, %i, %i, %i, %i, %i)", g_map, RoundFloat(g_zoneEndOrigin[0][0]), RoundFloat(g_zoneEndOrigin[0][1]), RoundFloat(g_zoneEndOrigin[0][2]), RoundFloat(g_zoneEndOrigin[1][0]), RoundFloat(g_zoneEndOrigin[1][1]), RoundFloat(g_zoneEndOrigin[1][2]));
		g_mysql.Query(SQLSetEndZones, query, _, DBPrio_Normal);
	}

	return;
}

public Action cmd_maptier(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			char arg[512] = "";
			GetCmdArgString(arg, sizeof(arg)); //https://www.sourcemod.net/new-api/console/GetCmdArgString

			int tier = StringToInt(arg);

			if(tier > 0)
			{
				PrintToServer("[Args] Tier: %i", tier);

				char query[512] = "";
				Format(query, sizeof(query), "DELETE FROM tier WHERE map = '%s' LIMIT 1", g_map);
				g_mysql.Query(SQLTierRemove, query, tier, DBPrio_Normal);
			}
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void SQLTierRemove(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTierRemove: %s", error);
	}

	else if(strlen(error) == 0)
	{
		char query[512] = "";
		Format(query, sizeof(query), "INSERT INTO tier (tier, map) VALUES (%i, '%s')", data, g_map);
		g_mysql.Query(SQLTierInsert, query, data, DBPrio_Normal);
	}

	return;
}

public void SQLTierInsert(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTierInsert: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("Tier %i is set for %s.", data, g_map);
		}
	}

	return;
}

public void SQLSetStartZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetStartZones: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("Start zone successfuly created.");
		}

		else if(results.HasResults == true)
		{
			PrintToServer("Start zone failed to create.");
		}
	}

	return;
}

public void SQLSetEndZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetEndZones: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("End zone successfuly created.");
		}

		else if(results.HasResults == true)
		{
			PrintToServer("End zone failed to create.");
		}
	}

	return;
}

public Action cmd_startmaxs(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		GetClientAbsOrigin(client, g_zoneStartOrigin[1]);

		char query[512] = "";
		Format(query, sizeof(query), "DELETE FROM zones WHERE map = '%s' AND type = 0 LIMIT 1", g_map);
		g_mysql.Query(SQLDeleteStartZone, query, _, DBPrio_Normal);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action cmd_endmaxs(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		GetClientAbsOrigin(client, g_zoneEndOrigin[1]);

		char query[512] = "";
		Format(query, sizeof(query), "DELETE FROM zones WHERE map = '%s' AND type = 1 LIMIT 1", g_map);
		g_mysql.Query(SQLDeleteEndZone, query, _, DBPrio_Normal);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action cmd_cpmins(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			char cmd[512] = "";
			GetCmdArg(args, cmd, sizeof(cmd));

			int cpnum = StringToInt(cmd);

			if(cpnum > 0)
			{
				PrintToChat(client, "CP: No.%i", cpnum);

				GetClientAbsOrigin(client, g_cpPos[cpnum][0]);
			}
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void SQLCPRemoved(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPRemoved: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("Checkpoint zone no. %i successfuly deleted.", data);
		}

		else if(results.HasResults == true)
		{
			PrintToServer("Checkpoint zone no. %i failed to delete.", data);
		}

		char query[512] = "";
		Format(query, sizeof(query), "INSERT INTO cp (cpnum, cpx, cpy, cpz, cpx2, cpy2, cpz2, map) VALUES (%i, %i, %i, %i, %i, %i, %i, '%s')", data, RoundFloat(g_cpPos[data][0][0]), RoundFloat(g_cpPos[data][0][1]), RoundFloat(g_cpPos[data][0][2]), RoundFloat(g_cpPos[data][1][0]), RoundFloat(g_cpPos[data][1][1]), RoundFloat(g_cpPos[data][1][2]), g_map);
		g_mysql.Query(SQLCPInserted, query, data, DBPrio_Normal);
	}

	return;
}

public Action cmd_cpmaxs(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		char cmd[512] = "";
		GetCmdArg(args, cmd, sizeof(cmd));

		int cpnum = StringToInt(cmd);

		if(cpnum > 0)
		{
			GetClientAbsOrigin(client, g_cpPos[1][cpnum]);

			char query[512] = "";
			Format(query, sizeof(query), "DELETE FROM cp WHERE cpnum = %i AND map = '%s'", cpnum, g_map);
			g_mysql.Query(SQLCPRemoved, query, cpnum, DBPrio_Normal);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void SQLCPInserted(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPInserted: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			PrintToServer("Checkpoint zone no. %i successfuly created.", data);
		}

		else if(results.HasResults == true)
		{
			PrintToServer("Checkpoint zone no. %i failed to create.");
		}
	}

	return;
}

public Action cmd_zones(int client, int args)
{
	int flags = GetUserFlagBits(client);

	if(flags & ADMFLAG_CUSTOM1)
	{
		if(g_devmap == true)
		{
			ZoneEditor(client);
		}

		else if(g_devmap == false)
		{
			char format[256] = "";
			Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
			SendMessage(client, format);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void ZoneEditor(int client)
{
	CPSetup(client);

	return;
}

stock void ZoneEditor2(int client)
{
	Menu menu = new Menu(zones_handler);
	menu.SetTitle("Zone editor");

	if(g_zoneHave[0] == true)
	{
		menu.AddItem("start", "Start zone");
	}

	if(g_zoneHave[1] == true)
	{
		menu.AddItem("end", "End zone");
	}

	if(g_cpCount > 0)
	{
		char cp[16] = "";
		char format[32] = "";

		for(int i = 1; i <= g_cpCount; i++)
		{
			Format(cp, sizeof(cp), "%i", i);
			Format(format, sizeof(format), "CP nr. %i zone", i);
			menu.AddItem(cp, format);
		}
	}

	else if(g_zoneHave[0] == false && g_zoneHave[1] == false && g_cpCount == 0)
	{
		menu.AddItem("-1", "No zones are setup.", ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

public int zones_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			if(StrEqual(item, "start", false) == true)
			{
				ZoneEditorStart(param1);
			}

			else if(StrEqual(item, "end", false) == true)
			{
				ZoneEditorEnd(param1);
			}

			for(int i = 1; i <= g_cpCount; i++)
			{
				char cp[16] = "";
				IntToString(i, cp, sizeof(cp));

				if(StrEqual(item, cp, false) == true)
				{
					ZoneEditorCP(param1, i);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

stock void ZoneEditorStart(int client)
{
	Menu menu = new Menu(zones2_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("Zone editor - Start zone");

	menu.AddItem("starttp", "Teleport to start zone");
	char format[16] = "";
	Format(format, sizeof(format), "Step: %i", g_step);
	menu.AddItem("step", format);
	menu.AddItem("start+xmaxs", "+x/maxs");
	menu.AddItem("start-xmaxs", "-x/maxs");
	menu.AddItem("start+ymins", "+y/mins");
	menu.AddItem("start-ymins", "-y/mins");
	menu.AddItem("empty", "");
	menu.AddItem("start+xmins", "+x/mins");
	menu.AddItem("start-xmins", "-x/mins");
	menu.AddItem("start+ymaxs", "+y/maxs");
	menu.AddItem("start-ymaxs", "-y/maxs");
	menu.AddItem("startupdate", "Update start zone");

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor = 0;

	return;
}

stock void ZoneEditorEnd(int client)
{
	Menu menu = new Menu(zones2_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("Zone editor - End zone");

	menu.AddItem("endtp", "Teleport to end zone");
	char format[16] = "";
	Format(format, sizeof(format), "Step: %i", g_step);
	menu.AddItem("step", format);
	menu.AddItem("end+xmaxs", "+x/maxs");
	menu.AddItem("end-xmaxs", "-x/maxs");
	menu.AddItem("end+ymins", "+y/mins");
	menu.AddItem("end-ymins", "-y/mins");
	menu.AddItem("empty", "");
	menu.AddItem("end+xmins", "+x/mins");
	menu.AddItem("end-xmins", "-x/mins");
	menu.AddItem("end+ymaxs", "+y/maxs");
	menu.AddItem("end-ymaxs", "-y/maxs");
	menu.AddItem("endupdate", "Update start zone");

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor = 1;

	return;
}

stock void ZoneEditorCP(int client, int cpnum)
{
	Menu menu = new Menu(zones2_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("Zone editor - CP nr. %i zone", cpnum);

	char button[32] = "";
	Format(button, sizeof(button), "Teleport to CP nr. %i zone", cpnum);

	char itemCP[16] = "";
	Format(itemCP, sizeof(itemCP), "tp;%i", cpnum);
	menu.AddItem(itemCP, button);

	char step[16] = "";
	Format(step, sizeof(step), "Step: %i", g_step);
	menu.AddItem("step", step);

	Format(itemCP, sizeof(itemCP), "5;%i", cpnum);
	menu.AddItem(itemCP, "+x/maxs");
	Format(itemCP, sizeof(itemCP), "6;%i", cpnum);
	menu.AddItem(itemCP, "-x/maxs");
	Format(itemCP, sizeof(itemCP), "3;%i", cpnum);
	menu.AddItem(itemCP, "+y/mins");
	Format(itemCP, sizeof(itemCP), "4;%i", cpnum);
	menu.AddItem(itemCP, "-y/mins");

	menu.AddItem("empty", "");

	Format(itemCP, sizeof(itemCP), "1;%i", cpnum);
	menu.AddItem(itemCP, "+x/mins");
	Format(itemCP, sizeof(itemCP), "2;%i", cpnum);
	menu.AddItem(itemCP, "-x/mins");
	Format(itemCP, sizeof(itemCP), "7;%i", cpnum);
	menu.AddItem(itemCP, "+y/maxs");
	Format(itemCP, sizeof(itemCP), "8;%i", cpnum);
	menu.AddItem(itemCP, "-y/maxs");

	char cpupdate[32] = "";
	Format(cpupdate, sizeof(cpupdate), "cpupdate;%i", cpnum);
	Format(button, sizeof(button), "Update CP nr. %i zone", cpnum);
	menu.AddItem(cpupdate, button);

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor = 2;

	g_ZoneEditorCP = cpnum;

	return;
}

public int zones2_handler(Menu menu, MenuAction action, int param1, int param2)
{
	bool bDelete = true;

	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
		{
			g_zoneDraw[param1] = true;
		}

		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			if(StrEqual(item, "starttp", false) == true)
			{
				TeleportEntity(param1, g_center[0], NULL_VECTOR, NULL_VECTOR);
			}

			else if(StrEqual(item, "step", false) == true)
			{
				ZoneEditorStep();

				if(g_ZoneEditor == 0)
				{
					ZoneEditorStart(param1);
				}

				else if(g_ZoneEditor == 1)
				{
					ZoneEditorEnd(param1);
				}

				else if(g_ZoneEditor == 2)
				{
					ZoneEditorCP(param1, g_ZoneEditorCP);
				}
			}

			else if(StrEqual(item, "start+xmins", false) == true)
			{
				g_zoneStartOrigin[0][0] += g_step;
			}

			else if(StrEqual(item, "start-xmins", false) == true)
			{
				g_zoneStartOrigin[0][0] -= g_step;
			}

			else if(StrEqual(item, "start+ymins", false) == true)
			{
				g_zoneStartOrigin[0][1] += g_step;
			}

			else if(StrEqual(item, "start-ymins", false) == true)
			{
				g_zoneStartOrigin[0][1] -= g_step;
			}

			else if(StrEqual(item, "start+xmaxs", false) == true)
			{
				g_zoneStartOrigin[1][0] += g_step;
			}

			else if(StrEqual(item, "start-xmaxs", false) == true)
			{
				g_zoneStartOrigin[1][0] -= g_step;
			}

			else if(StrEqual(item, "start+ymaxs", false) == true)
			{
				g_zoneStartOrigin[1][1] += g_step;
			}

			else if(StrEqual(item, "start-ymaxs", false) == true)
			{
				g_zoneStartOrigin[1][1] -= g_step;
			}

			else if(StrEqual(item, "endtp", false) == true)
			{
				TeleportEntity(param1, g_center[1], NULL_VECTOR, NULL_VECTOR);
			}

			else if(StrEqual(item, "end+xmins", false) == true)
			{
				g_zoneEndOrigin[0][0] += g_step;
			}

			else if(StrEqual(item, "end-xmins", false) == true)
			{
				g_zoneEndOrigin[0][0] -= g_step;
			}

			else if(StrEqual(item, "end+ymins", false) == true)
			{
				g_zoneEndOrigin[0][1] += g_step;
			}

			else if(StrEqual(item, "end-ymins", false) == true)
			{
				g_zoneEndOrigin[0][1] -= g_step;
			}

			else if(StrEqual(item, "end+xmaxs", false) == true)
			{
				g_zoneEndOrigin[1][0] += g_step;
			}

			else if(StrEqual(item, "end-xmaxs", false) == true)
			{
				g_zoneEndOrigin[1][0] -= g_step;
			}

			else if(StrEqual(item, "end+ymaxs", false) == true)
			{
				g_zoneEndOrigin[1][1] += g_step;
			}

			else if(StrEqual(item, "end-ymaxs", false) == true)
			{
				g_zoneEndOrigin[1][1] -= g_step;
			}

			//char exploded[1][16];
			char exploded[16][16];

			ExplodeString(item, ";", exploded, 2, sizeof(exploded));

			int cpnum = StringToInt(exploded[1]);

			//PrintToServer("%i, %s | %s | %s", cpnum, item, exploded[0], exploded[1]);

			char cpFormated[16] = "";

			Format(cpFormated, sizeof(cpFormated), "tp;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				TeleportEntity(param1, g_center[cpnum + 1], NULL_VECTOR, NULL_VECTOR);
			}

			Format(cpFormated, sizeof(cpFormated), "1;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][0][0] += g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "2;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][0][0] -= g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "3;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][0][1] += g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "4;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][0][1] -= g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "5;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][1][0] += g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "6;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][1][0] -= g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "7;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][1][1] += g_step;
			}

			Format(cpFormated, sizeof(cpFormated), "8;%i", cpnum);

			if(StrEqual(item, cpFormated, false) == true)
			{
				g_cpPos[cpnum][1][1] -= g_step;
			}

			char query[512] = "";

			Format(cpFormated, sizeof(cpFormated), "cpupdate;%i", cpnum);

			if(StrEqual(item, "startupdate", false) == true)
			{
				Format(query, sizeof(query), "UPDATE zones SET possition_x = %i, possition_y = %i, possition_z = %i, possition_x2 = %i, possition_y2 = %i, possition_z2 = %i WHERE type = 0 AND map = '%s'", RoundFloat(g_zoneStartOrigin[0][0]), RoundFloat(g_zoneStartOrigin[0][1]), RoundFloat(g_zoneStartOrigin[0][2]), RoundFloat(g_zoneStartOrigin[1][0]), RoundFloat(g_zoneStartOrigin[1][1]), RoundFloat(g_zoneStartOrigin[1][2]), g_map);
				g_mysql.Query(SQLUpdateZone, query, 0, DBPrio_Normal);
			}

			else if(StrEqual(item, "endupdate", false) == true)
			{
				Format(query, sizeof(query), "UPDATE zones SET possition_x = %i, possition_y = %i, possition_z = %i, possition_x2 = %i, possition_y2 = %i, possition_z2 = %i WHERE type = 1 AND map = '%s'", RoundFloat(g_zoneEndOrigin[0][0]), RoundFloat(g_zoneEndOrigin[0][1]), RoundFloat(g_zoneEndOrigin[0][2]), RoundFloat(g_zoneEndOrigin[1][0]), RoundFloat(g_zoneEndOrigin[1][1]), RoundFloat(g_zoneEndOrigin[1][2]), g_map);
				g_mysql.Query(SQLUpdateZone, query, 1, DBPrio_Normal);
			}

			else if(StrEqual(item, cpFormated, false) == true)
			{
				Format(query, sizeof(query), "UPDATE cp SET cpx = %i, cpy = %i, cpz = %i, cpx2 = %i, cpy2 = %i, cpz2 = %i WHERE cpnum = %i AND map = '%s'", RoundFloat(g_cpPos[0][cpnum][0]), RoundFloat(g_cpPos[0][cpnum][1]), RoundFloat(g_cpPos[0][cpnum][2]), RoundFloat(g_cpPos[1][cpnum][0]), RoundFloat(g_cpPos[1][cpnum][1]), RoundFloat(g_cpPos[1][cpnum][2]), cpnum, g_map);
				g_mysql.Query(SQLUpdateZone, query, cpnum + 1, DBPrio_Normal);
			}

			if(StrEqual(item, "step", false) == false)
			{
				menu.DisplayAt(param1, GetMenuSelectionPosition(), MENU_TIME_FOREVER); //https://forums.alliedmods.net/showthread.php?p=2091775

				bDelete = false;
			}
		}

		case MenuAction_Cancel: //trikz redux menuaction end
		{
			g_zoneDraw[param1] = false; //idea from expert zone.

			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
				{
					ZoneEditor(param1);
				}
			}
		}

		case MenuAction_Display:
		{
			g_zoneDraw[param1] = true;
		}

		case MenuAction_End:
		{
			if(bDelete == true)
			{
				delete menu;
			}
		}
	}

	return view_as<int>(action);
}

public void SQLUpdateZone(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUpdateZone: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			if(data == 1)
			{
				PrintToServer("End zone successfuly updated.");
			}

			else if(data == 0)
			{
				PrintToServer("Start zone successfuly updated.");
			}

			else if(data > 1)
			{
				PrintToServer("CP zone nr. %i successfuly updated.", data - 1);
			}
		}

		else if(results.HasResults == true)
		{
			if(data == 1)
			{
				PrintToServer("End zone failed to update.");
			}

			else if(data == 0)
			{
				PrintToServer("Start zone failed to update.");
			}

			else if(data > 1)
			{
				PrintToServer("CP zone nr. %i failed to update", data - 1);
			}
		}
	}

	return;
}

stock void ZoneEditorStep()
{
	g_step *= 2;

	if(g_step == 1024)
	{
		g_step = 1;
	}

	return;
}

//https://forums.alliedmods.net/showthread.php?t=261378

public Action cmd_createcp(int args)
{
	g_mysql.Query(SQLCreateCPTable, "CREATE TABLE IF NOT EXISTS cp (id INT AUTO_INCREMENT, cpnum INT, cpx INT, cpy INT, cpz INT, cpx2 INT, cpy2 INT, cpz2 INT, map VARCHAR(192), PRIMARY KEY(id))");

	return Plugin_Continue;
}

public void SQLCreateCPTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateCPTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("CP table successfuly created.");
	}

	return;
}

public Action cmd_createtier(int args)
{
	g_mysql.Query(SQLCreateTierTable, "CREATE TABLE IF NOT EXISTS tier (id INT AUTO_INCREMENT, tier INT, map VARCHAR(192), PRIMARY KEY(id))");

	return Plugin_Continue;
}

public void SQLCreateTierTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateTierTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Tier table successfuly created.");
	}

	return;
}

stock void CPSetup(int client)
{
	g_cpCount = 0;

	char query[512] = "";

	for(int i = 1; i <= 10; i++)
	{
		Format(query, sizeof(query), "SELECT cpx, cpy, cpz, cpx2, cpy2, cpz2 FROM cp WHERE cpnum = %i AND map = '%s' LIMIT 1", i, g_map);

		DataPack dp = new DataPack();
		dp.WriteCell(client > 0 ? GetClientSerial(client) : 0);
		dp.WriteCell(i);

		g_mysql.Query(SQLCPSetup, query, dp, DBPrio_Normal);
	}

	return;
}

public void SQLCPSetup(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSetup: %s", error);
	}

	else if(strlen(error) == 0)
	{
		dp.Reset();

		int client = GetClientFromSerial(dp.ReadCell());
		int cp = dp.ReadCell();

		delete dp;

		if(results.FetchRow() == true)
		{
			int result[2] = {0, 3};

			for(int i = 0; i <= 2; i++)
			{
				g_cpPos[cp][0][i] = results.FetchFloat(result[0]++);
				g_cpPos[cp][1][i] = results.FetchFloat(result[1]++);
			}

			if(g_devmap == false)
			{
				CreateCP(cp);
			}

			g_cpCount++;
		}

		if(cp == 10)
		{
			if(client > 0)
			{
				ZoneEditor2(client);
			}

			if(g_zoneHave[2] == false)
			{
				g_zoneHave[2] = true;
			}

			if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true)
					{
						OnClientPutInServer(i);
					}
				}
			}
		}
	}

	return;
}

stock void CreateCP(int cpnum)
{
	char trigger[32] = "";
	Format(trigger, sizeof(trigger), "trueexpert_cp%i", cpnum);

	int entity = CreateEntityByName("trigger_multiple", -1);

	DispatchKeyValue(entity, "spawnflags", "1"); //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0");
	DispatchKeyValue(entity, "targetname", trigger);

	DispatchSpawn(entity);

	SetEntityModel(entity, "models/player/t_arctic.mdl");

	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	for(int i = 0; i <= 2; i++)
	{
		g_center[cpnum + 1][i] = (g_cpPos[cpnum][1][i] + g_cpPos[cpnum][0][i]) / 2.0;
	}

	TeleportEntity(entity, g_center[cpnum + 1], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 1; i++)
	{
		mins[i] = (g_cpPos[cpnum][0][i] - g_cpPos[cpnum][1][i]) / 2.0;

		if(mins[i] > 0.0)
		{
			mins[i] *= -1.0;
		}

		maxs[i] = (g_cpPos[cpnum][0][i] - g_cpPos[cpnum][1][i]) / 2.0;

		if(maxs[i] < 0.0)
		{
			maxs[i] *= -1.0;
		}
	}

	maxs[2] = 124.0;

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0); //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch);

	PrintToServer("Checkpoint number %i is successfuly setup.", cpnum);

	return;
}

public Action cmd_createusers(int args)
{
	g_mysql.Query(SQLCreateUserTable, "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT, username VARCHAR(64), steamid INT, firstjoin INT, lastjoin INT, points INT, PRIMARY KEY(id))");

	return Plugin_Continue;
}

public void SQLCreateUserTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateUserTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Successfuly created user table.");
	}

	return;
}

public Action cmd_createrecords(int args)
{
	g_mysql.Query(SQLRecordsTable, "CREATE TABLE IF NOT EXISTS records (id INT AUTO_INCREMENT, playerid INT, partnerid INT, time FLOAT, finishes INT, tries INT, cp1 FLOAT, cp2 FLOAT, cp3 FLOAT, cp4 FLOAT, cp5 FLOAT, cp6 FLOAT, cp7 FLOAT, cp8 FLOAT, cp9 FLOAT, cp10 FLOAT, points INT, map VARCHAR(192), date INT, PRIMARY KEY(id))");

	return Plugin_Continue;
}

public void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecordsTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Successfuly created records table.");
	}

	return;
}

public Action SDKEndTouch(int entity, int other)
{
	if(IsValidClient(other) == true && IsValidPartner(other) == true && IsFakeClient(other) == false && g_timerReadyToStart[g_partner[other]] == true)
	{
		int partner = g_partner[other];

		g_timerState[other] = true;
		g_timerState[partner] = true;

		g_mapFinished[other] = false;
		g_mapFinished[partner] = false; //expert zone idea

		//g_timerTimeStart[other] = GetEngineTime();
		//g_timerTimeStart[partner] = GetEngineTime();

		g_timerTimeStart[other] = float(GetGameTickCount());
		g_timerTimeStart[partner] = float(GetGameTickCount());

		g_timerReadyToStart[other] = false;
		g_timerReadyToStart[partner] = false;

		CreateTimer(0.1, timer_clantag, other, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, timer_clantag, partner, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		for(int i = 1; i <= g_cpCount; i++)
		{
			g_cp[other][i] = false;
			g_cp[partner][i] = false;

			g_cpLock[other][i] = false;
			g_cpLock[partner][i] = false;
		}

		static GlobalForward hForward = null;
		hForward = new GlobalForward("Trikz_OnTimerStart", ET_Hook, Param_Cell, Param_Cell);
		Call_StartForward(hForward);
		Call_PushCell(other);
		Call_PushCell(partner);
		Call_Finish();
		delete hForward;

		char query[512] = "";
		Format(query, sizeof(query), "SELECT * FROM records LIMIT 1");
		g_mysql.Query(SQLSetTries, query, GetClientSerial(other), DBPrio_High);
	}

	return Plugin_Continue;
}

public Action SDKTouch(int entity, int other)
{
	if(!(GetEntityFlags(other) & FL_ONGROUND))
	{
		SDKEndTouch(entity, other);
	}

	return Plugin_Continue;
}

public Action SDKStartTouch(int entity, int other)
{
	if(IsValidClient(other) == true && g_devmap == false && IsFakeClient(other) == false)
	{
		char trigger[32] = "";
		GetEntPropString(entity, Prop_Data, "m_iName", trigger, sizeof(trigger), 0);

		int partner = g_partner[other];

		if(StrEqual(trigger, "trueexpert_startzone", false) == true && g_mapFinished[partner] == true)
		{
			Restart(other, false); //expert zone idea.
		}

		else if(StrEqual(trigger, "trueexpert_endzone", false) == true)
		{
			g_mapFinished[other] = true;

			if(g_mapFinished[partner] == true && g_timerState[other] == true)
			{
				char name[MAX_NAME_LENGTH] = "";
				GetClientName(other, name, sizeof(name));

				char namePartner[MAX_NAME_LENGTH] = "";
				GetClientName(partner, namePartner, sizeof(namePartner));

				float time = g_timerTime[other];

				char timeOwn[24] = "";
				FormatSeconds(time, timeOwn);

				float timeDiff = 0.0;
				
				bool record = false;

				if(g_ServerRecordTime > time)
				{
					timeDiff = g_ServerRecordTime - time;

					record = true;
				}

				else if(g_ServerRecordTime <= time)
				{
					timeDiff = time - g_ServerRecordTime;
				}

				char timeSR[24] = "";
				FormatSeconds(timeDiff, timeSR);

				if(record == true)
				{
					Format(timeSR, sizeof(timeSR), "-%s", timeSR);
				}

				else if(record == false)
				{
					Format(timeSR, sizeof(timeSR), "+%s", timeSR);
				}

				char format[256] = "";
				char query[512] = "";

				int playerid = GetSteamAccountID(other);
				int partnerid = GetSteamAccountID(partner);

				if(g_ServerRecordTime > 0.0)
				{
					if(g_teamRecord[other] > 0.0)
					{
						if(g_ServerRecordTime > time)
						{
							for(int i = 1; i <= MaxClients; i++)
							{
								if(IsClientInGame(i) == true)
								{
									Format(format, sizeof(format), "%T", "NewServerRecord", i);
									SendMessage(i, format); //smth like shavit functions.

									Format(format, sizeof(format), "%T", "NewServerRecordDetail", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, format);
								}
							}

							FinishMSG(other, false, true, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, true, false, false, false, 0, timeOwn, timeSR);

							Format(query, sizeof(query), "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' ORDER BY time ASC LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_mysql.Query(SQLUpdateRecord, query, _, DBPrio_Normal);

							g_haveRecord[other] = time;
							g_haveRecord[partner] = time; //logs help also expert zone ideas.

							g_teamRecord[other] = time;
							g_teamRecord[partner] = time;

							g_ServerRecord = true;
							g_ServerRecordTime = time;

							float sourcetvCV = gCV_sourceTV.FloatValue;

							if(sourcetvCV == 1.0)
							{
								CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE);
							}

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
							Call_StartForward(hForward);
							Call_PushCell(other);
							Call_PushCell(partner);
							Call_PushFloat(time);
							Call_PushFloat(timeDiff);
							Call_PushString("ServerRecord1");
							Call_Finish();
							delete hForward;
						}

						else if(g_ServerRecordTime <= time >= g_teamRecord[other])
						{
							for(int i = 1; i <= MaxClients; i++)
							{
								if(IsClientInGame(i) == true)
								{
									Format(format, sizeof(format), "%T", "Passed", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, format);
								}
							}
							
							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(query, sizeof(query), "UPDATE records SET finishes = finishes + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
							g_mysql.Query(SQLUpdateRecord, query, _, DBPrio_Normal);

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_OnFinish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
							Call_StartForward(hForward);
							Call_PushCell(other);
							Call_PushCell(partner);
							Call_PushFloat(time);
							Call_PushFloat(timeDiff);
							Call_PushString("Finish1");
							Call_Finish();
							delete hForward;
						}

						else if(g_ServerRecordTime <= time < g_teamRecord[other])
						{
							for(int i = 1; i <= MaxClients; i++)
							{
								if(IsClientInGame(i) == true)
								{
									Format(format, sizeof(format), "%T", "PassedImproved", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, format);
								}
							}
							
							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(query, sizeof(query), "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_mysql.Query(SQLUpdateRecord, query, _, DBPrio_Normal);

							if(g_haveRecord[other] > time)
							{
								g_haveRecord[other] = time;
							}

							if(g_haveRecord[partner] > time)
							{
								g_haveRecord[partner] = time;
							}

							if(g_teamRecord[other] > time)
							{
								g_teamRecord[other] = time;
								g_teamRecord[partner] = time;
							}

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_Finish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
							Call_StartForward(hForward);
							Call_PushCell(other);
							Call_PushCell(partner);
							Call_PushFloat(time);
							Call_PushFloat(timeDiff);
							Call_PushString("Finish2");
							Call_Finish();
							delete hForward;
						}
					}

					else if(g_teamRecord[other] == 0.0)
					{
						if(g_ServerRecordTime > time)
						{
							for(int i = 1; i <= MaxClients; i++)
							{
								if(IsClientInGame(i) == true)
								{
									Format(format, sizeof(format), "%T", "NewServerRecordNew", i);
									SendMessage(i, format); // all this plugin is based on expert zone ideas and log helps, so little bit ping from rumour and some alliedmodders code free and hlmod code free. and ws code free. entityfilter is made from george code. alot ideas i steal for leagal reason. gnu allows to copy codes if author accept it or public plugin.

									Format(format, sizeof(format), "%T", "NewServerRecordNewDetail", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, format);
								}
							}

							FinishMSG(other, false, true, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, true, false, false, false, 0, timeOwn, timeSR);

							Format(query, sizeof(query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_mysql.Query(SQLInsertRecord, query, _, DBPrio_Normal);

							g_haveRecord[other] = time;
							g_haveRecord[partner] = time;

							g_teamRecord[other] = time;
							g_teamRecord[partner] = time;

							g_ServerRecord = true;

							g_ServerRecordTime = time;

							float sourcetvCV = gCV_sourceTV.FloatValue;

							if(sourcetvCV == 1.0)
							{
								CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE);
							}

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
							Call_StartForward(hForward);
							Call_PushCell(other);
							Call_PushCell(partner);
							Call_PushFloat(time);
							Call_PushFloat(timeDiff);
							Call_PushString("ServerRecord2");
							Call_Finish();
							delete hForward;
						}

						else if(g_ServerRecordTime <= time)
						{
							for(int i = 1; i <= MaxClients; i++)
							{
								if(IsClientInGame(i) == true)
								{
									Format(format, sizeof(format), "%T", "JustPassed", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, format);
								}
							}

							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(query, sizeof(query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_mysql.Query(SQLInsertRecord, query, _, DBPrio_Normal);

							if(g_haveRecord[other] == 0.0)
							{
								g_haveRecord[other] = time;
							}

							if(g_haveRecord[partner] == 0.0)
							{
								g_haveRecord[partner] = time;
							}

							g_teamRecord[other] = time;
							g_teamRecord[partner] = time;

							static GlobalForward hForward = null;
							hForward = new GlobalForward("Trikz_Finish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
							Call_StartForward(hForward);
							Call_PushCell(other);
							Call_PushCell(partner);
							Call_PushFloat(time);
							Call_PushFloat(timeDiff);
							Call_PushString("Finish3");
							Call_Finish();
							delete hForward;
						}
					}

					for(int i = 1; i <= g_cpCount; i++)
					{
						if(g_cp[other][i] == true)
						{
							char timeCP[24] = "";
							FormatSeconds(g_cpDiffSR[other][i], timeCP);

							for(int j = 1; j <= MaxClients; j++)
							{
								if(IsClientInGame(j) == true)
								{
									Format(format, sizeof(format), "%T", g_cpTime[other][i] < g_cpTimeSR[i] == true ? "CPImprove" : "CPDeprove", j, i, timeCP);
									SendMessage(j, format);
								}
							}
						}
					}
				}

				else if(g_ServerRecordTime == 0.0)
				{
					g_ServerRecordTime = time;

					g_haveRecord[other] = time;
					g_haveRecord[partner] = time;

					g_teamRecord[other] = time;
					g_teamRecord[partner] = time;

					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) == true)
						{
							Format(format, sizeof(format), "%T", "NewServerRecordFirst", i);
							SendMessage(i, format);

							Format(format, sizeof(format), "%T", "NewServerRecordFirstDetail", i, name, namePartner, timeOwn, timeSR);
							SendMessage(i, format);

							for(int j = 1; j <= g_cpCount; j++)
							{
								if(g_cp[other][j] == true)
								{
									Format(format, sizeof(format), "%T", "CPNEW", i, j, timeSR);
									SendMessage(i, format);
								}
							}
						}
					}

					FinishMSG(other, true, false, false, false, false, 0, timeOwn, timeSR);
					FinishMSG(partner, true, false, false, false, false, 0, timeOwn, timeSR);

					g_ServerRecord = true;

					float sourcetvCV = gCV_sourceTV.FloatValue;

					if(sourcetvCV == 1.0)
					{
						CreateTimer(60.0, timer_sourcetv, _, TIMER_FLAG_NO_MAPCHANGE); //https://forums.alliedmods.net/showthread.php?t=191615
					}

					Format(query, sizeof(query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
					g_mysql.Query(SQLInsertRecord, query, _, DBPrio_Normal);

					static GlobalForward hForward = null;
					hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
					Call_StartForward(hForward);
					Call_PushCell(other);
					Call_PushCell(partner);
					Call_PushFloat(time);
					Call_PushFloat(0.0);
					Call_PushString("FirstServerRecord");
					Call_Finish();
					delete hForward;
				}

				g_timerState[other] = false;
				g_timerState[partner] = false;
			}
		}

		for(int i = 1; i <= g_cpCount; i++)
		{
			char triggerCP[32] = "";
			Format(triggerCP, sizeof(triggerCP), "trueexpert_cp%i", i);

			if(StrEqual(trigger, triggerCP, false) == true)
			{
				g_cp[other][i] = true;

				if(g_cp[i][partner] == true && g_cpLock[partner][i] == false)
				{
					g_cpLock[other][i] = true;
					g_cpLock[partner][i] = true;

					g_cpTime[i][other] = g_timerTime[other];
					g_cpTime[i][partner] = g_timerTime[other];

					char query[512] = ""; //https://stackoverflow.com/questions/9617453 https://www.w3schools.com/sql/sql_ref_order_by.asp#:~:text=%20SQL%20ORDER%20BY%20Keyword%20%201%20ORDER,data%20returned%20in%20descending%20order.%20%20More%20
					Format(query, sizeof(query), "SELECT cp%i FROM records LIMIT 1", i);

					DataPack dp = new DataPack();

					dp.WriteCell(GetClientSerial(other));
					dp.WriteCell(i);

					g_mysql.Query(SQLCPSelect, query, dp, DBPrio_Normal);
				}
			}
		}
	}

	return Plugin_Continue;
}

stock void FinishMSG(int client, bool firstServerRecord, bool serverRecord, bool onlyCP, bool firstCPRecord, bool cpRecord, int cpnum, const char[] time, const char[] timeSR)
{
	if(g_endMessage[client] == false)
	{
		return;
	}

	g_kv.Rewind();

	g_kv.GotoFirstSubKey(true);

	char section[64] = "";
	char posColor[64] = "";
	char exploded[7][8];

	float x[4] = {0.0, ...}, y[4] = {0.0, ...}, z[4] = {0.0, ...};
	int r[4] = {0, ...}, g[4] = {0, ...}, b[4] = {0, ...}, a[4] = {0, ...};

	char format[256] = "";

	if(onlyCP == true)
	{
		if(firstCPRecord == true)
		{
			do
			{
				if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "onlyCP_firstCPRecord", true) == true)
				{
					g_kv.GetString("CP-RecordHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[0] = StringToFloat(exploded[0]);
						y[0] = StringToFloat(exploded[1]);
						z[0] = StringToFloat(exploded[2]);
						
						r[0] = StringToInt(exploded[3]);
						g[0] = StringToInt(exploded[4]);
						b[0] = StringToInt(exploded[5]);
						a[0] = StringToInt(exploded[6]);
					}

					g_kv.GetString("CP-RecordDetailHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[1] = StringToFloat(exploded[0]);
						y[1] = StringToFloat(exploded[1]);
						z[1] = StringToFloat(exploded[2]);
						
						r[1] = StringToInt(exploded[3]);
						g[1] = StringToInt(exploded[4]);
						b[1] = StringToInt(exploded[5]);
						a[1] = StringToInt(exploded[6]);
					}

					g_kv.GetString("CP-DetailZeroHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[2] = StringToFloat(exploded[0]);
						y[2] = StringToFloat(exploded[1]);
						z[2] = StringToFloat(exploded[2]);
						
						r[2] = StringToInt(exploded[3]);
						g[2] = StringToInt(exploded[4]);
						b[2] = StringToInt(exploded[5]);
						a[2] = StringToInt(exploded[6]);
					}
				}
			}

			while(g_kv.GotoNextKey(true) == true);

			//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
			//ShowHudText(client, 1, "%i. CHECKPOINT RECORD!", cpnum); //https://sm.alliedmods.net/new-api/halflife/ShowHudText
			Format(format, sizeof(format), "%T", "CP-recordHud", client, cpnum);
			ShowHudText(client, 1, format);

			//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
			SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
			//ShowHudText(client, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
			Format(format, sizeof(format), "%T", "CP-recordDetailHud", client, time);
			ShowHudText(client, 2, format);
			
			//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
			SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
			//ShowHudText(client, 3, "+00:00:00");
			//Format(format, sizeof(format), "+00:00:00");
			Format(format, sizeof(format), "%T", "CP-DetailZeroHud", client, timeSR);
			ShowHudText(client, 3, format);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsClientObserver(i) == true)
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

					if(observerMode < 7 && observerTarget == client)
					{
						//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
						SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
						//ShowHudText(i, 1, "%i. CHECKPOINT RECORD!", cpnum);
						Format(format, sizeof(format), "%T", "CP-recordHud", i, cpnum);
						ShowHudText(i, 1, format);

						//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
						SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
						//ShowHudText(i, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
						Format(format, sizeof(format), "%T", "CP-recordDetailHud", i, time);
						ShowHudText(i, 2, format);

						//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
						SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
						Format(format, sizeof(format), "%T", "CP-DetailZeroHud", i, timeSR);
						ShowHudText(i, 3, format);
						//ShowHudText(i, 3, "+00:00:00");
					}
				}
			}
		}

		else if(firstCPRecord == false)
		{
			if(cpRecord == true)
			{
				do
				{
					if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "onlyCP_notFirstCPRecord_cpRecord", true) == true)
					{
						g_kv.GetString("CP-RecordNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[0] = StringToFloat(exploded[0]);
							y[0] = StringToFloat(exploded[1]);
							z[0] = StringToFloat(exploded[2]);
							
							r[0] = StringToInt(exploded[3]);
							g[0] = StringToInt(exploded[4]);
							b[0] = StringToInt(exploded[5]);
							a[0] = StringToInt(exploded[6]);
						}

						g_kv.GetString("CP-recordDetailNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[1] = StringToFloat(exploded[0]);
							y[1] = StringToFloat(exploded[1]);
							z[1] = StringToFloat(exploded[2]);
							
							r[1] = StringToInt(exploded[3]);
							g[1] = StringToInt(exploded[4]);
							b[1] = StringToInt(exploded[5]);
							a[1] = StringToInt(exploded[6]);
						}

						g_kv.GetString("CP-recordImproveNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);
							
							x[2] = StringToFloat(exploded[0]);
							y[2] = StringToFloat(exploded[1]);
							z[2] = StringToFloat(exploded[2]);
							
							r[2] = StringToInt(exploded[3]);
							g[2] = StringToInt(exploded[4]);
							b[2] = StringToInt(exploded[5]);
							a[2] = StringToInt(exploded[6]);
						}
					}
				}

				while(g_kv.GotoNextKey(true) == true);

				//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
				SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
				//ShowHudText(client, 1, "%i. CHECKPOINT RECORD!", cpnum); //https://steamuserimages-a.akamaihd.net/ugc/1788470716362427548/185302157bF4CBF4557D0C47842C6BBD705380A/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false
				Format(format, sizeof(format), "%T", "CP-recordNotFirstHud", client, cpnum);
				ShowHudText(client, 1, format);

				//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
				SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
				//ShowHudText(client, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
				Format(format, sizeof(format), "%T", "CP-recordDetailNotFirstHud", client, time);
				ShowHudText(client, 2, format);

				//SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255);
				SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
				Format(format, sizeof(format), "-%s", timeSR);
				Format(format, sizeof(format), "%T", "CP-recordImproveNotFirstHud", client, format);
				ShowHudText(client, 3, format);
				//ShowHudText(client, 3, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsClientObserver(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						if(observerMode < 7 && observerTarget == client)
						{
							//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
							SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
							Format(format, sizeof(format), "%T", "CP-recordNotFirstHud", i, cpnum);
							//ShowHudText(i, 1, "%i. CHECKPOINT RECORD!", cpnum);
							ShowHudText(i, 1, format);

							//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
							SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
							//ShowHudText(i, 2, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
							Format(format, sizeof(format), "%T", "CP-recordDetailNotFirstHud", i, time);
							ShowHudText(i, 2, format);

							//SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255);
							SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
							Format(format, sizeof(format), "%T", "CP-recordImproveNotFirstHud", i, timeSR);
							ShowHudText(i, 3, format);
							//ShowHudText(i, 3, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
						}
					}
				}
			}

			else if(cpRecord == false)
			{
				do
				{
					if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "onlyCP_notFirstCPRecord_notCPRecord", true) == true)
					{
						g_kv.GetString("CP-RecordNonHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[0] = StringToFloat(exploded[0]);
							y[0] = StringToFloat(exploded[1]);
							z[0] = StringToFloat(exploded[2]);
							
							r[0] = StringToInt(exploded[3]);
							g[0] = StringToInt(exploded[4]);
							b[0] = StringToInt(exploded[5]);
							a[0] = StringToInt(exploded[6]);
						}

						g_kv.GetString("CP-RecordDeproveHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);
							x[1] = StringToFloat(exploded[0]);
							y[1] = StringToFloat(exploded[1]);
							z[1] = StringToFloat(exploded[2]);
							
							r[1] = StringToInt(exploded[3]);
							g[1] = StringToInt(exploded[4]);
							b[1] = StringToInt(exploded[5]);
							a[1] = StringToInt(exploded[6]);
						}
					}
				}

				while(g_kv.GotoNextKey(true) == true);

				//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
				SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
				//Format(format, sizeof(format), "%T", "CP-recordDeprove"
				Format(format, sizeof(format), "%T", "CP-recordNonHud", client, time);
				ShowHudText(client, 1, format);
				//ShowHudText(client, 1, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond); //https://steamuserimages-a.akamaihd.net/ugc/1788470716362384940/4DD466582BD1CF04366BBE6D383DD55A079936DC/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false

				//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
				SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
				//ShowHudText(client, 2, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
				//Format(format, sizeof(format), "+%s", timeSR);
				Format(format, sizeof(format), "%T", "CP-recordDeproveHud", client, timeSR);
				ShowHudText(client, 2, format);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsClientObserver(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						if(observerMode < 7 && observerTarget == client)
						{
							//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
							SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
							//ShowHudText(i, 1, "CHECKPOINT: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
							Format(format, sizeof(format), "%T", "CP-recordNonHud", i, time);
							ShowHudText(i, 1, format);

							//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
							SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
							//ShowHudText(i, 2, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
							//Format(format, sizeof(format), "+%s", timeSR);
							Format(format, sizeof(format), "%T", "CP-recordDeproveHud", i, timeSR);
							ShowHudText(i, 2, format);
						}
					}
				}
			}
		}
	}

	else if(onlyCP == false)
	{
		if(firstServerRecord == true)
		{
			do
			{
				if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "notOnlyCP_firstServerRecord", true) == true)
				{
					g_kv.GetString("MapFinishedFirstRecordHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[0] = StringToFloat(exploded[0]);
						y[0] = StringToFloat(exploded[1]);
						z[0] = StringToFloat(exploded[2]);
						
						r[0] = StringToInt(exploded[3]);
						g[0] = StringToInt(exploded[4]);
						b[0] = StringToInt(exploded[5]);
						a[0] = StringToInt(exploded[6]);
					}

					g_kv.GetString("NewServerRecordHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[1] = StringToFloat(exploded[0]);
						y[1] = StringToFloat(exploded[1]);
						z[1] = StringToFloat(exploded[2]);
						
						r[1] = StringToInt(exploded[3]);
						g[1] = StringToInt(exploded[4]);
						b[1] = StringToInt(exploded[5]);
						a[1] = StringToInt(exploded[6]);
					}

					g_kv.GetString("FirstRecordHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[2] = StringToFloat(exploded[0]);
						y[2] = StringToFloat(exploded[1]);
						z[2] = StringToFloat(exploded[2]);
						
						r[2] = StringToInt(exploded[3]);
						g[2] = StringToInt(exploded[4]);
						b[2] = StringToInt(exploded[5]);
						a[2] = StringToInt(exploded[6]);
					}

					g_kv.GetString("FirstRecordZeroHud", posColor, sizeof(posColor));

					//if(strlen(posColor) > 0)
					{
						ExplodeString(posColor, ",", exploded, 7, 8, false);

						x[3] = StringToFloat(exploded[0]);
						y[3] = StringToFloat(exploded[1]);
						z[3] = StringToFloat(exploded[2]);
						
						r[3] = StringToInt(exploded[3]);
						g[3] = StringToInt(exploded[4]);
						b[3] = StringToInt(exploded[5]);
						a[3] = StringToInt(exploded[6]);
					}
				}
			}

			while(g_kv.GotoNextKey(true) == true);

			//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
			//ShowHudText(client, 1, "MAP FINISHED!"); //https://sm.alliedmods.net/new-api/halflife/ShowHudText
			Format(format, sizeof(format), "%T", "MapFinishedFirstRecordHud", client);
			ShowHudText(client, 1, format);

			//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
			SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
			//ShowHudText(client, 2, "NEW SERVER RECORD!");
			Format(format, sizeof(format), "%T", "NewServerRecordHud", client);
			ShowHudText(client, 2, format);

			//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
			SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
			//ShowHudText(client, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
			Format(format, sizeof(format), "%T", "FirstRecordHud", client, time);
			ShowHudText(client, 3, format);

			//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
			SetHudTextParams(x[3], y[3], z[3], r[3], g[3], b[3], a[3]);
			//ShowHudText(client, 4, "+00:00:00");
			Format(format, sizeof(format), "%T", "FirstRecordZeroHud", client, timeSR);
			ShowHudText(client, 4, format);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsClientObserver(i) == true)
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

					if(IsClientSourceTV(i) == true || (observerMode < 7 && observerTarget == client))
					{
						//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255);
						SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
						//ShowHudText(i, 1, "MAP FINISHED!");
						//Format(format, sizeof(format), "%T", "NewServerRecordHud", i);
						Format(format, sizeof(format), "%T", "MapFinishedFirstRecordHud", i);
						ShowHudText(i, 1, format);

						//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
						SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
						//ShowHudText(i, 2, "NEW SERVER RECORD!");
						//ShowHudText(i, 2, "%T", ""
						Format(format, sizeof(format), "%T", "NewServerRecordHud", i);
						ShowHudText(i, 2, format);

						//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
						SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
						//ShowHudText(i, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
						Format(format, sizeof(format), "%T", "FirstRecordHud", i, time);
						ShowHudText(i, 3, format);

						//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
						SetHudTextParams(x[3], y[3], z[3], r[3], g[3], b[3], a[3]);
						//ShowHudText(i, 4, "+00:00:00");
						Format(format, sizeof(format), "%T", "FirstRecordZeroHud", i, timeSR);
						ShowHudText(i, 4, format);
					}
				}
			}
		}

		else if(firstServerRecord == false)
		{
			if(serverRecord == true)
			{
				do
				{
					if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "notOnlyCP_notFirstServerRecord_serverRecord", true) == true)
					{
						g_kv.GetString("NewServerRecordMapFinishedNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[0] = StringToFloat(exploded[0]);
							y[0] = StringToFloat(exploded[1]);
							z[0] = StringToFloat(exploded[2]);
							
							r[0] = StringToInt(exploded[3]);
							g[0] = StringToInt(exploded[4]);
							b[0] = StringToInt(exploded[5]);
							a[0] = StringToInt(exploded[6]);
						}

						g_kv.GetString("NewServerRecordNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[1] = StringToFloat(exploded[0]);
							y[1] = StringToFloat(exploded[1]);
							z[1] = StringToFloat(exploded[2]);
							
							r[1] = StringToInt(exploded[3]);
							g[1] = StringToInt(exploded[4]);
							b[1] = StringToInt(exploded[5]);
							a[1] = StringToInt(exploded[6]);
						}
						
						g_kv.GetString("NewServerRecordDetailNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[2] = StringToFloat(exploded[0]);
							y[2] = StringToFloat(exploded[1]);
							z[2] = StringToFloat(exploded[2]);
							
							r[2] = StringToInt(exploded[3]);
							g[2] = StringToInt(exploded[4]);
							b[2] = StringToInt(exploded[5]);
							a[2] = StringToInt(exploded[6]);
						}

						g_kv.GetString("NewServerRecordImproveNotFirstHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[3] = StringToFloat(exploded[0]);
							y[3] = StringToFloat(exploded[1]);
							z[3] = StringToFloat(exploded[2]);
							
							r[3] = StringToInt(exploded[3]);
							g[3] = StringToInt(exploded[4]);
							b[3] = StringToInt(exploded[5]);
							a[3] = StringToInt(exploded[6]);
						}
					}
				}

				while(g_kv.GotoNextKey(true) == true);

				//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255);
				SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
				Format(format, sizeof(format), "%T", "NewServerRecordMapFinishedNotFirstHud", client);
				//ShowHudText(client, 1, "MAP FINISHED!");
				//Format(format, sizeof(format), "%T", "NewServerRecordMapFinishedNotFirstHud", client);
				ShowHudText(client, 1, format);

				//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
				SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
				//ShowHudText(client, 2, "NEW SERVER RECORD!");
				Format(format, sizeof(format), "%T", "NewServerRecordNotFirstHud", client);
				ShowHudText(client, 2, format);

				//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
				SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
				//ShowHudText(client, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
				Format(format, sizeof(format), "%T", "NewServerRecordDetailNotFirstHud", client, time);
				ShowHudText(client, 3, format);

				//SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255);
				SetHudTextParams(x[3], y[3], z[3], r[3], g[3], b[3], a[3]);
				//ShowHudText(client, 4, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond); //https://youtu.be/j4L3YvHowv8?t=45
				//Format(format, sizeof(format), "-%s", timeSR);
				Format(format, sizeof(format), "%T", "NewServerRecordImproveNotFirstHud", client, timeSR);
				ShowHudText(client, 4, format);
				
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsClientObserver(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						if(IsClientSourceTV(i) == true || (observerMode < 7 && observerTarget == client))
						{
							//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255);
							SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
							//ShowHudText(i, 1, "MAP FINISHED!");
							Format(format, sizeof(format), "%T", "NewServerRecordMapFinishedNotFirstHud", i);
							ShowHudText(i, 1, format);
							
							//SetHudTextParams(-1.0, -0.75, 3.0, 0, 255, 0, 255);
							SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
							//ShowHudText(i, 2, "NEW SERVER RECORD!");
							Format(format, sizeof(format), "%T", "NewServerRecordNotFirstHud", i);
							ShowHudText(i, 2, format);

							//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
							SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
							//ShowHudText(i, 3, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
							Format(format, sizeof(format), "%T", "NewServerRecordDetailNotFirstHud", i, time);
							ShowHudText(i, 3, format);

							//SetHudTextParams(-1.0, -0.6, 3.0, 0, 255, 0, 255);
							SetHudTextParams(x[3], y[3], z[3], r[3], g[3], b[3], a[3]);
							//ShowHudText(i, 4, "-%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
							Format(format, sizeof(format), "%T", "NewServerRecordImproveNotFirstHud", i, timeSR);
							ShowHudText(i, 4, format);
						}
					}
				}
			}

			else if(serverRecord == false)
			{
				do
				{
					if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, "notOnlyCP_notFirstServerRecord_notServerRecord", true) == true)
					{
						g_kv.GetString("MapFinishedDeproveHud", posColor, sizeof(posColor));

						ExplodeString(posColor, ",", exploded, 7, 8, false);

						//if(strlen(posColor) > 0)
						{
							x[0] = StringToFloat(exploded[0]);
							y[0] = StringToFloat(exploded[1]);
							z[0] = StringToFloat(exploded[2]);
							
							r[0] = StringToInt(exploded[3]);
							g[0] = StringToInt(exploded[4]);
							b[0] = StringToInt(exploded[5]);
							a[0] = StringToInt(exploded[6]);
						}

						g_kv.GetString("MapFinishedTimeDeproveHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[1] = StringToFloat(exploded[0]);
							y[1] = StringToFloat(exploded[1]);
							z[1] = StringToFloat(exploded[2]);
							
							r[1] = StringToInt(exploded[3]);
							g[1] = StringToInt(exploded[4]);
							b[1] = StringToInt(exploded[5]);
							a[1] = StringToInt(exploded[6]);
						}

						g_kv.GetString("MapFinishedTimeDeproveOwnHud", posColor, sizeof(posColor));

						//if(strlen(posColor) > 0)
						{
							ExplodeString(posColor, ",", exploded, 7, 8, false);

							x[2] = StringToFloat(exploded[0]);
							y[2] = StringToFloat(exploded[1]);
							z[2] = StringToFloat(exploded[2]);
							
							r[2] = StringToInt(exploded[3]);
							g[2] = StringToInt(exploded[4]);
							b[2] = StringToInt(exploded[5]);
							a[2] = StringToInt(exploded[6]);
						}
					}
				}

				while(g_kv.GotoNextKey(true) == true);

				//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255);
				SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
				//ShowHudText(client, 1, "MAP FINISHED!");
				Format(format, sizeof(format), "%T", "MapFinishedDeproveHud", client);
				ShowHudText(client, 1, format);

				//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
				SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
				//ShowHudText(client, 2, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
				Format(format, sizeof(format), "%T", "MapFinishedTimeDeproveHud", client, time);
				ShowHudText(client, 2, format);
				
				//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
				SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
				//ShowHudText(client, 3, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
				//Format(format, sizeof(format), "+%s", timeSR);
				Format(format, sizeof(format), "%T", "MapFinishedTimeDeproveOwnHud", client, timeSR);
				ShowHudText(client, 3, format);

				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsClientObserver(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						if(observerMode < 7 && observerTarget == client)
						{
							//SetHudTextParams(-1.0, -0.8, 3.0, 0, 255, 255, 255);
							SetHudTextParams(x[0], y[0], z[0], r[0], g[0], b[0], a[0]);
							Format(format, sizeof(format), "%T", "MapFinishedDeproveHud", i);
							//ShowHudText(i, 1, "MAP FINISHED!");
							ShowHudText(i, 1, format);

							//SetHudTextParams(-1.0, -0.63, 3.0, 255, 255, 255, 255);
							SetHudTextParams(x[1], y[1], z[1], r[1], g[1], b[1], a[1]);
							//ShowHudText(i, 2, "TIME: %02.i:%02.i:%02.i", personalHour, personalMinute, personalSecond);
							Format(format, sizeof(format), "%T", "MapFinishedTimeDeproveHud", i, time);
							ShowHudText(i, 2, format);
							
							//SetHudTextParams(-1.0, -0.6, 3.0, 255, 0, 0, 255);
							SetHudTextParams(x[2], y[2], z[2], r[2], g[2], b[2], a[2]);
							//ShowHudText(i, 3, "+%02.i:%02.i:%02.i", srHour, srMinute, srSecond);
							//Format(format, sizeof(format), "+%s", timeSR);
							Format(format, sizeof(format), "%T", "MapFinishedTimeDeproveOwnHud", i, timeSR);
							ShowHudText(i, 3, format);
						}
					}
				}
			}
		}
	}

	return;
}

public void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLUpdateRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLUpdateRecord callback is finished.");
		#endif
	}

	return;
}

public void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLInsertRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLInsertRecord callback finished.");
		#endif
	}

	return;
}

public Action timer_sourcetv(Handle timer)
{
	ConVar CV_sourcetv = FindConVar("tv_enable");

	bool sourcetv = CV_sourcetv.BoolValue; //https://sm.alliedmods.net/new-api/convars/__raw

	if(sourcetv == true)
	{
		ServerCommand("tv_stoprecord");

		g_sourcetvchangedFileName = false;

		CreateTimer(5.0, timer_runsourcetv, _, TIMER_FLAG_NO_MAPCHANGE);

		g_ServerRecord = false;
	}

	return Plugin_Stop;
}

public Action timer_runsourcetv(Handle timer)
{
	char filenameOld[256] = "";
	Format(filenameOld, sizeof(filenameOld), "%s-%s-%s.dem", g_date, g_time, g_map);

	char filenameNew[256] = "";
	Format(filenameNew, sizeof(filenameNew), "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map);

	RenameFile(filenameNew, filenameOld);
	ConVar CV_sourcetv = FindConVar("tv_enable");

	bool sourcetv = CV_sourcetv.BoolValue; //https://sm.alliedmods.net/new-api/convars/__raw

	if(sourcetv == true)
	{
		PrintToServer("SourceTV is start recording.");

		FormatTime(g_date, sizeof(g_date), "%Y-%m-%d", GetTime());
		FormatTime(g_time, sizeof(g_time), "%H-%M-%S", GetTime());

		ServerCommand("tv_record %s-%s-%s", g_date, g_time, g_map);

		g_sourcetvchangedFileName = true;
	}

	return Plugin_Continue;
}

public void SQLCPSelect(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSelect: %s", error);
	}

	else if(strlen(error) == 0)
	{
		data.Reset();

		int other = GetClientFromSerial(data.ReadCell());
		int cpnum = data.ReadCell();

		delete data;

		char query[512] = "";

		if(results.FetchRow() == false)
		{
			float time = g_timerTime[other];

			char timeOwn[24] = "";
			FormatSeconds(time, timeOwn);

			char timeSR[24] = "+00:00:00";

			int partner = g_partner[other];

			FinishMSG(other, false, false, true, true, false, cpnum, timeOwn, timeSR);
			FinishMSG(partner, false, false, true, true, false, cpnum, timeOwn, timeSR);

			static GlobalForward hForward = null;
			hForward = new GlobalForward("Trikz_OnCheckpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
			Call_StartForward(hForward);
			Call_PushCell(other);
			Call_PushCell(partner);
			Call_PushFloat(time);
			Call_PushFloat(0.0);
			Call_PushString("FirstCPRecord1");
			Call_Finish();
			delete hForward;

			return;
		}

		results.Rewind();

		if(results.FetchRow() == true)
		{
			Format(query, sizeof(query), "SELECT cp%i FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 1", cpnum, g_map); //log help me alot with this stuff, logs palīdzēja atrast kodu un saprast kā tas strādā.

			DataPack dp = new DataPack();

			dp.WriteCell(GetClientSerial(other));
			dp.WriteCell(cpnum);

			g_mysql.Query(SQLCPSelect2, query, dp, DBPrio_Normal);
		}
	}

	return;
}

public void SQLCPSelect2(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSelect2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		data.Reset();

		int other = GetClientFromSerial(data.ReadCell());
		int cpnum = data.ReadCell();

		delete data;

		float time = g_timerTime[other];

		char timeOwn[24] = "";
		FormatSeconds(time, timeOwn);

		char timeSR[24] = "+00:00:00";

		int partner = g_partner[other];

		if(results.FetchRow() == false)
		{
			FinishMSG(other, false, false, true, true, false, cpnum, timeOwn, timeSR);
			FinishMSG(partner, false, false, true, true, false, cpnum, timeOwn, timeSR);

			static GlobalForward hForward = null;
			hForward = new GlobalForward("Trikz_Checkpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
			Call_StartForward(hForward);
			Call_PushCell(other);
			Call_PushCell(partner);
			Call_PushFloat(time);
			Call_PushFloat(0.0);
			Call_PushString("FirstCPRecord2");
			Call_Finish();
			delete hForward;

			return;
		}

		results.Rewind();

		if(results.FetchRow() == true)
		{
			g_cpTimeSR[cpnum] = results.FetchFloat(0);

			if(g_cpTime[other][cpnum] < g_cpTimeSR[cpnum])
			{
				g_cpDiffSR[other][cpnum] = g_cpTimeSR[cpnum] - g_cpTime[other][cpnum];
				g_cpDiffSR[partner][cpnum] = g_cpTimeSR[cpnum] - g_cpTime[other][cpnum];

				float diff = g_cpDiffSR[other][cpnum];
				FormatSeconds(diff, timeSR);

				FinishMSG(other, false, false, true, false, true, cpnum, timeOwn, timeSR);
				FinishMSG(partner, false, false, true, false, true, cpnum, timeOwn, timeSR);

				static GlobalForward hForward = null;
				hForward = new GlobalForward("Trikz_Checkpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
				Call_StartForward(hForward);
				Call_PushCell(other);
				Call_PushCell(partner);
				Call_PushFloat(time);
				Call_PushFloat(diff);
				Call_PushString("CPImprove");
				Call_Finish();
				delete hForward;
			}

			else if(!(g_cpTime[other][cpnum] < g_cpTimeSR[cpnum]))
			{
				g_cpDiffSR[other][cpnum] = g_cpTime[other][cpnum] - g_cpTimeSR[cpnum];
				g_cpDiffSR[partner][cpnum] = g_cpTime[other][cpnum] - g_cpTimeSR[cpnum];

				float diff = g_cpDiffSR[other][cpnum];
				FormatSeconds(diff, timeSR);

				FinishMSG(other, false, false, true, false, false, cpnum, timeOwn, timeSR);
				FinishMSG(partner, false, false, true, false, false, cpnum, timeOwn, timeSR);

				static GlobalForward hForward = null;
				hForward = new GlobalForward("Trikz_Checkpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
				Call_StartForward(hForward);
				Call_PushCell(other);
				Call_PushCell(partner);
				Call_PushFloat(time);
				Call_PushFloat(diff);
				Call_PushString("CPDeprove");
				Call_Finish();

				delete hForward;
			}
		}
	}

	return;
}

public void SQLSetTries(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetTries: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLSetTries callback is finished.");
		#endif

		char query[512] = "";

		int client = GetClientFromSerial(data);

		int playerid = GetSteamAccountID(client);
		int partner = g_partner[client];
		int partnerid = GetSteamAccountID(partner);

		if(results.FetchRow() == false)
		{
			Format(query, sizeof(query), "INSERT INTO records (playerid, partnerid, tries, map, date) VALUES (%i, %i, 1, '%s', %i)", playerid, partnerid, g_map, GetTime());
			g_mysql.Query(SQLSetTriesInserted, query, _, DBPrio_High);

			return;
		}

		results.Rewind();

		if(results.FetchRow() == true)
		{
			Format(query, sizeof(query), "SELECT tries FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
			g_mysql.Query(SQLSetTries2, query, GetClientSerial(client), DBPrio_High);
		}
	}

	return;
}

public void SQLSetTriesInserted(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetTriesInserted: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLSetTriesInserted callback is finished.");
		#endif
	}
}

public void SQLSetTries2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetTries2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLSetTries2 callback is finished.");
		#endif

		char query[512] = "";

		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			int playerid = GetSteamAccountID(client);
			int partner = g_partner[client];
			int partnerid = GetSteamAccountID(partner);

			if(results.FetchRow() == false)
			{
				Format(query, sizeof(query), "INSERT INTO records (playerid, partnerid, tries, map, date) VALUES (%i, %i, 1, '%s', %i)", playerid, partnerid, g_map, GetTime());
				g_mysql.Query(SQLSetTriesInserted, query, _, DBPrio_High);

				return;
			}

			results.Rewind();

			if(results.FetchRow() == true)
			{
				Format(query, sizeof(query), "UPDATE records SET tries = tries + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
				g_mysql.Query(SQLSetTriesUpdated, query, _, DBPrio_Normal);
			}
		}
	}
}

public void SQLSetTriesUpdated(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetTriesUpdated: %s", error);
	}

	else if(strlen(error) == 0)
	{
		#if debug
		PrintToServer("SQLSetTriesUpdated callback is finished.");
		#endif
	}
}

public Action cmd_createzones(int args)
{
	g_mysql.Query(SQLCreateZonesTable, "CREATE TABLE IF NOT EXISTS zones (id INT AUTO_INCREMENT, map VARCHAR(128), type INT, possition_x INT, possition_y INT, possition_z INT, possition_x2 INT, possition_y2 INT, possition_z2 INT, PRIMARY KEY (id))"); //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key

	return Plugin_Continue;
}

public void SQLConnect(Database db, const char[] error, any data)
{
	if(db != INVALID_HANDLE)
	{
		PrintToServer("Successfuly connected to database."); //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/

		g_mysql = db;

		g_mysql.SetCharset("utf8"); //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-core.sp#L2883

		ForceZonesSetup(); //https://sm.alliedmods.net/new-api/dbi/__raw

		g_dbPassed = true; //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-stats.sp#L199

		char query[512] = "";
		Format(query, sizeof(query), "SELECT time FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 1", g_map);
		g_mysql.Query(SQLGetServerRecord, query, _, DBPrio_Normal);

		g_mysql.Query(SQLRecalculatePoints_GetMap, "SELECT map FROM tier", _, DBPrio_Normal);

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true)
			{
				g_mysql.Query(SQLAddUser, "SELECT id FROM users LIMIT 1", GetClientSerial(i), DBPrio_High);

				int steamid = GetSteamAccountID(i);
				Format(query, sizeof(query), "SELECT time FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s' ORDER BY time ASC LIMIT 1", steamid, steamid, g_map);
				g_mysql.Query(SQLGetPersonalRecord, query, GetClientSerial(i), DBPrio_Normal);
			}
		}
	}

	else if(db == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect to database. (%s)", error);
	}

	return;
}

stock void ForceZonesSetup()
{
	char query[512] = "";
	Format(query, sizeof(query), "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0 LIMIT 1", g_map);
	g_mysql.Query(SQLSetZoneStart, query);

	return;
}

public void SQLSetZoneStart(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetZoneStart: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			int result[2] = {0, 3};

			for(int i = 0; i <= 2; i++)
			{
				g_zoneStartOrigin[0][i] = results.FetchFloat(result[0]++);
				g_zoneStartOrigin[1][i] = results.FetchFloat(result[1]++);
			}

			CreateStart();

			char query[512] = "";
			Format(query, sizeof(query), "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1 LIMIT 1", g_map);
			g_mysql.Query(SQLSetZoneEnd, query, _, DBPrio_Normal);
		}
	}

	return;
}

public void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetZoneEnd: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			int result[2] = {0, 3};

			for(int i = 0; i <= 2; i++)
			{
				g_zoneEndOrigin[0][i] = results.FetchFloat(result[0]++);
				g_zoneEndOrigin[1][i] = results.FetchFloat(result[1]++);
			}

			CreateEnd();
		}
	}

	return;
}

public void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateZonesTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Zones table is successfuly created.");
	}

	return;
}

stock void DrawZone(int client, float life, float size, int speed)
{
	float start[12][3];
	float end[12][3];

	for(int i = 0; i <= 2; i++)
	{
		start[0][i] = g_zoneStartOrigin[0][i] < g_zoneStartOrigin[1][i] == true ? g_zoneStartOrigin[0][i] : g_zoneStartOrigin[1][i]; //zones calculation from tengu (tengulawl)
		end[0][i] = g_zoneStartOrigin[0][i] > g_zoneStartOrigin[1][i] == true ? g_zoneStartOrigin[0][i] : g_zoneStartOrigin[1][i];
		start[1][i] = g_zoneEndOrigin[0][i] < g_zoneEndOrigin[1][i] == true ? g_zoneEndOrigin[0][i] : g_zoneEndOrigin[1][i];
		end[1][i] = g_zoneEndOrigin[0][i] > g_zoneEndOrigin[1][i] == true ? g_zoneEndOrigin[0][i] : g_zoneEndOrigin[1][i];
	}

	for(int i = 0; i <= 1; i++)
	{
		start[i][2] += size;
		end[i][2] += size;
	}

	int zones = 1;
	int cpnum = 0;

	if(g_cpCount > 0)
	{
		zones += g_cpCount;

		for(int i = 2; i <= zones; i++)
		{
			cpnum = i - 1; //start count cp from 1.

			for(int j = 0; j <= 2; j++)
			{
				start[i][j] = g_cpPos[cpnum][0][j] < g_cpPos[cpnum][1][j] == true ? g_cpPos[cpnum][0][j] : g_cpPos[cpnum][1][j];
				end[i][j] = g_cpPos[cpnum][0][j] > g_cpPos[cpnum][1][j] == true ? g_cpPos[cpnum][0][j] : g_cpPos[cpnum][1][j];
			}

			start[i][2] += size;
			end[i][2] += size;
		}
	}

	float corners[12][8][3]; //https://github.com/tengulawl/scripting/blob/master/include/tengu_stocks.inc

	for(int i = 0; i <= zones; i++)
	{
		//bottom left front
		corners[i][0] = start[i]; //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L82

		//bottom right front
		corners[i][1] = start[i];
		corners[i][1][0] = end[i][0];

		//bottom right back
		corners[i][2] = end[i];
		corners[i][2][2] = start[i][2];

		//bottom left back
		corners[i][3] = start[i];
		corners[i][3][1] = end[i][1];

		int k = 0;
		int modelType = 0;
		int color[4] = {0, ...};

		if(i == 1)
		{
			modelType = 1;
		}

		else if(i > 1)
		{
			modelType = 2;
		}

		for(int j = 0; j <= 3; j++)
		{
			k = j + 1;

			if(j == 3)
			{
				k = 0;
			}
			
			TE_SetupBeamPoints(corners[i][j], corners[i][k], g_zoneModel[modelType], 0, 0, 0, life, size, size, 0, 0.0, color, speed); //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3050
			TE_SendToClient(client, 0.0);
		}
	}

	return;
}

stock void ResetFactory(int client)
{
	g_timerReadyToStart[client] = true;
	//g_timerTime[client] = 0.0;
	g_timerState[client] = false;

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	g_entityFlags[client] = GetEntityFlags(client);

	g_entityButtons[client] = buttons;

	bool bhop = gCV_bhop.BoolValue;

	if(bhop == true && g_bhop[client] == true && buttons & IN_JUMP && IsPlayerAlive(client) == true && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel", 4, 0) <= 1 && !(GetEntityMoveType(client) & MOVETYPE_LADDER)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
	{
		buttons &= ~IN_JUMP; //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
	}

	//Timer
	if(IsFakeClient(client) == false && g_timerState[client] == true && IsValidPartner(client) == true)
	{
		//g_timerTime[client] = GetEngineTime() - g_timerTimeStart[client];
		g_timerTime[client] = (float(GetGameTickCount()) - g_timerTimeStart[client]) * (GetTickInterval() + 0.000000001);

		//https://forums.alliedmods.net/archive/index.php/t-23912.html ShAyA format OneEyed format second
		int hour = (RoundToFloor(g_timerTime[client]) / 3600) % 24; //https://forums.alliedmods.net/archive/index.php/t-187536.html
		int minute = (RoundToFloor(g_timerTime[client]) / 60) % 60;
		int second = RoundToFloor(g_timerTime[client]) % 60;

		if(hour > 0)
		{
			Format(g_clantag[client][1], 256, "%02.i:%02.i:%02.i  ", hour, minute, second);
		}

		else if(hour == 0)
		{
			Format(g_clantag[client][1], 256, "%02.i:%02.i    ", minute, second);
		}

		if(IsPlayerAlive(client) == false)
		{
			ResetFactory(client);
			ResetFactory(g_partner[client]);
		}
	}

	if(g_skyBoost[client] == 1)
	{
		g_skyBoost[client] = 2;
	}

	else if(g_skyBoost[client] == 2)
	{
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, g_skyVel[client]);

		g_skyBoost[client] = 0;
	}

	if(g_boost[client] > 0)
	{
		float velocity[3] = {0.0, ...};

		if(g_boost[client] == 2)
		{
			velocity[0] = g_clientVel[client][0] - g_nadeVel[client][0];
			velocity[1] = g_clientVel[client][1] - g_nadeVel[client][1];
			velocity[2] = g_nadeVel[client][2];

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

			g_boost[client] = 3;
		}

		else if(g_boost[client] == 3) //Let make loop finish and come back to here.
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity, 0);

			if(g_groundBoost[client] == true)
			{
				velocity[0] += g_nadeVel[client][0];
				velocity[1] += g_nadeVel[client][1];
				velocity[2] += g_nadeVel[client][2];
			}

			else if(g_groundBoost[client] == false)
			{
				velocity[0] += g_nadeVel[client][0] * 0.135;
				velocity[1] += g_nadeVel[client][1] * 0.135;
			}

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity); //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L171-L192

			g_boost[client] = 0;

			g_mlsVel[client][1] = velocity;
			g_mlsVel[client][1][2] = 0.0;

			MLStats(client, false);
		}
	}

	if(IsPlayerAlive(client) == true)
	{
		if(buttons & IN_USE)
		{
			if(GetEntProp(client, Prop_Data, "m_afButtonPressed", 4, 0) & IN_USE)
			{
				g_pingTime[client] = GetEngineTime();
				g_pingLock[client] = false;

				#if debug == true
				PrintToServer("ping 1");
				#endif
			}
		}

		else if(!(buttons & IN_USE))
		{
			if(g_pingLock[client] == false)
			{
				g_pingLock[client] = true;

				#if debug == true
				PrintToServer("ping 2");
				#endif
			}
		}

		bool pingtool = gCV_pingtool.BoolValue;

		if(pingtool == true && g_pingLock[client] == false && GetEngineTime() - g_pingTime[client] >= 0.2)
		{
			g_pingLock[client] = true;

			int entityIndex = EntRefToEntIndex(g_pingModel[client]);

			if(entityIndex > 0)
			{
				char log[256] = "";
				GetEntityClassname(entityIndex, log, sizeof(log));

				if(StrEqual(log, "prop_dynamic", false) == false)
				{
					LogMessage("runcmd: %s", log);
				}

				RemoveEntity(entityIndex);

				g_pingModel[client] = 0;

				if(g_pingTimer[client] != INVALID_HANDLE)
				{
					KillTimer(g_pingTimer[client]);

					g_pingTimer[client] = INVALID_HANDLE;
				}
			}

			int entity = CreateEntityByName("prop_dynamic_override", -1); //https://www.bing.com/search?q=prop_dynamic_override&cvid=0babe0a3c6cd43aa9340fa9c3c2e0f78&aqs=edge..69i57.409j0j1&pglt=299&FORM=ANNTA1&PC=U531

			//SetEntityModel(g_pingModel[client], "models/trueexpert/pingtool/pingtool.mdl");
			SetEntityModel(entity, "models/effects/combineball.mdl");
			DispatchSpawn(entity);

			SetEntProp(entity, Prop_Data, "m_fEffects", 16, 4, 0); //https://pastebin.com/SdNC88Ma https://developer.valvesoftware.com/wiki/Effect_flags

			float start[3] = {0.0, ...};
			float angle[3] = {0.0, ...};
			float end[3] = {0.0, ...};

			GetClientEyePosition(client, start);

			GetClientEyeAngles(client, angle);

			GetAngleVectors(angle, angle, NULL_VECTOR, NULL_VECTOR);

			for(int i = 0; i <= 2; i++)
			{
				angle[i] *= 8192.0;
				end[i] = start[i] + angle[i]; //Thanks to rumour for pingtool original code.
			}

			TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint, TraceEntityFilterPlayer, client);

			if(TR_DidHit(INVALID_HANDLE) == true)
			{
				TR_GetEndPosition(end);

				float normal[3] = {0.0, ...};

				TR_GetPlaneNormal(null, normal); //https://github.com/alliedmodders/sourcemod/commit/1328984e0b4cb2ca0ee85eaf9326ab97df910483

				GetVectorAngles(normal, normal);

				GetAngleVectors(normal, angle, NULL_VECTOR, NULL_VECTOR);

				for(int i = 0; i <= 2; i++)
				{
					end[i] += angle[i];
				}

				//normal[0] -= 270.0;
				normal[0] -= 360.0;

				SetEntPropVector(entity, Prop_Data, "m_angRotation", normal, 0);
			}

			SetEntityRenderColor(entity, g_colorBuffer[client][1][0], g_colorBuffer[client][1][1], g_colorBuffer[client][1][2], 255);

			TeleportEntity(entity, end, NULL_VECTOR, NULL_VECTOR);

			//https://forums.alliedmods.net/showthread.php?p=1080444
			int color[4] = {0, 0, 0, 255};
			color = g_colorBuffer[client][1];

			start[2] -= 8.0;

			TE_SetupBeamPoints(start, end, g_laserBeam, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, color, 0);

			if(LibraryExists("trueexpert-entityfilter") == true)
			{
				SDKHook(entity, SDKHook_SetTransmit, SDKSetTransmitPing);

				g_pingModelOwner[entity] = client;

				int clients[MAXPLAYER] = {0, ...}; //64 + 1
				int count = 0;

				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						//if(g_partner[client] == g_partner[g_partner[i]] || i == client)
						if(g_partner[client] == g_partner[g_partner[i]] || i == client || ((observerTarget == client || observerTarget == g_partner[client]) && observerMode < 7))
						{
							clients[count++] = i;
							//PrintToServer("%N", i);
						}
					}
				}

				TE_Send(clients, count, 0.0);

				//EmitSound(clients, count, "trueexpert/pingtool/click.wav", client);
				EmitSound(clients, count, "items/gift_drop.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}

			else if(LibraryExists("trueepxert-entityfilter") == false)
			{
				TE_SendToAll(0.0);

				//EmitSoundToAll("trueexpert/pingtool/click.wav", client);
				EmitSoundToAll("items/gift_drop.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}

			g_pingTimer[client] = CreateTimer(5.0, timer_removePing, client, TIMER_FLAG_NO_MAPCHANGE);

			g_pingModel[client] = EntIndexToEntRef(entity);
		}
	}

	ConVar cvPhysics = FindConVar("sv_turbophysics");

	int physics = cvPhysics.IntValue;

	if(physics == 0)
	{
		if(IsPlayerAlive(client) == true)
		{
			if(g_block[client] == true && GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) != 5)
			{
				SetEntityCollisionGroup(client, 5);
			}

			else if(g_block[client] == false && GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) != 2)
			{
				SetEntityCollisionGroup(client, 2);
			}
		}
	}

	if(g_zoneDraw[client] == true)
	{
		if(GetEngineTime() - g_engineTime >= 0.1)
		{
			g_engineTime = GetEngineTime();

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true)
				{
					DrawZone(i, 0.1, 3.0, 10);

					EyeAngleTestHud(client);
				}
			}
		}
	}

	if(IsClientObserver(client) == true && GetEntProp(client, Prop_Data, "m_afButtonPressed", 4, 0) & IN_USE) //Make able to swtich wtih E to the partner via spectate.
	{
		int observerTarget = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget", 0);
		int observerMode = GetEntProp(client, Prop_Data, "m_iObserverMode", 4, 0);

		if(IsValidClient(observerTarget) == true && IsValidPartner(observerTarget) == true && IsPlayerAlive(g_partner[observerTarget]) == true && observerMode < 7)
		{
			SetEntPropEnt(client, Prop_Data, "m_hObserverTarget", g_partner[observerTarget], 0);
		}
	}

	if(GetEngineTime() - g_hudTime[client] >= 0.1)
	{
		g_hudTime[client] = GetEngineTime();

		if(g_zoneDraw[client] == false)
		{
			VelHud(client);
		}
	}

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_mlsCount[client] > 0)
		{
			int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity", 0);

			char class[32] = "";

			if(IsValidEntity(groundEntity) == true)
			{
				GetEntityClassname(groundEntity, class, sizeof(class));
			}

			if(StrEqual(class, "flashbang_projectile", false) == false)
			{
				GetClientAbsOrigin(client, g_mlsDistance[client][1]);

				MLStats(client, true);
			}
		}
	}

	int other = Stuck(client);

	if(IsValidClient(other) == true && IsFakeClient(client) == false && IsPlayerAlive(client) == true && g_block[other] == true)
	{
		if(GetEntProp(other, Prop_Data, "m_CollisionGroup", 4, 0) == 5)
		{
			SetEntityCollisionGroup(other, 2);

			SetEntityRenderColor(other, g_colorBuffer[other][0][0], g_colorBuffer[other][0][1], g_colorBuffer[other][0][2], 125);
		}
	}

	else if(IsFakeClient(client) == false && IsPlayerAlive(client) == true && other == -1 && g_block[client] == true)
	{
		if(GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) == 2)
		{
			SetEntityCollisionGroup(client, 5);

			SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], 255);
		}
	}

	if(buttons & IN_RELOAD)
	{
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed", 4, 0) & IN_RELOAD)
		{
			if(g_restartLock[client][0] == false)
			{
				g_restartHoldTime[client] = GetEngineTime();

				g_restartLock[client][0] = true;
				g_restartLock[client][1] = false;
			}
		}
	}

	else if(!(buttons & IN_RELOAD))
	{
		if(g_restartLock[client][0] == true)
		{
			g_restartLock[client][0] = false;
			g_restartLock[client][1] = false;
		}
	}

	if(g_restartLock[client][0] == true && g_restartLock[client][1] == false && GetEngineTime() - g_restartHoldTime[client] >= 0.7)
	{
		g_restartLock[client][1] = true;

		bool restartCV = gCV_restart.BoolValue;
		bool partnerCV = gCV_partner.BoolValue;

		if(IsValidPartner(client) == true && restartCV == true)
		{
			Restart(client, true);
		}

		else if(IsValidPartner(client) == false && partnerCV == true)
		{
			Partner(client);
		}
	}

	bool macro = gCV_macro.BoolValue;

	if(macro == true && g_macroDisabled[client] == false && IsPlayerAlive(client) == true)
	{
		if(buttons & IN_ATTACK2 && !(buttons & IN_ATTACK) && g_macroOpened[client] == false)
		{
			char classname[32] = "";
			GetClientWeapon(client, classname, sizeof(classname));

			if(StrEqual(classname, "weapon_flashbang", false) == true || StrEqual(classname, "weapon_hegrenade", false) == true || StrEqual(classname, "weapon_smokegrenade", false) == true)
			{
				g_macroTick[client] = 1;

				g_macroOpened[client] = true;
			}
		}

		if(g_macroOpened[client] == true)
		{
			if(g_macroTick[client] <= 2)
			{
				buttons |= IN_ATTACK;
			}

			if(g_macroTick[client] == 13)
			{
				buttons |= IN_JUMP;
			}

			if(g_macroTick[client] >= 13 && !(buttons & IN_ATTACK2))
			{
				g_macroOpened[client] = false;
			}

			if(g_macroTick[client] < 33)
			{
				g_macroTick[client]++;

				if(g_macroTick[client] == 33)
				{
					g_macroOpened[client] = false;
				}
			}
		}
	}

	float fix = GetEngineTime() - g_flashbangTime[client];

	if(fix >= 0.1 && (g_flashbangDoor[client][0] == true || g_flashbangDoor[client][1] == true))
	{
		if(g_flashbangDoor[client][0] == true)
		{
			FakeClientCommandEx(client, "use weapon_flashbang");

			g_flashbangDoor[client][0] = false;
		}

		if(fix >= 0.15 && g_flashbangDoor[client][1] == true)
		{
			SetEntProp(client, Prop_Data, "m_bDrawViewmodel", true, 4, 0);

			g_flashbangDoor[client][1] = false;
		}
	}

	return Plugin_Continue;
}

public Action ProjectileBoostFix(int entity, int other)
{
	if(IsValidClient(other) == true && g_boost[other] == 0 && !(g_entityFlags[other] & FL_ONGROUND))
	{
		float originOther[3] = {0.0, ...};
		GetClientAbsOrigin(other, originOther);

		float originEntity[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", originEntity, 0);

		float maxsEntity[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxsEntity, 0);

		float delta = originOther[2] - originEntity[2] - maxsEntity[2];

		#if debug == true
		PrintToServer("delta: %f", delta);
		#endif

		//Thanks to extremix/hornet for idea from 2019 year summer. Extremix version (if(!(clientOrigin[2] - 5 <= entityOrigin[2] <= clientOrigin[2])) //Calculate for Client/Flash - Thanks to extrem)/tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231 //https://forums.alliedmods.net/showthread.php?t=146241
		if(0.0 < delta < 2.0) //Tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", g_nadeVel[other], 0);
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", g_clientVel[other], 0);

			g_boostTime[other] = GetEngineTime();
			g_groundBoost[other] = g_bouncedOff[entity];

			SetEntProp(entity, Prop_Send, "m_nSolidType", 0, 4, 0); //https://forums.alliedmods.net/showthread.php?t=286568 non model no solid model Gray83 author of solid model types.

			g_flash[other] = EntIndexToEntRef(entity);
			g_boost[other] = 1;

			if(IsFakeClient(other) == false)
			{
				float vel[3] = {0.0, ...};
				GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", vel, 0);
				vel[2] = 0.0;

				g_mlsVel[other][0] = vel;

				g_mlsCount[other]++;

				g_mlsFlyer[other] = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);
			}
		}
	}

	return Plugin_Continue;
}

public Action cmd_devmap(int client, int args)
{
	bool devmap = gCV_devmap.BoolValue;

	if(devmap == false)
	{
		return Plugin_Continue;
	}

	char format[256] = "";

	if(GetEngineTime() - g_devmapTime > 35.0 && GetEngineTime() - g_afkTime > 30.0)
	{
		g_voters = 0;

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false && IsFakeClient(i) == false)
			{
				g_voters++;

				Menu menu = new Menu(devmap_handler);
				menu.SetTitle("%T", g_devmap == true ? "TurnOFFDevmap" : "TurnONDevmap", i);

				Format(format, sizeof(format), "%T", "Yes", i);
				menu.AddItem("yes", format);
				Format(format, sizeof(format), "%T", "No", i);
				menu.AddItem("no", format);

				menu.Display(i, 20);
			}
		}

		g_devmapTime = GetEngineTime();

		CreateTimer(20.0, timer_devmap, TIMER_FLAG_NO_MAPCHANGE);

		char name[MAX_NAME_LENGTH] = "";
		GetClientName(client, name, sizeof(name));

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true)
			{
				Format(format, sizeof(format), "%T", "DevmapStart", i, name);
				SendMessage(i, format);
			}
		}
	}

	else if(GetEngineTime() - g_devmapTime <= 35.0 || GetEngineTime() - g_afkTime <= 30.0)
	{
		Format(format, sizeof(format), "%T", "DevmapNotAllowed", client);
		SendMessage(client, format);
	}

	return Plugin_Handled;
}

public int devmap_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					g_devmapCount[1]++;

					g_voters--;

					Devmap(false);
				}

				case 1:
				{
					g_devmapCount[0]++;

					g_voters--;

					Devmap(false);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action timer_devmap(Handle timer)
{
	//devmap idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	Devmap(true);

	return Plugin_Stop;
}

stock void Devmap(bool force)
{
	if(force == true || g_voters == 0)
	{
		char format[256] = "";
		char float_[8] = "";

		if((g_devmapCount[1] > 0 || g_devmapCount[0] > 0) && g_devmapCount[1] >= g_devmapCount[0])
		{
			if(g_devmap == true)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsFakeClient(i) == false)
					{
						Format(float_, sizeof(float_), "%.0f", (float(g_devmapCount[1]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0);
						Format(format, sizeof(format), "%T", "DevmapWillBeDisabled", i, float_, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, format);
					}
				}
			}

			else if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsFakeClient(i) == false)
					{
						Format(float_, sizeof(float_), "%.0f", (float(g_devmapCount[1]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0);
						Format(format, sizeof(format), "%T", "DevmapWillBeEnabled", i, float_, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, format);
					}
				}
			}

			CreateTimer(5.0, timer_changelevel, g_devmap == true ? false : true, 0);
		}

		else if((g_devmapCount[1] || g_devmapCount[0]) && g_devmapCount[1] <= g_devmapCount[0])
		{
			if(g_devmap == true)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true)
					{
						Format(float_, sizeof(float_), "%.0f", (float(g_devmapCount[0]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0);
						Format(format, sizeof(format), "%T", "DevmapContinue", i, float_, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, format);
					}
				}
			}

			else if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true)
					{
						Format(float_, sizeof(float_), "%.0f", (float(g_devmapCount[0]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0);
						Format(format, sizeof(format), "%T", "DevmapWillNotBe", i, float_, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, format);
					}
				}
			}
		}

		for(int i = 0; i <= 1; i++)
		{
			g_devmapCount[i] = 0;
		}
	}

	return;
}

public Action timer_changelevel(Handle timer, bool value)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidPartner(i) == true)
		{
			ColorTeam(i, false);
		}
	}
	
	g_devmap = value;

	ForceChangeLevel(g_map, "Reason: Devmap");

	if(value == false)
	{
		ServerCommand("sv_nostats 0");
	}

	else if(value == true)
	{
		ServerCommand("sv_nostats 1");
	}

	return Plugin_Stop;
}

public Action cmd_top(int client, int args)
{
	bool top = gCV_top.BoolValue;

	if(top == false)
	{
		return Plugin_Continue;
	}

	CreateTimer(0.1, timer_motd, client, TIMER_FLAG_NO_MAPCHANGE); //OnMapStart() is not work from first try.

	return Plugin_Handled;
}

public Action timer_motd(Handle timer, int client)
{
	if(IsClientInGame(client) == true)
	{
		ConVar hostname = FindConVar("hostname");

		char hostnameBuffer[256] = "";
		hostname.GetString(hostnameBuffer, sizeof(hostnameBuffer));

		char url[192] = "";
		gCV_urlTop.GetString(url, sizeof(url));
		Format(url, sizeof(url), "%s%s", url, g_map);

		ShowMOTDPanel(client, hostnameBuffer, url, MOTDPANEL_TYPE_URL); //https://forums.alliedmods.net/showthread.php?t=232476
	}

	return Plugin_Stop;
}

public Action cmd_afk(int client, int args)
{
	bool afk = gCV_afk.BoolValue;

	if(afk == false)
	{
		return Plugin_Continue;
	}

	char format[256] = "";

	if(GetEngineTime() - g_afkTime > 30.0 && GetEngineTime() - g_devmapTime > 35.0)
	{
		g_voters = 0;

		g_afkClient = client;

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false && IsFakeClient(i) == false)
			{
				if(IsPlayerAlive(i) == true)
				{
					g_afk[i] = true;
				}
				
				if(IsPlayerAlive(i) == false && client != i)
				{
					g_afk[i] = false;

					g_voters++;

					Menu menu = new Menu(afk_handler);
					menu.SetTitle("%T", "AreYouHere?", i);

					Format(format, sizeof(format), "%T", "Yes", i);
					menu.AddItem("yes", format);
					Format(format, sizeof(format), "%T", "No", i);
					menu.AddItem("no", format);

					menu.Display(i, 20);
				}
			}
		}

		g_afkTime = GetEngineTime();

		CreateTimer(20.0, timer_afk, client, TIMER_FLAG_NO_MAPCHANGE);

		char name[MAX_NAME_LENGTH] = "";
		GetClientName(client, name, sizeof(name));

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true)
			{
				Format(format, sizeof(format), "%T", "AFKCHECK", i, name);
				SendMessage(i, format);
			}
		}
	}

	else if(GetEngineTime() - g_afkTime <= 30.0 || GetEngineTime() - g_devmapTime <= 35.0)
	{
		Format(format, sizeof(format), "%T", "AFKCHECK2", client);
		SendMessage(client, format);
	}

	return Plugin_Handled;
}

public int afk_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					g_afk[param1] = true;

					g_voters--;

					AFK(g_afkClient, false);
				}

				case 1:
				{
					g_voters--;

					AFK(g_afkClient, false);
				}
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action timer_afk(Handle timer, int client)
{
	//afk idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	AFK(client, true);

	return Plugin_Stop;
}

stock void AFK(int client, bool force)
{
	if(force == true || g_voters == 0)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsPlayerAlive(i) == false && IsClientSourceTV(i) == false && g_afk[i] == false && client != i)
			{
				KickClient(i, "%T", "AwayFromKeyboard", i);
			}
		}
	}

	return;
}

public Action cmd_noclip(int client, int args)
{
	bool noclip = gCV_noclip.BoolValue;

	if(noclip == false)
	{
		return Plugin_Continue;
	}

	Noclip(client);

	return Plugin_Handled;
}

stock void Noclip(int client)
{
	if(IsValidClient(client) == false)
	{
		return;
	}

	char format[256] = "";

	if(g_devmap == true)
	{
		SetEntityMoveType(client, GetEntityMoveType(client) == MOVETYPE_NOCLIP ? MOVETYPE_WALK : MOVETYPE_NOCLIP);

		if(g_menuOpened[client] == false)
		{
			Format(format, sizeof(format), "%T", GetEntityMoveType(client) == MOVETYPE_NOCLIP ? "NoclipChatON" : "NoclipChatOFF", client);
			SendMessage(client, format);
		}
	}

	else if(g_devmap == false)
	{
		Format(format, sizeof(format), "%T", "DevmapIsOFF", client);
		SendMessage(client, format);
	}

	if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return;
}

public Action cmd_spec(int client, int args)
{
	bool spec = gCV_spec.BoolValue;

	if(spec == false)
	{
		return Plugin_Continue;
	}

	ChangeClientTeam(client, CS_TEAM_SPECTATOR);

	return Plugin_Handled;
}

public Action cmd_hud(int client, int args)
{
	bool hud = gCV_hud.BoolValue;

	if(hud == false)
	{
		return Plugin_Continue;
	}

	HudMenu(client);

	return Plugin_Handled;
}

stock void HudMenu(int client)
{
	g_menuOpenedHud[client] = true;

	Menu menu = new Menu(hud_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("Hud");

	char format[128] = "";
	Format(format, sizeof(format), "%T", g_hudVel[client] == true ? "VelMenuON" : "VelMenuOFF", client);
	menu.AddItem("vel", format, gCV_vel.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(format, sizeof(format), "%T", g_mlstats[client] == true ? "MLStatsMenuON" : "MLStatsMenuOFF", client);
	menu.AddItem("mls", format, gCV_mlstats.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(format, sizeof(format), "%T", g_endMessage[client] == true ? "EndMessageMenuON" : "EndMessageMenuOFF", client);
	menu.AddItem("endmsg", format, gCV_endmsg.BoolValue == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	menu.Display(client, 20);

	return;
}

public int hud_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
		{
			g_menuOpenedHud[param1] = true;
		}

		case MenuAction_Select:
		{
			char value[8] = "";

			switch(param2)
			{
				case 0:
				{
					g_hudVel[param1] = !g_hudVel[param1];

					IntToString(g_hudVel[param1], value, sizeof(value));
					SetClientCookie(param1, g_cookie[0], value);
				}

				case 1:
				{
					g_mlstats[param1] = !g_mlstats[param1];

					IntToString(g_mlstats[param1], value, sizeof(value));
					SetClientCookie(param1, g_cookie[1], value);
				}

				case 2:
				{
					g_endMessage[param1] = !g_endMessage[param1];

					IntToString(g_endMessage[param1], value, sizeof(value));
					SetClientCookie(param1, g_cookie[8], value);
				}
			}

			cmd_hud(param1, 0);
		}

		case MenuAction_Cancel:
		{
			g_menuOpenedHud[param1] = false; //Idea from expert zone.
		}

		case MenuAction_Display:
		{
			g_menuOpenedHud[param1] = true;
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

public Action cmd_vel(int client, int args)
{
	bool vel = gCV_vel.BoolValue;

	if(vel == false)
	{
		return Plugin_Continue;
	}

	g_hudVel[client] = !g_hudVel[client];

	char value[8] = "";
	IntToString(g_hudVel[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[1], value);

	if(g_menuOpenedHud[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_hudVel[client] == true ? "VelChatON" : "VelChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

stock void VelHud(int client)
{
	float vel[3] = {0.0, ...};
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel, 0);
	vel[2] = 0.0;

	//float velXY = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0));

	float velFlat = GetVectorLength(vel);

	if(g_hudVel[client] == true)
	{
		PrintHintText(client, "%.0f", velFlat);
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true && IsPlayerAlive(i) == false && IsClientSourceTV(i) == false)
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 0);

			if(observerMode < 7 && observerTarget == client && g_hudVel[i] == true)
			{
				PrintHintText(i, "%.0f", velFlat);
			}
		}
	}

	return;
}

public Action cmd_mlstats(int client, int args)
{
	bool mlstats = gCV_mlstats.BoolValue;

	if(mlstats == false)
	{
		return Plugin_Continue;
	}

	g_mlstats[client] = !g_mlstats[client];

	char value[8] = "";
	IntToString(g_mlstats[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[1], value);

	if(g_menuOpenedHud[client] == false)
	{
		char format[256] = "";
		Format(format, sizeof(format), "%T", g_mlstats[client] == true ? "MLStatsChatON" : "MLStatsChatOFF", client);
		SendMessage(client, format);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

public Action cmd_button(int client, int args)
{
	bool button = gCV_button.BoolValue;

	if(button == false)
	{
		return Plugin_Continue;
	}

	g_button[client] = !g_button[client];

	char value[8] = "";
	IntToString(g_button[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[2], value);

	char format[256] = "";
	Format(format, sizeof(format), "%T", g_button[client] == true ? "ButtonAnnouncerON" : "ButtonAnnouncerOFF", client);
	SendMessage(client, format);

	return Plugin_Handled;
}

public Action cmd_pbutton(int client, int args)
{
	bool pbutton = gCV_pbutton.BoolValue;

	if(pbutton == false)
	{
		return Plugin_Continue;
	}

	g_pbutton[client] = !g_pbutton[client]; //toggling

	char value[8] = "";
	IntToString(g_pbutton[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[3], value);

	char format[256] = "";
	Format(format, sizeof(format), "%T", g_pbutton[client] == true ? "ButtonAnnouncerPartnerON" : "ButtonAnnouncerPartnerOFF", client);
	SendMessage(client, format);

	return Plugin_Handled;
}

public Action ProjectileBoostFixEndTouch(int entity, int other)
{
	if(other == 0)
	{
		g_bouncedOff[entity] = true; //Get from Tengu github "tengulawl" scriptig "boost-fix.sp".
	}

	return Plugin_Continue;
}

public Action cmd_time(int client, int args)
{
	if(IsPlayerAlive(client) == true)
	{
		//https://forums.alliedmods.net/archive/index.php/t-23912.html //ShAyA format OneEyed format second
		int hour = (RoundToFloor(g_timerTime[client]) / 3600) % 24; //https://forums.alliedmods.net/archive/index.php/t-187536.html
		int minute = (RoundToFloor(g_timerTime[client]) / 60) % 60;
		int second = RoundToFloor(g_timerTime[client]) % 60;

		PrintToChat(client, "Time: %02.i:%02.i:%02.i", hour, minute, second);

		if(IsValidPartner(client) == true)
		{
			PrintToChat(g_partner[client], "Time: %02.i:%02.i:%02.i", hour, minute, second);
		}
	}

	else if(IsPlayerAlive(client) == false)
	{
		int observerTarget = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget", 0);
		int observerMode = GetEntProp(client, Prop_Data, "m_iObserverMode", 4, 0);

		if(observerMode < 7)
		{
			//https://forums.alliedmods.net/archive/index.php/t-23912.html ShAyA format OneEyed format second
			int hour = (RoundToFloor(g_timerTime[observerTarget]) / 3600) % 24; //https://forums.alliedmods.net/archive/index.php/t-187536.html
			int minute = (RoundToFloor(g_timerTime[observerTarget]) / 60) % 60;
			int second = RoundToFloor(g_timerTime[observerTarget]) % 60;

			PrintToChat(client, "Time: %02.i:%02.i:%02.i", hour, minute, second);
		}
	}

	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile", true) != -1)
	{
		g_bouncedOff[entity] = false; //"Tengulawl" "boost-fix.sp".

		SDKHook(entity, SDKHook_StartTouch, ProjectileBoostFix);
		SDKHook(entity, SDKHook_EndTouch, ProjectileBoostFixEndTouch);
	}

	if(StrEqual(classname, "flashbang_projectile", true) == true)
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKProjectile);
	}

	return;
}

public void SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", 0);

	if(IsValidEntity(entity) == true && IsValidEntity(client) == true)
	{
		bool autoflashbang = gCV_autoflashbang.BoolValue;

		if(autoflashbang == true && (g_autoflash[client] == true || IsFakeClient(client) == true))
		{
			SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2, 4, false); //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
		}

		RequestFrame(frame_blockExplosion, entity);

		CreateTimer(1.5, timer_deleteProjectile, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);

		if(g_skinFlashbang[client] > 0)
		{
			SetEntProp(entity, Prop_Data, "m_nModelIndex", g_wModelThrown, 4, 0);
			SetEntProp(entity, Prop_Data, "m_nSkin", g_skinFlashbang[client], 4, 0);
		}

		SetEntityRenderColor(entity, g_colorBuffer[client][1][0], g_colorBuffer[client][1][1], g_colorBuffer[client][1][2], 255);

		bool autoswitch = gCV_autoswitch.BoolValue;
		
		if(autoswitch == true && (g_autoswitch[client] == true || IsFakeClient(client) == true))
		{
			SetEntProp(client, Prop_Data, "m_bDrawViewmodel", false, 4, 0); //Thanks to "Alliedmodders". (2019 year https://forums.alliedmods.net/archive/index.php/t-287052.html)

			g_silentKnife = true;

			FakeClientCommandEx(client, "use weapon_knife");
			
			g_flashbangTime[client] = GetEngineTime();

			g_flashbangDoor[client][0] = true;
			g_flashbangDoor[client][1] = true;
		}
	}

	return;
}

public void frame_blockExplosion(int entity)
{
	if(IsValidEntity(entity) == true)
	{
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", 0, 4, 0); //https://forums.alliedmods.net/showthread.php?t=301667 avoid random blinds.
	}

	return;
}

public Action timer_deleteProjectile(Handle timer, int entity)
{
	if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) == true)
	{
		FlashbangEffect(entity);

		char log[256] = "";
		GetEntityClassname(entity, log, sizeof(log));

		if(StrEqual(log, "flashbang_projectile", false) == false)
		{
			LogMessage("timer_deleteProjectile: %s", log);
		}
		
		RemoveEntity(entity);
	}

	return Plugin_Stop;
}

stock void FlashbangEffect(int entity)
{
	bool filter = LibraryExists("trueexpert-entityfilter");

	float origin[3] = {0.0, ...};
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin, 0);

	TE_SetupSmoke(origin, g_smoke, GetRandomFloat(0.5, 1.5), 100); //https://forums.alliedmods.net/showpost.php?p=2552543&postcount=5

	int clients[MAXPLAYER] = {0, ...};
	int count = 0;

	if(filter == true)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

		if(owner == -1)
		{
			owner = 0;
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false)
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

				//if(g_partner[owner] == g_partner[g_partner[i]] || i == owner)
				if(g_partner[owner] == g_partner[g_partner[i]] || i == owner || ((observerTarget == owner || observerTarget == g_partner[owner]) && observerMode < 7))
				{
					clients[count++] = i;
				}
			}
		}

		TE_Send(clients, count, 0.0);
	}

	else if(filter == false)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

		if(owner == -1)
		{
			owner = 0;
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true)
			{
				//int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget");
				//int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode");

				//if(g_partner[owner] == g_partner[g_partner[i]] || i == owner)
				//if(g_partner[owner] == g_partner[g_partner[i]] || i == owner || (observerTarget == owner && observerMode < 7))
				if(IsFakeClient(owner) == false || i == owner || IsClientObserver(i) == true)
				{
					clients[count++] = i;
				}
			}
		}

		TE_Send(clients, count, 0.0);

		//TE_SendToAll(0.0);
	}

	float dir[3] = {0.0, ...}; //https://forums.alliedmods.net/showthread.php?t=274452
	dir[0] = GetRandomFloat(-1.0, 1.0);
	dir[1] = GetRandomFloat(-1.0, 1.0);
	dir[2] = 1.0; //always up direction.
	TE_SetupSparks(origin, dir, 1, GetRandomInt(1, 2));

	char sample[2][PLATFORM_MAX_PATH] = {"weapons/flashbang/flashbang_explode1.wav", "weapons/flashbang/flashbang_explode2.wav"};

	if(filter == true)
	{
		TE_Send(clients, count, 0.0);

		EmitSound(clients, count, sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}

	else if(filter == false)
	{
		TE_Send(clients, count, 0.0);

		EmitSound(clients, count, sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);

		//TE_SendToAll(0.0); //Idea from "Expert-Zone". So, we just made non empty event.

		//EmitSoundToAll(sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0); //https://www.youtube.com/watch?v=0Dep7RXhetI&list=PL_2MB6_9kLAHnA4mS_byUpgpjPgETJpsV&index=171 https://github.com/Smesh292/Public-SourcePawn-Plugins/blob/master/trikz.sp#L23 So via "GCFScape" we can found "sound/weapons/flashbang", there we can use 2 sounds as random. flashbang_explode1.wav and flashbang_explode2.wav. These sound are similar, so, better to mix via random. https://forums.alliedmods.net/showthread.php?t=167638 https://world-source.ru/forum/100-2357-1 https://sm.alliedmods.net/new-api/sdktools_sound/__raw
	}

	return;
}

public Action SDKOnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR, 0); //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR, 0);

	return Plugin_Handled; //Full god-mode.
}

public void SDKWeaponEquip(int client, int weapon) //https://sm.alliedmods.net/new-api/sdkhooks/__raw Thanks to Lon for gave this idea. (aka trikz_failtime)
{
	bool autoflashbang = gCV_autoflashbang.BoolValue;

	if(autoflashbang == true)
	{
		RequestFrame(rf_giveflashbang, client); //replays drops knife
	}

	return;
}

public Action SDKWeaponDrop(int client, int weapon)
{
	if(IsValidEntity(weapon) == true)
	{
		char log[256] = "";
		GetEntityClassname(weapon, log, sizeof(log));

		if(StrContains(log, "weapon", false) == -1)
		{
			LogMessage("SDKWeaponDrop: %s", log);
		}

		RemoveEntity(weapon);
	}

	return Plugin_Continue;
}

stock void GiveFlashbang(int client)
{
	bool autoflashbang = gCV_autoflashbang.BoolValue;
	
	if(autoflashbang == true && IsClientInGame(client) == true && (g_autoflash[client] == true || IsFakeClient(client) == true) && IsPlayerAlive(client) == true)
	{
		if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 4) == 0)
		{
			GivePlayerItem(client, "weapon_flashbang", 0);
			GivePlayerItem(client, "weapon_flashbang", 0);
		}

		if(GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == -1)
		{
			GivePlayerItem(client, "weapon_knife", 0);
		}
	}

	return;
}

public bool TraceEntityFilterPlayer(int entity, int contentMask, int client)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		if(Trikz_GetEntityFilter(client, entity) == false)
		{
			if(entity > MaxClients)
			{
				return true;
			}
		}
	}

	else if(LibraryExists("trueexpert-entityfilter") == false)
	{
		if(entity > MaxClients)
		{
			return true;
		}
	}

	return false;
}

public bool TraceEntityFilterPlayerGround(int entity, int contentsMask, any data)
{
	if(entity == data)
	{
		return false;
	}

	return true;
}

public Action timer_removePing(Handle timer, int client)
{
	int entity = EntRefToEntIndex(g_pingModel[client]);

	if(IsValidEntity(entity) == true)
	{
		char log[256] = "";
		GetEntityClassname(g_pingModel[client], log, sizeof(log));

		if(StrEqual(log, "prop_dynamic", false) == false)
		{
			LogMessage("timer_removePing: %s", log);
		}

		RemoveEntity(entity);

		g_pingModel[client] = 0;

		g_pingTimer[client] = INVALID_HANDLE;
	}

	return Plugin_Stop;
}

public Action SDKSetTransmitPing(int entity, int client)
{
	if(IsPlayerAlive(client) == true && g_pingModelOwner[entity] != client && g_partner[g_pingModelOwner[entity]] != g_partner[g_partner[client]])
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action OnSound(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
{
	if(StrEqual(sample, "weapons/knife/knife_deploy1.wav", false) == true && g_silentKnife == true)
	{
		g_silentKnife = false;

		return Plugin_Handled;
	}

	else if(StrEqual(sample, "weapons/ClipEmpty_Rifle.wav", false) == true && g_silentF1F2 == true)
	{
		g_silentF1F2 = false;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action timer_clantag(Handle timer, int client)
{
	if(IsValidClient(client) == true)
	{
		if(g_timerState[client] == true)
		{
			CS_SetClientClanTag(client, g_clantag[client][1]);

			return Plugin_Continue;
		}

		else if(g_timerState[client] == false)
		{
			CS_SetClientClanTag(client, g_clantag[client][0]);
		}
	}

	return Plugin_Stop;
}

stock void MLStats(int client, bool ground)
{
	if(IsFakeClient(client) == true)
	{
		return;
	}
	
	float velPre = GetVectorLength(g_mlsVel[client][0]);
	float velPost = GetVectorLength(g_mlsVel[client][1]);

	int count = g_mlsCount[client];

	Format(g_mlsPrint[client][count], 256, "%i. %.0f - %.0f\n", count, velPre, velPost);

	char print[4][256];

	if(count <= 10)
	{
		for(int i = 1; i <= count <= 10; i++)
		{
			Format(print[0], 256, "%s%s", print[0], g_mlsPrint[client][i]);
		}
	}

	else if(count > 10)
	{
		for(int i = 1; i <= 10; i++)
		{
			Format(print[0], 256, "%s%s", print[0], g_mlsPrint[client][i]);
		}

		Format(print[0], 256, "%s...\n%s", print[0], g_mlsPrint[client][count]);
	}

	int flyer = g_mlsFlyer[client];
	float distance = 0.0;
	char tp[256] = "";

	if(ground == true)
	{
		float x = g_mlsDistance[client][1][0] - g_mlsDistance[client][0][0];
		float y = g_mlsDistance[client][1][1] - g_mlsDistance[client][0][1];
		distance = SquareRoot(Pow(x, 2.0) + Pow(y, 2.0)) + 32.0;

		if(g_teleported[client] == true)
		{
			Format(tp, sizeof(tp), "%T", "MLSTP", flyer);
		}

		//Format(print[1], 256, "%s\n%T: %.0f %T%s", print[0], "MLSDistance", flyer, distance, "MLSUnits", flyer, tp); //player hitbox xy size is 32.0 units. Distance measured from player middle back point. My long jump record on Velo++ server is 279.24 units per 2017 winter. I used logitech g303 for my father present. And smooth mouse pad from glorious gaming. map was trikz_measuregeneric longjump room at 240 block. i grown weed and use it for my self also. 20 januarty.
		Format(print[1], 256, "%s\n%T", print[0], "MLSFinishMsg", flyer, distance, tp);
		PrintToConsole(flyer, "%s", print[1]);

		if(g_teleported[client] == true)
		{
			Format(tp, sizeof(tp), "%T", "MLSTP", client);
		}

		//Format(print[2], 256, "%s\n%T: %.0f %T%s", print[0], "MLSDistance", client, distance, "MLSUnits", client, tp); //player hitbox xy size is 32.0 units. Distance measured from player middle back point. My long jump record on Velo++ server is 279.24 units per 2017 winter. I used logitech g303 for my father present. And smooth mouse pad from glorious gaming. map was trikz_measuregeneric longjump room at 240 block. i grown weed and use it for my self also. 20 januarty.
		Format(print[2], 256, "%s\n%T", print[0], "MLSFinishMsg", client, distance, tp);
		PrintToConsole(client, "%s", print[2]);

		g_mlsCount[client] = 0;

		g_teleported[client] = false;
	}

	if(g_mlstats[flyer] == true)
	{
		Handle KeyHintText = StartMessageOne("KeyHintText", flyer);
		BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
		bfmsg.WriteByte(true);
		bfmsg.WriteString(ground == true ? print[1] : print[0]);
		EndMessage();
	}

	if(g_mlstats[client] == true)
	{
		Handle KeyHintText = StartMessageOne("KeyHintText", client);
		BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
		bfmsg.WriteByte(true);
		bfmsg.WriteString(ground == true ? print[2] : print[0]);
		EndMessage();
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true && IsClientObserver(i) == true)
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

			if(observerMode < 7 && (observerTarget == client || observerTarget == flyer) && g_mlstats[i] == true)
			{
				if(g_teleported[client] == true)
				{
					Format(tp, sizeof(tp), "%T", "MLSTP", i);
				}

				//Format(print[3], 256, "%s\n%T: %.0f %T%s", print[0], "MLSDistance", i, distance, "MLSUnits", i, tp);
				Format(print[3], 256, "%s\n%T", print[0], "MLSFinishMsg", i, distance, tp);

				Handle KeyHintText = StartMessageOne("KeyHintText", i);
				BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
				bfmsg.WriteByte(true);
				bfmsg.WriteString(ground == true ? print[3] : print[0]);
				EndMessage();

				if(ground == true)
				{
					PrintToConsole(i, "%s", print[3]);
				}
			}
		}
	}

	return;
}

stock int Stuck(int client)
{
	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};
	float origin[3] = {0.0, ...};

	GetClientMins(client, mins);

	GetClientMaxs(client, maxs);

	GetClientAbsOrigin(client, origin);

	TR_TraceHullFilter(origin, origin, mins, maxs, MASK_PLAYERSOLID, TR_donthitself, client); //Skiper, Gurman idea, plugin 2020 year.

	return TR_GetEntityIndex();
}

public bool TR_donthitself(int entity, int mask, int client)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		if(entity != client && IsValidClient(entity) == true && g_partner[entity] == g_partner[g_partner[client]])
		{
			return true;
		}
	}

	else if(LibraryExists("trueexpert-entityfilter") == false)
	{
		if(entity != client && IsValidClient(entity) == true)
		{
			return true;
		}
	}

	return false;
}

public int Native_GetClientButtons(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_entityButtons[client];
}

public int Native_GetClientPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_partner[client];
}

public int Native_GetTimerState(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if(g_timerState[client] == true)
	{
		return true;
	}

	else //at else if(g_timerState[client] == false) waring with return value
	{
		return false;
	}
}

public int Native_SetPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int partner = GetNativeCell(2);

	g_partner[client] = partner;
	g_partner[partner] = client;

	return numParams;
}

public int Native_Restart(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool ask = GetNativeCell(2);
	
	Restart(client, ask);

	return numParams;
}

public int Native_GetDevmap(Handle plugin, int numParams)
{
	return g_devmap;
}

stock float GetGroundPos(int client) //https://forums.alliedmods.net/showpost.php?p=1042515&postcount=4
{
	float origin[3] = {0.0, ...};
	GetClientAbsOrigin(client, origin);

	float originDir[3] = {0.0, ...};
	GetClientAbsOrigin(client, originDir);

	originDir[2] -= 90.0;

	float mins[3] = {0.0, ...};
	GetClientMins(client, mins);

	float maxs[3] = {0.0, ...};
	GetClientMaxs(client, maxs);

	float pos[3] = {0.0, ...};
	TR_TraceHullFilter(origin, originDir, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayerGround, client);

	TR_GetEndPosition(pos);

	if(TR_DidHit(INVALID_HANDLE) == true)
	{
		return pos[2];
	}

	return pos[2];
}

/*public int GetColor(const int r, const int g, const int b, const int a)
{
	int color = 0;

	color |= (r & 255) << 24;
	color |= (g & 255) << 16;
	color |= (b & 255) << 8;
	color |= (a & 255) << 0;

	return color;
}*/

stock MRESReturn DHooksOnTeleport(int client, Handle hParams) //https://github.com/fafa-junhe/My-srcds-plugins/blob/0de19c28b4eb8bdd4d3a04c90c2489c473427f7a/all/teleport_stuck_fix.sp#L84
{
	bool originNull = DHookIsNullParam(hParams, 1);
	
	if(originNull == true)
	{
		return MRES_Ignored;
	}
	
	float origin[3] = {0.0, ...};
	DHookGetParamVector(hParams, 1, origin);

	if(g_mlsCount[client] > 0)
	{
		g_teleported[client] = true;
	}

	static GlobalForward hForward = null; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp
	hForward = new GlobalForward("Trikz_OnTeleport", ET_Ignore, Param_Cell, Param_Array);
	Call_StartForward(hForward);
	Call_PushCell(client);
	Call_PushArray(origin, 3);
	Call_Finish();
	delete hForward;
	
	return MRES_Ignored;
}

stock void EyeAngleTestHud(int client)
{
	float eye[3] = {0.0, ...};
	GetClientEyeAngles(client, eye);

	//PrintToServer("%f", eye[1]);

	if(-35.0 >= eye[1] >= -135.0)
	{
		PrintHintText(client, "x/mins");
	}

	else if(135.0 <= eye[1] >= -135.0)
	{
		PrintHintText(client, "y/mins");
	}

	else if(-45.0 <= eye[1] <= 45.0)
	{
		PrintHintText(client, "x/maxs");
	}

	else if(45.0 <= eye[1] <= 135.0)
	{
		PrintHintText(client, "y/maxs");
	}

	return;
}

stock void FormatSeconds(float time, char[] format)
{
	//https://forums.alliedmods.net/archive/index.php/t-23912.html ShAyA format OneEyed format second
	int hour = (RoundToFloor(time) / 3600) % 24; //https://forums.alliedmods.net/archive/index.php/t-187536.html
	int minute = (RoundToFloor(time) / 60) % 60;
	int second = RoundToFloor(time) % 60;

	Format(format, 24, "%02.i:%02.i:%02.i", hour, minute, second);

	return;
}

public void rf_giveflashbang(int client)
{
	GiveFlashbang(client);

	return;
}

stock void GetPoints(int client, char[] points)
{
	float precentage = float(g_points[client]) / float(g_pointsMaxs) * 100.0;

	char color[8] = "";

	if(precentage >= 90.0)
	{
		Format(color, sizeof(color), "FF8000");
	}

	else if(90.0 > precentage >= 70.0)
	{
		Format(color, sizeof(color), "A335EE");
	}

	else if(70.0 > precentage >= 55.0)
	{
		Format(color, sizeof(color), "0070DD");
	}

	else if(55.0 > precentage >= 40.0)
	{
		Format(color, sizeof(color), "1EFF00");
	}

	else if(40.0 > precentage >= 15.0)
	{
		Format(color, sizeof(color), "FFFFFF");
	}

	else if(15.0 > precentage >= 0.0)
	{
		Format(color, sizeof(color), "9D9D9D"); //https://wowpedia.fandom.com/wiki/Quality
	}

	if(g_points[client] < 1000)
	{
		Format(points, 32, "\x07%s%i\x01", color, g_points[client]);
	}

	else if(g_points[client] >= 1000)
	{
		Format(points, 32, "\x07%s%iK\x01", color, g_points[client] / 1000);
	}

	else if(g_points[client] >= 1000000)
	{
		Format(points, 32, "\x07%s%iM\x01", color, g_points[client] / 1000000);
	}

	return;
}
