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

#define ZoneStart 0
#define ZoneEnd 1
#define ZoneCP 2

//Partner system
int g_partner[MAXPLAYER] = {0, ...};

//Timer system
float g_zoneStartOrigin[2][3], //start zone corner1 and corner2
		g_zoneEndOrigin[2][3], //end zone corner1 and corner2
		g_zoneStartOriginTemp[MAXPLAYER][2][3],
		g_zoneEndOriginTemp[MAXPLAYER][2][3],
		g_timerTimeStart[MAXPLAYER] = {0.0, ...},
		g_timerTime[MAXPLAYER] = {0.0, ...},
		g_timerStartPos[3] = {0.0, ...},
		g_haveRecord[MAXPLAYER] = {0.0, ...},
		g_ServerRecordTime = 0.0,
		g_teamRecord[MAXPLAYER] = {0.0, ...},
		g_center[2][3],
		g_top10SR = 0.0,
		g_top10ac = 0.0;
bool g_timerState[MAXPLAYER] = {false, ...},
		g_mapFinished[MAXPLAYER] = {false, ...},
		g_timerReadyToStart[MAXPLAYER] = {false, ...},
		g_zoneHave[3] = {false, ...},
		g_ServerRecord = false;
int g_top10Count = 0;

//SQL system
Database g_sql = null;
bool g_dbPassed = false;

//Map name storage system
char g_map[192] = "";

//Timer-CP system
float g_cpPos[11][2][3],
		g_cpPosTemp[MAXPLAYER][11][2][3],
		g_cpTime[MAXPLAYER][11],
		g_cpDiffSR[MAXPLAYER][11],
		g_cpTimeSR[11] = {0.0, ...},
		g_centerCP[11][3];
bool g_cp[MAXPLAYER][11],
		g_cpLock[MAXPLAYER][11];
int g_cpCountTryToAlign[MAXPLAYER] = {0, ...},
		g_cpCount = 0;

//Console varible system
ConVar gCV_urlTop = null,
		gCV_trikz = null,
		gCV_block = null,
		gCV_partner = null,
		gCV_color = null,
		gCV_restart = null,
		gCV_checkpoint = null,
		gCV_afk = null,
		gCV_noclip = null,
		gCV_spec = null,
		gCV_button = null,
		gCV_bhop = null,
		gCV_autoswitch = null,
		gCV_autoflashbang = null,
		gCV_macro = null,
		gCV_pingtool = null,
		gCV_boostfix = null,
		gCV_devmap = null,
		gCV_hud = null,
		gCV_endmsg = null,
		gCV_top10 = null,
		gCV_control = null,
		gCV_top = null,
		gCV_mlstats = null,
		gCV_vel = null,
		gCV_sourceTV = null;

//Game menu system
bool g_menuOpened[MAXPLAYER] = {false, ...},
		g_menuOpenedHud[MAXPLAYER] = {false, ...},
		g_autoflash[MAXPLAYER] = {false, ...},
		g_autoswitch[MAXPLAYER] = {false, ...},
		g_bhop[MAXPLAYER] = {false, ...};

//Boost-fix system
int g_boost[MAXPLAYER] = {0, ...},
		g_skyBoost[MAXPLAYER] = {0, ...},
		g_flash[MAXPLAYER] = {0, ...},
		g_entityFlags[MAXPLAYER] = {0, ...};
bool g_bouncedOff[MAXENTITY] = {false, ...},
		g_groundBoost[MAXPLAYER] = {false, ...};

//Devmap system
int g_devmapCount[2] = {0, ...};
bool g_devmap = false;
float g_devmapTime = 0.0;

//CP-TP system
float g_cpOrigin[MAXPLAYER][2][3],
		g_cpAng[MAXPLAYER][2][3],
		g_cpVel[MAXPLAYER][2][3];
bool g_cpToggled[MAXPLAYER][2];

//Date storage system
char g_date[64] = "";

//Time storage system
char g_time[64] = "";

//Silent knife system
bool g_silentKnife = false;

//SourceTV system
bool g_sourcetv = false,
		g_sourcetvchangedFileName = true;

//Collision system
bool g_block[MAXPLAYER] = {false, ...};

//Skin system
int g_wModelThrown = 0,
	g_class[MAXPLAYER] = {0, ...},
	g_wModelPlayer[5] = {0, ...},
	g_skinFlashbang[MAXPLAYER] = {0, ...},
	g_skinPlayer[MAXPLAYER] = {0, ...};

//Ping system
int g_pingModel[MAXPLAYER] = {0, ...},
	g_pingModelOwner[MAXENTITY] = {0, ...};
Handle g_pingTimer[MAXPLAYER] = {INVALID_HANDLE, ...};
float g_pingTime[MAXPLAYER] = {0.0, ...};
bool g_pingLock[MAXPLAYER] = {false, ...};

//Cookie preference system
Handle g_cookie[12] = {INVALID_HANDLE, ...};

//Coloring system
char g_colorType[][] = {"255,255,255,white", "44,44,255,blue", "255,0,0,red", "48,203,0,green", "233,215,0,yellow"}; //https://www.color-hex.com/color-palette/ search for warm color type
int g_colorBuffer[MAXPLAYER][2][3],
	g_colorCount[MAXPLAYER][2];

//Zone drawing system
int g_zoneModel[3] = {0, ...};
bool g_zoneDraw[MAXPLAYER] = {false, ...};
float g_engineTime[MAXPLAYER] = {0.0, ...};

//Beam system
int g_laser = 0,
	g_laserBeam = 0;

//Boost-fix sysatem
float g_nadeVel[MAXPLAYER][3],
		g_clientVel[MAXPLAYER][3],
		g_boostTime[MAXPLAYER] = {0.0, ...},
		g_skyVel[MAXPLAYER][3];
int g_entityButtons[MAXPLAYER] = {0, ...};

//AFK system
float g_afkTime = 0.0;
bool g_afk[MAXPLAYER] = {false, ...};
int g_afkClient = 0;

//Chat message system
bool g_msg[MAXPLAYER] = {false, ...};

//Vote system
int g_voters = 0;

//HUD system
bool g_hudVel[MAXPLAYER] = {false, ...},
		g_endMessage[MAXPLAYER] = {false, ...};
float g_hudTime[MAXPLAYER] = {0.0, ...};

//Clantag system
char g_clantag[MAXPLAYER][2][256];
bool g_clantagOnce[MAXPLAYER] = {false, ...};

//ML statistics
float g_mlsVel[MAXPLAYER][2][3],
		g_mlsDistance[MAXPLAYER][2][3];
int g_mlsCount[MAXPLAYER] = {0, ...},
	g_mlsBooster[MAXPLAYER] = {0, ...};
ArrayList g_mlsBuffer[MAXPLAYER] = {null, ...};
bool g_mlstats[MAXPLAYER] = {false, ...},
		g_teleported[MAXPLAYER] = {false, ...};

//Button announcements
bool g_button[MAXPLAYER] = {false, ...};

//Sky crouch fix
float g_skyOrigin[MAXPLAYER][3],
		g_skyAble[MAXPLAYER] = {0.0, ...};

//Ranking system
int g_points[MAXPLAYER] = {0, ...},
	g_pointsMaxs = 1,
	g_queryLast = 0;

//Entityfilter entity
native bool Trikz_GetEntityFilter(int client, int entity);

//Restart button holding system
float g_restartHoldTime[MAXPLAYER] = {0.0, ...};
bool g_restartLock[MAXPLAYER][2];

//Flashbang effects
int g_smoke = 0;

//Macro system
bool g_macroDisabled[MAXPLAYER] = {false, ...},
		g_macroOpened[MAXPLAYER] = {false, ...};
int g_macroTick[MAXPLAYER] = {0, ...};

//Flashbang-projectile fix
float g_flashbangTime[MAXPLAYER] = {0.0, ...};
bool g_flashbangDoor[MAXPLAYER][2];

//Dynamic hook system
DynamicHook g_teleport = null;

//Silent button system
bool g_silentF1F2 = false;

//Finsh message system
KeyValues g_kv = null;

//Zone creator system
bool g_zoneDrawed[MAXPLAYER] = {false, ...},
		g_zoneCreator[MAXPLAYER] = {false, ...},
		g_zoneCursor[MAXPLAYER] = {false, ...},
		g_zoneCreatorUseProcess[MAXPLAYER][2],
		g_zoneSelectedCP[MAXPLAYER] = {false, ...},
		g_zoneCPnumReadyToNew[MAXPLAYER] = {false, ...};
int g_axis[MAXPLAYER] = {0, ...},
	g_step[MAXPLAYER] = {1, ...},
	g_ZoneEditor[MAXPLAYER] = {0, ...},
	g_ZoneEditorCP[MAXPLAYER] = {0, ...},
	g_ZoneEditorVIA[MAXPLAYER] = {0, ...},
	g_entityXYZ[MAXPLAYER] = {0, ...},
	g_zoneCreatorSelected[MAXPLAYER] = {0, ...};
char g_axisLater[][] = {"X", "Y", "Z"};
float g_zoneSelected[MAXPLAYER][2][3];

//Game message system
char g_buffer[256] = "";

//Query-SQL system
char g_query[512] = "";

//Timer dissolver
//Handle g_timerDissolver[MAXPLAYER] = {INVALID_HANDLE, ...};

public Plugin myinfo =
{
	name = "TrueExpert",
	author = "Niks Smesh Jurēvičs",
	description = "Allow to make \"trikz\" mode comfortable.",
	version = "4.676",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	//declaration
	int offset;
	Handle gamedata;

	//initialization
	gamedata = LoadGameConfigFile("sdktools.games");
	offset = GameConfGetOffset(gamedata, "Teleport");

	gCV_urlTop = CreateConVar("sm_te_topurl", "typeURLaddress", "Set url for top, for ex (http://www.trueexpert.rf.gd/?start=0&map=). To open web page, type to in-game chat !top", FCVAR_NOTIFY, false, 0.0, false, 0.0);
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
	gCV_top = CreateConVar("sm_te_top", "0.0", "Allow to use !top command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_mlstats = CreateConVar("sm_te_mlstats", "0.0", "Allow to use !mlstats command.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_vel = CreateConVar("sm_te_vel", "0.0", "Allow to use velocity in hint.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_sourceTV = CreateConVar("sm_te_sourcetv", "0.0,", "Save demo only when server record.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "plugin.trueexpert", "sourcemod"); //https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig

	RegConsoleCmd("sm_t", CommandTrikz, "Open trikz menu.");
	RegConsoleCmd("sm_trikz", CommandTrikz, "Open trikz menu.");
	RegConsoleCmd("sm_bl", CommandBlock, "Toggling collsiion state.");
	RegConsoleCmd("sm_block", CommandBlock, "Toggling collsiion state.");
	RegConsoleCmd("sm_p", CommandPartner, "Open partner chooser or breakup menu.");
	RegConsoleCmd("sm_partner", CommandPartner, "Open partner chooser or breakup menu.");
	RegConsoleCmd("sm_c", CommandColor, "Open color and skin changer menu.");
	RegConsoleCmd("sm_color", CommandColor, "Open color and skin changer menu.");
	RegConsoleCmd("sm_r", CommandRestart, "Do restart timer.");
	RegConsoleCmd("sm_restart", CommandRestart, "Do restart timer.");
	RegConsoleCmd("sm_autoflash", CommandAutoflash, "Toggling autoflash giving.");
	RegConsoleCmd("sm_flash", CommandAutoflash, "Toggling autoflash giving.");
	RegConsoleCmd("sm_autoswitch", CommandAutoswitch, "toggling autoswitch.");
	RegConsoleCmd("sm_switch", CommandAutoswitch, "Toggling autoswitch.");
	RegConsoleCmd("sm_cp", CommandCheckpoint, "Open checkpoint menu.");
	RegConsoleCmd("sm_devmap", CommandDevmap, "Start the vote for devmap toggling.");
	RegConsoleCmd("sm_top", CommandTop, "Open motd with server records.");
	RegConsoleCmd("sm_afk", CommandAfk, "Start the vote for afk check.");
	RegConsoleCmd("sm_nc", CommandNoclip, "Toggling noclip.");
	RegConsoleCmd("sm_noclip", CommandNoclip, "Toggling noclip.");
	RegConsoleCmd("sm_sp", CommandSpec, "Switch to spectator team.");
	RegConsoleCmd("sm_spec", CommandSpec, "Switch to specator team.");
	RegConsoleCmd("sm_hud", CommandHud, "Open hud menu.");
	RegConsoleCmd("sm_mls", CommandMLStats, "Toggling key hint ml-stats.");
	RegConsoleCmd("sm_button", CommandButton, "Toggling button pressing.");
	RegConsoleCmd("sm_macro", CommandMacro, "Toggling a macro.");
	RegConsoleCmd("sm_bhop", CommandBhop, "Toggling auto bunnyhoping.");
	RegConsoleCmd("sm_endmsg", CommandEndmsg, "Toggling cp and end hud message.");
	RegConsoleCmd("sm_top10", CommandTop10, "Show top 10 teams in-game chat.");
	RegConsoleCmd("sm_help", CommandControl, "Open help menu.");
	RegConsoleCmd("sm_control", CommandControl, "Open help menu.");
	RegConsoleCmd("sm_vel", CommandVel, "Toggling a velocity for hint.");

	RegAdminCmd("sm_zones", AdminCommandZones, ADMFLAG_CUSTOM1, "Open zone editor menu.");
	RegAdminCmd("sm_maptier", AdminCommandMaptier, ADMFLAG_CUSTOM1, "sm_maptier <value> set map tier.");
	RegAdminCmd("sm_deleteallcp", AdminCommandDeleteAllCP, ADMFLAG_CUSTOM1, "Delete all checkpoints.");
	RegAdminCmd("sm_test", AdminCommandTest, ADMFLAG_CUSTOM1, "Temporary test function.");

	AddNormalSoundHook(OnSound);

	HookUserMessage(GetUserMessageId("SayText2"), OnSayMessage, true); //thanks to VerMon idea. https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-chat.sp#L416
	HookUserMessage(GetUserMessageId("RadioText"), OnRadioMessage, true);

	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_jump", OnPlayerJump, EventHookMode_Post);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Post);

	HookEntityOutput("func_button", "OnPressed", OnPlayerButton);

	AddCommandListener(joinclass, "joinclass");
	AddCommandListener(autobuy, "autobuy");
	AddCommandListener(rebuy, "rebuy");
	AddCommandListener(commandmenu, "commandmenu");
	AddCommandListener(cheer, "cheer");
	AddCommandListener(showbriefing, "showbriefing");
	AddCommandListener(headtrack_reset_home_pos, "headtrack_reset_home_pos");
	AddCommandListener(ACLCPNUM, "say");
	AddCommandListener(ACLCPNUM, "say_team");

	LoadTranslations("trueexpert.phrases"); //https://wiki.alliedmods.net/Translations_(SourceMod_Scripting)

	RegPluginLibrary("trueexpert");

	g_cookie[0] = RegClientCookie("te_vel", "velocity in hint", CookieAccess_Protected);
	g_cookie[1] = RegClientCookie("te_mls", "mega long stats", CookieAccess_Protected);
	g_cookie[2] = RegClientCookie("te_button", "button", CookieAccess_Protected);
	g_cookie[3] = RegClientCookie("te_autoflash", "autoflash", CookieAccess_Protected);
	g_cookie[4] = RegClientCookie("te_autoswitch", "autoswitch", CookieAccess_Protected);
	g_cookie[5] = RegClientCookie("te_bhop", "bhop", CookieAccess_Protected);
	g_cookie[6] = RegClientCookie("te_macro", "macro", CookieAccess_Protected);
	g_cookie[7] = RegClientCookie("te_endmsg", "End message.", CookieAccess_Protected);
	g_cookie[8] = RegClientCookie("te_flashbangskin", "Flashbang skin.", CookieAccess_Protected);
	g_cookie[9] = RegClientCookie("te_flashbangcolor", "Flashbang color.", CookieAccess_Protected);
	g_cookie[10] = RegClientCookie("te_playerskin", "Player skin.", CookieAccess_Protected);
	g_cookie[11] = RegClientCookie("te_greetings", "Greetings", CookieAccess_Protected);

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
	g_kv.ImportFromFile("addons/sourcemod/configs/trueexpert-hud.cfg");

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
	CreateNative("Trikz_GetTeamColor", Native_GetTeamColor);

	MarkNativeAsOptional("Trikz_GetEntityFilter");

	return APLRes_Success;
}

public void OnMapStart()
{
	GetCurrentMap(g_map, sizeof(g_map));

	char name[10 + 1] = "trueexpert";
	any data = 0;
	Database.Connect(SQLConnect, name, data);

	for(int i = 0; i <= 2; i++)
	{
		g_zoneHave[i] = false;

		for(int j = 0; j <= 1; j++)
		{
			for(int k = 0; k <= 10; k++)
			{
				g_cpPos[k][j][i] = 0.0;

				for(int l = 1; l <= MAXPLAYERS; l++)
				{
					g_cpPosTemp[l][k][j][i] = 0.0;

					continue;
				}

				continue;
			}

			continue;
		}

		continue;
	}

	float sourcetvCV = gCV_sourceTV.FloatValue;

	if(sourcetvCV == 1.0)
	{
		ConVar CV_sourcetv = FindConVar("tv_enable");

		int sourcetv = CV_sourcetv.IntValue; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/funvotes.sp#L280

		if(sourcetv == 1.0)
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

		if(g_sourcetv == false && sourcetv == 0.0)
		{
			g_sourcetv = true;

			ForceChangeLevel(g_map, "Turning on SourceTV");

			//this should provides a crash if reload plugin (DHookEntity). https://issuehint.com/issue/alliedmodders/sourcemod/1688
			ServerCommand("tv_delay 0");
			ServerCommand("tv_transmitall 1");
		}
	}

	g_wModelThrown = PrecacheModel("models/expert_zone/flashbang/flashbang.mdl", true);

	g_wModelPlayer[1] = PrecacheModel("models/expert_zone/player/ct_urban.mdl", true);
	g_wModelPlayer[2] = PrecacheModel("models/expert_zone/player/ct_gsg9.mdl", true);
	g_wModelPlayer[3] = PrecacheModel("models/expert_zone/player/ct_sas.mdl", true);
	g_wModelPlayer[4] = PrecacheModel("models/expert_zone/player/ct_gign.mdl", true);

	//PrecacheSound("trueexpert/pingtool/click.wav", true); //https://forums.alliedmods.net/showthread.php?t=333211
	PrecacheSound("items/gift_drop.wav", true);

	//g_zoneModel[0] = PrecacheModel("materials/trueexpert/zones/start.vmt", true);
	//g_zoneModel[1] = PrecacheModel("materials/trueexpert/zones/finish.vmt", true);
	//g_zoneModel[2] = PrecacheModel("materials/trueexpert/zones/check_point.vmt", true);

	g_zoneModel[0] = PrecacheModel("materials/expert_zone/zone_editor/zones/start.vmt", true);
	g_zoneModel[1] = PrecacheModel("materials/expert_zone/zone_editor/zones/finish.vmt", true);
	g_zoneModel[2] = PrecacheModel("materials/expert_zone/zone_editor/zones/check_point.vmt", true);

	g_laser = PrecacheModel("materials/sprites/laser.vmt", true);
	g_laserBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_smoke = PrecacheModel("materials/sprites/smoke.vmt", true);
	
	PrecacheModel("models/effects/combineball.mdl", true);
	PrecacheModel("models/expert_zone/zone_editor/xyz/xyz.mdl", true);

	PrecacheSound("weapons/flashbang/flashbang_explode1.wav", true);
	PrecacheSound("weapons/flashbang/flashbang_explode2.wav", true);

	//char path[12][PLATFORM_MAX_PATH] = {"models/trueexpert/flashbang/", "models/trueexpert/pingtool/", "models/trueexpert/player/", "materials/trueexpert/flashbang/", "materials/trueexpert/pingtool/", "sound/trueexpert/pingtool/", "materials/trueexpert/player/ct_gign/", "materials/trueexpert/player/ct_gsg9/", "materials/trueexpert/player/ct_sas/", "materials/trueexpert/player/ct_urban/", "materials/trueexpert/player/", "materials/trueexpert/zones/"};
	char path[8][PLATFORM_MAX_PATH] = {"models/expert_zone/flashbang/", "models/expert_zone/player/", "materials/expert_zone/flashbang/", "materials/expert_zone/player/ct_gign/", "materials/expert_zone/player/ct_gsg9/", "materials/expert_zone/player/ct_sas/", "materials/expert_zone/player/ct_urban/", "materials/expert_zone/player/"};

	for(int i = 0; i < sizeof(path); i++)
	{
		DirectoryListing dir = OpenDirectory(path[i]);
		char filename[8][PLATFORM_MAX_PATH];

		FileType type = FileType_Unknown;
		char pathFull[8][PLATFORM_MAX_PATH];

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
			}

			continue;
		}

		delete dir;

		continue;
	}

	g_top10ac = 0.0;

	delete g_kv;
	g_kv = new KeyValues("TrueExpertHud");
	g_kv.ImportFromFile("addons/sourcemod/configs/trueexpert-hud.cfg");

	g_cpCount = 0;

	/*for(int i = 1; i <= MAXPLAYERS; i++)
	{
		g_timerDissolver[i] = INVALID_HANDLE;
	}*/

	return;
}

void SQLRecalculatePoints_GetMap(Database db, DBResultSet results, const char[] error, any data)
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

			Format(g_query, sizeof(g_query), "SELECT (SELECT COUNT(*) FROM records WHERE map = '%s' AND time != 0), (SELECT tier FROM tier WHERE map = '%s' LIMIT 1), id FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC", map, map, map); //https://stackoverflow.com/questions/38104018/select-and-count-rows-in-the-same-query
			g_sql.Query(SQLRecalculatePoints, g_query, _, DBPrio_Normal);

			continue;
		}
	}

	return;
}

void SQLRecalculatePoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int place = 0;

		while(results.FetchRow() == true)
		{
			int recordCount = results.FetchInt(0);
			int tier = results.FetchInt(1);
			int recordID = results.FetchInt(2);
			int points = tier * recordCount / ++place; //thanks to DeadSurfer //https://1drv.ms/u/s!Aq4KvqCyYZmHgpM9uKBA-74lYr2L3Q
			Format(g_query, sizeof(g_query), "UPDATE records SET points = %i WHERE id = %i LIMIT 1", points, recordID);
			g_queryLast++;
			g_sql.Query(SQLRecalculatePoints2, g_query, _, DBPrio_Normal);

			continue;
		}
	}

	return;
}

