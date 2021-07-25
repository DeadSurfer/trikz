/*GNU GENERAL PUBLIC LICENSE

VERSION 2, JUNE 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.*/

/*GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.*/
#include <sdktools>
#include <sdkhooks>
//#include <dhooks>
//#include <geoip>

//bool gB_block[MAXPLAYERS + 1]
int gI_partner[MAXPLAYERS + 1]
float gF_vec1[2][3]
float gF_vec2[2][3]
//int gI_beam
//int gI_halo
//#pragma dynamic 3000000 //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L35
//int gI_trigger
//int gI_entity
//Handle gH_mysql //https://forums.alliedmods.net/archive/index.php/t-260008.html
Database gD_mysql
float gF_TimeStart[MAXPLAYERS + 1]
float gF_Time[MAXPLAYERS + 1]
//int gI_hour
//int gI_minute
//int gI_second
bool gB_state[MAXPLAYERS + 1]
char gS_map[192]
//int gI_zonetype
bool gB_mapfinished[MAXPLAYERS + 1]
bool gB_pass
bool gB_passzone[MAXPLAYERS + 1]
float gF_vecStart[3]
//bool gB_newpass
//bool gB_runcmd[MAXPLAYERS + 1]
//int gI_other[MAXPLAYERS + 1]
float gF_boostTime[MAXPLAYERS + 1]
//float gF_vecAbs[MAXPLAYERS + 1][3]
//int gI_sky[MAXPLAYERS + 1]
//int gI_frame[MAXPLAYERS + 1]
//float gF_skyVelBooster[MAXPLAYERS + 1][3]
float gF_skyVel[MAXPLAYERS + 1][3]
//bool gB_onGround[MAXPLAYERS + 1]
bool gB_readyToStart[MAXPLAYERS + 1]
//float gF_bestTime
//float gF_personalBest[MAXPLAYERS + 1]
//bool gB_trigger[2048 + 1][MAXPLAYERS + 1]

/*bool gB_stateDefaultDisabled[2048 + 1]
bool gB_stateDisabled[MAXPLAYERS + 1][2048 + 1]
float gF_buttonDefaultDelay[2048 + 1]
float gF_buttonReady[MAXPLAYERS + 1][2048 + 1]*/

float gF_vec1cp[11][3]
float gF_vec2cp[11][3]
//int gI_cpCount
bool gB_cp[11][MAXPLAYERS + 1]
bool gB_cpLock[11][MAXPLAYERS + 1]
float gF_TimeCP[11][MAXPLAYERS + 1]
float gF_timeDiffCP[11][MAXPLAYERS + 1]
float gF_srCPTime[11][MAXPLAYERS + 1]
//bool gB_CPprint[10]

float gF_haveRecord[MAXPLAYERS + 1]
float gF_ServerRecord

ConVar gCV_steamid //https://wiki.alliedmods.net/ConVars_(SourceMod_Scripting)

int gI_type
int gI_cpnum

bool gB_TrikzMenuIsOpen[MAXPLAYERS + 1]
//bool gB_menuIsTrikz[MAXPLAYERS + 1]

//bool gB_isEndTouchBoost[MAXPLAYERS + 1][2048 + 1]
float gF_vecVelBoostFix[MAXPLAYERS + 1][3]
int gI_boost[MAXPLAYERS + 1]
//float gF_boostTime[MAXPLAYERS + 1]
int gI_skyStep[MAXPLAYERS + 1]
bool gB_bouncedOff[2048 + 1]
bool gB_groundBoost[MAXPLAYERS + 1]
//float gF_currentVelBooster[MAXPLAYERS + 1][3]
int gI_flash[MAXPLAYERS + 1]
int gI_skyFrame[MAXPLAYERS + 1]
//int gI_entityFlags[MAXPLAYERS + 1]
int gI_testvec[MAXPLAYERS + 1]
float gF_devmap[2]
bool gB_isDevmap
//bool gB_nospamvote
float gF_totalPlayers
//int gF_devmap_yes
//int gF_devmap_no
float gF_devmapTime

float gF_vec[MAXPLAYERS + 1][2][3]
float gF_angles[MAXPLAYERS + 1][2][3]
float gF_velocity[MAXPLAYERS +1][2][3]
bool gB_toggledCheckpoint[MAXPLAYERS + 1][2]

bool gB_haveZone

float gF_getGud
int gI_getGud

bool gB_isServerRecord
char gS_date[64]
char gS_time[64]

bool gB_silentKnife
float gF_mateRecord[MAXPLAYERS + 1]
bool gB_isTurnedOnSourceTV
bool gB_block[MAXPLAYERS + 1]
int gI_wModelThrown
//int gI_wModelThrowDef
int gI_class[MAXPLAYERS + 1]
bool gB_color[MAXPLAYERS + 1]
int gI_wModelPlayer[5]
int gI_wModelPlayerDef[5]
//int gI_wModel[MAXPLAYERS + 1][5]
int gI_randomInt[MAXPLAYERS + 1][3]
float gF_pingDelay[MAXPLAYERS + 1]
int gI_pingModel[MAXPLAYERS + 1]
int gI_pingTick[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "trikz + timer",
	author = "Smesh(Nick Yurevich)",
	description = "Allows to able make trikz more comfortable",
	version = "2.0",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	gCV_steamid = CreateConVar("steamid", "", "Set steamid for control the plugin ex. 120192594. Use status to check your uniqueid, without 'U:1:'.")
	//https://sm.alliedmods.net/new-api/sourcemod/AutoExecConfig
	AutoExecConfig(true)
	//PrintToServer("%i", GetConVarInt(gCV_steamid))
	RegConsoleCmd("sm_t", cmd_trikz)
	RegConsoleCmd("sm_tr", cmd_trikz)
	RegConsoleCmd("sm_tri", cmd_trikz)
	RegConsoleCmd("sm_trik", cmd_trikz)
	RegConsoleCmd("sm_trikz", cmd_trikz)
	RegConsoleCmd("sm_b", cmd_block)
	RegConsoleCmd("sm_bl", cmd_block)
	RegConsoleCmd("sm_blo", cmd_block)
	RegConsoleCmd("sm_bloc", cmd_block)
	RegConsoleCmd("sm_block", cmd_block)
	RegConsoleCmd("sm_p", cmd_partner)
	RegConsoleCmd("sm_pa", cmd_partner)
	RegConsoleCmd("sm_par", cmd_partner)
	RegConsoleCmd("sm_part", cmd_partner)
	RegConsoleCmd("sm_partn", cmd_partner)
	RegConsoleCmd("sm_partne", cmd_partner)
	RegConsoleCmd("sm_partner", cmd_partner)
	//RegConsoleCmd("sm_flash", cmd_giveflashbang)
	//RegConsoleCmd("sm_flashbang", cmd_giveflashbang)
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			OnClientPutInServer(i)
	//RegConsoleCmd("sm_createstart", cmd_createstart)
	//RegConsoleCmd("sm_createend", cmd_createend)
	//RegConsoleCmd("sm_1", cmd_create)
	RegConsoleCmd("sm_vecmins", cmd_vecmins)
	//RegConsoleCmd("sm_2", cmd_vecmins)
	RegConsoleCmd("sm_vecmaxs", cmd_vecmaxs)
	//RegConsoleCmd("sm_3", cmd_vecmaxs)
	//RegConsoleCmd("sm_starttouch", cmd_starttouch)
	//RegConsoleCmd("sm_4", cmd_starttouch)
	//RegConsoleCmd("sm_sum", cmd_sum)
	//RegConsoleCmd("sm_getid", cmd_getid)
	//RegConsoleCmd("sm_tptrigger", cmd_tp)
	//RegConsoleCmd("sm_tp", cmd_teleport)
	RegConsoleCmd("sm_cp", cmd_checkpoint)
	RegServerCmd("sm_createtable", cmd_createtable)
	RegConsoleCmd("sm_time", cmd_time)
	RegServerCmd("sm_createusertable", cmd_createuser)
	RegServerCmd("sm_createrecordstable", cmd_createrecords)
	//RegServerCmd("sm_setup", cmd_setup)
	RegConsoleCmd("sm_vecminsend", cmd_vecminsend)
	RegConsoleCmd("sm_vecmaxsend", cmd_vecmaxsend)
	RegConsoleCmd("sm_maptier", cmd_maptier)
	//RegConsoleCmd("sm_vectest", cmd_vectest)
	//RegConsoleCmd("sm_testtext", cmd_testtext)
	RegConsoleCmd("sm_cpmins", cmd_cpmins)
	RegConsoleCmd("sm_cpmaxs", cmd_cpmaxs)
	//RegConsoleCmd("sm_tp1", cmd_tp1)
	RegServerCmd("sm_manualcp", cmd_manualcp)
	RegConsoleCmd("sm_deleteallcp", cmd_deleteallcp)
	RegConsoleCmd("sm_eye66", cmd_eye66)
	RegConsoleCmd("sm_getgud", cmd_getgud) //get gud by atx. !getgud 0.1 = -263.559112 0.000000, !getgud 0.05 = -276.277801 0.000000. !getgud 0.025 = -279.457427 0.000000. !getgud 0.015 = -280.729309 0.000000. !getgud 0.007 = -281.746826 0.000000.
	RegConsoleCmd("sm_devmap", cmd_devmap)
	//!getgud 0.0075 = -281.683227 0.000000. !getgud 0.00725 = -281.714996 0.000000. !getgud 0.0076 = -281.670501 0.000000 !getgud 0.0078 = -281.645050 0.000000. !getgud 0.0079 = -281.632354 0.000000. !getgud 0.00795 = -281.625976 0.000000. koda povishaesh cifra umenshaetsa.
	//!getgud 0.00794 = -281.627258 0.000000. !getgud 0.00793 = -281.628540 0.000000. !getgud 0.00789 = -281.633605 0.000000 !getgud 0.00787 = -281.636138 0.000000. !getgud 0.00786 = -281.637420 0.000000
	//!getgud 0.007865 = -281.636779 0.000000. !getgud 0.007866 = -281.636657 0.000000. !getgud 0.007862 = -281.637176 0.000000. !getgud 0.0078625 = -281.637115 0.000000
	//
	//RegServerCmd("sm_y", cmd_findyifxandzexist)
	AddCommandListener(listenerf1, "autobuy") //https://sm.alliedmods.net/new-api/console/AddCommandListener
	AddNormalSoundHook(SoundHook)
	AddCommandListener(specchat, "say") //thanks to VerMon idea.
	//AddCommandListener(joinclass, "joinclass")
	HookEvent("player_spawn", event_playerspawn)
	//Database.Connect(SQLConnect, "fakeexpert")
	/*HookEvent("roundstart", roundstart)
	Handle hGamedata = LoadGameConfigFile("sdktools.games")
	if(hGamedata == null)
	{
		SetFailState("Failed to load \"sdktools.games\" gamedata.")
		delete hGamedata
	}
	int offset = GameConfGetOffset(hGamedata, "AcceptInput")
	if(offset == 0)
	{
		SetFailState("Failed to load \"AcceptInput\", invalid offset.")
		delete hGamedata
	}
	gH_AcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput)
	DHookAddParam(gH_AcceptInput, HookParamType_CharPtr)
	DHookAddParam(gH_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(gH_AcceptInput, HookParamType_CBaseEntity)
	DHookAddParam(gH_AcceptInput, HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP) //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(gH_AcceptInput, HookParamType_Int)
	//HookEvent("round_start", Event_RoundStart)
	hGamedata = LoadGameConfigFile("collisionhook")
	if(hGamedata == null)
	{
		SetFailState("Failed to load \"collisionhook.txt\" gamedata.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	gH_PassServerEntityFilter = DHookCreateFromConf(hGamedata, "PassServerEntityFilter")
	if(!gH_PassServerEntityFilter)
	{
		SetFailState("Failed to setup detour PassServerEntityFilter.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	if(!DHookEnableDetour(gH_PassServerEntityFilter, false, PassServerEntityFilter))
	{
		SetFailState("Failed to load detour PassServerEntityFilter.")
		delete hGamedata
		delete gH_PassServerEntityFilter
	}
	delete hGamedata
	delete gH_PassServerEntityFilter*/
	//CreateForward("Trikz_OnPartner", ET_Hook, Param_Cell, Param_Cell)
	//CreateForward("Trikz_OnBreakPartner", ET_Hook, Param_Cell, Param_Cell)
	//CreateForward("Trikz_OnStartTimer", ET_Hook, Param_Cell, Param_Cell)
}