void SQLRecalculatePoints2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(g_queryLast-- && g_queryLast == 0)
		{
			g_sql.Query(SQLRecalculatePoints3, "SELECT steamid FROM users", _, DBPrio_Normal);
		}
	}

	return;
}

void SQLRecalculatePoints3(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecalculatePoints3: %s", error);
	}

	else if(strlen(error) == 0)
	{
		while(results.FetchRow() == true)
		{
			int userid = results.FetchInt(0);
			Format(g_query, sizeof(g_query), "SELECT MAX(points) FROM records WHERE (playerid = %i OR partnerid = %i) GROUP BY map", userid, userid); //https://1drv.ms/u/s!Aq4KvqCyYZmHgpFWHdgkvSKx0wAi0w?e=7eShgc
			g_sql.Query(SQLRecalculateUserPoints, g_query, userid, DBPrio_Normal);

			continue;
		}
	}

	return;
}

void SQLRecalculateUserPoints(Database db, DBResultSet results, const char[] error, any data)
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

		Format(g_query, sizeof(g_query), "UPDATE users SET points = %i WHERE steamid = %i LIMIT 1", points, data);
		g_queryLast++;
		g_sql.Query(SQLUpdateUserPoints, g_query, _, DBPrio_Normal);
	}

	return;
}

void SQLUpdateUserPoints(Database db, DBResultSet results, const char[] error, any data)
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
				g_sql.Query(SQLGetPointsMaxs, "SELECT points FROM users ORDER BY points DESC LIMIT 1", _, DBPrio_Normal);
			}
		}
	}

	return;
}

void SQLGetPointsMaxs(Database db, DBResultSet results, const char[] error, any data)
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

			for(int i = 1; i <= MaxClients; ++i) //pre-increment must work once
			{
				if(IsClientInGame(i) == true && IsFakeClient(i) == false)
				{
					bool validate = true;
					int steamid = GetSteamAccountID(i, validate);
					Format(g_query, sizeof(g_query), "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid);
					int serial = GetClientSerial(i);
					g_sql.Query(SQLGetPoints, g_query, serial, DBPrio_Normal);
				}

				continue;
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

		int sourcetv = CV_sourcetv.IntValue;

		if(sourcetv == 1.0)
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

Action OnSayMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
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
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_Spec", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x07CCCCCC%s \x01:  %s", "Spectator", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_All", false) == true)
	{
		if(team == CS_TEAM_T)
		{
			Format(text, sizeof(text), "\x01[%s] \x07FF4040%s \x01:  %s", points, name, text); //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L638
		}

		else if(team == CS_TEAM_CT)
		{
			Format(text, sizeof(text), "\x01[%s] \x0799CCFF%s \x01:  %s", points, name, text); //https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc#L513
		}
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_AllDead", false) == true)
	{
		if(team == CS_TEAM_T)
		{
			Format(text, sizeof(text), "\x01*%T* [%s] \x07FF4040%s \x01:  %s", "Dead", client, points, name, text);
		}

		else if(team == CS_TEAM_CT)
		{
			Format(text, sizeof(text), "\x01*%T* [%s] \x0799CCFF%s \x01:  %s", "Dead", client, points, name, text);
		}
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x0799CCFF%s \x01:  %s", "Counter-Terrorist", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_CT_Dead", false) == true)
	{
		Format(text, sizeof(text), "\x01*%T*(%T) [%s] \x0799CCFF%s \x01:  %s", "Dead", client, "Counter-Terrorist", client, points, name, text);
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_T", false) == true)
	{
		Format(text, sizeof(text), "\x01(%T) [%s] \x07FF4040%s \x01:  %s", "Terrorist", client, points, name, text); //https://forums.alliedmods.net/showthread.php?t=185016
	}

	else if(StrEqual(msgBuffer, "Cstrike_Chat_T_Dead", false) == true)
	{
		Format(text, sizeof(text), "\x01*%T*(%T) [%s] \x07FF4040%s \x01:  %s", "Dead", client, "Terrorist", client, points, name, text);
	}

	int serial = GetClientSerial(client);
	int condition = StrContains(msgBuffer, "_All") != -1;

	DataPack dp = new DataPack();
	dp.WriteCell(serial);
	dp.WriteCell(condition);
	dp.WriteString(text);
	RequestFrame(FrameSayText2, dp);

	return Plugin_Handled;
}

void FrameSayText2(DataPack dp)
{
	dp.Reset();

	int serial = dp.ReadCell();

	bool allchat = dp.ReadCell();

	char text[256] = "";
	dp.ReadString(text, sizeof(text));

	delete dp;

	int client = GetClientFromSerial(serial);

	if(IsValidClient(client) == true)
	{
		int clients[MAXPLAYER] = {0, ...};
		int count = 0;
		int team = GetClientTeam(client);

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && (allchat == true || GetClientTeam(i) == team))
			{
				clients[count++] = i;
			}

			continue;
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

Action OnRadioMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) //RadioText https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/server/cstrike/cs_player.cpp#L3944
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
	RequestFrame(FrameRadioTXT, dp);

	return Plugin_Handled;
}

void FrameRadioTXT(DataPack dp)
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

	if(IsValidClient(client) == true)
	{
		int clients[MAXPLAYER] = {0, ...};
		int count = 0;

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsFakeClient(i) == false)
			{
				clients[count++] = i;
			}

			continue;
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

void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	char model[PLATFORM_MAX_PATH] = "";
	int maxlen = PLATFORM_MAX_PATH;
	GetClientModel(client, model, maxlen);

	if(StrEqual(model, "models/player/ct_urban.mdl", false) == true || StrEqual(model, "models/player/t_phoenix.mdl", false) == true)
	{
		g_class[client] = 1;
	}

	else if(StrEqual(model, "models/player/ct_gsg9.mdl", false) == true || StrEqual(model, "models/player/t_leet.mdl", false) == true)
	{
		g_class[client] = 2;
	}

	else if(StrEqual(model, "models/player/ct_sas.mdl", false) == true || StrEqual(model, "models/player/t_arctic.mdl", false) == true)
	{
		g_class[client] = 3;
	}

	else if(StrEqual(model, "models/player/ct_gign.mdl", false) == true || StrEqual(model, "models/player/t_guerilla.mdl", false) == true)
	{
		g_class[client] = 4;
	}

	PropType type = Prop_Data;
	char prop[13 + 1] = "";
	any value = 0;
	int size = 4;
	int element = 0;
	Format(prop, sizeof(prop), "m_nModelIndex");
	value = g_wModelPlayer[g_class[client]];
	SetEntProp(client, type, prop, value, size, element);

	PropType type2 = Prop_Data;
	char prop2[7 + 1] = "";
	any value2 = 0;
	int size2 = 4;
	int element2 = 0;
	Format(prop2, sizeof(prop2), "m_nSkin");
	value2 = g_skinPlayer[client];
	SetEntProp(client, type2, prop2, value2, size2, element2);

	int r = g_colorBuffer[client][0][0];
	int g = g_colorBuffer[client][0][1];
	int b = g_colorBuffer[client][0][2];
	int a = 255;
	SetEntityRenderColor(client, r, g, b, a);

	RenderMode mode = RENDER_TRANSALPHA;
	SetEntityRenderMode(client, mode); //maru is genius person who fix this bug. thanks maru for idea.

	if(g_devmap == false && g_clantagOnce[client] == false)
	{
		CS_GetClientClanTag(client, g_clantag[client][0], 256);
		g_clantagOnce[client] = true;
	}

	char points[32] = "";
	GetPoints(client, points); //Set player health precentage of points

	return;
}

void OnPlayerButton(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator) == true && GetClientButtons(activator) & IN_USE)
	{
		int button = gCV_button.IntValue;

		if(button == 0.0)
		{
			return;
		}

		if(g_button[activator] == true)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", activator, "YouPressedButton", activator);
			SendMessage(activator, g_buffer);
		}

		if(g_button[g_partner[activator]] == true)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", g_partner[activator], "YourPartnerPressedButton", g_partner[activator]);
			SendMessage(g_partner[activator], g_buffer);
		}
	}

	return;
}

void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	g_skyOrigin[client] = GetGroundPos(client);
	g_skyAble[client] = GetGameTime();

	GetClientAbsOrigin(client, g_mlsDistance[client][0]);

	return;
}

void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll", 0);

	char clsname[256] = "";
	GetEntityClassname(ragdoll, clsname, sizeof(clsname));

	if(StrEqual(clsname, "cs_ragdoll", false) == true)
	{
		RemoveEntity(ragdoll);
	}

	if(IsValidPartner(client) == true)
	{
		int partner = g_partner[client];

		g_partner[client] = 0;
		g_partner[partner] = 0;

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

void OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
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

Action joinclass(int client, const char[] command, int argc)
{
	float interval = 1.0;
	any data = client;
	int flags = TIMER_FLAG_NO_MAPCHANGE;
	CreateTimer(interval, TimerRespawn, data, flags);

	return Plugin_Continue;
}

Action TimerRespawn(Handle timer, int client)
{
	if(IsClientInGame(client) == true && GetClientTeam(client) != CS_TEAM_SPECTATOR && IsPlayerAlive(client) == false)
	{
		CS_RespawnPlayer(client);
	}

	return Plugin_Stop;
}

Action autobuy(int client, const char[] command, int argc)
{
	Block(client, false);

	g_silentF1F2 = true;

	return Plugin_Continue;
}

Action rebuy(int client, const char[] command, int argc)
{	
	if(g_menuOpened[client] == false)
	{
		Trikz(client);
	}

	g_silentF1F2 = true;

	return Plugin_Continue;
}

Action commandmenu(int client, const char[] command, int argc)
{
	Block(client, false);

	return Plugin_Continue;
}

Action cheer(int client, const char[] command, int argc)
{
	AdminCommandZones(client, 0);

	return Plugin_Continue; //happy holliday.
}

Action showbriefing(int client, const char[] command, int argc)
{
	Control(client);

	return Plugin_Continue;
}

void Control(int client)
{
	Menu menu = new Menu(MenuInfoHandler);

	Format(g_buffer, sizeof(g_buffer), "%T", "Control", client);
	menu.SetTitle("%s", g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "ControlTop", client);
	menu.AddItem("top", g_buffer, gCV_top.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlTop10", client);
	menu.AddItem("top10", g_buffer, gCV_top10.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlJS", client);
	menu.AddItem("js", g_buffer, LibraryExists("trueexpert-jumpstats") == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlBS", client);
	menu.AddItem("bs", g_buffer, LibraryExists("trueexpert-booststats") == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlHUD", client);
	menu.AddItem("hud", g_buffer, gCV_hud.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlButton", client);
	menu.AddItem("button", g_buffer, gCV_button.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlSpec", client);
	menu.AddItem("spec", g_buffer, gCV_spec.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlColor", client);
	menu.AddItem("color", g_buffer, gCV_color.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlAFK", client);
	menu.AddItem("afk", g_buffer, gCV_afk.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", "ControlTrikz", client);
	menu.AddItem("trikz", g_buffer, gCV_trikz.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	int time = 20;
	menu.Display(client, time);

	return;
}

int MenuInfoHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			int args = 0;
			char fmt[5 + 1] = "";

			switch(param2)
			{
				case 0:
				{
					CommandTop(param1, args);
				}

				case 1:
				{
					Top10(param1);
				}

				case 2:
				{
					Format(fmt, sizeof(fmt), "sm_js");
					FakeClientCommandEx(param1, fmt); //faster cooamnd respond
				}

				case 3:
				{
					Format(fmt, sizeof(fmt), "sm_bs");
					FakeClientCommandEx(param1, fmt); //faster command respond
				}

				case 4:
				{
					CommandHud(param1, args);
				}

				case 5:
				{
					CommandButton(param1, args);
				}

				case 6:
				{
					CommandSpec(param1, args);
				}

				case 7:
				{
					ColorSelect(param1);
				}

				case 8:
				{
					CommandAfk(param1, args);
				}

				case 9:
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

Action headtrack_reset_home_pos(int client, const char[] command, int argc)
{
	Partner(client);

	return Plugin_Continue;
}

Action ACLCPNUM(int client, const char[] command, int argc)
{
	if(g_zoneCPnumReadyToNew[client] == true)
	{
		char arg[256] = "";
		GetCmdArgString(arg, sizeof(arg));

		ReplaceString(arg, sizeof(arg), "\"", "", true); //somehow working here

		int cpnum = StringToInt(arg, 10);

		if(0 < cpnum <= 10)
		{
			g_ZoneEditorCP[client] = cpnum;
		}

		ZoneCreator(client);

		g_zoneCPnumReadyToNew[client] = false;
	}

	return Plugin_Continue;
}

Action CommandCheckpoint(int client, int args)
{
	int checkpoint = gCV_checkpoint.IntValue;

	if(checkpoint == 0.0)
	{
		return Plugin_Continue;
	}

	Checkpoint(client);

	return Plugin_Handled;
}

void Checkpoint(int client)
{
	if(g_devmap == true)
	{
		Menu menu = new Menu(CheckpointMenuHandler);
		menu.SetTitle("%T", "Checkpoint", client);

		Format(g_buffer, sizeof(g_buffer), "%T", "CP-save", client);
		menu.AddItem("Save", g_buffer);
		Format(g_buffer, sizeof(g_buffer), "%T", "CP-teleport", client);
		menu.AddItem("Teleport", g_buffer, g_cpToggled[client][0] == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		Format(g_buffer, sizeof(g_buffer), "%T", "CP-saveSecond", client);
		menu.AddItem("Save second", g_buffer);
		Format(g_buffer, sizeof(g_buffer), "%T", "CP-teleportSecond", client);
		menu.AddItem("Teleport second", g_buffer, g_cpToggled[client][1] == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
		menu.Display(client, MENU_TIME_FOREVER);
	}

	else if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	return;
}

int CheckpointMenuHandler(Menu menu, MenuAction action, int param1, int param2)
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
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_StartTouch, OnStartTouch);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost); //idea by tengulawl/scripting/blob/master/boost-fix tengulawl github.com
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);

	if(IsClientInGame(client) == true && g_dbPassed == true)
	{
		char query[28 + 1] = "SELECT id FROM users LIMIT 1";
		int serial = GetClientSerial(client);

		g_sql.Query(SQLAddUser, query, serial, DBPrio_High);

		int steamid = GetSteamAccountID(client, true);
		Format(g_query, sizeof(g_query), "SELECT time FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s' ORDER BY time ASC LIMIT 1", steamid, steamid, g_map);
		g_sql.Query(SQLGetPersonalRecord, g_query, serial, DBPrio_Normal);
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

			continue;
		}

		continue;
	}

	g_block[client] = true;
	//g_timerTime[client] = 0.0;

	if(g_devmap == false && g_zoneHave[0] == true && g_zoneHave[1] == true && g_zoneHave[2] == true && g_zoneDrawed[client] == false)
	{
		DrawZone(client, 0.0, 3.0, 10, -1, -1);

		g_zoneDrawed[client] = true;
	}

	g_msg[client] = true;

	if(AreClientCookiesCached(client) == false)
	{
		g_hudVel[client] = false;
		g_mlstats[client] = false;
		g_button[client] = false;
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

			continue;
		}
	}

	g_boost[client] = 0; //rare case

	char value[16] = "";
	GetClientCookie(client, g_cookie[11], value, sizeof(value));

	int cooldown = StringToInt(value, 10);

	if(cooldown < GetTime())
	{
		Greetings(client);
	}

	return;
}

public void OnClientCookiesCached(int client)
{
	char value[16] = "";
	int nBase = 10;

	GetClientCookie(client, g_cookie[0], value, sizeof(value));
	g_hudVel[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[1], value, sizeof(value));
	g_mlstats[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[2], value, sizeof(value));
	g_button[client] = view_as<bool>(StringToInt(value, nBase));
	
	GetClientCookie(client, g_cookie[3], value, sizeof(value));
	g_autoflash[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[4], value, sizeof(value));
	g_autoswitch[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[5], value, sizeof(value));
	g_bhop[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[6], value, sizeof(value));
	g_macroDisabled[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[7], value, sizeof(value));
	g_endMessage[client] = view_as<bool>(StringToInt(value, nBase));

	GetClientCookie(client, g_cookie[8], value, sizeof(value));
	g_skinFlashbang[client] = StringToInt(value, nBase);

	GetClientCookie(client, g_cookie[9], value, sizeof(value));

	char exploded[4][16];
	ExplodeString(value, ";", exploded, 4, 16);

	for(int i = 0; i <= 2; i++)
	{
		g_colorBuffer[client][1][i] = StringToInt(exploded[i], nBase);

		continue;
	}

	g_colorCount[client][1] = StringToInt(exploded[3], nBase);

	if(g_colorBuffer[client][1][0] == 0 && g_colorBuffer[client][1][1] == 0 && g_colorBuffer[client][1][2] == 0)
	{
		for(int i = 0; i <= 2; i++)
		{
			g_colorBuffer[client][1][i] = 255;

			continue;
		}
	}

	GetClientCookie(client, g_cookie[10], value, sizeof(value));
	g_skinPlayer[client] = StringToInt(value, nBase);

	GetClientCookie(client, g_cookie[11], value, sizeof(value));

	int cooldown = StringToInt(value, nBase);

	if(cooldown < GetTime())
	{
		Greetings(client);
	}

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

	if(g_devmap == false && IsValidPartner(client) == true && IsFakeClient(client) == false)
	{
		ResetFactory(partner);
	}

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

		continue;
	}

	for(int i = 0; i <= 1; i++)
	{
		g_flashbangDoor[client][i] = false;

		continue;
	}

	g_zoneDrawed[client] = false;

	char value[16] = "";
	Format(value, sizeof(value), "%i", GetTime() + 300);
	SetClientCookie(client, g_cookie[11], value);

	g_pingTimer[client] = INVALID_HANDLE;

	return;
}

void SQLAddUser(Database db, DBResultSet results, const char[] error, any data)
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
			//https://forums.alliedmods.net/showthread.php?t=261378
			int steamid = GetSteamAccountID(client, true);
			
			bool fetchrow = results.FetchRow();

			if(fetchrow == false)
			{
				Format(g_query, sizeof(g_query), "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES (\"%N\", %i, %i, %i)", client, steamid, GetTime(), GetTime());
				g_sql.Query(SQLUserAdded, g_query, _, DBPrio_Normal);

				#if debug == true
				PrintToServer("SQLAddUser: User (%N) trying to add to database...", client);
				#endif
			}

			else if(fetchrow == true)
			{
				Format(g_query, sizeof(g_query), "SELECT steamid FROM users WHERE steamid = %i LIMIT 1", steamid);
				g_sql.Query(SQLUpdateUser, g_query, GetClientSerial(client), DBPrio_High);

				#if debug == true
				PrintToServer("SQLAddUser: User (%N) selecting...", client);
				#endif
			}
		}
	}

	return;
}

void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
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

	return; //void function return nothing. Here code will quit and below code will be skiped in this function part.
}

void SQLUpdateUser(Database db, DBResultSet results, const char[] error, any data)
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
			int steamid = GetSteamAccountID(client, true);

			bool fetchrow = results.FetchRow();

			if(fetchrow == false)
			{
				Format(g_query, sizeof(g_query), "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES (\"%N\", %i, %i, %i)", client, steamid, GetTime(), GetTime());
			}

			else if(fetchrow == true)
			{
				Format(g_query, sizeof(g_query), "UPDATE users SET username = \"%N\", lastjoin = %i WHERE steamid = %i LIMIT 1", client, GetTime(), steamid);
			}

			g_sql.Query(SQLUpdateUserSuccess, g_query, GetClientSerial(client), DBPrio_High);

			#if debug == true
			//PrintToServer("SQLUpdateUser: Successfuly updated user");
			PrintToServer("SQLUpdateUser: User (%N) updating...", client);
			#endif
		}
	}

	return; //void return nothing
}

void SQLUpdateUserSuccess(Database db, DBResultSet results, const char[] error, any data)
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
				int steamid = GetSteamAccountID(client, true);
				Format(g_query, sizeof(g_query), "SELECT points FROM users WHERE steamid = %i LIMIT 1", steamid);
				g_sql.Query(SQLGetPoints, g_query, GetClientSerial(client), DBPrio_High);

				#if debug == true
				PrintToServer("SQLUpdateUserSuccess: Successfuly updated user");
				#endif
			}
		}
	}

	return;
}

void SQLGetPoints(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetPoints: %s", error);
	}

	else if(strlen(error) == 0)
	{
		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			g_points[client] = results.FetchRow() == true ? results.FetchInt(0) : 0;

			float precentage = float(g_points[client]) / float(g_pointsMaxs) * 100.0;
			CS_SetMVPCount(client, precentage <= 100.0 ? RoundToFloor(precentage) : 0);
		}
	}

	return;
}

void SQLGetServerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLGetServerRecord: %s", error);
	}

	else if(strlen(error) == 0)
	{
		g_ServerRecordTime = results.FetchRow() == true ? results.FetchFloat(0) : 0.0;
	}

	return;
}

void SQLGetPersonalRecord(Database db, DBResultSet results, const char[] error, any data)
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
			g_haveRecord[client] = results.FetchRow() == true ? results.FetchFloat(0) : 0.0;
		}
	}

	return;
}