/*Action roundstart(Event event, const char[] name, bool dontBoardcast)
{
	int entity = -1
	while((entity = FindEntityByClassname(entity, "func_brush")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
		if(GetEntProp(entity, Prop_Data, "m_iDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "func_wall_toggle")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_SetTransmit, EntityVisibleTransmit)
		if(GetEntProp(entity, Prop_Data, "m_spawnflags") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Toggle")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
		if(GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "trigger_teleport")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
		if(GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "trigger_teleport_relative")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
		if(GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "trigger_push")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
		if(GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "trigger_gravity")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity)
		SDKHook(entity, SDKHook_Touch, TouchTrigger)
		if(GetEntProp(entity, Prop_Data, "m_bDisabled") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			AcceptEntityInput(entity, "Enable")
			gB_stateDefaultDisabled[entity] = true
		}
	}
	while((entity = FindEntityByClassname(entity, "func_button")) != -1)
	{
		DHookEntity(gH_AcceptInput, false, entity, INVALID_FUNCTION, AcceptInputButton)
		SDKHook(entity, SDKHook_Use, HookButton)
		SDKHook(entity, SDKHook_OnTakeDamage, HookOnTakeDamage);
		gF_buttonDefaultDelay[entity] = GetEntPropFloat(entity, Prop_Data, "m_flWait")
		SetEntPropFloat(entity, Prop_Data, "m_flWait", 0.1)
		if(GetEntProp(entity, Prop_Data, "m_bLocked") == 0)
		{
			gB_stateDefaultDisabled[entity] = false
		}
		else
		{
			gB_stateDefaultDisabled[entity] = true
		}
	}
	for(int i = 1; i <= 2048; i++)
		gB_stateDisabled[0][i] = gB_stateDefaultDisabled[i]
	HookEntityOutput("trigger_multiple", "OnStartTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_teleport", "OnStartTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_teleport_relative", "OnStartTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_push", "OnStartTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_gravity", "OnStartTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_multiple", "OnEndTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_teleport", "OnEndTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_teleport_relative", "OnEndTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_push", "OnEndTouch", TriggerOutputHook) //make able to work !self
	HookEntityOutput("trigger_gravity", "OnEndTouch", TriggerOutputHook) //make able to work !self
}*/

/*Action Trigger(int entity, int other)
{
	if(GetEntProp(entity, Prop_Data, "m_bDisabled"))
		gB_trigger[entity][other] = true
	else
		gB_trigger[entity][other] = false
	if(GetEntProp(entity, Prop_Data, "m_bDisabled"))
		gB_trigger[entity][other] = true
	else
		gB_trigger[entity][other] = false
	return Plugin_Handled
}

Action Button(int entity, int activator, int caller, UseType type, float value)
{
	//if(GetEntProp(entity, Prop
}*/

/*MRESReturn AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(1 > activator || activator > MaxClients)
		return MRES_Ignored
	//int caller = DHookGetParam(hParams, 3)
	int partner = Trikz_FindPartner(activator)
	//int outputid = DHookGetParam(hParams, 5)
	if(StrEqual(sInput, "Enable"))
		if(partner != -1)
		{
			gB_stateDisabled[activator][pThis] = false
			gB_stateDisabled[partner][pThis] = false
		}
		else
		{
			gB_stateDisabled[0][pThis] = false
			for(int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && Trikz_FindPartner(i) == -1)
					gB_stateDisabled[i][pThis] = false
		}
	if(StrEqual(sInput, "Disable"))
		if(partner != -1)
		{
			gB_stateDisabled[activator][pThis] = true
			gB_stateDisabled[partner][pThis] = true
		}
		else
		{
			gB_stateDisabled[0][pThis] = true
			for(int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && Trikz_FindPartner(i) == -1)
					gB_stateDisabled[i][pThis] = true
		}
	char sClassname[32]
	char sName[32]
	char sCClassname[32]
	char sCName[32]
	GetEntPropString(pThis, Prop_Data, "m_iClassname", sClassname, 32)
	GetEntPropString(pThis, Prop_Data, "m_iName", sName, 32)
	GetEntPropString(caller, Prop_Data, "m_iClassname", sCClassname, 32)
	GetEntPropString(caller, Prop_Data, "m_iName", sCName, 32)
	PrintToServer("AcceptInput (%s | %s) pThis: %i input: %s activator: %N (%i) caller: %i (%s | %s) outputid: %i", sClassname, sName, pThis, sInput, activator, activator, caller, sCClassname, sCName, outputid)
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}

MRESReturn AcceptInputButton(int pThis, Handle hReturn, Handle hParams)
{
	//if(pThis < 0)
	//	pThis = EntRefToEntIndex(pThis)
	char sInput[32]
	DHookGetParamString(hParams, 1, sInput, 32)
	if(DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int activator = DHookGetParam(hParams, 2)
	if(activator < 1)
		return MRES_Ignored
	//int caller = DHookGetParam(hParams, 3)
	int partner = Trikz_FindPartner(activator)
	//int outputid = DHookGetParam(hParams, 5)
	if(StrEqual(sInput, "Unlock"))
		if(partner != -1)
		{
			gB_stateDisabled[activator][pThis] = false
			gB_stateDisabled[partner][pThis] = false
		}
		else
		{
			gB_stateDisabled[0][pThis] = false
			for(int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && Trikz_FindPartner(i) == -1)
					gB_stateDisabled[i][pThis] = false
		}
	if(StrEqual(sInput, "Lock"))
		if(partner != -1)
		{
			gB_stateDisabled[activator][pThis] = true
			gB_stateDisabled[partner][pThis] = true
		}
		else
		{
			gB_stateDisabled[0][pThis] = true
			for(int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && Trikz_FindPartner(i) == -1)
					gB_stateDisabled[i][pThis] = true
		}
	return MRES_Ignored
}

Action TouchTrigger(int entity, int other)
{
	if(0 < other <= MaxClients && gB_stateDisabled[other][entity])
		return Plugin_Handled
	
	
	if(0 < ent2 <= MaxClients && !gB_stateDisabled[ent2][ent1])
		return Plugin_Continue
	char classname[32]
	GetEntPropString(ent2, Prop_Data, "m_iClassname", classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients && !gB_stateDisabled[ent2owner][ent1])
			return Plugin_Continue
	}
	return Plugin_Continue
}

Action EntityVisibleTransmit(int entity, int client)
{
	if(gB_stateDisabled[client][entity])
		return Plugin_Handled
	return Plugin_Continue
}

Action HookButton(int entity, int activator, int caller, UseType type, float value)
{
	if(0.0 < gF_buttonReady[activator][entity] > GetGameTime())
		return Plugin_Handled
	if(gB_stateDisabled[activator][entity])
		return Plugin_Handled
	gF_buttonReady[activator][entity] = GetGameTime() + gF_buttonDefaultDelay[entity]
	int partner = Trikz_FindPartner(activator)
	if(partner != -1)
		gF_buttonReady[partner][entity] = gF_buttonReady[activator][entity]
	else
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i) && Trikz_FindPartner(i) == -1)
				gF_buttonReady[i][entity] = gF_buttonReady[activator][entity]
	if(GetEntProp(entity, Prop_Data, "m_bLocked") == 1)
		AcceptEntityInput(entity, "Unlock")
	return Plugin_Continue
}

Action HookOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	SetEntPropEnt(victim, Prop_Data, "m_hActivator", attacker)
}

Action TriggerOutputHook(const char[] output, int caller, int activator, float delay)
{
	if(gB_stateDisabled[activator][caller])
		return Plugin_Handled
	return Plugin_Continue
}*/

/*MRESReturn PassServerEntityFilter(Handle hReturn, Handle hParams)
{
	if(DHookIsNullParam(hParams, 1) || DHookIsNullParam(hParams, 2))
		return MRES_Ignored
	int ent1 = DHookGetParam(hParams, 1) //touch reciever
	int ent2 = DHookGetParam(hParams, 2) //touch sender
	Action result
	Call_StartForward(gH_PassServerEntityFilter)
	Call_PushCell(ent1)
	Call_PushCell(ent2)
	Call_Finish(result)
	if(result > Plugin_Continue)
	{
		DHookSetReturn(hReturn, false)
		return MRES_Supercede
	}
	if(0 < ent2 <= MaxClients && !gB_stateDisabled[ent2][ent1])
		return MRES_Ignored
	char classname[32]
	GetEntPropString(ent2, Prop_Data, "m_iClassname", classname, 32)
	if(StrContains(classname, "projectile") != -1)
	{
		int ent2owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
		if(0 < ent2owner <= MaxClients && !gB_stateDisabled[ent2owner][ent1])
			return MRES_Ignored
	}
	//PrintToServer("ent1 %i, ent2 %i", ent1, ent2)
	DHookSetReturn(hReturn, false)
	return MRES_Supercede
}*/
//int gI_vModel
//int gI_wModel
//#define d_wModelThrown "models/fakeexpert/models/weapons/flashbang.mdl"

public void OnMapStart()
{
	//gI_beam = PrecacheModel("materials/sprites/tp_beam001")
	//gI_beam = PrecacheModel("sprites/laserbeam.vmt", true) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L657-L658
	//gI_halo = PrecacheModel("sprites/glow01.vmt", true)
	GetCurrentMap(gS_map, 192)
	//gI_cpCount = 0
	Database.Connect(SQLConnect, "fakeexpert")
	//gI_cpCount = 0
	//GetCurrentMap(gS_map, 192)
	for(int i = 0; i <= 1; i++)
		gF_devmap[i] = 0.0
	//gB_nospamvote = false
	gB_haveZone = false
	ConVar CV_sourcetv
	CV_sourcetv = FindConVar("tv_enable")
	//int isSourceTV = CV_sourcetv.BoolValue()
	bool isSourceTV = GetConVarBool(CV_sourcetv)
	if(isSourceTV)
	{
		PrintToServer("sourcetv work.")
		//char sDate[64]
		FormatTime(gS_date, 64, "%Y-%m-%d", GetTime())
		//char sTime[64]
		FormatTime(gS_time, 64, "%H-%M-%S", GetTime())
		ServerCommand("tv_record %s-%s-%s", gS_date, gS_time, gS_map) //https://www.youtube.com/watch?v=GeGd4KOXNb8 https://forums.alliedmods.net/showthread.php?t=59474 https://www.php.net/strftime
	}
	gB_isServerRecord = false
	if(!gB_isTurnedOnSourceTV)
	{
		gB_isTurnedOnSourceTV = true
		ForceChangeLevel(gS_map, "Turn on SourceTV")
	}
	//gI_vModel = PrecacheModel("models/fakeexpert/models/weapons/v_eq_flashbang.mdl")
	//gI_wModel = PrecacheModel("models/fakeexpert/models/weapons/w_eq_flashbang.mdl")
	//gI_wModelThrowDef = PrecacheModel("models/weapons/w_eq_smokegrenade_thrown.mdl")
	gI_wModelThrown = PrecacheModel("models/fakeexpert/models/weapons/w_eq_flashbang_thrown.mdl")
	gI_wModelPlayerDef[1] = PrecacheModel("models/player/ct_urban.mdl")
	gI_wModelPlayerDef[2] = PrecacheModel("models/player/ct_gsg9.mdl")
	gI_wModelPlayerDef[3] = PrecacheModel("models/player/ct_sas.mdl")
	gI_wModelPlayerDef[4] = PrecacheModel("models/player/ct_gign.mdl")
	gI_wModelPlayer[1] = PrecacheModel("models/fakeexpert/player/ct_urban.mdl")
	gI_wModelPlayer[2] = PrecacheModel("models/fakeexpert/player/ct_gsg9.mdl")
	gI_wModelPlayer[3] = PrecacheModel("models/fakeexpert/player/ct_sas.mdl")
	gI_wModelPlayer[4] = PrecacheModel("models/fakeexpert/player/ct_gign.mdl")
	//gI_pingModel = PrecacheModel("models/fakeexpert/pingtool/pingtool.mdl")
	PrecacheModel("models/fakeexpert/pingtool/pingtool.mdl")
	//gI_wModelThrown = PrecacheModel("models/fakeexpert/models/weapons/flashbang.mdl")
	//gI_wModelThrown = PrecacheModel(d_wModelThrown)
	//PrecacheModel(
	//PrecacheModel("fakeexpert/models/weapons/v_eq_flashbang.mdl")
	//PrecacheModel("fakeexpert/models/weapons/w_eq_flashbang.mdl")
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
}

public void OnMapEnd()
{
	//RenameFile(
	ConVar CV_sourcetv
	CV_sourcetv = FindConVar("tv_enable")
	//int isSourceTV = CV_sourcetv.BoolValue()
	bool isSourceTV = GetConVarBool(CV_sourcetv)
	if(isSourceTV)
	{
		ServerCommand("tv_stoprecord")
		char sOldFileName[64]
		Format(sOldFileName, 64, "%s-%s-%s.dem", gS_date, gS_time, gS_map)
		if(gB_isServerRecord)
		{
			char sNewFileName[64]
			Format(sNewFileName, 64, "%s-%s-%s-ServerRecord.dem", gS_date, gS_time, gS_map)
			RenameFile(sNewFileName, sOldFileName)
		}
		else
			DeleteFile(sOldFileName)
	}
	//for(int i = 1; i <= MaxClients; i++)
		//CancelClientMenu(i)
}

//Action eventJump(Event event, const char[] name, bool dontBroadcast) //dontBroadcast = radit vair neradit.
//{
//}

Action listenerf1(int client, const char[] commnd, int argc) //extremix idea.
{
	//Trikz(client)
	//PrintToServer("autobuy")
}

Action specchat(int client, const char[] command, int argc)
{
	if(MaxClients >= client > 0 && GetClientTeam(client) == 1)
	{
		char sName[MAX_NAME_LENGTH]
		GetClientName(client, sName, MAX_NAME_LENGTH)
		char sChat[256]
		//GetCmdArgString(sChat, 256)
		GetCmdArg(argc, sChat, 256)
		//GetCmdArgs(
		//GetCmdReplySource(
		//PrintToChatAll("%s", sChat)
		//PrintToChat(client, "\x07FF4040text21") //red - terrorist
		//PrintToChat(client, "\x0799CCFFtext2") //blue - counter-terrorist
		//if(Get)
		//PrintToChatAll("(Spectator) %s: %s", sName, sChat) //sourcemod.net arg
		//char sColor[][] = {"0xCCCCCC"}
		//Handle hTrie = CreateTrie()
		//SetTrieValue(hTrie, "gray", 0xCCCCCC)
		//int value
		//GetTrieValue(hTrie, "gray", value)
		//char sFormat[256]
		//Format(sFormat, 256, "*SPEC* \x07%06X %s \x01:  %s", value, sName, sChat) //https://wiki.alliedmods.net/Format_Class_Functions_(SourceMod_Scripting)#:~:text=Format-class%20functions%20are%20variable%20argument%20functions%20in%20SourceMod,will%20then%20be%3A%20%22%20Your%20name%20is%3A%20Mark.%22
		PrintToChatAll("*SPEC* %s :  %s", sName, sChat) //   SetTrieValue(hTrie, "grey", 0xCCCCCC);
		//PrintToChatAll("%s", sFormat)
		return Plugin_Handled
	}
	return Plugin_Continue
}