Action OnStartTouch(int client, int other) //client = booster; other = flyer
{
	int boostfix = gCV_boostfix.IntValue;

	if(boostfix == 1.0)
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
					if(FloatAbs(g_skyOrigin[client][2] - g_skyOrigin[other][2]) >= 16.0 || GetGameTime() - g_skyAble[other] > 0.5)
					{
						float velFlyer[3] = {0.0, ...};
						GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", velFlyer, 0);

						g_skyVel[other][0] = velFlyer[0];
						g_skyVel[other][1] = velFlyer[1];
						g_skyVel[other][2] = velBooster[2] * 3.572;

						float midMax = 800.0 - (800.0 - 770.0) / 2.0;

						if(midMax > g_skyVel[other][2])
						{
							g_skyVel[other][2] = g_skyVel[other][2] - (midMax - (g_skyVel[other][2] / midMax) * midMax) / 2.0;
						}

						else if(midMax <= g_skyVel[other][2])
						{
							g_skyVel[other][2] = g_skyVel[other][2] + (midMax - (g_skyVel[other][2] / midMax) * midMax) / 2.0;
						}

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

						g_skyBoost[other] = 1;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

void OnPostThinkPost(int client)
{
	int boostfix = gCV_boostfix.IntValue;

	if(boostfix == 1.0)
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

Action CommandTrikz(int client, int args)
{
	int trikz = gCV_trikz.IntValue;

	if(trikz == 0.0)
	{
		return Plugin_Continue;
	}

	if(g_menuOpened[client] == false)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

void Trikz(int client)
{
	g_menuOpened[client] = true;

	Menu menu = new Menu(TrikzMenuHandler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End); //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	menu.SetTitle("%T", "Trikz", client);

	Format(g_buffer, sizeof(g_buffer), "%T", g_block[client] == true ? "BlockMenuON" : "BlockMenuOFF", client);
	menu.AddItem("block", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", g_autoflash[client] == true ? "AutoflashMenuON" : "AutoflashMenuOFF", client);
	menu.AddItem("autoflash", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", g_autoswitch[client] == true ? "AutoswitchMenuON" : "AutoswitchMenuOFF", client);
	menu.AddItem("autoswitch", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", g_bhop[client] == true ? "BhopMenuON" : "BhopMenuOFF", client);
	menu.AddItem("bhop", g_buffer);

	if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", IsValidPartner(client) == true ? "Breakup" : "Partner", client);
		menu.AddItem(IsValidPartner(client) == true ? "breakup" : "partner", g_buffer, ITEMDRAW_DEFAULT);
	}

	Format(g_buffer, sizeof(g_buffer), "%T", "Color", client);
	menu.AddItem("color", g_buffer);

	if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "Restart", client);
		menu.AddItem("restart", g_buffer, IsValidPartner(client) == true ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	if(g_devmap == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", GetEntityMoveType(client) == MOVETYPE_NOCLIP ? "NoclipMenuON" : "NoclipMenuOFF", client);
		menu.AddItem("noclip", g_buffer);
		Format(g_buffer, sizeof(g_buffer), "%T", "Checkpoint", client);
		menu.AddItem("checkpoint", g_buffer);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

int TrikzMenuHandler(Menu menu, MenuAction action, int param1, int param2)
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
				Block(param1, false);
			}

			else if(StrEqual(item, "autoflash", true) == true)
			{
				CommandAutoflash(param1, 0);
			}

			else if(StrEqual(item, "autoswitch", true) == true)
			{
				CommandAutoswitch(param1, 0);
			}

			else if(StrEqual(item, "bhop", true) == true)
			{
				CommandBhop(param1, 0);
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

Action CommandBlock(int client, int args)
{
	int block = gCV_block.IntValue;

	if(block == 0.0)
	{
		return Plugin_Continue;
	}

	Block(client, true);

	return Plugin_Handled;
}

Action Block(int client, bool chat) //thanks maru for optimization.
{
	g_block[client] = !g_block[client];

	SetEntityCollisionGroup(client, g_block[client] == true ? 5 : 2);

	SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[client] == true ? 255 : 125);

	SetEntProp(client, Prop_Data, "m_ArmorValue", g_block[client] == true ? 0 : 1);

	if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	else if(g_menuOpened[client] == false && chat == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_block[client] == true ? "BlockChatON" : "BlockChatOFF", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
}

Action CommandPartner(int client, int args)
{
	int partner = gCV_partner.IntValue;

	if(partner == 0.0)
	{
		return Plugin_Continue;
	}

	Partner(client);

	return Plugin_Handled;
}

void Partner(int client)
{
	if(g_devmap == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_devmap == false)
	{
		if(IsPlayerAlive(client) == false)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "YouAreDead", client);
			SendMessage(client, g_buffer);

			return;
		}

		if(g_dbPassed == false)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DBLoading", client);
			SendMessage(client, g_buffer);

			return;
		}

		int time = 20;

		if(IsValidPartner(client) == false)
		{
			Menu menu = new Menu(PartnerMenuHandler);
			menu.SetTitle("%T", "ChoosePartner", client);

			char name[MAX_NAME_LENGTH] = "";
			bool player = false;

			for(int i = 1; i <= MaxClients; ++i)
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

				continue;
			}

			switch(player)
			{
				case false:
				{
					Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "NoFreePlayer", client);
					SendMessage(client, g_buffer);
				}

				case true:
				{
					menu.Display(client, time);
				}
			}
			
		}

		else if(IsValidPartner(client) == true)
		{			
			Menu menu = new Menu(CancelPartnerMenuHandler);

			char name[MAX_NAME_LENGTH] = "";
			GetClientName(g_partner[client], name, sizeof(name));
			menu.SetTitle("%T", "CancelPartnership", client, name);

			char partner[4] = "";
			IntToString(g_partner[client], partner, sizeof(partner)); //do global integer to string.

			Format(g_buffer, sizeof(g_buffer), "%T", "Yes", client);
			menu.AddItem(partner, g_buffer);
			Format(g_buffer, sizeof(g_buffer), "%T", "No", client);
			menu.AddItem("", g_buffer);

			menu.Display(client, time);
		}
	}

	return;
}

int PartnerMenuHandler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[4] = "";
			menu.GetItem(param2, item, sizeof(item));
			
			Menu menu2 = new Menu(AskPartnerMenuHandler);

			char name[MAX_NAME_LENGTH] = "";
			GetClientName(param1, name, sizeof(name));

			int partner = StringToInt(item, 10);
			menu2.SetTitle("%T", "AgreePartner", partner, name);
			
			char str[2 + 1] = "";
			IntToString(param1, str, sizeof(str)); //sizeof do 4

			Format(g_buffer, sizeof(g_buffer), "%T", "Yes", partner);
			menu2.AddItem(str, g_buffer);
			Format(g_buffer, sizeof(g_buffer), "%T", "No", partner);
			menu2.AddItem(item, g_buffer);

			int time = 20;
			menu2.Display(partner, time);
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

int AskPartnerMenuHandler(Menu menu, MenuAction action, int param1, int param2) //param1 = client; param2 = server -> partner
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char infoBuf[4] = "";
			menu.GetItem(param2, infoBuf, sizeof(infoBuf));

			int partner = StringToInt(infoBuf, 10);

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

							GlobalForward hForward = new GlobalForward("Trikz_OnPartner", ET_Hook, Param_Cell, Param_Cell);
							Call_StartForward(hForward);
							Call_PushCell(param1);
							Call_PushCell(partner);
							Call_Finish();
							delete hForward;

							char name[MAX_NAME_LENGTH] = "";
							GetClientName(partner, name, sizeof(name));
							Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "TeamConfirming", param1, name); //reciever
							PrintToConsole(param1, "%s", g_buffer);

							GetClientName(param1, name, sizeof(name));
							Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", partner, "GetConfirmed", partner, name); //sender
							SendMessage(partner, g_buffer);

							Restart(param1, false); //Expert-Zone idea.

							int client = GetSteamAccountID(param1, true);
							int iPartner = GetSteamAccountID(partner, true);

							Format(g_query, sizeof(g_query), "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", client, iPartner, iPartner, client, g_map);
							g_sql.Query(SQLGetPartnerRecord, g_query, GetClientSerial(param1), DBPrio_Normal);

							RequestFrame(FrameAskColor, partner);
						}

						else if(IsValidPartner(partner) == true)
						{
							Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "AlreadyHavePartner", param1);
							SendMessage(param1, g_buffer);
						}
					}

					else if(IsPlayerAlive(param1) == false)
					{
						Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "YouAreDead", param1);
						SendMessage(param1, g_buffer);
					}
				}

				case 1:
				{
					char name[MAX_NAME_LENGTH] = "";
					GetClientName(param1, name, sizeof(name));
					Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "PartnerDeclined", param1, name);
					PrintToConsole(param1, "%s", g_buffer);
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

void FrameAskColor(int client)
{
	Menu menu = new Menu(MenuAskForColor);
	Format(g_buffer, sizeof(g_buffer), "%T", "TeamColor", client);
	menu.SetTitle("%s", g_buffer);

	char buffers[4][16];
	char str[1 + 1] = "";

	for(int i = 1; i < sizeof(g_colorType); i++)
	{
		IntToString(i, str, sizeof(str));
		ExplodeString(g_colorType[i], ",", buffers, 4, 16, false);
		buffers[3][0] = CharToUpper(buffers[3][0]);
		Format(buffers[3], 16, "%T", buffers[3], client);
		menu.AddItem(str, buffers[3]);
	}

	int time = 20;
	menu.Display(client, time);

	return;
}

int MenuAskForColor(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[1 + 1] = "";
			menu.GetItem(param2, item, sizeof(item));

			int num = StringToInt(item);

			for(int i = 1; i <= num; i++)
			{
				ColorTeam(param1, true);
			}
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

int CancelPartnerMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[8] = "";
			menu.GetItem(param2, item, sizeof(item));

			int partner = StringToInt(item, 10);

			switch(param2)
			{
				case 0:
				{
					ColorTeam(param1, false);

					g_partner[param1] = 0;
					g_partner[partner] = 0;

					GlobalForward hForward = new GlobalForward("Trikz_OnBreakup", ET_Hook, Param_Cell, Param_Cell);
					Call_StartForward(hForward);
					Call_PushCell(param1);
					Call_PushCell(partner);
					Call_Finish();
					delete hForward;

					ResetFactory(param1);
					ResetFactory(partner);

					char name[MAX_NAME_LENGTH] = "";
					GetClientName(partner, name, sizeof(name));

					Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "PartnerCanceled", param1, name);
					PrintToConsole(param1, "%s", g_buffer);

					GetClientName(param1, name, sizeof(name));
					Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", partner, "PartnerCanceledBy", partner, name);
					SendMessage(partner, g_buffer);
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

Action CommandColor(int client, int args)
{
	int color = gCV_color.IntValue;

	if(color == 0.0)
	{
		return Plugin_Handled;
	}

	ColorSelect(client);

	return Plugin_Handled;
}

void ColorSelect(int client)
{
	Menu menu = new Menu(MenuHandlerColor);
	menu.SetTitle("%T", "Color", client);

	Format(g_buffer, sizeof(g_buffer), "%T", "ColorTeam", client);
	menu.AddItem("team_color", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "PlayerSkin", client);
	menu.AddItem("player_skin", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "FlashbangSkin", client);
	menu.AddItem("flashbang_skin", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ColorPingFL", client);
	menu.AddItem("object_color", g_buffer);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

int MenuHandlerColor(Menu menu, MenuAction action, int param1, int param2)
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
					FlashbangSkin(param1);
				}

				case 3:
				{
					ColorFlashbang(param1);
					ColorSelect(param1);
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

void ColorTeam(int client, bool allowColor)
{
	if(IsClientInGame(client) == true && IsFakeClient(client) == false)
	{
		int colorCV = gCV_color.IntValue;

		if(colorCV == 0.0)
		{
			return;
		}
		
		if(g_devmap == false && IsValidPartner(client) == false)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DontHavePartner", client);
			SendMessage(client, g_buffer);

			return;
		}

		else if(g_devmap == true)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsON", client);
			SendMessage(client, g_buffer);

			return;
		}

		int partner = g_partner[client];

		if(allowColor == true)
		{
			g_colorCount[client][0]++;
			g_colorCount[partner][0]++;

			if(g_colorCount[client][0] == sizeof(g_colorType))
			{
				g_colorCount[client][0] = 0;
				g_colorCount[partner][0] = 0;
			}

			char colorTypeExploded[32][4];
			ExplodeString(g_colorType[g_colorCount[client][0]], ",", colorTypeExploded, 4, sizeof(colorTypeExploded));

			for(int i = 0; i <= 2; i++)
			{
				g_colorBuffer[client][0][i] = StringToInt(colorTypeExploded[i], 10);
				g_colorBuffer[partner][0][i] = StringToInt(colorTypeExploded[i], 10);

				continue;
			}

			SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[client] == true ? 255 : 125);
			SetEntityRenderColor(partner, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], g_block[partner] == true ? 255 : 125);

			GlobalForward hForward = new GlobalForward("Trikz_OnColorTeam", ET_Ignore, Param_Cell, Param_Cell, Param_Array); //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp
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

				continue;
			}

			SetEntityRenderColor(client, 255, 255, 255, g_block[client] == true ? 255 : 125);
			SetEntityRenderColor(partner, 255, 255, 255, g_block[partner] == true ? 255 : 125);
		}
	}

	return;
}

void ColorFlashbang(int client)
{
	if(IsClientInGame(client) == true && IsFakeClient(client) == false)
	{
		int colorCV = gCV_color.IntValue;

		if(colorCV == 0.0)
		{
			return;
		}

		g_colorCount[client][1]++;

		if(g_colorCount[client][1] == sizeof(g_colorType))
		{
			g_colorCount[client][1] = 0;
		}

		char colorTypeExploded[32][4];
		ExplodeString(g_colorType[g_colorCount[client][1]], ",", colorTypeExploded, 4, sizeof(colorTypeExploded));

		for(int i = 0; i <= 2; i++)
		{
			g_colorBuffer[client][1][i] = StringToInt(colorTypeExploded[i], 10);

			continue;
		}

		char value[16] = "";
		Format(value, sizeof(value), "%s;%s;%s;%i", colorTypeExploded[0], colorTypeExploded[1], colorTypeExploded[2], g_colorCount[client][1]);
		SetClientCookie(client, g_cookie[9], value);

		GlobalForward hForward = new GlobalForward("Trikz_OnColorFlashbang", ET_Ignore, Param_Cell, Param_Array); //public void Trikz_OnColorFlashbang(int client, int red, int green, int blue)
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

void SQLGetPartnerRecord(Database db, DBResultSet results, const char[] error, any data)
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
			float time = results.FetchRow() == true ? results.FetchFloat(0) : 0.0;
			g_teamRecord[client] = time;
			g_teamRecord[g_partner[client]] = time;
		}
	}

	return;
}

Action CommandRestart(int client, int args)
{
	int restart = gCV_restart.IntValue;

	if(restart == 0.0)
	{
		return Plugin_Continue;
	}

	Restart(client, true);

	return Plugin_Handled;
}

void Restart(int client, bool ask)
{
	if(g_devmap == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
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
					Menu menu = new Menu(MenuHandlerAskForRestart);
					menu.SetTitle("%T", "AskForRestart", client);

					Format(g_buffer, sizeof(g_buffer), "%T", "Yes", client);
					menu.AddItem("yes", g_buffer);
					Format(g_buffer, sizeof(g_buffer), "%T", "No", client);
					menu.AddItem("no", g_buffer);

					menu.Display(client, 20);
				}
			}

			else if(IsValidPartner(client) == false)
			{
				Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DontHavePartner", client);
				SendMessage(client, g_buffer);
			}
		}
	}

	return;
}

void DoRestart(int client)
{
	if(IsValidPartner(client) == true)
	{
		int partner = g_partner[client];
		float vel[3] = {0.0, ...};

		CreateTimer(0.1, TimerResetFactory, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, TimerResetFactory, partner, TIMER_FLAG_NO_MAPCHANGE);

		GlobalForward hForward = new GlobalForward("Trikz_OnRestart", ET_Hook, Param_Cell, Param_Cell);
		Call_StartForward(hForward);
		Call_PushCell(client);
		Call_PushCell(partner);
		Call_Finish();
		delete hForward;

		CS_RespawnPlayer(client);
		CS_RespawnPlayer(partner);

		TeleportEntity(client, g_timerStartPos, NULL_VECTOR, vel);
		TeleportEntity(partner, g_timerStartPos, NULL_VECTOR, vel);

		g_block[client] = true;
		g_block[partner] = true;

		SetEntProp(client, Prop_Data, "m_ArmorValue", 0);
		SetEntProp(partner, Prop_Data, "m_ArmorValue", 0);
	}
}

int MenuHandlerAskForRestart(Menu menu, MenuAction action, int param1, int param2)
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