/*Action joinclass(int client, const char[] command, int argc)
{
	PrintToServer("%i %n %s %i", client, client, command, argc)
	//GetCmdArg(argc, 
	gI_class[client] = StringToInt(command)
}*/

Action event_playerspawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	char sModel[64]
	GetClientModel(client, sModel, 64)
	//PrintToServer("%s", sModel)
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
				{
					Trikz(param1)
				}
			}
		case MenuAction_End:
			delete menu
	}
}

public void OnClientPutInServer(int client)
{
	//gI_partner[client] = 0
	//if(gB_TrikzMenuIsOpen[gI_partner[client]])
	//	Trikz(gI_partner[client])
	//gI_partner[gI_partner[client]] = 0
	SDKHook(client, SDKHook_SpawnPost, SDKPlayerSpawnPost)
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage)
	SDKHook(client, SDKHook_StartTouch, SDKSkyFix)
	SDKHook(client, SDKHook_PostThinkPost, SDKBoostFix) //idea by tengulawl/scripting/blob/master/boost-fix tengulawl github.com
	SDKHook(client, SDKHook_WeaponEquipPost, SDKWeaponEquipPost)
	char sQuery[512]
	if(IsClientInGame(client) && gB_pass)
	{
		int steamid = GetSteamAccountID(client)
		Format(sQuery, 512, "SELECT * FROM users")
		gD_mysql.Query(SQLAddUser, sQuery, GetClientSerial(client))
		Format(sQuery, 512, "SELECT MIN(time) FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s'", steamid, steamid, gS_map)
		gD_mysql.Query(SQLGetPersonalRecord, sQuery, GetClientSerial(client))
	}
	/*for(int i = 1; i <= 2048; i++)
	{
		gB_stateDisabled[client][i] = gB_stateDisabled[0][i]
		gF_buttonReady[client][i] = 0.0
	}*/
	gB_TrikzMenuIsOpen[client] = false
	//PrintToServer("%i %i", gI_partner[client], gI_partner[gI_partner[client]])
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
	gB_color[gI_partner[client]] = false
	gB_color[client] = false
	gI_pingTick[client] = 0
}

public void OnClientDisconnect(int client)
{
	if(gB_TrikzMenuIsOpen[gI_partner[client]])
		Trikz(gI_partner[client])
	gI_partner[gI_partner[client]] = 0
	gI_partner[client] = 0
	CancelClientMenu(client)
	//PrintToServer("%i %N disconnected.", client, client)
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
	if(data == 0)
		return
	int client = GetClientFromSerial(data)
	if(client == 0)
		return
	if(IsClientInGame(client))
	{
		char sName[64]
		GetClientName(client, sName, 64)
		char sQuery[512]
		int steamid = GetSteamAccountID(client)
		//char sIP[32]
		//GetClientIP(client, sIP, 32)
		//char sCode2[3]
		//GeoipCode2(sIP, sCode2) //https://pastebin.com/AEwTXWV9
		if(results.FetchRow())
		{
			PrintToServer("%s %i [3 - update]", sName, steamid)
			//Format(sQuery, 512, "UPDATE users SET username = '%s', geoipcode2 = '%s', lastjoin = %i WHERE steamid = %i", sName, sCode2, GetTime(), steamid)
			Format(sQuery, 512, "UPDATE users SET username = '%s', lastjoin = %i WHERE steamid = %i", sName, GetTime(), steamid)
			gD_mysql.Query(SQLUpdateUsernameSuccess, sQuery)
		}
		else
		{
			//Format(sQuery, 512, "INSERT INTO users (username, steamid, geoipcode2, firstjoin, lastjoin) VALUES ('%s', %i, '%s', %i, %i)", sName, steamid, sCode2, GetTime(), GetTime())
			Format(sQuery, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%s', %i, %i, %i)", sName, steamid, GetTime(), GetTime())
			gD_mysql.Query(SQLUpdateUsernameSuccess, sQuery)
			PrintToServer("%s %i [4 - insert]", sName, steamid)
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
			PrintToServer("%s %i [1 - select]", sName, steamid)
			Format(sQuery, 512, "SELECT steamid FROM users WHERE steamid = %i", steamid)
			gD_mysql.Query(SQLUpdateUsername, sQuery, GetClientSerial(client))
		}
		else
		{
			//char sIP[32]
			//GetClientIP(client, sIP, 32)
			//char sCode2[3]
			//GeoipCode2(sIP, sCode2)
			//Format(sQuery, 512, "INSERT INTO users (username, steamid, geoipcode2, firstjoin, lastjoin) VALUES ('%s', %i, '%s', %i, %i)", sName, steamid, sCode2, GetTime(), GetTime())
			Format(sQuery, 512, "INSERT INTO users (username, steamid, firstjoin, lastjoin) VALUES ('%s', %i, %i, %i)", sName, steamid, GetTime(), GetTime())
			gD_mysql.Query(SQLUserAdded, sQuery)
			PrintToServer("%s %i [2 - insert]", sName, steamid)
		}
	}
}

void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
{
}

//bool IsClientValid(int client)
//{
	//return (client > 0 && client <= MaxClients && IsClientInGame(client))
//}

void SDKSkyFix(int client, int other) //client = booster; other = flyer
{
	//if(0 < other <= MaxClients)
		//return
	//PrintToServer("SDKSkyFix: %i %i", client, other)
	//if(!IsClientValid(other) || gI_entityFlags[other] & FL_ONGROUND || gI_boost[client] || GetGameTime() - gF_boostTime[client] < 0.15)
	//	return
	//if(0 < other <= MaxClients && 0 < client <= MaxClients)
	//if(!(GetEntityFlags(other) & FL_ONGROUND))
	{
		/*float vecAbsClient[3]
		//if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		if(delta > 0.0 && delta < 2.0)
		{
			vecAbs[2] = FloatAbs(vecAbs[2]) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L84
			//if(vecAbs[2] > 0.0)
			gF_skyVel[other][2] = vecAbs[2] //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L84
			//https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-hud.sp#L918
			//	gI_sky[other] = 1 //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L121
		}*/
		
		float vecAbsBooster[3]
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vecAbsBooster)
		float vecAbsFlyer[3]
		GetEntPropVector(other, Prop_Data, "m_vecOrigin", vecAbsFlyer)
		float vecMaxs[3]
		GetEntPropVector(client, Prop_Data, "m_vecMaxs", vecMaxs)
		float delta = vecAbsFlyer[2] - vecAbsBooster[2] - vecMaxs[2] //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71
		//PrintToServer("delta: %f", delta)
		if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		{
			//PrintToServer("%f", getCurrentVel[2]) // -118.006614 in couch, in normal -106.006614
			//if(!(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(other) & IN_DUCK) && gI_skyStep[other] == 0 && GetGameTime() - gF_boostTime[other] < 0.15) //gF_boostTime[other] < 0.15 and GetGameTime() is from tengu lawl github.com scripting boost-fix.sp https://www.github.com/tengulawl/scripting/main/blob/boost-fix.sp
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
					if(FloatAbs(vecVelFlyer[2]) > 118.006614)
					{
						gI_skyStep[other] = 1
						gI_skyFrame[other] = 1
					}
				}
			}
		}
	}
}

void SDKBoostFix(int client)
{
	if(gI_boost[client] == 1)
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
				gI_boost[client] = 2
			}
		}
	}
	if(gI_boost[client] == 2)
	{
		if(gB_groundBoost[client])
		{
			gF_vecVelBoostFix[client][2] *= 3.0
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, gF_vecVelBoostFix[client])
		}
		else
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, gF_vecVelBoostFix[client])
		gI_boost[client] = 0
	}
}

Action cmd_trikz(int client, int args)
{
	//gB_TrikzMenuIsOpen[client] = true
	Trikz(client)
	return Plugin_Handled
}

void Trikz(int client)
{
	gB_TrikzMenuIsOpen[client] = true
	//gB_menuIsTrikz[client] = true
	Menu menu = new Menu(trikz_handler, MenuAction_Start | MenuAction_Select | MenuAction_Display | MenuAction_Cancel) //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	//Menu menu = new Menu(trikz_handler) //https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)
	//menu.SetTitle("Trikz", client) //https://forums.alliedmods.net/showthread.php?p=2051806
	menu.SetTitle("Trikz")
	char sDisplay[32]
	//Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
	//Format(sDisplay, 32, GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5 ? "Block [v]" : "Block [x]")
	Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
	menu.AddItem("block", sDisplay)
	Format(sDisplay, 32, gI_partner[client] ? "Breakup" : "Partner")
	//if(gB_isDevmap)
	//	menu.AddItem("partner", "Partner", ITEMDRAW_DISABLED)
	//else
	menu.AddItem("partner", sDisplay, gB_isDevmap ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT)
	menu.AddItem("Color", "Color", gI_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
	//if(gI_partner[client] == 0)
	//Format() //https://forums.alliedmods.net/showthread.php?p=2552601
	menu.AddItem("restart", "Restart", gI_partner[client] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED) //shavit trikz githgub alliedmods net https://forums.alliedmods.net/showthread.php?p=2051806
	//menu.AddItem("restart", "Restart")
	//if(gI_partner[client] != 0)
		//menu.AddItem("restart", "Restart", ITEMDRAW_DEFAULT)
	if(gB_isDevmap)
	{
		menu.AddItem("Checkpoint", "Checkpoint")
		Format(sDisplay, 32, GetEntityMoveType(client) & MOVETYPE_NOCLIP ? "Noclip [v]" : "Noclip [x]")
		menu.AddItem("Noclip", sDisplay)
	}
	//menu.Display(client, 20)
	menu.Display(client, MENU_TIME_FOREVER)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Start:
		{//expert-zone idea. thank to ed, maru.
			//PrintToServer("menu start trikz.")
			gB_TrikzMenuIsOpen[param1] = true
		}
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					Block(param1)
					//delete menu
					//Trikz(param1)
				}
				case 1:
				{
					Partner(param1)
					gB_TrikzMenuIsOpen[param1] = false
				}
				case 2:
				{
					//gB_color[param1] = true
					Color(param1, true)
					Trikz(param1)
				}
				case 3:
					Restart(param1)
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
					//delete menu
					Trikz(param1)
				}
			}
		}//https://forums.alliedmods.net/showthread.php?t=288351
		/*case MenuAction_DisplayItem:
		{
			char sInfo[32]
			menu.GetItem(param2, sInfo, 32)
			if(StrEqual(sInfo, "Restart"))
			{
				char sDisplay[32]
				Format(sDisplay, 32, "Restart1", param1, gI_partner[param1] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED) //https://forums.alliedmods.net/showthread.php?p=2051806
				return RedrawMenuItem(sDisplay)
			}
		}
		case MenuAction_DrawItem:
		{
			char sInfo[32]
			menu.GetItem(param2, sInfo, 32)
			if(StrEqual(sInfo, "Restart"))
			{
				char sDisplay[32]
				Format(sDisplay, 32, "Restart3", gI_partner[param1] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED)
				return RedrawMenuItem(sDisplay)
				//return sDisplay
			}
		}*/
		case MenuAction_Cancel:
		{
			//if(param2 == -2)
			//{
				//char sGetItem[32]
				//menu.GetItem(param2, sGetItem, 32)
				//PrintToServer("sGetItem: %s", sGetItem)
			//}
			//if(param2 == -3 || param2 == -5)
			//{
				//char sItem[32]
				//menu.GetItem(param2, sItem, 32)
				//char sTitle[32]
				//menu.GetTitle(sTitle, 32)
				//PrintToServer("sItem: %s sTitle: %s", sItem, sTitle)
			gB_TrikzMenuIsOpen[param1] = false //idea from expert zone.
			//PrintToServer("Client %d's menu was cancelled. Reason: %d", param1, param2) //https://wiki.alliedmods.net/Menu_API_(SourceMod)
			//}
			//delete menu
		}
		case MenuAction_Display:
		{
			//PrintToServer("menu display trikz.")
			gB_TrikzMenuIsOpen[param1] = true
		}
		case MenuAction_End:
		{
			//PrintToServer("Client %d's menu was end. Reason: %d", param1, param2) //https://wiki.alliedmods.net/Menu_API_(SourceMod)
			delete menu
		}
	}
	//return view_as<int>(Plugin_Continue)
}

//https://forums.alliedmods.net/showthread.php?t=302374

Action cmd_block(int client, int args)
{
	//if(gB_TrikzMenuIsOpen[client])
	//{
		//Trikz(client)
		//Block(client)
	//}
	//else
	Block(client)
	return Plugin_Handled
}