Action CommandAutoflash(int client, int args)
{
	float autoflashbang = 0.0;
	autoflashbang = gCV_autoflashbang.FloatValue;
	
	if(autoflashbang == 0.0)
	{
		return Plugin_Continue;
	}

	g_autoflash[client] = !g_autoflash[client];

	GiveFlashbang(client);

	char value[1 + 1] = "";
	IntToString(g_autoflash[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[3], value);

	if(g_menuOpened[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_autoflash[client] == true ? "AutoflashChatON" : "AutoflashChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

Action CommandAutoswitch(int client, int args)
{
	float autoswitch = 0.0;
	autoswitch = gCV_autoswitch.FloatValue;
	
	if(autoswitch == 0.0)
	{
		return Plugin_Continue;
	}
	
	g_autoswitch[client] = !g_autoswitch[client];

	char value[1 + 1] = "";
	IntToString(g_autoswitch[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[4], value);

	if(g_menuOpened[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_autoswitch[client] == true ? "AutoswitchChatON" : "AutoswitchChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

Action CommandBhop(int client, int args)
{
	float bhop = 0.0;
	bhop = gCV_bhop.FloatValue;
	
	if(bhop == 0.0)
	{
		return Plugin_Continue;
	}

	g_bhop[client] = !g_bhop[client];
	
	char value[1 + 1] = "";
	IntToString(g_bhop[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[5], value);

	if(g_menuOpened[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_bhop[client] == true ? "BhopChatON" : "BhopChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return Plugin_Handled;
}

Action CommandEndmsg(int client, int args)
{
	float endmsg = 0.0;
	endmsg = gCV_endmsg.FloatValue;

	if(endmsg == 0.0)
	{
		return Plugin_Continue;
	}

	g_endMessage[client] = !g_endMessage[client];

	char value[1 + 1] = "";
	IntToString(g_bhop[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[7], value);

	if(g_menuOpenedHud[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_endMessage[client] == true ? "EndMessageChatON" : "EndMessageChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

Action CommandTop10(int client, int args)
{
	int top10 = 0;
	top10 = gCV_top10.IntValue;

	if(top10 == 0.0)
	{
		return Plugin_Continue;
	}

	Top10(client);

	return Plugin_Handled;
}

void Top10(int client)
{
	if(g_top10ac <= GetGameTime())
	{
		if(g_dbPassed == false)
		{
			Format(g_buffer, sizeof(g_buffer), "Wait for database loading...");
			SendMessage(client, g_buffer);

			return;
		}

		g_top10ac = GetGameTime() + 10.0;

		Format(g_query, sizeof(g_query), "SELECT * FROM records LIMIT 1");
		g_sql.Query(SQLTop10, g_query, _, DBPrio_Normal);
	}

	else if(g_top10ac > GetGameTime())
	{
		char time[8] = "";
		Format(time, sizeof(time), "%.0f", g_top10ac - GetGameTime());
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "Top10ac", client, time);
		SendMessage(client, g_buffer);
	}

	return;
}

void SQLTop10(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10: %s", error);
	}

	else if(strlen(error) == 0)
	{
		bool fetchrow = false;
		fetchrow = results.FetchRow();

		if(fetchrow == false)
		{
			for(int i = 1; i <= MaxClients; ++i)
			{
				if(IsClientInGame(i) == true)
				{
					Format(g_buffer, sizeof(g_buffer), "%T", "Top10details", i);
					SendMessage(i, g_buffer);

					Format(g_buffer, sizeof(g_buffer), "%T", "NoRecords", i);
					SendMessage(i, g_buffer);
				}

				continue;
			}
		}

		else if(fetchrow == true)
		{
			Format(g_query, sizeof(g_query), "SELECT playerid, partnerid, time FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 10", g_map);
			g_sql.Query(SQLTop10_2, g_query, _, DBPrio_Normal);
		}
	}

	return;
}

void SQLTop10_2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10_2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == false)
		{
			for(int i = 1; i <= MaxClients; ++i)
			{
				if(IsClientInGame(i) == true)
				{
					Format(g_buffer, sizeof(g_buffer), "%T", "Top10details", i);
					SendMessage(i, g_buffer);

					Format(g_buffer, sizeof(g_buffer), "%T", "NoRecords", i);
					SendMessage(i, g_buffer);
				}

				continue;
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

			Format(g_query, sizeof(g_query), "SELECT username, (SELECT username FROM users WHERE steamid = %i LIMIT 1) FROM users WHERE steamid = %i LIMIT 1", partnerid, playerid);
			g_sql.Query(SQLTop10_3, g_query, time, DBPrio_Normal);

			continue;
		}
	}

	return;
}

void SQLTop10_3(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLTop10_3: %s", error);
	}

	else if(strlen(error) == 0)
	{
		float time = 0.0;
		time = data;

		if(results.FetchRow() == true)
		{
			char name1[MAX_NAME_LENGTH] = "";
			char name2[MAX_NAME_LENGTH] = "";
			char formatTime[8 + 3 + 1] = "";
			char formatTimeDiff[8 + 3 + 1] = "8"; //00:00:00
			int count = 0;

			results.FetchString(0, name1, sizeof(name1));
			results.FetchString(1, name2, sizeof(name2));
			
			FormatSeconds(time, formatTime);

			count = ++g_top10Count;

			if(count == 1)
			{
				g_top10SR = time;
			}

			float timeDiff = 0.0;
			timeDiff = time - g_top10SR;

			FormatSeconds(timeDiff, formatTimeDiff);
			Format(formatTimeDiff, sizeof(formatTimeDiff), "+%s", formatTimeDiff);

			for(int i = 1; i <= MaxClients; ++i)
			{
				if(IsClientInGame(i) == true)
				{
					if(count == 1)
					{
						Format(g_buffer, sizeof(g_buffer), "%T", "Top10details", i);
						SendMessage(i, g_buffer);
					}
					
					if(count < 10)
					{
						Format(g_buffer, sizeof(g_buffer), "%T", "Top10source1-9", i, count, formatTime, formatTimeDiff, name1, name2);
						SendMessage(i, g_buffer);
					}

					else if(count == 10)
					{
						Format(g_buffer, sizeof(g_buffer), "%T", "Top10source10", i, count, formatTime, formatTimeDiff, name1, name2);
						SendMessage(i, g_buffer);
					}
				}

				continue;
			}
		}
	}

	return;
}

Action CommandControl(int client, int args)
{
	int control = gCV_control.IntValue;

	if(control == 0.0)
	{
		return Plugin_Continue;
	}

	Control(client);

	return Plugin_Handled;
}

void PlayerSkin(int client)
{
	Menu menu = new Menu(SkinTypeMenuHandler);

	Format(g_buffer, sizeof(g_buffer), "%T", "PlayerSkin", client);
	menu.SetTitle(g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "Default", client);
	menu.AddItem("default_ps", g_buffer, g_skinPlayer[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(g_buffer, sizeof(g_buffer), "%T", "Shadow", client);
	menu.AddItem("shadow_ps", g_buffer, g_skinPlayer[client] == 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(g_buffer, sizeof(g_buffer), "%T", "Bright", client);
	menu.AddItem("bright_ps", g_buffer, g_skinPlayer[client] == 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

void FlashbangSkin(int client)
{
	Menu menu = new Menu(SkinTypeMenuHandler);

	Format(g_buffer, sizeof(g_buffer), "%T", "FlashbangSkin", client);
	menu.SetTitle(g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "Default", client);
	menu.AddItem("default_fs", g_buffer, g_skinFlashbang[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(g_buffer, sizeof(g_buffer), "%T", "Shadow", client);
	menu.AddItem("shadow_fs", g_buffer, g_skinFlashbang[client] == 2 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(g_buffer, sizeof(g_buffer), "%T", "Bright", client);
	menu.AddItem("bright_fs", g_buffer, g_skinFlashbang[client] == 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	Format(g_buffer, sizeof(g_buffer), "%T", "Wireframe", client);
	menu.AddItem("wireframe_fs", g_buffer, g_skinFlashbang[client] == 3 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	menu.ExitBackButton = true;
	menu.Display(client, 20);

	return;
}

int SkinTypeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			char str[1 + 1] = ""; //1 = 2 numbers

			if(StrContains(item, "ps", false) != -1)
			{
				if(StrEqual(item, "default_ps", false) == true)
				{
					g_skinPlayer[param1] = 0;
					SetEntProp(param1, Prop_Data, "m_nSkin", 0, 4, 0);
				}

				else if(StrEqual(item, "shadow_ps", false) == true)
				{
					g_skinPlayer[param1] = 1;
					SetEntProp(param1, Prop_Data, "m_nSkin", 1, 4, 0);
				}

				else if(StrEqual(item, "bright_ps", false) == true)
				{
					g_skinPlayer[param1] = 2;
					SetEntProp(param1, Prop_Data, "m_nSkin", 2, 4, 0);
				}

				IntToString(g_skinPlayer[param1], str, sizeof(str));
				SetClientCookie(param1, g_cookie[10], str);

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

				IntToString(g_skinFlashbang[param1], str, sizeof(str));
				SetClientCookie(param1, g_cookie[8], str);

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

Action CommandMacro(int client, int args)
{
	int macro = gCV_macro.IntValue;
	
	if(macro == 0.0)
	{
		return Plugin_Continue;
	}

	g_macroDisabled[client] = !g_macroDisabled[client];
	
	char str[1 + 1] = "";
	IntToString(g_macroDisabled[client], str, sizeof(str));
	SetClientCookie(client, g_cookie[6], str);

	Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_macroDisabled[client] == false ? "MacroON" : "MacroOFF", client);
	SendMessage(client, g_buffer);

	return Plugin_Handled;
}

Action TimerResetFactory(Handle timer, int client)
{
	if(IsClientInGame(client) == true)
	{
		ResetFactory(client);
	}

	return Plugin_Stop;
}

void CreateStart()
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

		continue;
	}

	float value = (g_zoneStartOrigin[0][2] - g_zoneStartOrigin[1][2]) / 2.0;
	g_center[0][2] -= FloatAbs(value);

	TeleportEntity(entity, g_center[0], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	g_timerStartPos = g_center[0];
	g_timerStartPos[2] = g_center[0][2] + 1.0;

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 2; i++)
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

		continue;
	}

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, OnZoneStartTouch);
	SDKHook(entity, SDKHook_EndTouch, OnZoneEndTouch);
	SDKHook(entity, SDKHook_Touch, OnZoneTouch);

	PrintToServer("Start zone is successfuly setup.");

	g_zoneHave[0] = true;

	return;
}

void CreateEnd()
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

		continue;
	}

	g_center[1][2] -= FloatAbs((g_zoneEndOrigin[0][2] - g_zoneEndOrigin[1][2]) / 2.0);

	TeleportEntity(entity, g_center[1], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 2; i++)
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

		continue;
	}

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0); //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, OnZoneStartTouch);

	PrintToServer("End zone is successfuly setup.");

	CPSetup();

	g_zoneHave[1] = true;

	return;
}

void SQLDeleteZone(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset();
	int id = data.ReadCell();
	int type = data.ReadCell();
	int cpnum = data.ReadCell();

	int client = GetClientFromSerial(id);

	if(strlen(error) > 0)
	{
		char auth[32] = "";
		GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

		PrintToServer("SQLDeleteZone - CP: [%i] Type: [%i] Name: [%N] SteamID64: [%s]: Error: [%s]", cpnum, type, client, auth, error);
	}

	else if(strlen(error) == 0)
	{
		if(type == ZoneStart)
		{
			Format(g_query, sizeof(g_query), "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', ZoneStart, %f, %f, %f, %f, %f, %f)", g_map, g_zoneStartOriginTemp[client][0][0], g_zoneStartOriginTemp[client][0][1], g_zoneStartOriginTemp[client][0][2], g_zoneStartOriginTemp[client][1][0], g_zoneStartOriginTemp[client][1][1], g_zoneStartOriginTemp[client][1][2]);
			g_sql.Query(SQLSetZone, g_query, data, DBPrio_Normal);
		}

		else if(type == ZoneEnd)
		{
			Format(g_query, sizeof(g_query), "INSERT INTO zones (map, type, possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2) VALUES ('%s', ZoneEnd, %f, %f, %f, %f, %f, %f)", g_map, g_zoneEndOriginTemp[client][0][0], g_zoneEndOriginTemp[client][0][1], g_zoneEndOriginTemp[client][0][2], g_zoneEndOriginTemp[client][1][0], g_zoneEndOriginTemp[client][1][1], g_zoneEndOriginTemp[client][1][2]);
			g_sql.Query(SQLSetZone, g_query, data, DBPrio_Normal);
		}

		else if(type == ZoneCP)
		{
			Format(g_query, sizeof(g_query), "INSERT INTO cp (cpnum, cpx, cpy, cpz, cpx2, cpy2, cpz2, map) VALUES (%i, %f, %f, %f, %f, %f, %f, '%s')", cpnum, g_cpPosTemp[client][cpnum][0][0], g_cpPosTemp[client][cpnum][0][1], g_cpPosTemp[client][cpnum][0][2], g_cpPosTemp[client][cpnum][1][0], g_cpPosTemp[client][cpnum][1][1], g_cpPosTemp[client][cpnum][1][2], g_map);
			g_sql.Query(SQLSetZone, g_query, data, DBPrio_Normal);

			if(results.HasResults == false)
			{
				PrintToServer("Checkpoint zone no. %i successfuly deleted.", cpnum);
			}

			else if(results.HasResults == true)
			{
				PrintToServer("Checkpoint zone no. %i failed to delete.", cpnum);
			}
		}
	}

	return;
}

Action AdminCommandDeleteAllCP(int client, int args)
{
	if(g_devmap == true)
	{
		int serial = GetClientSerial(client);
		Format(g_query, sizeof(g_query), "DELETE FROM cp WHERE map = '%s'", g_map); //https://www.w3schools.com/sql/sql_delete.asp
		g_sql.Query(SQLDeleteAllCP, g_query, serial, DBPrio_Normal);
	}

	else if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
}

void SQLDeleteAllCP(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data);

	char auth[32] = "";
	GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

	if(strlen(error) > 0)
	{
		PrintToServer("SQLDeleteAllCP - Name: [%N] SteamID64: [%s]: Error: [%s]", client, auth, error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			LogToFileEx("addons/sourcemod/logs/trueexpert.log", "All checkpoints are deleted. MAP: [%s] edited by [%N] SteamID64: [%s]", g_map, client, auth);

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
		char section[64] = ""; //https://forums.alliedmods.net/showthread.php?t=270684
		kv.GetSectionName(section, sizeof(section));

		if(StrEqual(section, "ClanTagChanged", false) == true)
		{
			CS_GetClientClanTag(client, g_clantag[client][0], 256);
		}
	}

	return Plugin_Continue;
}

Action AdminCommandTest(int client, int args)
{
	char buffer[256] = "";
	GetCmdArgString(buffer, sizeof(buffer));

	char buffers[2][2 + 1];
	ExplodeString(buffer, ",", buffers, 2, 3, false);

	int nBase = 10;
	int player1 = 0, player2 = 0;
	player1 = StringToInt(buffers[0], nBase);
	player2 = StringToInt(buffers[1], nBase);

	if(IsValidClient(player1) == true && IsValidClient(player2) == true)
	{
		g_partner[player1] = player2;
		g_partner[player2] = player1;

		Restart(player1, false);
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) == true)
		{
			PrintToServer("[%N] [%i]", i, i);
		}

		continue;
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

void SendMessage(int client, const char[] buffer)
{
	char name[MAX_NAME_LENGTH] = "";
	GetClientName(client, name, sizeof(name));

	int team = GetClientTeam(client);

	char color[32] = "";

	switch(team)
	{
		case CS_TEAM_SPECTATOR:
		{
			Format(color, sizeof(color), "\x07CCCCCC");
		}

		case CS_TEAM_T:
		{
			Format(color, sizeof(color), "\x07FF4040");
		}

		case CS_TEAM_CT:
		{
			Format(color, sizeof(color), "\x0799CCFF");
		}
	}

	char buffer2[256] = "";
	Format(buffer2, sizeof(buffer2), "\x01%s", buffer);

	ReplaceString(buffer2, sizeof(buffer2), ";#", "\x07");
	ReplaceString(buffer2, sizeof(buffer2), "{default}", "\x01");
	ReplaceString(buffer2, sizeof(buffer2), "{teamcolor}", color);

	if(IsValidClient(client) == true)
	{
		char msgname[10] = "SayText2";
		int flags = USERMSG_RELIABLE | USERMSG_BLOCKHOOKS;
		Handle msg = StartMessageOne(msgname, client, flags); //https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/morecolors.inc#L195
		BfWrite bf = UserMessageToBfWrite(msg); //dont show color codes in console.
		bf.WriteByte(client); //Message author
		bf.WriteByte(true); //Chat message
		bf.WriteString(buffer2); //Message text
		EndMessage();
	}

	return;
}

Action AdminCommandMaptier(int client, int args)
{
	if(g_devmap == true)
	{
		char buffer[256] = "";
		GetCmdArgString(buffer, sizeof(buffer)); //https://www.sourcemod.net/new-api/console/GetCmdArgString

		int nBase = 10;
		char str[2 + 1] = "";
		int tier = StringToInt(str, nBase);

		if(tier > 0)
		{
			PrintToServer("[Args] Tier: %i", tier);

			Format(g_query, sizeof(g_query), "DELETE FROM tier WHERE map = '%s' LIMIT 1", g_map);
			DataPack dp = new DataPack();
			any serial = GetClientSerial(client);
			bool insert = false;
			dp.WriteCell(serial, insert);
			dp.WriteCell(tier, insert);
			g_sql.Query(SQLTierRemove, g_query, dp, DBPrio_Normal);
		}
	}

	else if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
}

void SQLTierRemove(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset();
	int serial = data.ReadCell();
	int tier = data.ReadCell();
	delete data;

	int client = GetClientFromSerial(serial);

	if(strlen(error) > 0)
	{
		char auth[32] = "";
		GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

		PrintToServer("SQLTierRemove - Tier: [%i] Name: [%N] SteamID64: [%s]: Error: [%s]", tier, client, auth, error);
	}

	else if(strlen(error) == 0)
	{
		Format(g_query, sizeof(g_query), "INSERT INTO tier (tier, map) VALUES (%i, '%s')", tier, g_map);
		DataPack dp = new DataPack();
		dp.WriteCell(GetClientSerial(client));
		dp.WriteCell(tier);
		g_sql.Query(SQLTierInsert, g_query, dp, DBPrio_Normal);
	}

	return;
}

void SQLTierInsert(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset();
	int serial = data.ReadCell();
	int tier = data.ReadCell();
	delete data;

	int client = GetClientFromSerial(serial);

	char auth[32] = "";
	GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

	if(strlen(error) > 0)
	{
		PrintToServer("SQLTierInsert - Tier: [%i] Name: [%N] SteamID64: [%s]: Error: [%s]", tier, client, auth, error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			LogToFileEx("addons/sourcemod/logs/trueexpert.log", "Tier: [%i] is set for MAP: [%s]. Edited by [%N] SteamID64: [%s]", tier, g_map, client, auth);

			PrintToServer("Tier %i is set for %s.", tier, g_map);
		}
	}

	return;
}

void SQLSetZone(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset();
	int serial = data.ReadCell();
	int type = data.ReadCell();
	int cpnum = data.ReadCell();
	delete data;

	int client = GetClientFromSerial(serial);

	char auth[32] = "";
	GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true);

	if(strlen(error) > 0)
	{
		PrintToServer("SQLSetZone - CP: [%i] Name: [%N] SteamID64: [%s]: Error: [%s]", cpnum, client, auth, error);
	}

	else if(strlen(error) == 0)
	{
		if(results.HasResults == false)
		{
			if(type == ZoneStart)
			{
				for(int i = 0; i <= 1; i++)
				{
					g_zoneStartOrigin[i] = g_zoneStartOriginTemp[client][i];

					continue;
				}

				for(int i = 0; i <= 2; i++)
				{
					g_center[cpnum][i] = (g_zoneStartOrigin[0][i] + g_zoneStartOrigin[1][i]) / 2.0;

					continue;
				}

				g_center[cpnum][2] -= FloatAbs((g_zoneStartOrigin[0][2] - g_zoneStartOrigin[1][2]) / 2.0);
				
				LogToFileEx("addons/sourcemod/logs/trueexpert.log", "Start zone successfuly created. POS1: [X: %f Y: %f Z: %f] POS2: [X: %f Y: %f Z: %f] MAP: [%s] edited by [%N] SteamID64: [%s]", g_zoneStartOrigin[0][0], g_zoneStartOrigin[0][1], g_zoneStartOrigin[0][2], g_zoneStartOrigin[1][0], g_zoneStartOrigin[1][1], g_zoneStartOrigin[1][2], g_map, client, auth);
			}

			else if(type == ZoneEnd)
			{
				for(int i = 0; i <= 1; i++)
				{
					g_zoneEndOrigin[i] = g_zoneEndOriginTemp[client][i];

					continue;
				}

				for(int i = 0; i <= 2; i++)
				{
					g_center[cpnum][i] = (g_zoneEndOrigin[0][i] + g_zoneEndOrigin[1][i]) / 2.0;

					continue;
				}

				g_center[cpnum][2] -= FloatAbs((g_zoneEndOrigin[0][2] - g_zoneEndOrigin[1][2]) / 2.0);

				LogToFileEx("addons/sourcemod/logs/trueexpert.log", "End zone successfuly created. POS1: [X: %f Y: %f Z: %f] POS2: [X: %f Y: %f Z: %f] MAP: [%s] edited by [%N] SteamID64: [%s]", g_zoneEndOrigin[0][0], g_zoneEndOrigin[0][1], g_zoneEndOrigin[0][2], g_zoneEndOrigin[1][0], g_zoneEndOrigin[1][1], g_zoneEndOrigin[1][2], g_map, client, auth);
			}

			else if(type == ZoneCP)
			{
				for(int i = 0; i <= 1; i++)
				{
					g_cpPos[cpnum][i] = g_cpPosTemp[client][cpnum][i];

					continue;
				}

				for(int i = 0; i <= 2; i++)
				{
					g_centerCP[cpnum][i] = (g_cpPos[cpnum][0][i] + g_cpPos[cpnum][1][i]) / 2.0;

					continue;
				}

				g_centerCP[cpnum][2] -= FloatAbs((g_cpPos[cpnum][0][2] - g_cpPos[cpnum][0][2]) / 2.0);

				CPSetup();

				LogToFileEx("addons/sourcemod/logs/trueexpert.log", "Checkpoint zone no. %i successfuly created. POS1: [X: %f Y: %f Z: %f] POS2: [X: %f Y: %f Z: %f] MAP: [%s] edited by [%N] SteamID64: [%s]", cpnum, g_cpPos[cpnum][0][0], g_cpPos[cpnum][0][1], g_cpPos[cpnum][0][2], g_cpPos[cpnum][1][0], g_cpPos[cpnum][1][1], g_cpPos[cpnum][1][2], g_map, client, auth);
			}
		}

		else if(results.HasResults == true)
		{
			if(type == ZoneStart)
			{
				PrintToServer("Start zone failed to create.");
			}

			else if(type == ZoneEnd)
			{
				PrintToServer("End zone failed to create.");
			}

			else if(type == ZoneCP)
			{
				PrintToServer("Checkpoint zone no. %i failed to create.", cpnum);
			}
		}
	}

	return;
}

Action AdminCommandZones(int client, int args)
{
	if(g_devmap == true)
	{
		if(g_zoneHave[2] == true)
		{
			ZoneEditor(client);
		}

		else if(g_zoneHave[2] == false)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DBLoading", client);
			SendMessage(client, g_buffer);
		}
	}

	else if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
}

void ZoneEditor(int client)
{
	float nulled[3] = {0.0, ...};

	for(int i = 0; i <= 1; i++)
	{
		g_zoneStartOriginTemp[client][i] = nulled;
		g_zoneEndOriginTemp[client][i] = nulled;

		g_zoneCreatorUseProcess[client][i] = false;

		g_zoneSelected[client][i] = nulled;

		for(int j = 0; j <= 10; ++j)
		{
			g_cpPosTemp[client][j][i] = nulled;

			continue;
		}

		continue;
	}

	g_step[client] = 1;
	g_zoneCursor[client] = false;
	g_ZoneEditorCP[client] = 1;

	Menu menu = new Menu(ZoneEditorMainMenuHandler);
	menu.SetTitle("%T", "ZoneEditor", client);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorAddButton", client);
	menu.AddItem("add", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorEditButton", client);
	menu.AddItem("edit", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorTPButton", client);
	menu.AddItem("tp", g_buffer);
	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

int ZoneEditorMainMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					ZoneAdd(param1);
				}

				case 1:
				{
					ZoneEdit(param1);
				}

				case 2:
				{
					ZoneTP(param1);
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

void ZoneAdd(int client)
{
	float nulled[3] = {0.0, ...};

	for(int i = 0; i <= 1; i++)
	{
		g_zoneStartOriginTemp[client][i] = nulled;
		g_zoneEndOriginTemp[client][i] = nulled;

		g_zoneCreatorUseProcess[client][i] = false;

		g_zoneSelected[client][i] = nulled;

		for(int j = 0; j <= 10; ++j)
		{
			g_cpPosTemp[client][j][i] = nulled;

			continue;
		}

		continue;
	}

	g_step[client] = 1;
	g_zoneCursor[client] = false;
	g_ZoneEditorCP[client] = 1;
	g_ZoneEditorVIA[client] = 0;

	Menu menu = new Menu(ZoneEditorAddZoneMenuHandler);
	menu.SetTitle("%T", "ZoneEditorAdd", client);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStartZoneButton", client);
	menu.AddItem("add_start", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorEndZoneButton", client);
	menu.AddItem("add_end", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorCPZoneButton", client);
	menu.AddItem("add_cp", g_buffer);
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

int ZoneEditorAddZoneMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					g_zoneCreatorSelected[param1] = 0;
					g_zoneSelectedCP[param1] = false;
					g_ZoneEditor[param1] = 0;
				}

				case 1:
				{
					g_zoneCreatorSelected[param1] = 1;
					g_zoneSelectedCP[param1] = false;
					g_ZoneEditor[param1] = 1;
				}
				
				case 2:
				{
					g_zoneCreatorSelected[param1] = 2;
					g_zoneSelectedCP[param1] = true;
					g_ZoneEditor[param1] = 2;
				}
			}

			ZoneCreator(param1);
		}

		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack: 
				{
					ZoneEditor(param1);
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

void ZoneEdit(int client)
{
	Menu menu = new Menu(ZoneEditorEditZoneMenuHandler);
	menu.SetTitle("%T", "ZoneEditorEdit", client);

	if(g_zoneHave[0] == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStartZoneButton", client);
		menu.AddItem("start", g_buffer);
	}

	if(g_zoneHave[1] == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorEndZoneButton", client);
		menu.AddItem("end", g_buffer);
	}

	if(g_cpCount > 0)
	{
		char cp[8] = "";

		for(int i = 1; i <= g_cpCount; ++i)
		{
			Format(cp, sizeof(cp), "%i", i);
			Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorCPButton", client, i);
			menu.AddItem(cp, g_buffer);

			continue;
		}
	}

	else if(g_zoneHave[0] == false && g_zoneHave[1] == false && g_cpCount == 0)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorNoZone", client);
		menu.AddItem("-1", g_buffer, ITEMDRAW_DISABLED);
	}

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	g_step[client] = 1;
	g_axis[client] = 0;

	g_ZoneEditorVIA[client] = 1;

	return;
}

void ZoneCreator(int client)
{
	Menu menu = new Menu(ZoneEditorCreatorMenuHandler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("%T", "ZoneEditorUse", client);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep1", client, g_step[client]);
	menu.AddItem("step1", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep2", client);
	menu.AddItem("step2", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", g_zoneCursor[client] == true ? "CursorPossitionON" : "CursorPossitionOFF", client);
	menu.AddItem("cursor", g_buffer);

	if(g_zoneSelectedCP[client] == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSelectedCPnum", client, g_ZoneEditorCP[client]);
		menu.AddItem("cpnum", g_buffer);
	}

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	g_zoneCreator[client] = true;

	return;
}

int ZoneEditorCreatorMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start:
		{
			g_zoneDraw[param1] = true;
		}
		
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					if(g_step[param1] < 64)
					{
						g_step[param1] *= 2;
					}

					ZoneCreator(param1);
				}

				case 1:
				{
					if(g_step[param1] > 1)
					{
						g_step[param1] /= 2;
					}

					ZoneCreator(param1);
				}

				case 2:
				{
					g_zoneCursor[param1] = !g_zoneCursor[param1];

					ZoneCreator(param1);
				}

				case 3:
				{
					g_zoneCPnumReadyToNew[param1] = true;

					Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", param1, "ZoneEditorTypeCPnum", param1);
					SendMessage(param1, g_buffer);
				}
			}
		}

		case MenuAction_Cancel:
		{
			g_zoneDraw[param1] = false;

			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					g_zoneCreator[param1] = false;

					ZoneAdd(param1);
				}
			}
		}

		case MenuAction_Display:
		{
			g_zoneDraw[param1] = true;
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

int ZoneEditorEditZoneMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			if(StrEqual(item, "start", false) == true)
			{
				for(int i = 0; i <= 1; i++)
				{
					g_zoneStartOriginTemp[param1][i] = g_zoneStartOrigin[i];

					continue;
				}
				
				ZoneEditorStart(param1);
			}

			else if(StrEqual(item, "end", false) == true)
			{
				for(int i = 0; i <= 1; i++)
				{
					g_zoneEndOriginTemp[param1][i] = g_zoneEndOrigin[i];

					continue;
				}

				ZoneEditorEnd(param1);
			}

			for(int i = 1; i <= g_cpCount; ++i)
			{
				char cp[8] = "";
				IntToString(i, cp, sizeof(cp));

				if(StrEqual(item, cp, false) == true)
				{
					for(int j = 0; j <= 1; j++)
					{
						g_cpPosTemp[param1][i][j] = g_cpPos[i][j];

						continue;
					}

					ZoneEditorCP(param1, i);
				}

				continue;
			}
		}

		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					ZoneEditor(param1);
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

void ZoneEditorStart(int client)
{
	Menu menu = new Menu(ZoneEditortZoneMenuHandler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("%T", "ZoneEditorStartZone", client);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep1", client, g_step[client]);
	menu.AddItem("step1", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep2", client);
	menu.AddItem("step2", g_buffer);

	char format2[24] = "";
	Format(format2, sizeof(format2), "0;%i;1;sidestart", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "0;%i;0;sidestart", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "1;%i;1;sidestart", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "1;%i;0;sidestart", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorAxis", client);
	menu.AddItem("axis", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorApplyStartZone", client);
	menu.AddItem("startapply", g_buffer);

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor[client] = 0;

	return;
}

void ZoneEditorEnd(int client)
{
	Menu menu = new Menu(ZoneEditortZoneMenuHandler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("%T", "ZoneEditorEndZone", client);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep1", client, g_step[client]);
	menu.AddItem("step1", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep2", client);
	menu.AddItem("step2", g_buffer);

	char format2[16] = "";
	Format(format2, sizeof(format2), "0;%i;1;sideend", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "0;%i;0;sideend", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "1;%i;1;sideend", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "1;%i;0;sideend", g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorAxis", client);
	menu.AddItem("axis", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorApplyEndZone", client);
	menu.AddItem("endapply", g_buffer);

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor[client] = 1;

	return;
}

void ZoneEditorCP(int client, int cpnum)
{
	Menu menu = new Menu(ZoneEditortZoneMenuHandler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	menu.SetTitle("%T", "ZoneEditorCPZone", client, cpnum);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep1", client, g_step[client]);
	menu.AddItem("step1", g_buffer);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStep2", client);
	menu.AddItem("step2", g_buffer);

	char format2[24] = "";
	Format(format2, sizeof(format2), "%i;0;%i;1;sidecp", cpnum, g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "%i;0;%i;0;sidecp", cpnum, g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide1-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "%i;1;%i;1;sidecp", cpnum, g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2+", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(format2, sizeof(format2), "%i;1;%i;0;sidecp", cpnum, g_axis[client]);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorSide2-", client, g_axisLater[g_axis[client]], g_step[client]);
	menu.AddItem(format2, g_buffer);

	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorAxis", client);
	menu.AddItem("axis", g_buffer);

	char cpupdate[16] = "";
	Format(cpupdate, sizeof(cpupdate), "%i;cpapply", cpnum);
	Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorApplyCPZone", client, cpnum);
	menu.AddItem(cpupdate, g_buffer);

	menu.ExitBackButton = true; //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L49
	menu.Display(client, MENU_TIME_FOREVER);

	g_ZoneEditor[client] = 2;
	g_ZoneEditorCP[client] = cpnum;

	return;
}

int ZoneEditortZoneMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
		{
			g_zoneDraw[param1] = true;
		}

		case MenuAction_Select:
		{
			char item[32] = "";
			menu.GetItem(param2, item, sizeof(item));

			int cpnum = 0;

			char exploded[4][16];
			ExplodeString(item, ";", exploded, 4, 16, false);

			if(StrContains(item, "cp", false) != -1)
			{
				cpnum = StringToInt(exploded[0], 10);
			}

			bool cpMenu = StrContains(item, "cp", false) != -1;
			int side = StringToInt(exploded[cpMenu == true ? 1 : 0], 10);
			int axis = StringToInt(exploded[cpMenu == true ? 2 : 1], 10);
			int mode = StringToInt(exploded[cpMenu == true ? 3 : 2], 10);

			if(StrEqual(item, "step1", false) == true)
			{
				if(g_step[param1] < 64)
				{
					g_step[param1] *= 2;
				}
			}

			else if(StrEqual(item, "step2", false) == true)
			{
				if(g_step[param1] > 1)
				{
					g_step[param1] /= 2;
				}
			}

			else if(StrEqual(item, "axis", false) == true)
			{
				g_axis[param1]++;

				if(g_axis[param1] > 2)
				{
					g_axis[param1] = 0;
				}
			}

			if(StrContains(item, "sidestart", false) != -1)
			{
				g_zoneStartOriginTemp[param1][side][axis] += mode == 1 ? g_step[param1] : -g_step[param1];
			}

			else if(StrContains(item, "sideend", false) != -1)
			{
				g_zoneEndOriginTemp[param1][side][axis] += mode == 1 ? g_step[param1] : -g_step[param1];
			}

			else if(StrContains(item, "sidecp", false) != -1)
			{
				g_cpPosTemp[param1][cpnum][side][axis] += mode == 1 ? g_step[param1] : -g_step[param1];
			}

			if(StrEqual(item, "startapply", false) == true)
			{
				Format(g_query, sizeof(g_query), "DELETE FROM zones WHERE map = '%s' AND type = ZoneStart LIMIT 1", g_map);
				DataPack dp = new DataPack();
				dp.WriteCell(GetClientSerial(param1));
				dp.WriteCell(ZoneStart);
				dp.WriteCell(0);
				g_sql.Query(SQLDeleteZone, g_query, dp, DBPrio_Normal);
			}

			else if(StrEqual(item, "endapply", false) == true)
			{
				Format(g_query, sizeof(g_query), "DELETE FROM zones WHERE map = '%s' AND type = ZoneEnd LIMIT 1", g_map);
				DataPack dp = new DataPack();
				dp.WriteCell(GetClientSerial(param1));
				dp.WriteCell(ZoneEnd);
				dp.WriteCell(0);
				g_sql.Query(SQLDeleteZone, g_query, dp, DBPrio_Normal);
			}

			else if(StrContains(item, "cpapply", false) != -1)
			{
				Format(g_query, sizeof(g_query), "DELETE FROM cp WHERE cpnum = %i AND map = '%s' LIMIT 1", cpnum, g_map);
				DataPack dp = new DataPack();
				dp.WriteCell(GetClientSerial(param1));
				dp.WriteCell(ZoneCP);
				dp.WriteCell(cpnum);
				g_sql.Query(SQLDeleteZone, g_query, dp, DBPrio_Normal);
			}

			if(g_ZoneEditor[param1] == ZoneStart)
			{
				ZoneEditorStart(param1);
			}

			else if(g_ZoneEditor[param1] == ZoneEnd)
			{
				ZoneEditorEnd(param1);
			}

			else if(g_ZoneEditor[param1] == ZoneCP)
			{
				ZoneEditorCP(param1, g_ZoneEditorCP[param1]);
			}
		}

		case MenuAction_Cancel: //trikz redux menuaction end
		{
			g_zoneDraw[param1] = false; //idea from expert zone.

			switch(param2)
			{
				case MenuCancel_ExitBack: //https://cc.bingj.com/cache.aspx?q=ExitBackButton+sourcemod&d=4737211702971338&mkt=en-WW&setlang=en-US&w=wg9m5FNl3EpqPBL0vTge58piA8n5NsLz#L125
				{
					switch(g_ZoneEditorVIA[param1])
					{
						case 0:
						{
							ZoneAdd(param1);
						}

						case 1:
						{
							ZoneEdit(param1);
						}
					}
				}
			}
		}

		case MenuAction_Display:
		{
			g_zoneDraw[param1] = true;
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}

	return view_as<int>(action);
}

void ZoneTP(int client)
{
	Menu menu = new Menu(ZoneEditorTPMenuHandler);
	menu.SetTitle("%T", "ZoneEditorTP", client);

	if(g_zoneHave[0] == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorStartZoneButton", client);
		menu.AddItem("start", g_buffer);
	}

	if(g_zoneHave[1] == true)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorEndZoneButton", client);
		menu.AddItem("end", g_buffer);
	}

	if(g_cpCount > 0)
	{
		char cp[8] = "";

		for(int i = 1; i <= g_cpCount; ++i)
		{
			Format(cp, sizeof(cp), "%i;cp", i);
			Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorCPButton", client, i);
			menu.AddItem(cp, g_buffer);

			continue;
		}
	}

	else if(g_zoneHave[0] == false && g_zoneHave[1] == false && g_cpCount == 0)
	{
		Format(g_buffer, sizeof(g_buffer), "%T", "ZoneEditorNoZone", client);
		menu.AddItem("-1", g_buffer, ITEMDRAW_DISABLED);
	}

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);

	return;
}

int ZoneEditorTPMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[16] = "";
			menu.GetItem(param2, item, sizeof(item));

			float pos[3] = {0.0, ...};

			if(StrEqual(item, "start", false) == true)
			{
				pos = g_center[0];
				pos[2] += 1.0;
				TeleportEntity(param1, pos, NULL_VECTOR, NULL_VECTOR);
			}

			else if(StrEqual(item, "end", false) == true)
			{
				pos = g_center[1];
				pos[2] += 1.0;
				TeleportEntity(param1, pos, NULL_VECTOR, NULL_VECTOR);
			}

			else if(StrContains(item, "cp", false) != -1)
			{
				char exploded[1][8];
				ExplodeString(item, ";", exploded, 1, 8, false);
				int cpnum = StringToInt(exploded[0], 10);

				pos = g_centerCP[cpnum];
				pos[2] += 1.0;
				TeleportEntity(param1, pos, NULL_VECTOR, NULL_VECTOR);
			}

			ZoneTP(param1);
		}

		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					ZoneEditor(param1);
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

//https://forums.alliedmods.net/showthread.php?t=261378

void SQLCreateCPTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateCPTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("CP table successfuly created, if not exist.");
	}

	return;
}

void SQLCreateTierTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateTierTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Tier table successfuly created, if not exist.");
	}

	return;
}

void CPSetup()
{
	g_cpCount = 0;
	g_zoneHave[2] = false;

	char format[24 + 1] = "";
	Format(format, sizeof(format), "SELECT * FROM cp LIMIT 1");

	Format(g_query, sizeof(g_query), format);
	DBPriority prio = DBPrio_Normal;
	g_sql.Query(SQLCPSetup, g_query, _, prio);

	return;
}

void SQLCPSetup(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSetup: %s", error);
	}

	else if(strlen(error) == 0)
	{
		bool fetchrow = results.FetchRow();

		if(fetchrow == true)
		{
			for(int i = 1; i <= 10; ++i)
			{
				Format(g_query, sizeof(g_query), "SELECT cpx, cpy, cpz, cpx2, cpy2, cpz2 FROM cp WHERE cpnum = %i AND map = '%s' LIMIT 1", i, g_map);
				g_sql.Query(SQLCPSetup2, g_query, i, DBPrio_Normal);

				continue;
			}
		}

		else if(fetchrow == false)
		{
			if(g_zoneHave[2] == false)
			{
				g_zoneHave[2] = true;
			}
		}
	}

	return;
}

void SQLCPSetup2(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSetup2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		if(results.FetchRow() == true)
		{
			int result[2] = {0, 3};

			for(int i = 0; i <= 2; i++)
			{
				g_cpPos[data][0][i] = results.FetchFloat(result[0]++);
				g_cpPos[data][1][i] = results.FetchFloat(result[1]++);

				continue;
			}

			if(g_devmap == false)
			{
				CreateCP(data);
			}

			g_cpCount++;
		}

		if(data == 10)
		{
			if(g_zoneHave[2] == false)
			{
				g_zoneHave[2] = true;
			}

			if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true && IsFakeClient(i) == false)
					{
						if(g_devmap == false && g_zoneHave[0] == true && g_zoneHave[1] == true && g_zoneDrawed[i] == false)
						{
							DrawZone(i, 0.0, 3.0, 10, -1, -1);

							g_zoneDrawed[i] = true;
						}
					}

					continue;
				}
			}
		}
	}

	return;
}

void CreateCP(int cpnum)
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
		g_centerCP[cpnum][i] = (g_cpPos[cpnum][1][i] + g_cpPos[cpnum][0][i]) / 2.0;

		continue;
	}

	g_centerCP[cpnum][2] -= FloatAbs((g_cpPos[cpnum][0][2] - g_cpPos[cpnum][1][2]) / 2.0);

	TeleportEntity(entity, g_centerCP[cpnum], NULL_VECTOR, NULL_VECTOR); //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1

	float mins[3] = {0.0, ...};
	float maxs[3] = {0.0, ...};

	for(int i = 0; i <= 2; i++)
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

		continue;
	}

	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins, 0); //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs, 0);

	SetEntProp(entity, Prop_Send, "m_nSolidType", 2, 4, 0);

	SDKHook(entity, SDKHook_StartTouch, OnZoneStartTouch);

	PrintToServer("Checkpoint number %i is successfuly setup.", cpnum);

	return;
}

void SQLCreateUserTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateUserTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Successfuly created user table, if not exist.");
	}

	return;
}

void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLRecordsTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Successfuly created records table, if not exist.");
	}

	return;
}