Action Block(int client)
{
	//if(GetEntProp(client, Prop_Send, "m_CollisionGroup") != 5)
	//{
		//PrintToServer("block = %i %N", GetEntProp(client, Prop_Send, "m_CollisionGroup"), client)
	//}
	//if(GetEntProp(client, Prop_Send, "m_CollisionGroup") != 2)
		//PrintToServer("block = %i %N", GetEntProp(client, Prop_Send, "m_CollisionGroup"), client) //https://github.com/shanapu/MyJailbreak/commit/9e7480a
	//if(GetEntProp(client, Prop_Send, "m_CollisionGroup") == 5) //https://developer.valvesoftware.com/wiki/Collision_groups
	gB_block[client] = !gB_block[client]
	if(gB_block[client])
	{
		SetEntProp(client, Prop_Send, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		//gB_block[client] = true
		if(gB_TrikzMenuIsOpen[client])
			Trikz(client)
		PrintToChat(client, "Block enabled.")
		return Plugin_Handled
	}//if(GetEntProp(client, Prop_Send, "m_CollisionGroup") <= 2)
	else
	{

		SetEntProp(client, Prop_Send, "m_CollisionGroup", 2)
		SetEntityRenderMode(client, RENDER_TRANSALPHA)
		SetEntityRenderColor(client, 255, 255, 255, 100)
		//gB_block[client] = false
		if(gB_TrikzMenuIsOpen[client])
			Trikz(client)
		PrintToChat(client, "Block disabled.")
		return Plugin_Handled
	}
	//return Plugin_Handled
}

Action cmd_partner(int client, int args)
{
	Partner(client)
	return Plugin_Handled
}

void Partner(int client)
{
	if(gI_partner[client] == 0)
	{
		Menu menu = new Menu(partner_handler)
		menu.SetTitle("Choose partner")
		char sName[MAX_NAME_LENGTH]
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && client != i) //https://github.com/Figawe2/trikz-plugin/blob/master/scripting/trikz.sp#L635
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
			//int param2x = param2
			char sItem[32]
			menu.GetItem(param2, sItem, 32)
			int partner = StringToInt(sItem)
			switch(param2)
			{
				case 0:
				{
					if(gI_partner[partner] == 0)
					{
						//PrintToServer("%i %N, %i %N", param1, param1, param2x, param2x)
						gI_partner[param1] = partner
						gI_partner[partner] = param1
						//PrintToServer("p1: %i %N p2: %i %N", partner, partner, param1, param1)
						PrintToChat(param1, "Partnersheep agreed with %N.", partner) //reciever
						PrintToChat(partner, "You have %N as partner.", param1) //sender
						//Reseta
						Restart(param1)
						Restart(partner) //Expert-Zone idea.
						//PrintToServer("partner1: %i %N, partner2: %i %N", gI_partner[param1], gI_partner[param1], gI_partner[partner], gI_partner[partner])
						if(gB_TrikzMenuIsOpen[partner])
							Trikz(partner)
						/*for(int i = 1; i <= 2048; i++)
						{
							gB_stateDisabled[param1][i] = gB_stateDefaultDisabled[i]
							gB_stateDisabled[partner][i] = gB_stateDefaultDisabled[i]
							gF_buttonReady[param1][i] = 0.0
							gF_buttonReady[partner][i] = 0.0
						}*/
						char sQuery[512]
						Format(sQuery, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i))", GetSteamAccountID(partner), GetSteamAccountID(param1), GetSteamAccountID(param1), GetSteamAccountID(partner))
						gD_mysql.Query(SQLGetPartnerRecord, sQuery, GetClientSerial(partner))
					}
					else
						PrintToChat(param1, "A player already have a partner.")
				}
				case 1:
				{
					PrintToChat(param1, "Partnersheep declined with %N.", partner)
				}
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
					gI_partner[param1] = 0
					gI_partner[partner] = 0
					PrintToChat(param1, "Partnership is canceled with %N", partner)
					PrintToChat(partner, "Partnership is canceled by %N", param1)
					//gB_color[param1] = false
					//gB_color[partner] = false
					Color(param1, false)
					Color(partner, false)
					/*for(int i = 1; i <= 2048; i++)
					{
						gB_stateDisabled[gI_partner[param1]][i] = gB_stateDefaultDisabled[i]
						gB_stateDisabled[gI_partner[partner]][i] = gB_stateDefaultDisabled[i]
						gF_buttonReady[gI_partner[param1]][i] = 0.0
						gF_buttonReady[gI_partner[partner]][i] = 0.0
					}*/
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
		//gI_wModel[client] = gI_class[client]
		if(gI_class[client] == 1)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayer[1])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayer[1])
		}
		if(gI_class[client] == 2)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayer[2])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayer[2])
		}
		if(gI_class[client] == 3)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayer[3])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayer[3])
		}
		if(gI_class[client] == 4)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayer[4])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayer[4])
		}
		SetEntProp(client, Prop_Data, "m_nSkin", 1)
		SetEntProp(gI_partner[client], Prop_Data, "m_nSkin", 1)
		gI_randomInt[client][0] = GetRandomInt(0, 255)
		gI_randomInt[client][1] = GetRandomInt(0, 255)
		gI_randomInt[client][2] = GetRandomInt(0, 255)
		gI_randomInt[gI_partner[client]][0] = gI_randomInt[client][0]
		gI_randomInt[gI_partner[client]][1] = gI_randomInt[client][1]
		gI_randomInt[gI_partner[client]][2] = gI_randomInt[client][2]
		SetEntityRenderColor(client, gI_randomInt[client][0], gI_randomInt[client][1], gI_randomInt[client][2], 255)
		SetEntityRenderColor(gI_partner[client], gI_randomInt[client][0], gI_randomInt[client][1], gI_randomInt[client][2], 255)
	}
	else
	{
		gB_color[client] = false
		gB_color[gI_partner[client]] = false
		//gI_wModel[client] = gI_class[client]
		if(gI_class[client] == 1)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[1])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[1])
		}
		if(gI_class[client] == 2)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[2])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[2])
		}
		if(gI_class[client] == 3)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[3])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[3])
		}
		if(gI_class[client] == 4)
		{
			SetEntProp(client, Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[4])
			SetEntProp(gI_partner[client], Prop_Data, "m_nModelIndex", gI_wModelPlayerDef[4])
		}
		//SetEntProp(client, Prop_Data, "m_nSkin", 1)
		SetEntityRenderColor(client, 255, 255, 255, 255)
		SetEntityRenderColor(gI_partner[client], 255, 255, 255, 255)
	}
}

void SQLGetPartnerRecord(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	if(results.FetchRow())
		gF_mateRecord[client] = results.FetchFloat(0)
	else
		gF_mateRecord[client] = 0.0
}

/*Action cmd_giveflashbang(int client, int args)
{
	if(IsPlayerAlive(client) && GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	{
		GivePlayerItem(client, "weapon_flashbang")
		SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2)
	}
	return Plugin_Handled
}*/

void Restart(int client)
{
	if(!gB_isDevmap && gB_haveZone)
	{
		if(gI_partner[client] != 0)
		{
			if(IsPlayerAlive(client) && IsPlayerAlive(gI_partner[client]))
			{
				gB_readyToStart[client] = true
				gB_readyToStart[gI_partner[client]] = true
				gF_Time[client] = 0.0
				gF_Time[gI_partner[client]] = 0.0
				gB_state[client] = false
				gB_state[gI_partner[client]] = false
				float vecVel[3]
				//vecVel[0] = 30.0
				//vecVel[1] = 30.0
				//vecVel[2] = 0.0
				TeleportEntity(client, gF_vecStart, NULL_VECTOR, vecVel)
				TeleportEntity(gI_partner[client], gF_vecStart, NULL_VECTOR, vecVel)
				SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
				SetEntityRenderMode(client, RENDER_TRANSALPHA)
				SetEntityRenderColor(client, 255, 255, 255, 100)
				SetEntProp(gI_partner[client], Prop_Data, "m_CollisionGroup", 2)
				SetEntityRenderColor(gI_partner[client], 255, 255, 255, 100)
				SetEntityRenderMode(gI_partner[client], RENDER_TRANSALPHA)
				if(gB_TrikzMenuIsOpen[client])
					Trikz(client)
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
		SetEntProp(gI_partner[client], Prop_Data, "m_CollisionGroup", 5)
		//SetEntityRenderColor(gI_partner[client], 255, 255, 255, 75)
		SetEntityRenderMode(gI_partner[client], RENDER_NORMAL)
		if(gB_TrikzMenuIsOpen[client])
			Trikz(client)
	}
	return Plugin_Stop
}

//Action cmd_createstart(int client, int args)
void createstart()
{
	char sTriggerName2[64]
	int index
	while((index = FindEntityByClassname(index, "trigger_multiple")) != -1) //https://forums.alliedmods.net/showthread.php?t=290655
	{
		GetEntPropString(index, Prop_Data, "m_iName", sTriggerName2, 64)
		if(StrEqual(sTriggerName2, "fakeexpert_startzone"))
			return
	}
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_startzone")
	//ActivateEntity(entity)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vec2[0][0] + gF_vec1[0][0]) / 2.0
	center[1] = (gF_vec2[0][1] + gF_vec1[0][1]) / 2.0
	center[2] = (gF_vec2[0][2] + gF_vec1[0][2]) / 2.0
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	gF_vecStart[0] = center[0]
	gF_vecStart[1] = center[1]
	gF_vecStart[2] = center[2]
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	//mins[0] = gF_vec[0]
	//mins[1] = gF_vec[1]
	//mins[2] = gF_vec[2]
	//mins[0] = FloatAbs((gF_vec1[0] - gF_vec2[0]) / 2.0)
	//mins[1] = FloatAbs((gF_vec1[1] - gF_vec2[1]) / 2.0)
	//mins[2] = FloatAbs((gF_vec1[2] - gF_vec2[2]) / 2.0 + 128.0)
	//mins[0] = mins[0] * 2.0
	//mins[0] = -mins[0]
	//mins[1] = mins[1] * 2.0
	//mins[1] = -mins[1]
	//mins[2] = -128.0
	//PrintToServer("mins: %f %f %f", mins[0], mins[1], mins[2])
	//mins[0] = FloatAbs(gF_vec1[0] - gF_vec2[0])
	mins[0] = (gF_vec1[0][0] - gF_vec2[0][0]) / 2.0
	if(mins[0] > 0.0)
		mins[0] = mins[0] * -1.0
	//mins[1] = FloatAbs(gF_vec1[1] - gF_vec2[1])
	mins[1] = (gF_vec1[0][1] - gF_vec2[0][1]) / 2.0
	if(mins[1] > 0.0)
		mins[1] = mins[1] * -1.0	
	//mins[2] = FloatAbs(gF_vec1[2] - gF_vec2[2])
	//if(mins[
	//mins[2] = mins[2] += 128.0
	//mins[2] = mins[2] += 128.0
	mins[2] = -128.0
	//PrintToServer("Mins: %f %f %f", mins[0], mins[1], mins[2])
	//SetEntPropVector(entity, Prop_Send, "m_vecMins", maxs) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	//SetEntPropVector(entity, Prop_Data, "m_vecMins", gF_vec1)
	//mins[0] = mins[0] * -1.0
	//mins[1] = mins[1] * -1.0
	//mins[2] = 128.0
	//PrintToServer("maxs: %f %f %f", mins[0], mins[1], mins[2])
	//SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	//SetEntPropVector(entity, Prop_Data, "m_vecMaxs", gF_vec2)
	//SetEntPropVector(entity, Prop_Data, "m_vecMins", gF_vec1)
	float maxs[3]
	//maxs[0] = FloatAbs(gF_vec1[0] - gF_vec2[0]) / 2.0
	maxs[0] = (gF_vec1[0][0] - gF_vec2[0][0]) / 2.0
	if(maxs[0] < 0.0)
		maxs[0] = maxs[0] * -1.0
	maxs[1] = (gF_vec1[0][1] - gF_vec2[0][1]) / 2.0
	if(maxs[1] < 0.0)
		maxs[1] = maxs[1] * -1.0
	maxs[2] = gF_vec1[0][2] - gF_vec2[0][2]
	if(maxs[2] < 0.0)
		maxs[2] = maxs[2] * -1.0
	//maxs[2] = maxs[2] -= 128.0
	//maxs[2] = maxs[2] -= -128.0
	maxs[2] = 128.0
	//PrintToServer("Maxs: %f %f %f", maxs[0], maxs[1], maxs[2])
	//SetEntPropVector(entity, Prop_Data, "m_vecMins", maxs)
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins)
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	//SetEntPropVector(entity, Prop_Send, "m_vecMins", maxs)
	//SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	SDKHook(entity, SDKHook_EndTouch, SDKEndTouch)
	//PrintToServer("entity start: %i created", entity)
	//return Plugin_Handled
}

/*Action cmd_tp1(int client, int args)
{
	float maxs[3]
	//maxs[0] = FloatAbs(gF_vec1[0] - gF_vec2[0]) / 2.0
	maxs[0] = gF_vec1[0][0] - gF_vec2[0][0]
	if(maxs[0] > 0.0)
		maxs[0] = maxs[0] * -1.0
	maxs[1] = gF_vec1[0][1] - gF_vec2[0][1]
	if(maxs[1] > 0.0)
		maxs[1] = maxs[1] * -1.0
	maxs[2] = gF_vec1[0][2] - gF_vec2[0][2]
	if(maxs[2] > 0.0)
		maxs[2] = maxs[2] * -1.0
	//maxs[2] = maxs[2] -= 128.0
	maxs[2] = maxs[2] -= -128.0
	PrintToServer("%f %f %f", maxs[0], maxs[1], maxs[2])
	TeleportEntity(client, maxs, NULL_VECTOR, NULL_VECTOR)
	return Plugin_Handled
}*/

//Action cmd_createend(int client, int args)
void createend()
{
	char sTriggerName2[64]
	int index
	while((index = FindEntityByClassname(index, "trigger_multiple")) != -1) //https://forums.alliedmods.net/showthread.php?t=290655
	{
		GetEntPropString(index, Prop_Data, "m_iName", sTriggerName2, 64)
		if(StrEqual(sTriggerName2, "fakeexpert_endzone"))
			return
	}
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", "fakeexpert_endzone")
	//ActivateEntity(entity)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vec2[1][0] + gF_vec1[1][0]) / 2
	center[1] = (gF_vec2[1][1] + gF_vec1[1][1]) / 2
	center[2] = (gF_vec2[1][2] + gF_vec1[1][2]) / 2
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	//mins[0] = FloatAbs((gF_vec1[0] - gF_vec2[0]) / 2.0)
	//mins[1] = FloatAbs((gF_vec1[1] - gF_vec2[1]) / 2.0)
	//mins[2] = FloatAbs((gF_vec1[2] - gF_vec2[2]) / 2.0)
	//mins[0] = mins[0] * 2.0
	//mins[0] = -mins[0]
	//mins[1] = mins[1] * 2.0
	//mins[1] = -mins[1]
	//mins[2] = -128.0
	//PrintToServer("mins: %f %f %f", mins[0], mins[1], mins[2])
	mins[0] = (gF_vec1[1][0] - gF_vec2[1][0]) / 2.0
	if(mins[0] > 0.0)
		mins[0] = mins[0] * -1.0
	//if(mins[1] = gF_vec1[1] - gF_vec2[1])
	mins[1] = (gF_vec1[1][1] - gF_vec2[1][1]) / 2.0
	if(mins[1] > 0.0)
		mins[1] = mins[1] * -1.0
	mins[2] = -128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	//mins[0] = mins[0] * -1.0
	//mins[1] = mins[1] * -1.0
	//mins[2] = 128.0
	//PrintToServer("maxs: %f %f %f", mins[0], mins[1], mins[2])
	//SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	float maxs[3]
	maxs[0] = (gF_vec1[1][0] - gF_vec2[1][0]) / 2.0
	if(maxs[0] < 0.0)
		maxs[0] = maxs[0] * -1.0
	maxs[1] = (gF_vec1[1][1] - gF_vec2[1][1]) / 2.0
	if(maxs[1] < 0.0)
		maxs[1] = maxs[1] * -1.0
	maxs[2] = 128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	//SetEntPropVector(entity, Prop_Data, "m_vecMins", maxs)
	//SetEntPropVector(entity, Prop_Data, "m_vecMaxs", mins)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	//PrintToServer("entity end: %i created", entity)
	//return Plugin_Handled
	CPSetup()
}

Action cmd_vecmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		//float vec[3]
		GetClientAbsOrigin(client, gF_vec1[0])
		//gF_vec1[0][0] = vec[0]
		//gF_vec1[0][1] = vec[1]
		//gF_vec1[0][2] = vec[2]
		PrintToServer("vec1: %f %f %f", gF_vec1[0][0], gF_vec1[0][1], gF_vec1[0][2])
		char sQuery[512]
		args = 0 //https://www.w3schools.com/sql/sql_delete.asp
		gI_type = args
		//gI_zonetype = 0
		//Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x = '%f', possition_y = '%f', possition_z = '%f' WHERE map = '%s' AND type = '%i';", gS_map, args, gF_vec1[0][0], gF_vec1[0][1], gF_vec1[0][2], gS_map, args)
		//gD_mysql.Query(SQLSetZones, sQuery)
		Format(sQuery, 512, "DELETE FROM zones WHERE map = '%s' AND type = %i", gS_map, args)
		gD_mysql.Query(SQLDeleteZone, sQuery)
		//Format(sQuery, 512, "SELECT
	}
	return Plugin_Handled
}