Action OnZoneEndTouch(int entity, int other)
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

		CreateTimer(0.1, TimerClantag, other, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, TimerClantag, partner, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		for(int i = 1; i <= g_cpCount; ++i)
		{
			g_cp[other][i] = false;
			g_cp[partner][i] = false;

			g_cpLock[other][i] = false;
			g_cpLock[partner][i] = false;

			continue;
		}

		g_cpCountTryToAlign[other] = 0;
		g_cpCountTryToAlign[partner] = 0;

		GlobalForward hForward = new GlobalForward("Trikz_OnTimerStart", ET_Hook, Param_Cell, Param_Cell);
		Call_StartForward(hForward);
		Call_PushCell(other);
		Call_PushCell(partner);
		Call_Finish();
		delete hForward;

		Format(g_query, sizeof(g_query), "SELECT * FROM records LIMIT 1");
		int serial = GetClientSerial(other);
		DBPriority prio = DBPrio_High;
		g_sql.Query(SQLSetTries, g_query, serial, prio);
	}

	return Plugin_Continue;
}

Action OnZoneTouch(int entity, int other)
{
	if(!(GetEntityFlags(other) & FL_ONGROUND))
	{
		OnZoneEndTouch(entity, other);
	}

	return Plugin_Continue;
}

Action OnZoneStartTouch(int entity, int other)
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

				if(g_ServerRecordTime > 0.0)
				{
					if(g_ServerRecordTime > time)
					{
						timeDiff = g_ServerRecordTime - time;

						record = true;
					}

					else if(g_ServerRecordTime <= time)
					{
						timeDiff = time - g_ServerRecordTime;
					}
				}

				else if(g_ServerRecordTime == 0.0)
				{
					timeDiff = 0.0;
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

				int playerid = GetSteamAccountID(other, true);
				int partnerid = GetSteamAccountID(partner, true);

				if(g_ServerRecordTime > 0.0)
				{
					if(g_teamRecord[other] > 0.0)
					{
						if(g_ServerRecordTime > time)
						{
							for(int i = 1; i <= MaxClients; ++i)
							{
								if(IsClientInGame(i) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecord", i);
									SendMessage(i, g_buffer); //smth like shavit functions.

									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecordDetail", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}

							FinishMSG(other, false, true, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, true, false, false, false, 0, timeOwn, timeSR);

							Format(g_query, sizeof(g_query), "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' ORDER BY time ASC LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_sql.Query(SQLUpdateRecord, g_query, _, DBPrio_Normal);

							g_haveRecord[other] = time;
							g_haveRecord[partner] = time; //logs help also expert zone ideas.

							g_teamRecord[other] = time;
							g_teamRecord[partner] = time;

							g_ServerRecord = true;
							g_ServerRecordTime = time;

							float sourcetvCV = gCV_sourceTV.FloatValue;

							if(sourcetvCV == 1.0)
							{
								CreateTimer(60.0, TimerSourceTV, _, TIMER_FLAG_NO_MAPCHANGE);
							}

							GlobalForward hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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
							for(int i = 1; i <= MaxClients; ++i)
							{
								if(IsClientInGame(i) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "Passed", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}
							
							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(g_query, sizeof(g_query), "UPDATE records SET finishes = finishes + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
							g_sql.Query(SQLUpdateRecord, g_query, _, DBPrio_Normal);

							GlobalForward hForward = new GlobalForward("Trikz_OnFinish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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
							for(int i = 1; i <= MaxClients; ++i)
							{
								if(IsClientInGame(i) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "PassedImproved", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}
							
							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(g_query, sizeof(g_query), "UPDATE records SET time = %f, finishes = finishes + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_sql.Query(SQLUpdateRecord, g_query, _, DBPrio_Normal);

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

							GlobalForward hForward = new GlobalForward("Trikz_OnFinish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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
							for(int i = 1; i <= MaxClients; ++i)
							{
								if(IsClientInGame(i) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecordNew", i);
									SendMessage(i, g_buffer); //all this plugin is based on expert zone ideas and log helps, so little bit ping from rumour and some alliedmodders code free and hlmod code free. and ws code free. entityfilter is made from george code. alot ideas i steal for leagal reason. gnu allows to copy codes if author accept it or public plugin.

									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecordNewDetail", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}

							FinishMSG(other, false, true, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, true, false, false, false, 0, timeOwn, timeSR);

							Format(g_query, sizeof(g_query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_sql.Query(SQLInsertRecord, g_query, _, DBPrio_Normal);

							g_haveRecord[other] = time;
							g_haveRecord[partner] = time;

							g_teamRecord[other] = time;
							g_teamRecord[partner] = time;

							g_ServerRecord = true;

							g_ServerRecordTime = time;

							float sourcetvCV = gCV_sourceTV.FloatValue;

							if(sourcetvCV == 1.0)
							{
								CreateTimer(60.0, TimerSourceTV, _, TIMER_FLAG_NO_MAPCHANGE);
							}

							GlobalForward hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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
							for(int i = 1; i <= MaxClients; ++i)
							{
								if(IsClientInGame(i) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "JustPassed", i, name, namePartner, timeOwn, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}

							FinishMSG(other, false, false, false, false, false, 0, timeOwn, timeSR);
							FinishMSG(partner, false, false, false, false, false, 0, timeOwn, timeSR);

							Format(g_query, sizeof(g_query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
							g_sql.Query(SQLInsertRecord, g_query, _, DBPrio_Normal);

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

							GlobalForward hForward = new GlobalForward("Trikz_OnFinish", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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

					for(int i = 1; i <= g_cpCount; ++i)
					{
						if(g_cp[other][i] == true)
						{
							char timeCP[24] = "";
							FormatSeconds(g_cpDiffSR[other][i], timeCP);

							for(int j = 1; j <= MaxClients; ++j)
							{
								if(IsClientInGame(j) == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", j, g_cpTime[other][i] < g_cpTimeSR[i] == true ? "CPImprove" : "CPDeprove", j, i, timeCP);
									SendMessage(j, g_buffer);
								}

								continue;
							}
						}

						continue;
					}
				}

				else if(g_ServerRecordTime == 0.0)
				{
					g_ServerRecordTime = time;

					g_haveRecord[other] = time;
					g_haveRecord[partner] = time;

					g_teamRecord[other] = time;
					g_teamRecord[partner] = time;

					for(int i = 1; i <= MaxClients; ++i)
					{
						if(IsClientInGame(i) == true)
						{
							Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecordFirst", i);
							SendMessage(i, g_buffer);

							Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "NewServerRecordFirstDetail", i, name, namePartner, timeOwn, timeSR);
							SendMessage(i, g_buffer);

							for(int j = 1; j <= g_cpCount; ++j)
							{
								if(g_cp[other][j] == true)
								{
									Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTimer", i, "CPNEW", i, j, timeSR);
									SendMessage(i, g_buffer);
								}

								continue;
							}
						}

						continue;
					}

					FinishMSG(other, true, false, false, false, false, 0, timeOwn, timeSR);
					FinishMSG(partner, true, false, false, false, false, 0, timeOwn, timeSR);

					g_ServerRecord = true;

					float sourcetvCV = gCV_sourceTV.FloatValue;

					if(sourcetvCV == 1.0)
					{
						CreateTimer(60.0, TimerSourceTV, _, TIMER_FLAG_NO_MAPCHANGE); //https://forums.alliedmods.net/showthread.php?t=191615
					}

					Format(g_query, sizeof(g_query), "UPDATE records SET time = %f, finishes = 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", g_timerTime[other], g_cpTime[other][1], g_cpTime[other][2], g_cpTime[other][3], g_cpTime[other][4], g_cpTime[other][5], g_cpTime[other][6], g_cpTime[other][7], g_cpTime[other][8], g_cpTime[other][9], g_cpTime[other][10], GetTime(), playerid, partnerid, partnerid, playerid, g_map);
					g_sql.Query(SQLInsertRecord, g_query, _, DBPrio_Normal);

					GlobalForward hForward = new GlobalForward("Trikz_OnRecord", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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

		for(int i = 1; i <= g_cpCount; ++i)
		{
			char triggerCP[32] = "";
			Format(triggerCP, sizeof(triggerCP), "trueexpert_cp%i", i);

			if(StrEqual(trigger, triggerCP, false) == true)
			{
				if(g_cpLock[other][i] == false)
				{
					g_cpLock[other][i] = true;

					int cpnumAligned = ++g_cpCountTryToAlign[other];
					g_cp[other][cpnumAligned] = true;

					if(g_cpLock[partner][i] == true)
					{
						g_cpTime[other][cpnumAligned] = g_timerTime[other];
						g_cpTime[partner][cpnumAligned] = g_timerTime[other];

						//https://stackoverflow.com/questions/9617453 https://www.w3schools.com/sql/sql_ref_order_by.asp#:~:text=%20SQL%20ORDER%20BY%20Keyword%20%201%20ORDER,data%20returned%20in%20descending%20order.%20%20More%20
						Format(g_query, sizeof(g_query), "SELECT cp%i FROM records LIMIT 1", cpnumAligned);

						DataPack dp = new DataPack();
						dp.WriteCell(GetClientSerial(other));
						dp.WriteCell(cpnumAligned);

						g_sql.Query(SQLCPSelect, g_query, dp, DBPrio_Normal);
					}
				}
			}

			continue;
		}
	}

	return Plugin_Continue;
}

void FinishMSG(int client, bool firstServerRecord, bool serverRecord, bool onlyCP, bool firstCPRecord, bool cpRecord, int cpnum, const char[] time, const char[] timeSR)
{
	if(g_endMessage[client] == false)
	{
		return;
	}

	if(onlyCP == true)
	{
		if(firstCPRecord == true)
		{
			FinishMSGHUD(client, 0, "onlyCP_firstCPRecord", cpnum, time, timeSR);
		}

		else if(firstCPRecord == false)
		{
			if(cpRecord == true)
			{
				FinishMSGHUD(client, 1, "onlyCP_notFirstCPRecord_cpRecord", cpnum, time, timeSR);
			}

			else if(cpRecord == false)
			{
				FinishMSGHUD(client, 2, "onlyCP_notFirstCPRecord_notCPRecord", cpnum, time, timeSR);
			}
		}
	}

	else if(onlyCP == false)
	{
		if(firstServerRecord == true)
		{
			FinishMSGHUD(client, 3, "notOnlyCP_firstServerRecord", cpnum, time, timeSR);
		}

		else if(firstServerRecord == false)
		{
			if(serverRecord == true)
			{
				FinishMSGHUD(client, 4, "notOnlyCP_notFirstServerRecord_serverRecord", cpnum, time, timeSR);
			}

			else if(serverRecord == false)
			{
				FinishMSGHUD(client, 5, "notOnlyCP_notFirstServerRecord_notServerRecord", cpnum, time, timeSR);
			}
		}
	}

	return;
}

void FinishMSGHUD(int client, int keynum, const char[] sectiontype, int cpnum, const char[] time, const char[] timeSR)
{
	g_kv.Rewind();
	g_kv.GotoFirstSubKey(true);

	char key[4][64] = {"", "", "", ""};
	char section[64], posColor[64], exploded[7][8];
	float xy[4][2], holdtime[4];
	int start = 0, rgba[4][4], nBase = 10, size = 4, element = 0;

	if(StrEqual(sectiontype, "onlyCP_notFirstCPRecord_notCPRecord", true) == true)
	{
		start = 1;
	}

	else if(StrEqual(sectiontype, "notOnlyCP_notFirstServerRecord_notServerRecord", true) == true)
	{
		start = 1;
	}

	switch(keynum)
	{
		case 0:
		{
			Format(key[0], 64, "CP-recordHud");
			Format(key[1], 64, "CP-recordDetailHud");
			Format(key[2], 64, "CP-DetailZeroHud");
		}

		case 1:
		{
			Format(key[0], 64, "CP-recordNotFirstHud");
			Format(key[1], 64, "CP-recordDetailNotFirstHud");
			Format(key[2], 64, "CP-recordImproveNotFirstHud");
		}

		case 2:
		{
			Format(key[1], 64, "CP-recordNonHud");
			Format(key[2], 64, "CP-recordDeproveHud");
		}

		case 3:
		{
			Format(key[0], 64, "MapFinishedFirstRecordHud");
			Format(key[1], 64, "NewServerRecordHud");
			Format(key[2], 64, "FirstRecordHud");
			Format(key[3], 64, "FirstRecordZeroHud");
		}

		case 4:
		{
			Format(key[0], 64, "NewServerRecordMapFinishedNotFirstHud");
			Format(key[1], 64, "NewServerRecordNotFirstHud");
			Format(key[2], 64, "NewServerRecordDetailNotFirstHud");
			Format(key[3], 64, "NewServerRecordImproveNotFirstHud");
		}

		case 5:
		{
			Format(key[1], 64, "MapFinishedDeproveHud");
			Format(key[2], 64, "MapFinishedTimeDeproveHud");
			Format(key[3], 64, "MapFinishedTimeDeproveOwnHud");
		}
	}

	do
	{
		if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, sectiontype, true) == true)
		{
			for(int i = start; i < sizeof(key); i++)
			{
				g_kv.GetString(key[i], posColor, sizeof(posColor));

				if(strlen(posColor) == 0)
				{
					break;
				}

				ExplodeString(posColor, ",", exploded, 7, 8, false);

				for(int j = 0; j <= 1; j++)
				{
					xy[i][j] = StringToFloat(exploded[j]);

					continue;
				}

				holdtime[i] = StringToFloat(exploded[2]);
				
				for(int j = 3; j <= 6; j++)
				{
					rgba[i][j - 3] = StringToInt(exploded[j], nBase);

					continue;
				}

				if(cpnum > 0)
				{
					if(TestCase(keynum, i) == true)
					{
						break;
					}
				}
			}

			break;
		}

		continue;
	}

	while(g_kv.GotoNextKey(true) == true);

	int channel = 1;

	for(int i = start; i < sizeof(key); i++)
	{
		if(cpnum > 0)
		{
			SetHudTextParams(xy[i][0], xy[i][1], holdtime[i], rgba[i][0], rgba[i][1], rgba[i][2], rgba[i][3]); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			if(i == 0){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client, cpnum);} //https://steamuserimages-a.akamaihd.net/ugc/1788470716362427548/185302157bF4CBF4557D0C47842C6BBD705380A/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false
			else if(i == 1){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client, time);}
			else if(i == 2){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client, timeSR);}
			ShowHudText(client, channel++, g_buffer); //https://sm.alliedmods.net/new-api/halflife/ShowHudText

			if(TestCase(keynum, i) == true)
			{
				break;
			}
		}

		else if(cpnum == 0)
		{
			SetHudTextParams(xy[i][0], xy[i][1], holdtime[i], rgba[i][0], rgba[i][1], rgba[i][2], rgba[i][3]); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
			if(i == 0){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client);}
			else if(i == 1){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client);}
			else if(i == 2){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client, time);}
			else if(i == 3){Format(g_buffer, sizeof(g_buffer), "%T", key[i], client, timeSR);}
			ShowHudText(client, channel++, g_buffer); //https://sm.alliedmods.net/new-api/halflife/ShowHudText
		}

		continue;
	}

	for(int i = 1; i <= MaxClients; ++i)
	{
		if(IsClientInGame(i) == true && IsClientObserver(i) == true)
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", element);
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", size, element);

			if(IsClientSourceTV(i) == true || (observerMode < 7 && observerTarget == client))
			{
				int channelSpec = 1;

				for(int j = start; j < sizeof(key); j++)
				{
					if(cpnum > 0)
					{
						SetHudTextParams(xy[j][0], xy[j][1], holdtime[j], rgba[j][0], rgba[j][1], rgba[j][2], rgba[j][3]); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
						if(j == 0){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i, cpnum);}
						else if(j == 1){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i, time);}
						else if(j == 2){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i, timeSR);}
						ShowHudText(i, channelSpec++, g_buffer); //https://sm.alliedmods.net/new-api/halflife/ShowHudText

						if(TestCase(keynum, j) == true)
						{
							break;
						}
					}

					else if(cpnum == 0)
					{
						SetHudTextParams(xy[j][0], xy[j][1], holdtime[j], rgba[j][0], rgba[j][1], rgba[j][2], rgba[j][3]); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
						if(j == 0){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i);}
						else if(j == 1){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i);}
						else if(j == 2){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i, time);}
						else if(j == 3){Format(g_buffer, sizeof(g_buffer), "%T", key[j], i, timeSR);}
						ShowHudText(i, channelSpec++, g_buffer); //https://sm.alliedmods.net/new-api/halflife/ShowHudText
					}


					continue;
				}
			}
		}

		continue;
	}

	return;
}

bool TestCase(int keynum, int iter)
{
	switch(keynum)
	{
		case 0,1,2:
		{
			if(iter == 2)
			{
				return true;
			}
		}
	}

	return false;
}

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, any data)
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

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
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

Action TimerSourceTV(Handle timer)
{
	ConVar CV_sourcetv = FindConVar("tv_enable");

	int sourcetv = CV_sourcetv.IntValue; //https://sm.alliedmods.net/new-api/convars/__raw

	if(sourcetv == 1.0)
	{
		ServerCommand("tv_stoprecord");

		g_sourcetvchangedFileName = false;

		CreateTimer(5.0, TimerRunSourceTV, _, TIMER_FLAG_NO_MAPCHANGE);

		g_ServerRecord = false;
	}

	return Plugin_Stop;
}

Action TimerRunSourceTV(Handle timer)
{
	char filenameOld[256] = "";
	Format(filenameOld, sizeof(filenameOld), "%s-%s-%s.dem", g_date, g_time, g_map);

	char filenameNew[256] = "";
	Format(filenameNew, sizeof(filenameNew), "%s-%s-%s-ServerRecord.dem", g_date, g_time, g_map);

	RenameFile(filenameNew, filenameOld);
	ConVar CV_sourcetv = FindConVar("tv_enable");

	int sourcetv = CV_sourcetv.IntValue; //https://sm.alliedmods.net/new-api/convars/__raw

	if(sourcetv == 1.0)
	{
		PrintToServer("SourceTV is start recording.");

		FormatTime(g_date, sizeof(g_date), "%Y-%m-%d", GetTime());
		FormatTime(g_time, sizeof(g_time), "%H-%M-%S", GetTime());

		ServerCommand("tv_record %s-%s-%s", g_date, g_time, g_map);

		g_sourcetvchangedFileName = true;
	}

	return Plugin_Continue;
}

void SQLCPSelect(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSelect: %s", error);
	}

	else if(strlen(error) == 0)
	{
		data.Reset();
		int serial = data.ReadCell();
		int cpnum = data.ReadCell();
		delete data;

		int other = GetClientFromSerial(serial);

		bool fetchrow = results.FetchRow();

		if(fetchrow == false)
		{
			float time = g_timerTime[other];

			char timeOwn[24] = "";
			FormatSeconds(time, timeOwn);

			char timeSR[24] = "+00:00:00";

			int partner = g_partner[other];

			FinishMSG(other, false, false, true, true, false, cpnum, timeOwn, timeSR);
			FinishMSG(partner, false, false, true, true, false, cpnum, timeOwn, timeSR);

			GlobalForward hForward = new GlobalForward("Trikz_OnCheckpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
			Call_StartForward(hForward);
			Call_PushCell(other);
			Call_PushCell(partner);
			Call_PushFloat(time);
			Call_PushFloat(0.0);
			Call_PushString("FirstCPRecord1");
			Call_Finish();
			delete hForward;
		}

		else if(fetchrow == true)
		{
			Format(g_query, sizeof(g_query), "SELECT cp%i FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 1", cpnum, g_map); //log help me alot with this stuff, logs palīdzēja atrast kodu un saprast kā tas strādā.
			DataPack dp = new DataPack();
			dp.WriteCell(serial);
			dp.WriteCell(cpnum);
			g_sql.Query(SQLCPSelect2, g_query, dp, DBPrio_Normal);
		}
	}

	return;
}

void SQLCPSelect2(Database db, DBResultSet results, const char[] error, DataPack data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCPSelect2: %s", error);
	}

	else if(strlen(error) == 0)
	{
		data.Reset();
		int serial = data.ReadCell();
		int cpnum = data.ReadCell();
		delete data;

		int other = GetClientFromSerial(serial);

		float time = g_timerTime[other];

		char timeOwn[24] = "";
		FormatSeconds(time, timeOwn);

		char timeSR[24] = "+00:00:00";

		int partner = g_partner[other];

		bool fetchrow = results.FetchRow();

		if(fetchrow == false)
		{
			FinishMSG(other, false, false, true, true, false, cpnum, timeOwn, timeSR);
			FinishMSG(partner, false, false, true, true, false, cpnum, timeOwn, timeSR);

			GlobalForward hForward = new GlobalForward("Trikz_OnCheckpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
			Call_StartForward(hForward);
			Call_PushCell(other);
			Call_PushCell(partner);
			Call_PushFloat(time);
			Call_PushFloat(0.0);
			Call_PushString("FirstCPRecord2");
			Call_Finish();
			delete hForward;
		}

		else if(fetchrow == true)
		{
			g_cpTimeSR[cpnum] = results.FetchFloat(0);

			if(g_cpTime[other][cpnum] < g_cpTimeSR[cpnum])
			{
				g_cpDiffSR[other][cpnum] = g_cpTimeSR[cpnum] - g_cpTime[other][cpnum];
				g_cpDiffSR[partner][cpnum] = g_cpTimeSR[cpnum] - g_cpTime[other][cpnum];

				float diff = g_cpDiffSR[other][cpnum];
				FormatSeconds(diff, timeSR);

				Format(timeSR, sizeof(timeSR), "-%s", timeSR);

				FinishMSG(other, false, false, true, false, true, cpnum, timeOwn, timeSR);
				FinishMSG(partner, false, false, true, false, true, cpnum, timeOwn, timeSR);

				GlobalForward hForward = new GlobalForward("Trikz_OnCheckpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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

				Format(timeSR, sizeof(timeSR), "+%s", timeSR);

				FinishMSG(other, false, false, true, false, false, cpnum, timeOwn, timeSR);
				FinishMSG(partner, false, false, true, false, false, cpnum, timeOwn, timeSR);

				GlobalForward hForward = new GlobalForward("Trikz_OnCheckpoint", ET_Hook, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_String);
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

void SQLSetTries(Database db, DBResultSet results, const char[] error, any data)
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

		int client = GetClientFromSerial(data);

		int playerid = GetSteamAccountID(client, true);
		int partner = g_partner[client];
		int partnerid = GetSteamAccountID(partner, true);

		bool fetchrow = results.FetchRow();

		if(fetchrow == false)
		{
			Format(g_query, sizeof(g_query), "INSERT INTO records (playerid, partnerid, tries, map, date) VALUES (%i, %i, 1, '%s', %i)", playerid, partnerid, g_map, GetTime());
			g_sql.Query(SQLSetTriesInserted, g_query, _, DBPrio_High);
		}

		else if(fetchrow == true)
		{
			Format(g_query, sizeof(g_query), "SELECT tries FROM records WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
			int serial = GetClientSerial(client);
			g_sql.Query(SQLSetTries2, g_query, serial, DBPrio_High);
		}
	}

	return;
}

void SQLSetTriesInserted(Database db, DBResultSet results, const char[] error, any data)
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

void SQLSetTries2(Database db, DBResultSet results, const char[] error, any data)
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

		int client = GetClientFromSerial(data);

		if(IsValidClient(client) == true)
		{
			int playerid = GetSteamAccountID(client, true);
			int partner = g_partner[client];
			int partnerid = GetSteamAccountID(partner, true);

			bool fetchrow = results.FetchRow();

			if(fetchrow == false)
			{
				Format(g_query, sizeof(g_query), "INSERT INTO records (playerid, partnerid, tries, map, date) VALUES (%i, %i, 1, '%s', %i)", playerid, partnerid, g_map, GetTime());
				g_sql.Query(SQLSetTriesInserted, g_query, _, DBPrio_High);
			}

			else if(fetchrow == true)
			{
				Format(g_query, sizeof(g_query), "UPDATE records SET tries = tries + 1 WHERE ((playerid = %i AND partnerid = %i) OR (playerid = %i AND partnerid = %i)) AND map = '%s' LIMIT 1", playerid, partnerid, partnerid, playerid, g_map);
				g_sql.Query(SQLSetTriesUpdated, g_query, _, DBPrio_Normal);
			}
		}
	}

	return;
}

void SQLSetTriesUpdated(Database db, DBResultSet results, const char[] error, any data)
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

void CreateTables()
{
	g_sql.Query(SQLCreateZonesTable, "CREATE TABLE IF NOT EXISTS zones (id INT AUTO_INCREMENT, map VARCHAR(128), type INT, possition_x FLOAT, possition_y FLOAT, possition_z FLOAT, possition_x2 FLOAT, possition_y2 FLOAT, possition_z2 FLOAT, PRIMARY KEY (id))", _, DBPrio_High); //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key
	g_sql.Query(SQLCreateUserTable, "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT, username VARCHAR(64), steamid INT, firstjoin INT, lastjoin INT, points INT, PRIMARY KEY(id))", _, DBPrio_High);
	g_sql.Query(SQLRecordsTable, "CREATE TABLE IF NOT EXISTS records (id INT AUTO_INCREMENT, playerid INT, partnerid INT, time FLOAT, finishes INT, tries INT, cp1 FLOAT, cp2 FLOAT, cp3 FLOAT, cp4 FLOAT, cp5 FLOAT, cp6 FLOAT, cp7 FLOAT, cp8 FLOAT, cp9 FLOAT, cp10 FLOAT, points INT, map VARCHAR(192), date INT, PRIMARY KEY(id))", _, DBPrio_High);
	g_sql.Query(SQLCreateCPTable, "CREATE TABLE IF NOT EXISTS cp (id INT AUTO_INCREMENT, cpnum INT, cpx FLOAT, cpy FLOAT, cpz FLOAT, cpx2 FLOAT, cpy2 FLOAT, cpz2 FLOAT, map VARCHAR(192), PRIMARY KEY(id))", _, DBPrio_High);
	g_sql.Query(SQLCreateTierTable, "CREATE TABLE IF NOT EXISTS tier (id INT AUTO_INCREMENT, tier INT, map VARCHAR(192), PRIMARY KEY(id))", _, DBPrio_High);

	return;
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(db != INVALID_HANDLE)
	{
		PrintToServer("Successfuly connected to database."); //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/

		g_sql = db;

		g_sql.SetCharset("utf8"); //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-core.sp#L2883

		CreateTables();

		ForceZonesSetup(); //https://sm.alliedmods.net/new-api/dbi/__raw

		g_dbPassed = true; //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-stats.sp#L199

		Format(g_query, sizeof(g_query), "SELECT time FROM records WHERE map = '%s' AND time != 0 ORDER BY time ASC LIMIT 1", g_map);
		g_sql.Query(SQLGetServerRecord, g_query, _, DBPrio_Normal);

		g_sql.Query(SQLRecalculatePoints_GetMap, "SELECT map FROM tier", _, DBPrio_Normal);

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true)
			{
				int serial = GetClientSerial(i);
				g_sql.Query(SQLAddUser, "SELECT id FROM users LIMIT 1", serial, DBPrio_High);

				int steamid = GetSteamAccountID(i, true);
				Format(g_query, sizeof(g_query), "SELECT time FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s' ORDER BY time ASC LIMIT 1", steamid, steamid, g_map);
				g_sql.Query(SQLGetPersonalRecord, g_query, serial, DBPrio_Normal);
			}

			continue;
		}
	}

	else if(db == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect to database. (%s)", error);
	}

	return;
}

void ForceZonesSetup()
{
	Format(g_query, sizeof(g_query), "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0 LIMIT 1", g_map);
	g_sql.Query(SQLSetZoneStart, g_query);

	return;
}

void SQLSetZoneStart(Database db, DBResultSet results, const char[] error, any data)
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

				continue;
			}

			CreateStart();

			Format(g_query, sizeof(g_query), "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1 LIMIT 1", g_map);
			g_sql.Query(SQLSetZoneEnd, g_query, _, DBPrio_Normal);
		}
	}

	return;
}

void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
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

				continue;
			}

			CreateEnd();
		}
	}

	return;
}

void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQLCreateZonesTable: %s", error);
	}

	else if(strlen(error) == 0)
	{
		PrintToServer("Zones table is successfuly created, if not exist.");
	}

	return;
}

void DrawZone(int client, float life, float size, int speed, int zonetype, int zonecount)
{
	float point[12][2][3], start[12][3], end[12][3];

	for(int i = 0; i <= 1; i++)
	{
		point[0][i] = g_devmap == true ? g_zoneStartOriginTemp[client][i] : g_zoneStartOrigin[i];
		point[1][i] = g_devmap == true ? g_zoneEndOriginTemp[client][i] : g_zoneEndOrigin[i];

		continue;
	}

	for(int i = 0; i <= 1; i++)
	{
		for(int j = 0; j <= 2; j++)
		{
			start[i][j] = point[i][0][j] < point[i][1][j] ? point[i][0][j] : point[i][1][j]; //zones calculation from tengu (tengulawl)
			end[i][j] = point[i][0][j] > point[i][1][j] ? point[i][0][j] : point[i][1][j];

			continue;
		}

		if(g_devmap == false)
		{
			start[i][2] += size;
			end[i][2] += size;
		}

		continue;
	}

	int zones = 11, cpnum = 0;

	for(int i = 2; i <= zones; i++)
	{
		cpnum = i - 1; //start count cp from 1.

		for(int j = 0; j <= 1; j++)
		{
			point[i][j] = g_devmap == true ? g_cpPosTemp[client][cpnum][j] : g_cpPos[cpnum][j];

			continue;
		}

		for(int j = 0; j <= 1; j++)
		{
			for(int k = 0; k <= 2; k++)
			{
				start[i][k] = point[i][0][k] < point[i][1][k] ? point[i][0][k] : point[i][1][k]; 
				end[i][k] = point[i][0][k] > point[i][1][k] ? point[i][0][k] : point[i][1][k];

				continue;
			}

			continue;
		}

		if(g_devmap == false)
		{
			start[i][2] += size;
			end[i][2] += size;
		}

		continue;
	}

	int ix = 0;
	float beam[12][8][3]; //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L4828

	for(int i = 0; i <= zones; i++)
	{
		if(g_devmap == true)
		{
			if(zonetype < ZoneCP) //First is Start then End, Then CP
			{
				ix = zonetype;
			}

			else if(zonetype == ZoneCP)
			{
				ix = zonecount + 1;
			}
		}

		else if(g_devmap == false)
		{
			ix = g_devmap == true ? ix : i;
		}

		beam[ix][0] = start[ix];
		beam[ix][7] = end[ix];

		//calculate all zone edges
		for(int j = 1; j <= 6; ++j) //pre increment working as postincrement
		{
			for(int k = 0; k <= 2; k++)
			{
				beam[ix][j][k] = beam[ix][((j >> (2 - k)) & 1) * 7][k];

				continue;
			}

			continue;
		}

		/*if(g_devmap == true)
		{
			float center[2] = {0.0, ...};
			center[0] = (beam[i][0][0] + beam[i][7][0]) / 2;
			center[1] = (beam[i][0][1] + beam[i][7][1]) / 2;

			for(int j = 0; j < 8; j++)
			{
				for(int k = 0; k < 2; k++)
				{
					if(beam[i][j][k] < center[k])
					{
						beam[i][j][k] += 1.0;
					}

					else if(beam[i][j][k] > center[k])
					{
						beam[i][j][k] -= 1.0;
					}
				}
			}
		}*/

		int pairs[][] = {{0, 2}, {2, 6}, {6, 4}, {4, 0}, {0, 1}, {3, 1}, {3, 2}, {3, 7}, {5, 1}, {5, 4}, {6, 7}, {7, 5}};
		int color[4] = {255, ...};

		for(int j = 0; j < (g_devmap == true ? 12 : 4); j++) //3d 12, 2d 4
		{			
			TE_SetupBeamPoints(beam[ix][pairs[j][1]], beam[ix][pairs[j][0]], g_devmap == true ? g_laserBeam : g_zoneModel[ix > 2 ? 2 : ix], 0, 0, 0, life, size, size, 0, 0.0, color, speed); //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3050
			TE_SendToClient(client, 0.0);

			continue;
		}

		continue;
	}

	return;
}