void SQLDeleteZone(Database db, DBResultSet results, const char[] error, any data)
{
	char sQuery[512]
	//Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x = '%f', possition_y = '%f', possition_z = '%f' WHERE map = '%s' AND type = '%i';", gS_map, gI_type, gF_vec1[0][0], gF_vec1[0][1], gF_vec1[0][2], gS_map, gI_type)
	Format(sQuery, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z) VALUES ('%s', %i, %f, %f, %f)", gS_map, gI_type, gF_vec1[0][0], gF_vec1[0][1], gF_vec1[0][2])
	gD_mysql.Query(SQLSetZones, sQuery)
}

Action cmd_deleteallcp(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID)) //https://sm.alliedmods.net/new-api/
	{
		char sQuery[512]
		Format(sQuery, 512, "DELETE FROM cp WHERE map = '%s'", gS_map)
		gD_mysql.Query(SQLDeleteAllCP, sQuery)
	}
}

void SQLDeleteAllCP(Database db, DBResultSet results, const char[] error, any data)
{
}

Action cmd_vecminsend(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		//float vec[3]
		GetClientAbsOrigin(client, gF_vec1[1])
		//gF_vec1[1][0] = vec[0]
		//gF_vec1[1][1] = vec[1]
		//gF_vec1[1][2] = vec[2]
		//PrintToServer("vec1: %f %f %f", gF_vec1[0], gF_vec1[1], gF_vec1[2])
		char sQuery[512]
		args = 1
		gI_type = args
		//Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec1[1][0], gF_vec1[1][1], gF_vec1[1][2], gS_map, args)
		//gD_mysql.Query(SQLSetZones, sQuery)
		Format(sQuery, 512, "DELETE FROM zones WHERE map = '%s' AND type = %i", gS_map, args)
		gD_mysql.Query(SQLDeleteZone2, sQuery)
	}
	return Plugin_Handled
}

void SQLDeleteZone2(Database db, DBResultSet results, const char[] error, any data)
{
	char sQuery[512]
	//Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f WHERE map = '%s' AND type = %i", gS_map, gI_type, gF_vec1[1][0], gF_vec1[1][1], gF_vec1[1][2], gS_map, gI_type)
	Format(sQuery, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z) VALUES ('%s', %i, %f, %f, %f)", gS_map, gI_type, gF_vec1[1][0], gF_vec1[1][1], gF_vec1[1][2])
	gD_mysql.Query(SQLSetZones, sQuery)
}

Action cmd_maptier(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		char sArgString[512]
		GetCmdArgString(sArgString, 512) //https://www.sourcemod.net/new-api/console/GetCmdArgString
		int tier = StringToInt(sArgString)
		PrintToServer("Args: %i", tier)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE zones SET tier = %i WHERE map = '%s' AND type = 0", tier, gS_map)
		gD_mysql.Query(SQLTier, sQuery)
	}
	return Plugin_Handled
}

void SQLTier(Database db, DBResultSet results, const char[] error, any data)
{
}

void SQLSetZones(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Zone successfuly updated.")
}

Action cmd_vecmaxs(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		//float vec[3]
		GetClientAbsOrigin(client, gF_vec2[0])
		//gF_vec2[0][0] = vec[0]
		//gF_vec2[0][1] = vec[1]
		//gF_vec2[0][2] = vec[2]
		//PrintToServer("vec2: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
		char sQuery[512]
		args = 0
		gI_type = args
		//PrintToServer("%s", gS_map)
		Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x2 = '%f', possition_y2 = '%f', possition_z2 = '%f' WHERE map = '%s' AND type = '%i'", gS_map, args, gF_vec2[0][0], gF_vec2[0][1], gF_vec2[0][2], gS_map, args)
		gD_mysql.Query(SQLSetZones, sQuery)
		//Format(sQuery, 512, "DELETE FROM zones WHERE map = '%s' AND type = %i", gS_map, args)
		//gD_mysql.Query(SQLDeleteZone3, sQuery)
	}
	return Plugin_Handled
}

/*void SQLDeleteZone3(Database db, DBResultSet results, const char[] error, any data)
{
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x2 = '%f', possition_y2 = '%f', possition_z2 = '%f' WHERE map = '%s' AND type = '%i'", gS_map, gI_type, gF_vec2[0][0], gF_vec2[0][1], gF_vec2[0][2], gS_map, gI_type)
	gD_mysql.Query(SQLSetZones, sQuery)
}*/

Action cmd_vecmaxsend(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		//float vec[3]
		GetClientAbsOrigin(client, gF_vec2[1])
		//gF_vec2[1][0] = vec[0]
		//gF_vec2[1][1] = vec[1]
		//gF_vec2[1][2] = vec[2]
		//PrintToServer("vec2: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
		char sQuery[512]
		args = 1
		Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x2 = %f, possition_y2 = %f, possition_z2 = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec2[1][0], gF_vec2[1][1], gF_vec2[1][2], gS_map, args)
		gD_mysql.Query(SQLSetZones, sQuery)
	}
	return Plugin_Handled
}

Action cmd_cpmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		char sCmd[512]
		GetCmdArgString(sCmd, 512)
		int cpnum = StringToInt(sCmd)
		PrintToChat(client, "%i", cpnum)
		GetClientAbsOrigin(client, gF_vec1cp[cpnum])
		char sQuery[512]
		//Format(sQuery, 512, "UPDATE cp SET cpx = %f, cpy = %f, cpz = %f WHERE map = '%s'", sCmd, gF_vec1cp[0], gF_vec1cp[1], gF_vec1cp[2], gS_map)
		gI_cpnum = cpnum
		Format(sQuery, 512, "DELETE FROM cp WHERE cpnum = %i AND map = '%s'", gI_cpnum, gS_map)
		gD_mysql.Query(SQLCPRemove, sQuery)
	}
	return Plugin_Handled
}

void SQLCPRemove(Database db, DBResultSet results, const char[] error, any data)
{
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO cp (cpnum, cpx, cpy, cpz, map) VALUES (%i, %f, %f, %f, '%s')", gI_cpnum, gF_vec1cp[gI_cpnum][0], gF_vec1cp[gI_cpnum][1], gF_vec1cp[gI_cpnum][2], gS_map)
	gD_mysql.Query(SQLCPUpdate, sQuery)
	PrintToServer("CP is inserted.")
}

Action cmd_cpmaxs(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	PrintToServer("%i", GetConVarInt(gCV_steamid))
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	PrintToServer("string: %s", sSteamID)
	//if(steamid == GetConVarInt(gCV_steamid))
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		char sCmd[512]
		GetCmdArgString(sCmd, 512)
		int cpnum = StringToInt(sCmd)
		GetClientAbsOrigin(client, gF_vec2cp[cpnum])
		char sQuery[512]
		Format(sQuery, 512, "UPDATE cp SET cpx2 = %f, cpy2 = %f, cpz2 = %f WHERE cpnum = %i AND map = '%s'", gF_vec2cp[cpnum][0], gF_vec2cp[cpnum][1], gF_vec2cp[cpnum][2], cpnum, gS_map)
		//Format(sQuery, 512, "INSERT INTO cp (
		gD_mysql.Query(SQLCPUpdate, sQuery)
	}
	return Plugin_Handled
}

void SQLCPUpdate(Database db, DBResultSet results, const char[] error, any data)
{
}
//https://forums.alliedmods.net/showthread.php?t=261378
Action cmd_manualcp(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `cp` (`id` INT AUTO_INCREMENT, `cpnum` INT, `cpx` FLOAT, `cpy` FLOAT, `cpz` FLOAT, `cpx2` FLOAT, `cpy2` FLOAT, `cpz2` FLOAT, `map` VARCHAR(192),  PRIMARY KEY(id))")
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
		gF_vec1cp[data][0] = results.FetchFloat(0)
		gF_vec1cp[data][1] = results.FetchFloat(1)
		gF_vec1cp[data][2] = results.FetchFloat(2)
		gF_vec2cp[data][0] = results.FetchFloat(3)
		gF_vec2cp[data][1] = results.FetchFloat(4)
		gF_vec2cp[data][2] = results.FetchFloat(5)
		createcp(data)
		gB_haveZone = true
	}
}

void createcp(int cpnum)
{
	char sTriggerName[64]
	Format(sTriggerName, 64, "fakeexpert_cp%i", cpnum)
	char sTriggerName2[64]
	int index
	//int gI_cpCount
	while((index = FindEntityByClassname(index, "trigger_multiple")) != -1) //https://forums.alliedmods.net/showthread.php?t=290655
	{
		GetEntPropString(index, Prop_Data, "m_iName", sTriggerName2, 64)
		if(StrEqual(sTriggerName2, sTriggerName))
			return
	}
	int entity = CreateEntityByName("trigger_multiple")
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	DispatchKeyValue(entity, "targetname", sTriggerName)
	//ActivateEntity(entity)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	float center[3]
	//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
	center[0] = (gF_vec2cp[cpnum][0] + gF_vec1cp[cpnum][0]) / 2.0
	center[1] = (gF_vec2cp[cpnum][1] + gF_vec1cp[cpnum][1]) / 2.0
	center[2] = (gF_vec2cp[cpnum][2] + gF_vec1cp[cpnum][2]) / 2.0
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	mins[0] = (gF_vec1cp[cpnum][0] - gF_vec2cp[cpnum][0]) / 2.0
	if(mins[0] > 0.0)
		mins[0] = mins[0] * -1.0
	mins[1] = (gF_vec1cp[cpnum][1] - gF_vec2cp[cpnum][1]) / 2.0
	if(mins[1] > 0.0)
		mins[1] = mins[1] * -1.0
	mins[2] = -128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	float maxs[3]
	maxs[0] = (gF_vec1cp[cpnum][0] - gF_vec2cp[cpnum][0]) / 2.0
	if(maxs[0] < 0.0)
		maxs[0] = maxs[0] * -1.0
	maxs[1] = (gF_vec1cp[cpnum][1] - gF_vec2cp[cpnum][1]) / 2.0
	if(maxs[1] < 0.0)
		maxs[1] = maxs[1] * -1.0
	maxs[2] = 128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	//PrintToServer("entity end: %i created", entity)
	//return Plugin_Handled
	PrintToServer("Checkpoint number %i is successfuly setup.", cpnum)
}

/*Action cmd_starttouch(int client, int args)
{
	SDKHook(gI_trigger, SDKHook_StartTouch, SDKStartTouch)
	SDKHook(gI_trigger, SDKHook_EndTouch, SDKEndTouch)
	if(IsValidEntity(gI_trigger) && ActivateEntity(gI_trigger) && DispatchSpawn(gI_trigger))
	{
		PrintToServer("Trigger is valid.")
	}
	return Plugin_Handled
}*/

Action cmd_createuser(int args)
{
	char sQuery[512]
	//Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `users` (`id` INT AUTO_INCREMENT, `username` VARCHAR(64), `steamid` INT, `geoipcode2` VARCHAR(64), `firstjoin` INT, `lastjoin` INT, `points` INT, PRIMARY KEY(id))")
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `users` (`id` INT AUTO_INCREMENT, `username` VARCHAR(64), `steamid` INT, `firstjoin` INT, `lastjoin` INT, `points` INT, PRIMARY KEY(id))")
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
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `records` (`id` INT AUTO_INCREMENT, `playerid` INT, `partnerid` INT, `time` FLOAT, `completions` INT, `cp1` FLOAT, `cp2` FLOAT, `cp3` FLOAT, `cp4` FLOAT, `cp5` FLOAT, `cp6` FLOAT, `cp7` FLOAT, `cp8` FLOAT, `cp9` FLOAT, `cp10` FLOAT, `map` VARCHAR(192), `date` INT, PRIMARY KEY(id))")
	gD_mysql.Query(SQLRecordsTable, sQuery)
}

void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successfuly created records table.")
}

/*Action cmd_vectest(int client, int args)
{
	//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, {-6843.03, 4143.97, 1808.03})
	//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, {-7471.97, 3241.55, 1408.03})
	//TeleportEntity(client, {-6843.03, 4143.97, 1808.03}, NULL_VECTOR, NULL_VECTOR)
	//TeleportEntity(client, {-7471.97, 3241.55, 1408.03}, NULL_VECTOR, NULL_VECTOR)
	return Plugin_Handled
}*/

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
		//PrintToServer("EndTouch")
		gB_passzone[other] = true
		gB_passzone[gI_partner[other]] = true
		gB_readyToStart[other] = false
		//gB_readyToStart[gI_other[other
		gB_readyToStart[gI_partner[other]] = false
		for(int i = 1; i <= 10; i++)
		{
			gB_cp[i][other] = false
			gB_cp[i][gI_partner[other]] = false
			gB_cpLock[i][other] = false
			gB_cpLock[i][gI_partner[other]] = false
		}
		/*for(int i = 1; i <= 2048; i++)
		{
			gB_stateDisabled[other][i] = gB_stateDefaultDisabled[i]
			gB_stateDisabled[gI_partner[other]][i] = gB_stateDefaultDisabled[i]
			gF_buttonReady[other][i] = 0.0
			gF_buttonReady[gI_partner[other]][i] = 0.0
		}*/
	}
}

Action SDKStartTouch(int entity, int other)
{
	if(0 < other <= MaxClients && gB_passzone[other])
	{
		//gB_insideZone[other] = true //Expert-Zone idea.
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
			gB_passzone[other] = false
			//gB_zonepass[other
			if(gB_mapfinished[other] && gB_mapfinished[gI_partner[other]])
			{
				//second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
				char sQuery[512]
				int playerid = GetSteamAccountID(other)
				int partnerid = GetSteamAccountID(gI_partner[other])
				char sCPnum[32]
				if(gF_ServerRecord != 0.0)
				{
					if(gF_mateRecord[other] != 0.0)
					{
						if(gF_ServerRecord > gF_Time[other])
						{
							float timeDiff = gF_ServerRecord - gF_Time[other]
							int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
							int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
							int personalSecond = RoundToFloor(gF_Time[other]) % 60
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET time = %f, completions = completions + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s'", gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], GetTime(), playerid, partnerid, playerid, partnerid, gS_map)
							gD_mysql.Query(SQLUpdateRecord, sQuery)
							gF_haveRecord[other] = gF_Time[other]
							gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
							gB_isServerRecord = true
						}
						else if(gF_ServerRecord < gF_Time[other] > gF_mateRecord[other])
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
							int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
							int personalSecond = RoundToFloor(gF_Time[other]) % 60
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET completions = completions + 1 WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s'", playerid, partnerid, playerid, partnerid, gS_map)
							gD_mysql.Query(SQLUpdateRecord, sQuery)
						}
						else if(gF_ServerRecord < gF_Time[other] < gF_mateRecord[other])
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
							int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
							int personalSecond = RoundToFloor(gF_Time[other]) % 60
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "UPDATE records SET time = %f, completions = completions + 1, cp1 = %f, cp2 = %f, cp3 = %f, cp4 = %f, cp5 = %f, cp6 = %f, cp7 = %f, cp8 = %f, cp9 = %f, cp10 = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s'", gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], GetTime(), playerid, partnerid, playerid, partnerid, gS_map)
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
							int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
							int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
							int personalSecond = RoundToFloor(gF_Time[other]) % 60
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, completions, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
							gD_mysql.Query(SQLInsertRecord, sQuery)
							gF_haveRecord[other] = gF_Time[other]
							gF_haveRecord[gI_partner[other]] = gF_Time[other]
							gF_mateRecord[other] = gF_Time[other]
							gF_mateRecord[gI_partner[other]] = gF_Time[other]
							gB_isServerRecord = true
						}
						else
						{
							float timeDiff = gF_Time[other] - gF_ServerRecord
							int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
							int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
							int personalSecond = RoundToFloor(gF_Time[other]) % 60
							int srHour = (RoundToFloor(timeDiff) / 3600) % 24
							int srMinute = (RoundToFloor(timeDiff) / 60) % 60
							int srSecond = RoundToFloor(timeDiff) % 60
							PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
							Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, completions, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, 1, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
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
							if(gF_TimeCP[i][other] < gF_srCPTime[i][other])
							{
								int srCPHour = (RoundToFloor(gF_timeDiffCP[i][other]) / 3600) % 24
								int srCPMinute = (RoundToFloor(gF_timeDiffCP[i][other]) / 60) % 60
								int srCPSecond = RoundToFloor(gF_timeDiffCP[i][other]) % 60
								PrintToChatAll("%s. Checkpoint: -%02.i:%02.i:%02.i", sCPnum, srCPHour, srCPMinute, srCPSecond)
							}
							else
							{
								int srCPHour = (RoundToFloor(gF_timeDiffCP[i][other]) / 3600) % 24
								int srCPMinute = (RoundToFloor(gF_timeDiffCP[i][other]) / 60) % 60
								int srCPSecond = RoundToFloor(gF_timeDiffCP[i][other]) % 60
								PrintToChatAll("%s. Checkpoint: +%02.i:%02.i:%02.i", sCPnum, srCPHour, srCPMinute, srCPSecond)
							}
						}
					}
				}
				else
				{
					//PrintToServer("x123x")
					gF_ServerRecord = gF_Time[other]
					gF_haveRecord[other] = gF_Time[other]
					gF_haveRecord[gI_partner[other]] = gF_Time[other]
					int personalHour = (RoundToFloor(gF_Time[other]) / 3600) % 24
					int personalMinute = (RoundToFloor(gF_Time[other]) / 60) % 60
					int personalSecond = RoundToFloor(gF_Time[other]) % 60
					PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +00:00:00)", other, gI_partner[other], personalHour, personalMinute, personalSecond)
					for(int i = 1; i <= 10; i++)
					{
						IntToString(i, sCPnum, 32)
						if(gB_cp[i][other])
							PrintToChatAll("%s. Checkpoint: +00:00:00", sCPnum)
					}
					gB_isServerRecord = true
					Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, map, date) VALUES (%i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, '%s', %i)", playerid, partnerid, gF_Time[other], gF_TimeCP[1][other], gF_TimeCP[2][other], gF_TimeCP[3][other], gF_TimeCP[4][other], gF_TimeCP[5][other], gF_TimeCP[6][other], gF_TimeCP[7][other], gF_TimeCP[8][other], gF_TimeCP[9][other], gF_TimeCP[10][other], gS_map, GetTime())
					gD_mysql.Query(SQLInsertRecord, sQuery)
				}
				
				//dp.WriteFloat(gF_Time[other]) //https://sm.alliedmods.net/new-api/datapack/DataPack
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
				//gB_cp[i][other] = true
				//if(gB_cp[i][other] && gB_cp[i][gI_partner[other]] && !gB_cpLock[i][other])
				//if(!gB_cpLock[i][other])
				gB_cp[i][other] = true
				if(gB_cp[i][other] && gB_cp[i][gI_partner[other]] && !gB_cpLock[i][other])
				{
					//int hour = RoundToFloor(gF_Time[other])
					//hour = (hour / 3600) % 24
					//int minute = RoundToFloor(gF_Time[other])
					//minute = (minute / 60) % 60
					//int second = RoundToFloor(gF_Time[other])
					//second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
					//PrintToChat(other, "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], hour, minute, second)
					//PrintToChat(gI_partner[other], "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], hour, minute, second)
					//PrintToChatAll("Time: %02.i:%02.i:%02.i %N and %N finished map.", hour, minute, second, other, gI_partner[other])
					//gB_cp[i][other] = true
					gB_cpLock[i][other] = true
					gB_cpLock[i][gI_partner[other]] = true
					gF_TimeCP[i][other] = gF_Time[other]
					//gF_TimeCP[1][gI_partner[other]] = gF_Time[gI_partner[other]]
					gF_TimeCP[i][gI_partner[other]] = gF_Time[other]
					//PrintToServer("%f 2x2", gF_Time[other])
					char sQuery[512] //https://stackoverflow.com/questions/9617453 //https://www.w3schools.com/sql/sql_ref_order_by.asp#:~:text=%20SQL%20ORDER%20BY%20Keyword%20%201%20ORDER,data%20returned%20in%20descending%20order.%20%20More%20
					//Format(sQuery, 512, "SELECT MIN(time), cp%i FROM records WHERE map = '%s' HAVING MIN(time)", i, gS_map) //https://www.encodedna.com/sqlserver/using-sql-server-min-function-inside-where-clause.htm#:~:text=How%20to%20use%20MIN%20function%20inside%20Where%20Clause,use%20the%20MIN%20function%20in%20a%20WHERE%20clause. //https://www.encodedna.com/sqlserver/using-sql-server-min-function-inside-where-clause.htm
					//Format(sQuery, 512, "SELECT cp%i FROM records WHERE map = '%s' ORDER BY time LIMIT 1", i, gS_map)  //log help me alot with this stuff
					Format(sQuery, 512, "SELECT cp%i FROM records", i)
					DataPack dp = new DataPack()
					dp.WriteCell(GetClientSerial(other))
					dp.WriteCell(i)
					gD_mysql.Query(SQLCPSelect, sQuery, dp)
					//PrintToServer("cp1")
				}
				//PrintToServer("cp1pre")
				//gB_cp[1][other] = true
				//gB_cp[1][gI_partner[other]] = true
			}
		}
	}
	//gB_passzone[other] = false
}

/*void SQL123x(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		PrintToServer("123x32maps is lol")
	}
	else
	{
		PrintToServer("paitisnaodsfjslndfkljsdbnflkjn")
	}
}*/

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	PrintToServer("Record updated.")
}

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Record inserted.")
}

void SQLGetMapTier(Database db, DBResultSet results, const char[] error, any data)
{
	if(data == 0)
		return
	int other = GetClientFromSerial(data)
	int clientid = GetSteamAccountID(other)
	int partnerid = GetSteamAccountID(gI_partner[other])
	if(results.FetchRow())
	{
		int tier = results.FetchInt(0)
		int points = tier * 20
		DataPack dp2 = new DataPack()
		dp2.WriteCell(points)
		dp2.WriteCell(clientid)
		dp2.WriteCell(other)
		char sQuery[512]
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", clientid)
		gD_mysql.Query(SQLGetPoints, sQuery, dp2)
		DataPack dp3 = new DataPack()
		dp3.WriteCell(points)
		dp3.WriteCell(partnerid)
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", partnerid)
		gD_mysql.Query(SQLGetPointsPartner, sQuery, dp2)
	}
}

void SQLGetPoints(Database db, DBResultSet results, const char[] error, DataPack dp2)
{
	dp2.Reset()
	int earnedpoints = dp2.ReadCell()
	int clientid = dp2.ReadCell()
	if(results.FetchRow())
	{
		int points = results.FetchInt(0)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE users SET points = %i + %i WHERE steamid = %i", points, earnedpoints, clientid)
		gD_mysql.Query(SQLEarnedPoints, sQuery)
		//PrintToChat(other, "You recived %i points. You have %i points.", earnedpoints, points + earnedpoints)
		//PrintToChat(gI_partner[other], "You recived %i points. You have %i points.", earnedpoints, points + earnedpoints)
	}
}