void ResetFactory(int client)
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

	int bhop = gCV_bhop.IntValue;

	if(bhop == 1.0 && g_bhop[client] == true && buttons & IN_JUMP && IsPlayerAlive(client) == true && !(GetEntityFlags(client) & FL_ONGROUND) && GetEntProp(client, Prop_Data, "m_nWaterLevel", 4, 0) <= 1 && !(GetEntityMoveType(client) & MOVETYPE_LADDER)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
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

		int pingtool = gCV_pingtool.IntValue;

		if(pingtool == 1.0 && g_pingLock[client] == false && GetEngineTime() - g_pingTime[client] >= 0.2)
		{
			g_pingLock[client] = true;

			int entity = EntRefToEntIndex(g_pingModel[client]);

			if(entity > 0)
			{
				char clsname[12 + 1] = "";
				GetEntityClassname(entity, clsname, sizeof(clsname));

				if(StrEqual(clsname, "prop_dynamic", false) == true)
				{
					RemoveEntity(entity);
				}

				g_pingModel[client] = 0;

				if(g_pingTimer[client] != INVALID_HANDLE)
				{
					KillTimer(g_pingTimer[client]);

					g_pingTimer[client] = INVALID_HANDLE;
				}
			}

			entity = CreateEntityByName("prop_dynamic_override", -1); //https://www.bing.com/search?q=prop_dynamic_override&cvid=0babe0a3c6cd43aa9340fa9c3c2e0f78&aqs=edge..69i57.409j0j1&pglt=299&FORM=ANNTA1&PC=U531

			//SetEntityModel(g_pingModel[client], "models/trueexpert/pingtool/pingtool.mdl");
			SetEntityModel(entity, "models/effects/combineball.mdl");
			DispatchSpawn(entity);

			SetEntProp(entity, Prop_Data, "m_fEffects", 16, 4, 0); //https://pastebin.com/SdNC88Ma https://developer.valvesoftware.com/wiki/Effect_flags

			float start[3] = {0.0, ...}, angle[3] = {0.0, ...}, end[3] = {0.0, ...};

			GetClientEyePosition(client, start);

			GetClientEyeAngles(client, angle);

			GetAngleVectors(angle, angle, NULL_VECTOR, NULL_VECTOR);

			for(int i = 0; i <= 2; i++)
			{
				angle[i] *= 8192.0;
				end[i] = start[i] + angle[i]; //Thanks to rumour for pingtool original code.

				continue;
			}

			TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint, TraceFilter, client);

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

					continue;
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

			TE_SetupBeamPoints(start, end, g_laser, 0, 0, 0, 0.5, 1.0, 1.0, 0, 0.0, color, 0);

			if(LibraryExists("trueexpert-entityfilter") == true)
			{
				SDKHook(entity, SDKHook_SetTransmit, SDKSetTransmitPing);

				g_pingModelOwner[entity] = client;

				int clients[MAXPLAYER] = {0, ...}; //64 + 1
				int count = 0;

				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true)
					{
						//int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
						//int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

						//if(g_partner[g_partner[i]] == g_partner[client] || i == client || (IsValidClient(observerTarget) == true && g_partner[g_partner[observerTarget]] == g_partner[client] && observerMode < 7))
						if(g_partner[i] == g_partner[client] || i == client || IsClientObserver(i) == true)
						{
							clients[count++] = i;
						}
					}

					continue;
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

			g_pingTimer[client] = CreateTimer(5.0, TimerClenupPing, client, TIMER_FLAG_NO_MAPCHANGE);

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
				SetEntProp(client, Prop_Data, "m_ArmorValue", 0);
			}

			else if(g_block[client] == false && GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) != 2)
			{
				SetEntityCollisionGroup(client, 2);
				SetEntProp(client, Prop_Data, "m_ArmorValue", 1);
			}
		}
	}

	if(g_zoneDraw[client] == true)
	{
		if(GetEngineTime() - g_engineTime[client] >= 0.07)
		{
			g_engineTime[client] = GetEngineTime();

			for(int i = 1; i <= MaxClients; ++i)
			{
				if(IsClientInGame(i) == true)
				{
					DrawZone(i, 0.1, 3.0, 10, g_ZoneEditor[client], g_ZoneEditorCP[client]);
				}

				continue;
			}
		}
	}

	if(GetEntProp(client, Prop_Data, "m_afButtonPressed", 4, 0) & IN_USE) //Make able to swtich wtih E to the partner via spectate.
	{
		if(IsClientObserver(client) == true)
		{
			int observerTarget = GetEntPropEnt(client, Prop_Data, "m_hObserverTarget", 0);
			int observerMode = GetEntProp(client, Prop_Data, "m_iObserverMode", 4, 0);

			if(IsValidClient(observerTarget) == true && IsValidPartner(observerTarget) == true && IsPlayerAlive(g_partner[observerTarget]) == true && observerMode < 7)
			{
				SetEntPropEnt(client, Prop_Data, "m_hObserverTarget", g_partner[observerTarget], 0);
			}
		}

		if(g_zoneDraw[client] == true && g_zoneCreator[client] == true)
		{
			if(g_zoneCreatorUseProcess[client][0] == true && g_zoneCreatorUseProcess[client][1] == false)
			{
				g_zoneCreatorUseProcess[client][1] = true;
			}

			if(g_zoneCreatorUseProcess[client][0] == false)
			{
				g_zoneCreatorUseProcess[client][0] = true;
			}
		}
	}

	if(GetEngineTime() - g_hudTime[client] >= 0.07)
	{
		g_hudTime[client] = GetEngineTime();

		VelHud(client);

		if(g_devmap == true)
		{
			if(g_zoneDraw[client] == true)
			{
				if(g_zoneCreator[client] == true)
				{
					float origin[3] = {0.0, ...};
					GetClientAbsOrigin(client, origin);

					float nulled[3] = {0.0, ...};

					if(g_zoneCreatorUseProcess[client][0] == false)
					{
						if(g_zoneCursor[client] == true)
						{
							g_zoneSelected[client][0] = GetAimPosition(client);
							g_zoneSelected[client][1] = GetAimPosition(client);
						}

						else if(g_zoneCursor[client] == false)
						{
							GetClientAbsOrigin(client, g_zoneSelected[client][0]);
							GetClientAbsOrigin(client, g_zoneSelected[client][1]);

							//SnapToWall(origin, client, g_zoneCursor[client] == true ? g_zoneSelected[client][0] : nulled);
							//SnapToWall(origin, client, g_zoneCursor[client] == true ? g_zoneSelected[client][1] : nulled);

							g_zoneSelected[client][0] = SnapToGrid(g_zoneSelected[client][0], g_step[client], false);
							g_zoneSelected[client][1] = SnapToGrid(g_zoneSelected[client][1], g_step[client], false);
						}

						g_zoneSelected[client][0][2] = origin[2];
						g_zoneSelected[client][1][2] = origin[2];

						ModelXYZ(client, g_zoneSelected[client][0], true, g_zoneCursor[client] == true ? true : false);
					}

					else if(g_zoneCreatorUseProcess[client][0] == true && g_zoneCreatorUseProcess[client][1] == false)
					{
						if(g_zoneCursor[client] == true)
						{
							g_zoneSelected[client][1] = GetAimPosition(client);
							g_zoneSelected[client][1][2] = origin[2];
						}

						else if(g_zoneCursor[client] == false)
						{
							GetClientAbsOrigin(client, g_zoneSelected[client][1]);

							//SnapToWall(origin, client, g_zoneCursor[client] == true ? g_zoneSelected[client][1] : nulled);

							g_zoneSelected[client][1] = SnapToGrid(g_zoneSelected[client][1], g_step[client], false);
						}

						ModelXYZ(client, g_zoneSelected[client][1], true, g_zoneCursor[client] == true ? true : false);

						g_zoneSelected[client][1][2] += 256.0;
					}

					else if(g_zoneCreatorUseProcess[client][1] == true)
					{
						switch(g_zoneCreatorSelected[client])
						{
							case 0:
							{
								ZoneEditorStart(client);
							}

							case 1:
							{
								ZoneEditorEnd(client);
							}

							case 2:
							{
								ZoneEditorCP(client, g_ZoneEditorCP[client]);
							}
						}

						g_zoneCreator[client] = false;

						for(int i = 0; i <= 1; i++)
						{
							g_zoneCreatorUseProcess[client][i] = false;

							continue;
						}

						ModelXYZ(client, nulled, false, false);
					}

					switch(g_zoneCreatorSelected[client])
					{
						case 0:
						{
							g_zoneStartOriginTemp[client][0] = g_zoneSelected[client][0];
							g_zoneStartOriginTemp[client][1] = g_zoneSelected[client][1];
						}

						case 1:
						{
							g_zoneEndOriginTemp[client][0] = g_zoneSelected[client][0];
							g_zoneEndOriginTemp[client][1] = g_zoneSelected[client][1];
						}

						case 2:
						{
							g_cpPosTemp[client][g_ZoneEditorCP[client]][0] = g_zoneSelected[client][0];
							g_cpPosTemp[client][g_ZoneEditorCP[client]][1] = g_zoneSelected[client][1];
						}
					}
				}
			}

			else if(g_zoneDraw[client] == false)
			{
				ModelXYZ(client, NULL_VECTOR, false, false);
			}
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

			SetEntProp(client, Prop_Data, "m_ArmorValue", 1);
		}
	}

	else if(IsFakeClient(client) == false && IsPlayerAlive(client) == true && other == -1 && g_block[client] == true)
	{
		if(GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) == 2)
		{
			SetEntityCollisionGroup(client, 5);

			SetEntityRenderColor(client, g_colorBuffer[client][0][0], g_colorBuffer[client][0][1], g_colorBuffer[client][0][2], 255);

			SetEntProp(client, Prop_Data, "m_ArmorValue", 0);
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

		int restartCV = gCV_restart.IntValue;
		int partnerCV = gCV_partner.IntValue;

		if(IsValidPartner(client) == true && restartCV == 1.0)
		{
			Restart(client, true);
		}

		else if(IsValidPartner(client) == false && partnerCV == 1.0)
		{
			Partner(client);
		}
	}

	int macro = gCV_macro.IntValue;

	if(macro == 1.0 && g_macroDisabled[client] == false && IsPlayerAlive(client) == true)
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

	if(fix >= 0.10 && g_flashbangDoor[client][0] == true) // 0.1 looks like 0.1999...
	{
		FakeClientCommandEx(client, "use weapon_flashbang");

		g_flashbangDoor[client][0] = false;
	}

	else if(fix >= 0.15 && g_flashbangDoor[client][1] == true)
	{
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", true, 4, 0);

		g_flashbangDoor[client][1] = false;
	}

	return Plugin_Continue;
}

Action OnProjectileStartTouch(int entity, int other)
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

				if(g_mlsCount[other] == 1)
				{
					delete g_mlsBuffer[other];
					g_mlsBuffer[other] = new ArrayList(64, 0); //sizeof of enum stuct
				}

				g_mlsBooster[other] = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);
			}
		}
	}

	return Plugin_Continue;
}

Action CommandDevmap(int client, int args)
{
	int devmap = gCV_devmap.IntValue;

	if(devmap == 0.0)
	{
		return Plugin_Continue;
	}

	if(GetEngineTime() - g_devmapTime > 35.0 && GetEngineTime() - g_afkTime > 30.0)
	{
		g_voters = 0;

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false && IsFakeClient(i) == false)
			{
				g_voters++;

				Menu menu = new Menu(devmap_handler);
				menu.SetTitle("%T", g_devmap == true ? "TurnOFFDevmap" : "TurnONDevmap", i);

				Format(g_buffer, sizeof(g_buffer), "%T", "Yes", i);
				menu.AddItem("yes", g_buffer);
				Format(g_buffer, sizeof(g_buffer), "%T", "No", i);
				menu.AddItem("no", g_buffer);

				menu.Display(i, 20);
			}

			continue;
		}

		g_devmapTime = GetEngineTime();

		CreateTimer(20.0, TimerDevamp, TIMER_FLAG_NO_MAPCHANGE);

		char name[MAX_NAME_LENGTH] = "";
		GetClientName(client, name, sizeof(name));

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true)
			{
				Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "DevmapStart", i, name);
				SendMessage(i, g_buffer);
			}

			continue;
		}
	}

	else if(GetEngineTime() - g_devmapTime <= 35.0 || GetEngineTime() - g_afkTime <= 30.0)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, "DevmapNotAllowed", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
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

Action TimerDevamp(Handle timer)
{
	//devmap idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	Devmap(true);

	return Plugin_Stop;
}

void Devmap(bool force)
{
	if(force == true || g_voters == 0)
	{
		char buffer[8] = "";

		if(g_devmapCount[1] > g_devmapCount[0])
		{
			float result = (float(g_devmapCount[1]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0;

			if(g_devmap == true)
			{
				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true && IsFakeClient(i) == false)
					{
						Format(buffer, sizeof(buffer), "%.0f", result);
						Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "DevmapWillBeDisabled", i, buffer, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, g_buffer);
					}

					continue;
				}
			}

			else if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true && IsFakeClient(i) == false)
					{
						Format(buffer, sizeof(buffer), "%.0f", result);
						Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "DevmapWillBeEnabled", i, buffer, g_devmapCount[1], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, g_buffer);
					}

					continue;
				}
			}

			float interval = 5.0;
			any data = g_devmap == true ? false : true;
			int flags = 0;
			CreateTimer(interval, TimerChangelevel, data, flags);
		}

		else if(g_devmapCount[1] < g_devmapCount[0])
		{
			float result = (float(g_devmapCount[0]) / (float(g_devmapCount[0]) + float(g_devmapCount[1]))) * 100.0;

			if(g_devmap == true)
			{
				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true)
					{
						Format(buffer, sizeof(buffer), "%.0f", result);
						Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "DevmapContinue", i, buffer, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, g_buffer);
					}

					continue;
				}
			}

			else if(g_devmap == false)
			{
				for(int i = 1; i <= MaxClients; ++i)
				{
					if(IsClientInGame(i) == true)
					{
						Format(buffer, sizeof(buffer), "%.0f", result);
						Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "DevmapWillNotBe", i, buffer, g_devmapCount[0], g_devmapCount[0] + g_devmapCount[1]);
						SendMessage(i, g_buffer);
					}

					continue;
				}
			}
		}

		for(int i = 0; i <= 1; i++)
		{
			g_devmapCount[i] = 0;

			continue;
		}
	}

	return;
}

Action TimerChangelevel(Handle timer, bool value)
{
	for(int i = 1; i <= MaxClients; ++i)
	{
		if(IsValidPartner(i) == true)
		{
			ColorTeam(i, false);
		}

		continue;
	}
	
	g_devmap = value;

	ForceChangeLevel(g_map, "Reason: Devmap");

	ServerCommand("sv_nostats %i", view_as<int>(value));

	return Plugin_Stop;
}

Action CommandTop(int client, int args)
{
	int top = gCV_top.IntValue;

	if(top == 0.0)
	{
		return Plugin_Continue;
	}

	float interval = 0.1;
	int flags = TIMER_FLAG_NO_MAPCHANGE;
	CreateTimer(interval, TimerMotd, client, flags); //OnMapStart() is not work from first try.

	return Plugin_Handled;
}

Action TimerMotd(Handle timer, int client)
{
	if(IsClientInGame(client) == true)
	{
		ConVar hostname = FindConVar("hostname");

		char title[256] = "";
		hostname.GetString(title, sizeof(title));

		char msg[192] = "";
		gCV_urlTop.GetString(msg, sizeof(msg));
		Format(msg, sizeof(msg), "%s%s", msg, g_map);

		int type = MOTDPANEL_TYPE_URL;

		ShowMOTDPanel(client, title, msg, type); //https://forums.alliedmods.net/showthread.php?t=232476
	}

	return Plugin_Stop;
}

Action CommandAfk(int client, int args)
{
	int afk = gCV_afk.IntValue;

	if(afk == 0.0)
	{
		return Plugin_Continue;
	}

	if(GetEngineTime() - g_afkTime > 30.0 && GetEngineTime() - g_devmapTime > 35.0)
	{
		g_voters = 0;

		g_afkClient = client;

		for(int i = 1; i <= MaxClients; ++i)
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

					Menu menu = new Menu(MenuCallbackAFK);
					menu.SetTitle("%T", "AreYouHere?", i);

					Format(g_buffer, sizeof(g_buffer), "%T", "Yes", i);
					menu.AddItem("yes", g_buffer);
					Format(g_buffer, sizeof(g_buffer), "%T", "No", i);
					menu.AddItem("no", g_buffer);

					int time = 20;
					menu.Display(i, time);
				}
			}

			continue;
		}

		g_afkTime = GetEngineTime();

		float interval = 20.0;
		int flags = TIMER_FLAG_NO_MAPCHANGE;
		CreateTimer(interval, TimerAFK, client, flags);

		char name[MAX_NAME_LENGTH] = "";
		GetClientName(client, name, sizeof(name));

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true)
			{
				Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", i, "AFKCHECK", i, name);
				SendMessage(i, g_buffer);
			}

			continue;
		}
	}

	else if(GetEngineTime() - g_afkTime <= 30.0 || GetEngineTime() - g_devmapTime <= 35.0)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, "AFKCHECK2", client);
		SendMessage(client, g_buffer);
	}

	return Plugin_Handled;
}

int MenuCallbackAFK(Menu menu, MenuAction action, int param1, int param2)
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

Action TimerAFK(Handle timer, int client)
{
	//afk idea by expert zone. thanks to ed and maru. thanks to lon to give tp idea for server i could made it like that "profesional style".
	AFK(client, true);

	return Plugin_Stop;
}

void AFK(int client, bool force)
{
	if(force == true || g_voters == 0)
	{
		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsPlayerAlive(i) == false && IsClientSourceTV(i) == false && g_afk[i] == false && client != i)
			{
				KickClient(i, "%T", "AwayFromKeyboard", i);
			}

			continue;
		}
	}

	return;
}

Action CommandNoclip(int client, int args)
{
	int noclip = gCV_noclip.IntValue;

	if(noclip == 0.0)
	{
		return Plugin_Continue;
	}

	Noclip(client);

	return Plugin_Handled;
}

void Noclip(int client)
{
	if(IsValidClient(client) == false)
	{
		return;
	}

	if(g_devmap == true)
	{
		SetEntityMoveType(client, GetEntityMoveType(client) == MOVETYPE_NOCLIP ? MOVETYPE_WALK : MOVETYPE_NOCLIP);

		if(g_menuOpened[client] == false)
		{
			Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, GetEntityMoveType(client) == MOVETYPE_NOCLIP ? "NoclipChatON" : "NoclipChatOFF", client);
			SendMessage(client, g_buffer);
		}
	}

	else if(g_devmap == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, "DevmapIsOFF", client);
		SendMessage(client, g_buffer);
	}

	if(g_menuOpened[client] == true)
	{
		Trikz(client);
	}

	return;
}

Action CommandSpec(int client, int args)
{
	int spec = gCV_spec.IntValue;

	if(spec == 0.0)
	{
		return Plugin_Continue;
	}

	ChangeClientTeam(client, CS_TEAM_SPECTATOR);

	return Plugin_Handled;
}

Action CommandHud(int client, int args)
{
	int hud = gCV_hud.IntValue;

	if(hud == 0.0)
	{
		return Plugin_Continue;
	}

	HudMenu(client);

	return Plugin_Handled;
}