void SQLGetPointsPartner(Database db, DBResultSet results, const char[] error, DataPack dp3)
{
	dp3.Reset()
	int earnedpoints = dp3.ReadCell()
	int partnerid = dp3.ReadCell()
	if(results.FetchRow())
	{
		int points = results.FetchInt(0)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE users SET points = %i + %i WHERE steamid = %i", points, earnedpoints, partnerid)
		gD_mysql.Query(SQLEarnedPoints, sQuery)
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
		Format(sQuery, 512, "SELECT cp%i FROM records WHERE map = '%s' ORDER BY time LIMIT 1", cpnum, gS_map)
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
		//PrintToServer("123j298bh3testcpfisrtt is goding uyp to tyhe sky and seek dontn make me cry.")
	}
}
/*Action cmd_sum(int client, int args)
{
	float vec[3]
	float vec2[3]
	//DispatchKeyValueVector(trigger, "origin", vec) //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//DispatchSpawn(trigger)
	//GetClientAbsOrigin
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", vec)
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", vec2)
	vec2[1] = vec2[1] += 256.0
	TE_SetupBeamPoints(vec, vec2, gI_beam, gI_halo, 0, 0, 0.1, 1.0, 1.0, 0, 0.0, {255, 255, 255, 75}, 0) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L2612 //Exception reported: Stack leak detected: sp:42876 should be 25228!
	TE_SendToAll(0.0)
	return Plugin_Handled
}*/

Action cmd_createtable(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `zones` (`id` INT AUTO_INCREMENT, `map` VARCHAR(128), `type` INT, `possition_x` FLOAT, `possition_y` FLOAT, `possition_z` FLOAT, `possition_x2` FLOAT, `possition_y2` FLOAT, `possition_z2` FLOAT, `tier` INT, PRIMARY KEY (id))") //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key
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
	gB_pass = true //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-stats.sp#L199
	char sQuery[512]
	Format(sQuery, 512, "SELECT MIN(time) FROM records WHERE map = '%s'", gS_map)
	gD_mysql.Query(SQLGetServerRecord, sQuery)
}

void ForceZonesSetup()
{
	//shavit results null
	//if(results == null)
	//{
		//PrintToServer("Error with mysql connection %s", error)
		//return
	//}
	char sQuery[512]
	Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0", gS_map)
	gD_mysql.Query(SQLSetZoneStart, sQuery)
}

void SQLSetZoneStart(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vec1[0][0] = results.FetchFloat(0)
		gF_vec1[0][1] = results.FetchFloat(1)
		gF_vec1[0][2] = results.FetchFloat(2)
		gF_vec2[0][0] = results.FetchFloat(3)
		gF_vec2[0][1] = results.FetchFloat(4)
		gF_vec2[0][2] = results.FetchFloat(5)
		createstart()
		//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
		//PrintToServer("SQLSetZoneStart successfuly.")
		PrintToServer("Start zone is successfuly setup.")
		char sQuery[512]
		Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1", gS_map)
		gD_mysql.Query(SQLSetZoneEnd, sQuery)
	}
}

void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vec1[1][0] = results.FetchFloat(0)
		gF_vec1[1][1] = results.FetchFloat(1)
		gF_vec1[1][2] = results.FetchFloat(2)
		gF_vec2[1][0] = results.FetchFloat(3)
		gF_vec2[1][1] = results.FetchFloat(4)
		gF_vec2[1][2] = results.FetchFloat(5)
		//PrintToServer("SQLSetZoneEnd: %f %f %f", gF_vec2[1][0], gF_vec2[1][1], gF_vec2[1][2])
		PrintToServer("End zone is successfuly setup.")
		//cmd_createend(0, 0)
		createend()
	}
}

void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Zones table is successfuly created.")
}

/*Action cmd_tp(int client, int args)
{
	//TeleportEntity(client, gI_trigger, NULL_VECTOR, NULL_VECTOR)
	float vecBase[3]
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vecBase)
	PrintToServer("cmd_tp: vecbase: %f %f %f", vecBase[0], vecBase[1], vecBase[2])
	return Plugin_Handled
}*/

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	//gI_entityFlags[client] = GetEntityFlags(client)
	if(buttons & IN_JUMP && !(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(client) & FL_INWATER) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && IsPlayerAlive(client)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
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
	if(gI_boost[client] && gI_skyStep[client])
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
			PrintToServer("sky")
		}
	}
	if(gI_testvec[client])
	{
		gI_testvec[client]++
		float vectest[3]
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vectest)
		PrintToServer("%f %f", vectest[0], vectest[1]) //-340.697296 -1.455074 by tengu boost. -328.707794 -0.779926 by smesh292 nick jurevich boost fix. second time -340.981445 -0.323044 tengu boost fix. right corner. -330.161163 1.097039 by smesh nick jurevich boostfix. third time -281.430755 -0.935560 boost fix by tengu. -272.891448 -0.258201 by smesh292 nick jurevich boost fix. -272.375030 0.000143 by smesh292 tengu boost fix nick jurevich boost fix. -272.669219 -0.776694 smesh292 nick jurevich boost fix. -273.259918 -1.685742 nick jurevich smesh292 boost fix. -273.549072 -0.129200 by smersh292 boost fix tengu bosot fix. smesh292 boostfix. -273.273681 -0.259195 boost fix by nick jurevich smesh292. -272.974426 -0.906334 nick jurevich smesh292 tengu boost fiux tryubng to make same -281 by x coordinate. ] getpossetpos -4592.999023 -496.987518 704.031311;setang -65.097122 0.108658 0.000000
		//i will use x eye coordinate 66. !eye66 get -282.637115 0.000000 on tengu boost fix. (-282.637115 0.000000 tengu boost fix). -274.431518 0.000000 smesh boost fix by nick jurevich. -275.213897 0.000000 nick jureivch boost fix. -276.277801 0.000000 by nick jurevich boost fix. -279.457427 0.000000 on 40.0 boost fix by smesh nick jurevich. -280.093383 0.000000 nick jurevich boost fix. on 50.0. -280.517333 0.000000 on 60.0 nick jurevich. Smesh292. -280.820159 0.000000 on 70.0 by smesh nick jurevich. -281.047241 0.133382 on 80.0 nick jurevich smesh292. -281.047271 0.000000 on 80.0 by smesh292 nick jurevich. -281.223937 0.000000 on 90.0 by smesh292 nick jurevich. right bottom corner. -281.365264 0.000000 100.0 by smesh 292 nick jurevich. -281.789184 0.000000 on 150.0 by smesh292 nick jurevich. -281.728637 0.000000 on 140.0 by smesh292 nick jurevich. -281.658752 0.000000 on 130.0 nick jurevich smesh292. -281.619628 0.000000 on 125.0 nick jurevich Smesh292. -281.635650 0.000000 on 127.0 by nick jurevich smesh292. -281.639556 0.000000 on 127.5 by smesh292 nick jurevich. -281.637603 0.000000 on 127.25 by nick jurevich smesh292. -281.637542 0.000000 on 127.24 by nick jurevich smesh292. -281.637451 0.000000 on 127.23 by nick jurevich smesh922 smehs292. -281.637390 0.000000 on 127.22 by nick jurevich smesh292. -281.637298 0.000000 on 127.21 by nick jurevich smesh292. -281.637237 0.000000 on 127.2 by nick jurevich smesh292. -281.636810 0.000000 on 127.15 by nick jurevich smesh292. -281.636993 0.000000 on 127.17 by nick jurevich smesh292.
		//-281.637145 0.000000 on 127.19 by nick jurevich smesh292. -281.637115 0.000000 on 127.85 by nick jurevich smesh292.
		if(gI_testvec[client] == 10)
			gI_testvec[client] = 0
	}
	//return Plugin_Continue
	//if(IsPlayerAlive(client) && buttons & IN_USE && GetGameTime() - gF_pingDelay[client] > 0.5)
	if(IsPlayerAlive(client))
	{
		if(buttons & IN_USE)
		{
			if(GetEntProp(client, Prop_Data, "m_afButtonPressed"))
				PrintToServer("%i", GetEntProp(client, Prop_Data, "m_afButtonPressed"))
			//if(GetEntProp(client, Prop_Data, "m_afButtonPressed"))
			//	gI_pingTick[client] = 1
			//if(buttons & IN_USE && gI_pingTick[client] > 0)
			gI_pingTick[client]++
		}
		else
			if(gI_pingTick[client] > 0)
				gI_pingTick[client] = 0
		//if(IsPlayerAlive(client) && buttons & IN_USE && GetGameTime() - gF_pingDelay[client] > 0.5)
		//if(IsPlayerAlive(client) && buttons & IN_USE && gI_pingTick[client] == 50)
		if(gI_pingTick[client] == 50)
		{
			//gF_pingDelay[client] = GetGameTime()
			gI_pingTick[client] = 0
			gI_pingModel[client] = CreateEntityByName("prop_dynamic_override") //https://www.bing.com/search?q=prop_dynamic_override&cvid=0babe0a3c6cd43aa9340fa9c3c2e0f78&aqs=edge..69i57.409j0j1&pglt=299&FORM=ANNTA1&PC=U531
			//SetEntProp(ping, Prop_Data, "m_nModelIndex", gI_pingModel)
			SetEntityModel(gI_pingModel[client], "models/fakeexpert/pingtool/pingtool.mdl")
			DispatchSpawn(gI_pingModel[client])
			ActivateEntity(gI_pingModel[client])
			//GetClientAimTarget(
			//https://forums.alliedmods.net/showthread.php?t=152726
			float start[3]
			float angle[3]
			float end[3]
			//float normal[3]
			GetClientEyePosition(client, start)
			GetClientEyeAngles(client, angle)
			TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer, client)
			if(TR_DidHit(INVALID_HANDLE))
				TR_GetEndPosition(end, INVALID_HANDLE)
			TeleportEntity(gI_pingModel[client], end, NULL_VECTOR, NULL_VECTOR)
			CreateTimer(3.0, timer_removePing, gI_pingModel[client], TIMER_FLAG_NO_MAPCHANGE)
		}
	}
}

bool TraceEntityFilterPlayer(int entity, int contentMask, any data)
{
	return entity > MaxClients
}

Action timer_removePing(Handle timer, int ping)
{
	RemoveEntity(ping)
	return Plugin_Stop
}

Action cmd_eye66(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
		TeleportEntity(client, NULL_VECTOR, view_as<float>({-65.097122, 0.0, 0.0}), NULL_VECTOR)
	return Plugin_Handled
}

//Thanks to extremix/hornet for idea from 2019 year summer. Extremix version (if(!(clientOrigin[2] - 5 <= entityOrigin[2] <= clientOrigin[2])) //Calculate for Client/Flash - Thanks to extrem)/tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231//https://forums.alliedmods.net/showthread.php?t=146241

Action cmd_getgud(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	char sCurrentSteamID[64]
	IntToString(steamid, sCurrentSteamID, 64)
	char sSteamID[64]
	GetConVarString(gCV_steamid, sSteamID, 64)
	if(StrEqual(sSteamID, sCurrentSteamID))
	{
		char sGet[32]
		GetCmdArg(args, sGet, 32)
		float result = StringToFloat(sGet)
		gF_getGud = result
		char sArg[32]
		GetCmdArg(args, sArg, 32)
		PrintToServer("%s", sArg)
		gI_getGud = StringToInt(sArg)
		PrintToServer("ToInt: %i", gI_getGud)
		PrintToServer("get gud: %f", gF_getGud)
		//PrintToChat(client, "\x07a71919text") //https://wiki.alliedmods.net/Scripting_FAQ_(SourceMod) https://forums.alliedmods.net/showthread.php?t=307595 https://www.bing.com/search?q=default+color+sourcemod&cvid=be0df2495cd74ba489d75d72194aca7e&aqs=edge..69i57j0l6.3136j0j1&pglt=299&FORM=ANNTA1&PC=U531
		//PrintToChat(client, "\x01text2")
		//PrintToChat(client, "\x02text2")
		//PrintToChat(client, "\x03text2")
		//PrintToChat(client, "\x04text2")
		//PrintToChat(client, "\x05text2")
		//PrintToChat(client, "\x06text2")
		//PrintToChat(client, "\x07text2")
		//PrintToChat(client, "\x08text2")
		//PrintToChat(client, "\x09text2")
		//PrintToChat(client, "\0x01text2")
		//PrintToChat(client, "\0x02text2")
		//PrintToChat(client, "\0x03text2")
		//PrintToChat(client, "\0x04text2")
		PrintToChat(client, "\x07FF4040text21") //red - terrorist
		PrintToChat(client, "\x0799CCFFtext2") //blue - counter-terrorist
		PrintToChat(client, "m_GroupCollision = %i", GetEntProp(client, Prop_Data, "m_CollisionGroup"))
		//https://forums.alliedmods.net/showthread.php?p=1398702?p=1398702#post1398702
		//https://forums.alliedmods.net/showthread.php?t=185016?t=185016
		//https://www.color-hex.com/
		//https://forums.alliedmods.net/showthread.php?t=96831?t=96831
		CancelClientMenu(client, true)
		//char sIP[32]
		//GetClientIP(client, sIP, 32)
		//char sCode2[3]
		//GeoipCode2(sIP, sCode2)
		//PrintToChat(client, "%s", sCode2)
		//SetEntProp(client, Prop_Data, "m_nSkin", 1)
		//SetEntityModel(client, "fakeexpert/models/weapons/v_eq_flashbang.mdl")
		//SetEntityModel(client, "fakeexpert/models/weapons/w_eq_flashbang.mdl")
		//SetEntProp(client, Prop_Send, "m_nModelIndex", gI_vModel)
		//SetEntProp(client, Prop_Send, "m_nModelIndex", gI_wModel)
		//SetEntProp(client, Prop_Data, "m_nSkin", gI_getGud)
		//DispatchKeyValue(client, "skin", sArg)
		//SetEntityRenderColor(client, 255, 0, 0, 255)
		//gI_skin[client] = true
		//https://www.bing.com/search?q=hex+color&cvid=11f4b6fc1a44492a93b6cf985212ee05&aqs=edge.0.0l7.1551j0j1&pglt=43&FORM=ANNTA1&PC=U531
	}
	return Plugin_Handled
}