void HudMenu(int client)
{
	g_menuOpenedHud[client] = true;

	Menu menu = new Menu(MenuCallbackHUD, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel | MenuAction_End);
	char fmt[3 + 1] = "Hud";
	menu.SetTitle(fmt);

	Format(g_buffer, sizeof(g_buffer), "%T", g_hudVel[client] == true ? "VelMenuON" : "VelMenuOFF", client);
	menu.AddItem("vel", g_buffer, gCV_vel.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", g_mlstats[client] == true ? "MLStatsMenuON" : "MLStatsMenuOFF", client);
	menu.AddItem("mls", g_buffer, gCV_mlstats.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	Format(g_buffer, sizeof(g_buffer), "%T", g_endMessage[client] == true ? "EndMessageMenuON" : "EndMessageMenuOFF", client);
	menu.AddItem("endmsg", g_buffer, gCV_endmsg.IntValue == 1.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	int time = 20;
	menu.Display(client, time);

	return;
}

int MenuCallbackHUD(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start: //expert-zone idea. thank to ed, maru.
		{
			g_menuOpenedHud[param1] = true;
		}

		case MenuAction_Select:
		{
			char value[1 + 1] = "";

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
					SetClientCookie(param1, g_cookie[7], value);
				}
			}

			CommandHud(param1, 0);
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

Action CommandVel(int client, int args)
{
	int vel = gCV_vel.IntValue;

	if(vel == 0.0)
	{
		return Plugin_Continue;
	}

	g_hudVel[client] = !g_hudVel[client];

	char value[1 + 1] = "";
	IntToString(g_hudVel[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[0], value);

	if(g_menuOpenedHud[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_hudVel[client] == true ? "VelChatON" : "VelChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

void VelHud(int client)
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

	for(int i = 1; i <= MaxClients; ++i)
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

		continue;
	}

	return;
}

Action CommandMLStats(int client, int args)
{
	int mlstats = gCV_mlstats.IntValue;

	if(mlstats == 0.0)
	{
		return Plugin_Continue;
	}

	g_mlstats[client] = !g_mlstats[client];

	char value[1 + 1] = "";
	IntToString(g_mlstats[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[1], value);

	if(g_menuOpenedHud[client] == false)
	{
		Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_mlstats[client] == true ? "MLStatsChatON" : "MLStatsChatOFF", client);
		SendMessage(client, g_buffer);
	}

	else if(g_menuOpenedHud[client] == true)
	{
		HudMenu(client);
	}

	return Plugin_Handled;
}

Action CommandButton(int client, int args)
{
	int button = gCV_button.IntValue;

	if(button == 0.0)
	{
		return Plugin_Continue;
	}

	g_button[client] = !g_button[client];

	char value[1 + 1] = "";
	IntToString(g_button[client], value, sizeof(value));
	SetClientCookie(client, g_cookie[2], value);

	Format(g_buffer, sizeof(g_buffer), "%T%T", "PrefixTrikz", client, g_button[client] == true ? "ButtonAnnouncerON" : "ButtonAnnouncerOFF", client);
	SendMessage(client, g_buffer);

	return Plugin_Handled;
}

Action OnProjectileEndTouch(int entity, int other)
{
	if(other == 0)
	{
		g_bouncedOff[entity] = true; //Get from Tengu github "tengulawl" scriptig "boost-fix.sp".
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile", true) != -1)
	{
		g_bouncedOff[entity] = false; //"Tengulawl" "boost-fix.sp".

		SDKHook(entity, SDKHook_StartTouch, OnProjectileStartTouch);
		SDKHook(entity, SDKHook_EndTouch, OnProjectileEndTouch);
	}

	if(StrEqual(classname, "flashbang_projectile", true) == true)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnProjectileSpawnPost);
	}

	return;
}

void OnProjectileSpawnPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", 0);

	if(IsValidEntity(entity) == true && IsValidEntity(client) == true)
	{
		int autoflashbang = gCV_autoflashbang.IntValue;

		if(autoflashbang == 1.0 && (g_autoflash[client] == true || IsFakeClient(client) == true))
		{
			int offset = FindDataMapInfo(client, "m_iAmmo") + 12 * 4;
			SetEntData(client, offset, 2, 4, false); //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
		}

		RequestFrame(FrameExplosionPrevent, entity);

		float interval = 1.5;
		any data = EntIndexToEntRef(entity);
		int flags = TIMER_FLAG_NO_MAPCHANGE;
		CreateTimer(interval, TimerProjectileRemove, data, flags);

		if(g_skinFlashbang[client] > 0)
		{
			SetEntProp(entity, Prop_Data, "m_nModelIndex", g_wModelThrown, 4, 0);
			SetEntProp(entity, Prop_Data, "m_nSkin", g_skinFlashbang[client], 4, 0);
		}

		SetEntityRenderColor(entity, g_colorBuffer[client][1][0], g_colorBuffer[client][1][1], g_colorBuffer[client][1][2], 255);

		int autoswitch = gCV_autoswitch.IntValue;
		
		if(autoswitch == 1.0 && (g_autoswitch[client] == true || IsFakeClient(client) == true))
		{
			SetEntProp(client, Prop_Data, "m_bDrawViewmodel", false, 4, 0); //Thanks to "Alliedmodders". (2019 year https://forums.alliedmods.net/archive/index.php/t-287052.html)

			g_silentKnife = true;

			char fmt[16 + 1] = "";
			Format(fmt, sizeof(fmt), "use weapon_knife");
			FakeClientCommandEx(client, fmt);
			
			g_flashbangTime[client] = GetEngineTime();

			g_flashbangDoor[client][0] = true;
			g_flashbangDoor[client][1] = true;
		}
	}

	return;
}

void FrameExplosionPrevent(int entity)
{
	if(IsValidEntity(entity) == true)
	{
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", 0, 4, 0); //https://forums.alliedmods.net/showthread.php?t=301667 avoid random blinds.
	}

	return;
}

Action TimerProjectileRemove(Handle timer, int entity)
{
	if(entity != INVALID_ENT_REFERENCE && IsValidEntity(entity) == true)
	{
		FlashbangEffect(entity);

		char clsname[256] = "";
		GetEntityClassname(entity, clsname, sizeof(clsname));
		
		if(StrEqual(clsname, "flashbang_projectile", false) == true)
		{
			RemoveEntity(entity);
		}
	}

	return Plugin_Stop;
}

void FlashbangEffect(int entity)
{
	bool filter = LibraryExists("trueexpert-entityfilter");

	float origin[3] = {0.0, ...};
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin, 0);

	TE_SetupSmoke(origin, g_smoke, GetRandomFloat(0.5, 1.5), 100); //https://forums.alliedmods.net/showpost.php?p=2552543&postcount=5

	int clients[MAXPLAYER] = {0, ...}, count = 0;

	if(filter == true)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

		if(owner == -1)
		{
			owner = 0;
		}

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsClientSourceTV(i) == false)
			{
				//int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
				//int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

				//if(g_partner[i] == g_partner[owner] || i == owner || (IsValidClient(observerTarget) == true && (g_partner[observerTarget] == owner || g_partner[observerTarget] == g_partner[owner]) && observerMode < 7))
				if(g_partner[i] == g_partner[owner] || i == owner || IsClientObserver(i) == true)
				{
					clients[count++] = i;
				}
			}

			continue;
		}

		TE_Send(clients, count, 0.0);
	}

	else if(filter == false)
	{
		TE_SendToAll(0.0);
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
		TE_SendToAll(0.0); //Idea from "Expert-Zone". So, we just made non empty event.

		EmitSoundToAll(sample[GetRandomInt(0, 1)], entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0); //https://www.youtube.com/watch?v=0Dep7RXhetI&list=PL_2MB6_9kLAHnA4mS_byUpgpjPgETJpsV&index=171 https://github.com/Smesh292/Public-SourcePawn-Plugins/blob/master/trikz.sp#L23 So via "GCFScape" we can found "sound/weapons/flashbang", there we can use 2 sounds as random. flashbang_explode1.wav and flashbang_explode2.wav. These sound are similar, so, better to mix via random. https://forums.alliedmods.net/showthread.php?t=167638 https://world-source.ru/forum/100-2357-1 https://sm.alliedmods.net/new-api/sdktools_sound/__raw
	}

	return;
}

Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR, 0); //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR, 0);

	return Plugin_Handled; //Full god-mode.
}

void OnWeaponEquipPost(int client, int weapon) //https://sm.alliedmods.net/new-api/sdkhooks/__raw Thanks to Lon for gave this idea. (aka trikz_failtime)
{
	int autoflashbang = gCV_autoflashbang.IntValue;

	if(autoflashbang == 1.0)
	{
		RequestFrame(OnFrameGiveFlashbang, client); //replays drops knife
	}

	/*if(g_timerDissolver[client] != INVALID_HANDLE)
	{
		CloseHandle(g_timerDissolver[client]);
	}*/

	return;
}

Action OnWeaponDrop(int client, int weapon)
{
	if(IsValidEntity(weapon) == true)
	{
		char clsname[256] = "";
		GetEntityClassname(weapon, clsname, sizeof(clsname));

		if(StrContains(clsname, "weapon", false) != -1)
		{
			//RemoveEntity(weapon);
			int dissolver = CreateEntityByName("env_entity_dissolver"); //https://forums.alliedmods.net/showthread.php?p=622834

			if(dissolver != -1)
			{
				char dname[6 + 1] = "";
				Format(dname, sizeof(dname), "dis_%i", weapon);
				DispatchKeyValue(weapon, "targetname", dname);
				DispatchKeyValue(dissolver, "dissolvetype", "2");
				DispatchKeyValue(dissolver, "target", dname);
				//DataPack dp = new DataPack();
				//dp.WriteCell(client);
				//dp.WriteCell(weapon);
				//dp.WriteCell(dissolver);
				//g_timerDissolver[client] = CreateTimer(3.0, TimerDissolve, dp, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, TimerDissolve, dissolver, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	return Plugin_Continue;
}

//Action TimerDissolve(Handle timer, DataPack dp)
Action TimerDissolve(Handle timer, int dissolver)
{
	/*dp.Reset();
	int client = dp.ReadCell();
	int weapon = dp.ReadCell();
	int dissolver = dp.ReadCell();
	delete dp;*/

	if(dissolver != -1)
	{
		AcceptEntityInput(dissolver, "Dissolve");
		AcceptEntityInput(dissolver, "Kill");

		/*GlobalForward hForward = new GlobalForward("Trikz_OnWeaponDissolve", ET_Hook, Param_Cell, Param_Cell);
		Call_StartForward(hForward);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_Finish();
		delete hForward;*/
	}

	return Plugin_Continue;
}

void GiveFlashbang(int client)
{
	int autoflashbang = gCV_autoflashbang.IntValue;
	
	if(autoflashbang == 1.0 && IsClientInGame(client) == true && (g_autoflash[client] == true || IsFakeClient(client) == true) && IsPlayerAlive(client) == true)
	{
		int offset = FindDataMapInfo(client, "m_iAmmo") + 12 * 4;

		if(GetEntData(client, offset, 4) == 0)
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

bool TraceFilter(int entity, int contentMask, int client)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		if(Trikz_GetEntityFilter(client, entity) == false)
		{
			return entity > MaxClients;
		}
	}

	else if(LibraryExists("trueexpert-entityfilter") == false)
	{
		return entity > MaxClients;
	}

	return false;
}

bool TraceFilterDontHitSelf(int entity, int contentsMask, any data)
{
	return entity != data;
}

Action TimerClenupPing(Handle timer, int client)
{
	int entity = EntRefToEntIndex(g_pingModel[client]);

	if(IsValidEntity(entity) == true)
	{
		char clsname[12 + 1] = "";
		GetEntityClassname(entity, clsname, sizeof(clsname));

		if(StrEqual(clsname, "prop_dynamic", false) == true)
		{
			RemoveEntity(entity);
		}

		g_pingModel[client] = 0;

		g_pingTimer[client] = INVALID_HANDLE;
	}

	return Plugin_Stop;
}

Action SDKSetTransmitPing(int entity, int client)
{
	if(IsPlayerAlive(client) == true && g_pingModelOwner[entity] != client && g_partner[g_pingModelOwner[entity]] != g_partner[g_partner[client]])
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action OnSound(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
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

Action TimerClantag(Handle timer, int client)
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

void MLStats(int client, bool ground)
{
	if(IsFakeClient(client) == true)
	{
		return;
	}
	
	float velPre = GetVectorLength(g_mlsVel[client][0]);
	float velPost = GetVectorLength(g_mlsVel[client][1]);

	int count = g_mlsCount[client];

	char buffer[256] = "";
	Format(buffer, sizeof(buffer), "%i. %.0f - %.0f\n", count, velPre, velPost);
	g_mlsBuffer[client].PushString(buffer);

	char print[4][256];

	if(count <= 10)
	{
		for(int i = 1; i <= count <= 10; ++i)
		{
			g_mlsBuffer[client].GetString(i - 1, buffer, sizeof(buffer));
			Format(print[0], 256, "%s%s", print[0], buffer);

			continue;
		}
	}

	else if(count > 10)
	{
		for(int i = 1; i <= 10; ++i)
		{
			g_mlsBuffer[client].GetString(i - 1, buffer, sizeof(buffer));
			Format(print[0], 256, "%s%s", print[0], buffer);

			continue;
		}

		g_mlsBuffer[client].GetString(count - 1, buffer, sizeof(buffer));
		Format(print[0], 256, "%s...\n%s", print[0], buffer);
	}

	int booster = g_mlsBooster[client];

	float distance = 0.0;
	char tp[256] = "";

	if(ground == true)
	{
		float x = g_mlsDistance[client][1][0] - g_mlsDistance[client][0][0];
		float y = g_mlsDistance[client][1][1] - g_mlsDistance[client][0][1];
		distance = SquareRoot(Pow(x, 2.0) + Pow(y, 2.0)) + 32.0;

		if(IsValidClient(booster) == true)
		{
			if(g_teleported[client] == true)
			{
				Format(tp, sizeof(tp), "%T", "MLSTP", booster);
			}

			//Format(print[1], 256, "%s\n%T: %.0f %T%s", print[0], "MLSDistance", flyer, distance, "MLSUnits", flyer, tp); //player hitbox xy size is 32.0 units. Distance measured from player middle back point. My long jump record on Velo++ server is 279.24 units per 2017 winter. I used logitech g303 for my father present. And smooth mouse pad from glorious gaming. map was trikz_measuregeneric longjump room at 240 block. i grown weed and use it for my self also. 20 januarty.
			Format(print[1], 256, "%s\n%T", print[0], "MLSFinishMsg", booster, distance, tp);
			PrintToConsole(booster, "%s", print[1]);
		}

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

	if(IsValidClient(booster) == true && g_mlstats[booster] == true)
	{
		Handle KeyHintText = StartMessageOne("KeyHintText", booster);
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

	for(int i = 1; i <= MaxClients; ++i)
	{
		if(IsClientInGame(i) == true && IsClientObserver(i) == true)
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

			if(observerMode < 7 && (observerTarget == client || (IsValidClient(booster) == true && observerTarget == booster)) && g_mlstats[i] == true)
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

		continue;
	}

	return;
}

int Stuck(int client)
{
	float mins[3] = {0.0, ...}, maxs[3] = {0.0, ...}, origin[3] = {0.0, ...};
	GetClientMins(client, mins);
	GetClientMaxs(client, maxs);
	GetClientAbsOrigin(client, origin);
	TR_TraceHullFilter(origin, origin, mins, maxs, MASK_PLAYERSOLID, TraceDontHitSelf, client); //Skiper, Gurman idea, plugin 2020 year.

	return TR_GetEntityIndex();
}

bool TraceDontHitSelf(int entity, int mask, int client)
{
	if(LibraryExists("trueexpert-entityfilter") == true)
	{
		return entity != client && IsValidClient(entity) == true && g_partner[entity] == g_partner[g_partner[client]];
	}

	else if(LibraryExists("trueexpert-entityfilter") == false)
	{
		return entity != client && IsValidClient(entity) == true;
	}

	return false;
}

int Native_GetClientButtons(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_entityButtons[client];
}

int Native_GetClientPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_partner[client];
}

int Native_GetTimerState(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	return g_timerState[client];
}

int Native_SetPartner(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int partner = GetNativeCell(2);

	g_partner[client] = partner;
	g_partner[partner] = client;

	return numParams;
}

int Native_Restart(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool ask = GetNativeCell(2);
	
	Restart(client, ask);

	return numParams;
}

int Native_GetDevmap(Handle plugin, int numParams)
{
	return g_devmap;
}

int Native_GetTeamColor(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	SetNativeArray(2, g_colorBuffer[client][0], 3);
	return numParams;
}

float[] GetGroundPos(int client) //https://forums.alliedmods.net/showpost.php?p=1042515&postcount=4
{
	float origin[3] = {0.0, ...};
	GetClientAbsOrigin(client, origin);

	float originDir[3] = {0.0, ...};
	GetClientAbsOrigin(client, originDir);
	originDir[2] -= 2.0;

	float mins[3] = {0.0, ...};
	GetClientMins(client, mins);

	float maxs[3] = {0.0, ...};
	GetClientMaxs(client, maxs);

	TR_TraceHullFilter(origin, originDir, mins, maxs, MASK_PLAYERSOLID, TraceFilterDontHitSelf, client);

	float pos[3] = {0.0, ...};
	TR_GetEndPosition(pos);

	if(TR_DidHit(INVALID_HANDLE) == true)
	{
		#if debug == true
		PrintToServer("%f %i", origin[2] - pos[2], TR_GetEntityIndex());
		#endif

		return pos;
	}

	else //if(TR_DidHit(INVALID_HANDLE) == false) //function GetGroundPos should return a value. The function does not have a return statement, or it does not have an expression behind the return statement, but the function’s result is used in a expression.
	{
		return pos;
	}
}

/*int GetColor(const int r, const int g, const int b, const int a)
{
	int color = 0;

	color |= (r & 255) << 24;
	color |= (g & 255) << 16;
	color |= (b & 255) << 8;
	color |= (a & 255) << 0;

	return color;
}*/

MRESReturn DHooksOnTeleport(int client, Handle hParams) //https://github.com/fafa-junhe/My-srcds-plugins/blob/0de19c28b4eb8bdd4d3a04c90c2489c473427f7a/all/teleport_stuck_fix.sp#L84
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

	GlobalForward hForward = new GlobalForward("Trikz_OnTeleport", ET_Ignore, Param_Cell, Param_Array);
	Call_StartForward(hForward);
	Call_PushCell(client);
	int size = 3;
	Call_PushArray(origin, size);
	Call_Finish();
	delete hForward;
	
	return MRES_Ignored;
}

void FormatSeconds(float time, char[] format)
{
	int maxlength = 24;

	//https://forums.alliedmods.net/archive/index.php/t-23912.html ShAyA format OneEyed format second
	int hour = (RoundToFloor(time) / 3600) % 24; //https://forums.alliedmods.net/archive/index.php/t-187536.html
	int minute = (RoundToFloor(time) / 60) % 60;
	int second = RoundToFloor(time) % 60;

	Format(format, maxlength, "%02.i:%02.i:%02.i", hour, minute, second);

	return;
}

void OnFrameGiveFlashbang(int client)
{
	GiveFlashbang(client);

	return;
}

void GetPoints(int client, char[] points)
{
	float precentage = float(g_points[client]) / float(g_pointsMaxs) * 100.0;
	CS_SetMVPCount(client, precentage <= 100.0 ? RoundToFloor(precentage) : 0);

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

	else if(1000 <= g_points[client] < 1000000)
	{
		Format(points, 32, "\x07%s%iK\x01", color, g_points[client] / 1000);
	}

	else if(g_points[client] >= 1000000)
	{
		Format(points, 32, "\x07%s%iM\x01", color, g_points[client] / 1000000);
	}

	return;
}

float[] GetAimPosition(int client) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3890
{
	float eyePos[3] = {0.0, ...};
	GetClientEyePosition(client, eyePos);

	float eyeAngles[3] = {0.0, ...};
	GetClientEyeAngles(client, eyeAngles);

	TR_TraceRayFilter(eyePos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceFilterDontHitSelf, client);

	if(TR_DidHit(INVALID_HANDLE))
	{
		float end[3] = {0.0, ...};
		TR_GetEndPosition(end);

		return SnapToGrid(end, g_step[client], true);
	}

	return eyePos;
}

float[] SnapToGrid(float pos[3], int grid, bool third) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3832
{
	float origin[3] = {0.0, ...};
	origin = pos;

	origin[0] = float(RoundToNearest(pos[0] / grid) * grid);
	origin[1] = float(RoundToNearest(pos[1] / grid) * grid);

	if(third == true)
	{
		origin[2] = float(RoundToNearest(pos[2] / grid) * grid);
	}

	return origin;
}

/*void SnapToWall(float pos[3], int client, float final[3]) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L3848
{
	bool hit = false;
	float end[3] = {0.0, ...}, temp[3] = {0.0, ...}, prefinal[3] = {0.0, ...};
	prefinal = pos;

	for(int i = 0; i < 4; i++)
	{
		end = pos;

		int axis = (i / 2);

		end[axis] += i % 2 == 1 ? -g_step[client] : g_step[client];

		TR_TraceRayFilter(pos, end, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilterDontHitSelf, client);

		if(TR_DidHit(INVALID_HANDLE))
		{
			TR_GetEndPosition(temp);

			prefinal[axis] = temp[axis];

			hit = true;
		}

		continue;
	}

	if(hit == true && GetVectorDistance(prefinal, pos) <= g_step[client])
	{
		final = SnapToGrid(prefinal, g_step[client], false);
	}

	return;
}*/

void ModelXYZ(int client, float origin[3], bool showmodel, bool showbeam)
{
	if(g_entityXYZ[client] > 0)
	{
		if(IsValidEntity(g_entityXYZ[client]) == true)
		{
			RemoveEntity(g_entityXYZ[client]);
		}

		g_entityXYZ[client] = 0;
	}

	if(showmodel == true)
	{
		g_entityXYZ[client] = CreateEntityByName("prop_dynamic_override", -1);

		SetEntityModel(g_entityXYZ[client], "models/expert_zone/zone_editor/xyz/xyz.mdl");
		DispatchSpawn(g_entityXYZ[client]);

		SetEntProp(g_entityXYZ[client], Prop_Data, "m_fEffects", 16, 4, 0);

		TeleportEntity(g_entityXYZ[client], origin, NULL_VECTOR, NULL_VECTOR);
	}

	/*else if(showmodel == false)
	{
		//https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L4704-L4721

		float playerOrigin[3] = {0.0, ...};
		GetClientAbsOrigin(client, playerOrigin);

		TE_SetupBeamPoints(playerOrigin, origin, g_laser, 0, 0, 0, 0.1, 1.0, 1.0, 0, 0.0, {255, 255, 255, 75}, 0);
		TE_SendToAll(0.0);

		//visualize grid snap
		float snap1[3];
		float snap2[3];

		for(int i = 0; i < 3; i++)
		{
			snap1 = origin;
			snap1[i] -= g_step[client];

			snap2 = origin;
			snap2[i] += g_step[client];

			TE_SetupBeamPoints(snap1, snap2, g_laser, 0, 0, 0, 0.1, 1.0, 1.0, 0, 0.0, {255, 255, 255, 75}, 0);
			TE_SendToAll(0.0);

			continue;
		}
	}*/

	if(showbeam == true)
	{
		float eyePos[3] = {0.0, ...};
		GetClientEyePosition(client, eyePos);
		eyePos[2] -= 8;
		TE_SetupBeamPoints(eyePos, origin, g_laser, 0, 0, 0, 0.1, 1.0, 1.0, 0, 0.0, {255, 255, 255, 255}, 0);
		float delay = 0.0;
		TE_SendToAll(delay);
	}

	return;
}

void Greetings(int client)
{
	if(IsValidClient(client) == false)
	{
		return;
	}

	float interval = 5.0;
	int flags = TIMER_FLAG_NO_MAPCHANGE;
	any data = client;
	CreateTimer(interval, TimerGreetings, data, flags);

	return;
}

Action TimerGreetings(Handle timer, int client)
{
	if(IsClientInGame(client) == false)
	{
		return Plugin_Continue;
	}

	bool keyOnly = true;

	g_kv.Rewind();
	g_kv.GotoFirstSubKey(keyOnly);

	char section[16] = "", key[] = "Greetings", posColor[128] = "", exploded[15][8];
	float xy[2] = {0.0, ...}, holdtime = 0.0, fxtime = 0.0, fadein = 0.0, fadeout = 0.0;
	int rgba[2][4] = {{0, ...}, {0, ...}}, effect = 0;

	do
	{
		if(g_kv.GetSectionName(section, sizeof(section)) == true && StrEqual(section, key, true) == true)
		{
			g_kv.GetString(key, posColor, sizeof(posColor));

			if(strlen(posColor) == 0)
			{
				break;
			}

			ExplodeString(posColor, ",", exploded, 15, 8, false);

			for(int j = 0; j <= 1; j++)
			{
				xy[j] = StringToFloat(exploded[j]);

				continue;
			}

			holdtime = StringToFloat(exploded[2]);

			for(int j = 3; j <= 10; j++)
			{
				rgba[j <= 6 ? 0 : 1][j <= 6 ? j - 3 : j - 7] = StringToInt(exploded[j], 10);

				continue;
			}

			effect = StringToInt(exploded[11], 10);
			fxtime = StringToFloat(exploded[12]);
			fadein = StringToFloat(exploded[13]);
			fadeout = StringToFloat(exploded[14]);

			break;
		}

		continue;
	}

	while(g_kv.GotoNextKey(keyOnly) == true);

	SetHudTextParamsEx(xy[0], xy[1], holdtime, rgba[0], rgba[1], effect, fxtime, fadein, fadeout); //https://sm.alliedmods.net/new-api/halflife/SetHudTextParams
	Format(g_buffer, sizeof(g_buffer), "%T", g_devmap == true ? "GreetingsPractice" : "GreetingsStatistics", client);
	ShowHudText(client, 1, g_buffer); //https://sm.alliedmods.net/new-api/halflife/ShowHudText

	return Plugin_Continue;
}