Action ProjectileBoostFix(int entity, int other)
{
	//if(!IsClientValid(other))
	//	return Plugin_Continue
	//if(!IsClientInGame(other) && !IsPlayerAlive(other))
	//	return Plugin_Continue
	//if(gI_boost[other] || GetEntityFlags(other) & FL_ONGROUND)
	if(!gI_testvec[other] && gF_getGud != 0.0)
		gI_testvec[other] = 1
	//CreateTimer(0.25, Timer_removeflashbangonhit, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE)
	//if(gI_boost[other] || gI_entityFlags[other] & FL_ONGROUND)
		//return Plugin_Continue
	//if(0 < other <= MaxClients && IsClientInGame(other) && IsPlayerAlive(other)) //if 0 < other <= MaxClients continue code. If false stop code.
	//if(!gI_boost[other] || !(gI_entityFlags[other] & FL_ONGROUND))
	if(!(GetEntityFlags(other) & FL_ONGROUND))
	{
		float vecOriginOther[3]
		GetClientAbsOrigin(other, vecOriginOther)
		float vecOriginEntity[3]
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOriginEntity)
		//if(vecOriginOther[2] >= vecOriginEntity[2]) //Thanks to extremix/hornet for idea from 2019 year summer. Extremix version (if(!(clientOrigin[2] - 5 <= entityOrigin[2] <= clientOrigin[2])) //Calculate for Client/Flash - Thanks to extrem)
		//if(0.0 < (deltaOrigin - vecMaxs[2]) < 2.0) //tengu code from github https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L231
		if(vecOriginOther[2] >= vecOriginEntity[2])
		{
			float vecVelClient[3]
			GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", vecVelClient)
			float vecVelEntity[3]
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vecVelEntity)
			//PrintToChatAll("vecVelClient: x: %f, y: %f, z: %f", vecVelClient[0], vecVelClient[1], vecVelClient[2])
			//PrintToChatAll("vecVelEntity: x: %f, y: %f, z: %f", vecVelEntity[0], vecVelEntity[1], vecVelEntity[2])
			gI_boost[other] = 1
			//vecVelClient[1] -= vecVelEntity[1] * 0.97 //!getgud 0.995 !getgud 0.997 !getgud 0.9965 = -281.647888 0.000000 !getgud 0.99645 = -281.633758 0.000000 !getgud 0.99646 = -281.636596 0.000000
			vecVelClient[0] -= vecVelEntity[0] * 0.9964619
			vecVelClient[1] -= vecVelEntity[1] * 0.9964619
			//!getgud 0.996462 = -281.637145 0.000000 !getgud 0.996460 = -281.636596 0.000000 !getgud 0.996462 = -281.637145 0.000000
			//!getgud 0.9964619 = -281.637115 0.000000 code bugging by nick jurevich smesh292
			gF_vecVelBoostFix[other][0] = vecVelClient[0]
			gF_vecVelBoostFix[other][1] = vecVelClient[1]
			gF_vecVelBoostFix[other][2] = FloatAbs(vecVelEntity[2])
			gF_boostTime[other] = GetGameTime()
			gB_groundBoost[other] = gB_bouncedOff[entity]
			SetEntProp(entity, Prop_Send, "m_nSolidType", 0) //https://forums.alliedmods.net/showthread.php?t=286568 non model no solid model Gray83 author of solid model types.
			gI_flash[other] = EntIndexToEntRef(entity) //check this for postthink post to correct set first telelportentity speed. starttouch have some outputs only one of them is coorect wich gives correct other(player) id.
			//PrintToChatAll("start touch %i", count)//Whe just make filter for 0 other id.
			//PrintToChatAll("elastisity of nade: %f", GetEntPropFloat(entity, Prop_Data, "m_flElasticity")) //https://forums.alliedmods.net/showthread.php?t=146241
		}
	}
	return Plugin_Continue
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
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				gF_totalPlayers++
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
		PrintToChatAll("Devmap will be enabled. \"Yes\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[1] / gF_totalPlayers) * 100.0, gF_devmap[1], gF_totalPlayers)
		gB_isDevmap = true
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gF_totalPlayers = 0.0
		CreateTimer(5.0, timer_changelevel)
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] >= gF_devmap[0] && gB_isDevmap)
	{
		PrintToChatAll("Devmap will be continue. \"No\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[1] / gF_totalPlayers) * 100.0, gF_devmap[1], gF_totalPlayers)
		//google translate russian to english.
		gB_isDevmap = true
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gF_totalPlayers = 0.0
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] <= gF_devmap[0] && gB_isDevmap)
	{
		PrintToChatAll("Devmap will be disabled. \"Yes\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[0] / gF_totalPlayers) * 100.0, gF_devmap[0], gF_totalPlayers)
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gB_isDevmap = false
		gF_totalPlayers = 0.0
		CreateTimer(5.0, timer_changelevel)
	}
	if((gF_devmap[1] || gF_devmap[0]) && gF_devmap[1] <= gF_devmap[0] && !gB_isDevmap)
	{
		PrintToChatAll("Devmap will not be enabled. \"No\" chose %0.f%%% or %0.f of %0.f players.", (gF_devmap[0] / gF_totalPlayers) * 100.0, gF_devmap[0], gF_totalPlayers)
		for(int i = 0; i <= 1; i++)
			gF_devmap[i] = 0.0
		gB_isDevmap = false
		gF_totalPlayers = 0.0
	}
	for(int i = 0; i <= 1; i++)
		gF_devmap[i] = 0.0
	gF_totalPlayers = 0.0
	return Plugin_Stop
}

Action timer_changelevel(Handle timer)
{
	ForceChangeLevel(gS_map, "Reason: Devmap")
}

/*Action Timer_removeflashbangonhit(Handle timer, int entityref)
{
	int entity = EntRefToEntIndex(entityref)
	if(entity != INVALID_ENT_REFERENCE)
		AcceptEntityInput(entity, "Kill")
}*/

Action ProjectileBoostFixEndTouch(int entity, int other)
{
	if(!other)
		gB_bouncedOff[entity] = true //get from tengu github tengulawl scriptig boost-fix.sp
}

Action cmd_time(int client, int args)
{
	//Format(sTime, 32, "" //https://forums.alliedmods.net/archive/index.php/t-23912.html //ShAyA format OneEyed format second
	int hour = (RoundToFloor(gF_Time[client]) / 3600) % 24
	int minute = (RoundToFloor(gF_Time[client]) / 60) % 60
	int second = RoundToFloor(gF_Time[client]) % 60
	//gI_second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
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
	if(!IsValidEntity(entity) || !IsPlayerAlive(client))
		return
	//GivePlayerItem(client, "weapon_flashbang")
	SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2)
	//GivePlayerAmmo(client, 2, 48, true)
	gB_silentKnife = true
	FakeClientCommand(client, "use weapon_knife")
	SetEntProp(client, Prop_Data, "m_bDrawViewmodel", 0) //thanks to alliedmodders. 2019 //https://forums.alliedmods.net/archive/index.php/t-287052.html
	ClientCommand(client, "lastinv") //hornet, log idea, main idea Nick Yurevich since 2019, hornet found ClientCommand - lastinv
	//CreateTimer(0.2, timer_draw, client, TIMER_FLAG_NO_MAPCHANGE)
	SetEntProp(client, Prop_Data, "m_bDrawViewmodel", 1)
	CreateTimer(1.5, timer_delete, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE) //sometimes flashbang going to flash, entindextoentref must fix it.
}

void SDKProjectilePost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	if(!IsValidEntity(entity) || !IsPlayerAlive(client))
		return
	if(gB_color[client])
	{
		SetEntProp(entity, Prop_Data, "m_nModelIndex", gI_wModelThrown)
		SetEntProp(entity, Prop_Data, "m_nSkin", 1)
		SetEntityRenderColor(entity, gI_randomInt[client][0], gI_randomInt[client][1], gI_randomInt[client][2], 255)
	}
}

/*Action timer_draw(Handle timer, int client)
{
	if(IsClientInGame(client))
		SetEntProp(client, Prop_Data, "m_bDrawViewmodel", 1)
	return Plugin_Stop
}*/

Action timer_delete(Handle timer, int entity)
{
	entity = EntRefToEntIndex(entity)
	if(IsValidEntity(entity))
	{
		//RemoveEntity(entity)
		AcceptEntityInput(entity, "Kill")
	}
	return Plugin_Stop
}

void SDKPlayerSpawnPost(int client)
{
	//if(GetEntProp(client, Prop_Data, "m_iAmmo", 
	//if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	//{
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
		//GivePlayerItem(client, "weapon_flashbang")
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
		//GivePlayerItem(client, "weapon_flashbang") 
		//EquipPlayerWeapon(client, 26) //26 = weapon_flashbang
		//https://wiki.alliedmods.net/Counter-Strike:_Source_Weapons
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
	//}
	//if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 1)
		//GivePlayerItem(client, "weapon_flashbang")
	//SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2) //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
	//GivePlayerAmmo(client, 2, 48, true)
}

Action SDKOnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR) //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR)
	return Plugin_Handled
}

void SDKWeaponEquipPost(int client, int weapon) //https://sm.alliedmods.net/new-api/sdkhooks/__raw
{
	//char sWeapon[32]
	//GetEntPropString(weapon, Prop_Data, "m_iClassname", sWeapon, 32)
	//GetEdictClassname(wea
	//PrintToServer("equip %i %N %s", weapon, client, sWeapon) //https://www.bing.com/search?q=classname+sourcemod&cvid=5320ed13713b4484a18ef73e7e3f75f6&aqs=edge..69i57j0l6.2216j0j1&pglt=299&FORM=ANNTA1&PC=U531
	//if(IsPlayerAlive(client) && GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	/*if(StrEqual(sWeapon, "weapon_flashbang"))
	{
		//SetEntProp(weapon, Prop_Data, "m_nModelIndex", gI_vModel)
		SetEntProp(weapon, Prop_Data, "m_nModelIndex", gI_wModel)
		SetEntProp(weapon, Prop_Data, "m_nSkin", gI_getGud)
		//char sGetGud[32]
		//IntToString(gI_getGud, sGetGud, 32)
		//DispatchKeyValue(weapon, "skin", sGetGud)
		SetEntityRenderColor(weapon, 255, 0, 0, 255)
		PrintToServer("%s %i %i %N", sWeapon, weapon, client, client)
	}*/
	/*int index
	while((index = FindEntityByClassname(index, "predicted_viewmodel")) != -1) //https://forums.alliedmods.net/showthread.php?t=273885
	{
		int owner = GetEntPropEnt(index, Prop_Data, "m_hOwner")
		if(client == owner)
		{
			SetEntProp(index, Prop_Data, "m_nModelIndex", gI_vModel)
			SetEntProp(index, Prop_Data, "m_nSkin", gI_getGud)
			//SetEntityRenderColor(index, 255, 0, 0, 255)
			continue
		}
		
	}*/
	//DataPack dp = new DataPack()
	//dp.WriteCell(client)
	//dp.WriteCell(weapon)
	//CreateTimer(1.0, timer_skin, dp, TIMER_FLAG_NO_MAPCHANGE)
	if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	{
		GivePlayerItem(client, "weapon_flashbang")
		GivePlayerItem(client, "weapon_flashbang")
	}
}

/*Action timer_skin(Handle timer, DataPack dp)
{
	dp.Reset()
	int client = dp.ReadCell()
	int weapon = dp.ReadCell()
	char sWeapon[32]
	GetEntPropString(weapon, Prop_Data, "m_iClassname", sWeapon, 32)
	if(StrEqual(sWeapon, "weapon_flashbang"))
	{
		//SetEntProp(weapon, Prop_Data, "m_nModelIndex", gI_vModel)
		SetEntProp(weapon, Prop_Data, "m_nModelIndex", gI_wModel)
		SetEntProp(weapon, Prop_Data, "m_nSkin", gI_getGud)
		//char sGetGud[32]
		//IntToString(gI_getGud, sGetGud, 32)
		//DispatchKeyValue(weapon, "skin", sGetGud)
		SetEntityRenderColor(weapon, 255, 0, 0, 255)
		PrintToServer("%s %i %i %N", sWeapon, weapon, client, client)
	}
	return Plugin_Stop
}*/

Action SoundHook(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
{
	if(StrEqual(sample, "weapons/knife/knife_deploy1.wav") && gB_silentKnife)
	{
		gB_silentKnife = false
		return Plugin_Handled
	}
	return Plugin_Continue
}
