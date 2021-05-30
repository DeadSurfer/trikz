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

//bool gB_block[MAXPLAYERS + 1]
int gI_partner[MAXPLAYERS + 1]
float gF_vec1[3]
float gF_vec2[3]
//int gI_beam
//int gI_halo
//#pragma dynamic 3000000 //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L35
//int gI_trigger
//int gI_entity
//Handle gH_mysql //https://forums.alliedmods.net/archive/index.php/t-260008.html
Database gD_mysql
float gF_TimeStart[MAXPLAYERS + 1]
float gF_Time[MAXPLAYERS + 1]
int gI_hour
int gI_minute
int gI_second
bool gB_state[MAXPLAYERS + 1]
char gS_map[192]
//int gI_zonetype
bool gB_mapfinished[MAXPLAYERS + 1]
bool gB_pass
//bool gB_insideZone[MAXPLAYERS + 1]
bool gB_passzone[MAXPLAYERS + 1]
float gF_vecStart[3]
//bool gB_newpass
//bool gB_runcmd[MAXPLAYERS + 1]
//int gI_other[MAXPLAYERS + 1]
//float gI_boostTime[MAXPLAYERS + 1]
//float gF_vecAbs[MAXPLAYERS + 1][3]
//int gI_sky[MAXPLAYERS + 1]
//int gI_frame[MAXPLAYERS + 1]
float gF_fallVel[MAXPLAYERS + 1][3]
bool gB_onGround[MAXPLAYERS + 1]
bool gB_readyToStart[MAXPLAYERS + 1]
//float gF_bestTime
//float gF_personalBest[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "trikz + timer",
	author = "Smesh(Nick Yurevich)",
	description = "Allows to able make trikz more comfortable",
	version = "1.0",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
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
	RegConsoleCmd("sm_tptrigger", cmd_tp)
	RegServerCmd("sm_createtable", cmd_createtable)
	RegConsoleCmd("sm_time", cmd_time)
	RegServerCmd("sm_createusertable", cmd_createuser)
	RegServerCmd("sm_createrecordstable", cmd_createrecords)
	//RegServerCmd("sm_setup", cmd_setup)
	RegConsoleCmd("sm_vecminsend", cmd_vecminsend)
	RegConsoleCmd("sm_vecmaxsend", cmd_vecmaxsend)
	RegConsoleCmd("sm_maptier", cmd_maptier)
	RegServerCmd("sm_manualinsert", cmd_manualinsert)
	//RegConsoleCmd("sm_gent", cmd_gent)
	//RegConsoleCmd("sm_vectest", cmd_vectest)
	//RegConsoleCmd("sm_vectest2", cmd_vectest2)
	//RegConsoleCmd("sm_getenginetime", cmd_getenginetime)
	//RegServerCmd("sm_fakerecord", cmd_fakerecord)
	//RegConsoleCmd("sm_testtext", cmd_testtext)
	AddCommandListener(listenerf1, "autobuy") //https://sm.alliedmods.net/new-api/console/AddCommandListener
	AddNormalSoundHook(SoundHook)
	GetCurrentMap(gS_map, 192)
	//Database.Connect(SQLConnect, "fakeexpert")
	//HookEvent(
}

public void OnMapStart()
{
	//gI_beam = PrecacheModel("materials/sprites/tp_beam001")
	//gI_beam = PrecacheModel("sprites/laserbeam.vmt", true) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L657-L658
	//gI_halo = PrecacheModel("sprites/glow01.vmt", true)
	Database.Connect(SQLConnect, "fakeexpert")
}

//Action eventJump(Event event, const char[] name, bool dontBroadcast) //dontBroadcast = radit vair neradit.
//{
//}

Action listenerf1(int client, const char[] commnd, int argc) //extremix idea.
{
	//Trikz(client)
	//PrintToServer("autobuy")
}

//Action cmd_setup(int args)
/*void setup()
{
	char sQuery[512]
	Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, type, possition_x2, possition_y2, possition_z2 WHERE map = %s", gS_map)
	gD_mysql.Query(SQLSetupZones, sQuery)
}

void SQLSetupZones(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vec1[0] = results.FetchFloat(0)
		gF_vec1[1] = results.FetchFloat(0)
		gF_vec1[2] = results.FetchFloat(0)
		gI_zonetype = results.FetchInt(0)
		gF_vec2[0] = results.FetchFloat(0)
		gF_vec2[1] = results.FetchFloat(0)
		gF_vec2[2] = results.FetchFloat(0)
	}
	PrintToServer("[%f] [%f] [%f] [%i]", gF_vec1[0], gF_vec1[1], gF_vec1[2], gI_zonetype)
	PrintToServer("[%f] [%f] [%f] [%i]", gF_vec2[0], gF_vec2[1], gF_vec2[2], gI_zonetype)
}*/

public void OnClientPutInServer(int client)
{
	gI_partner[client] = 0
	gI_partner[gI_partner[client]] = 0
	SDKHook(client, SDKHook_SpawnPost, SDKPlayerSpawn)
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage)
	SDKHook(client, SDKHook_StartTouch, SDKSkyFix)
	char sQuery[512]
	int steamid = GetSteamAccountID(client)
	//PrintToServer("%i", steamid)
	if(IsClientInGame(client) && gB_pass)
	{
		//int steamid = GetSteamAccountID(client)
		Format(sQuery, 512, "SELECT steamid FROM users WHERE steamid = %i", steamid)
		gD_mysql.Query(SQLAddUser, sQuery, client)
		//Format(sQuery, 512, "SELECT MIN(time) FROM records WHERE (playerid = %i OR partnerid = %i) AND map = '%s'", steamid, steamid, gS_map)
		//gD_mysql.Query(SQLGetRecord, sQuery, GetClientSerial(client))
	}
}

//public void OnDissconnectClient(
public void OnClientDisconnect(int client)
{
	gI_partner[client] = 0
	gI_partner[gI_partner[client]] = 0
}

/*void SQLGetRecord(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientFromSerial(data)
	if(results.FetchRow())
	{
		float time = results.FetchFloat(0)
		gF_personalBest[client] = time
	}
	else
	{
		//gF_
	}
}*/

/*public void OnClinetConnected(int client)
{
	char sQuery[512]
	int steamid = GetSteamAccountID(client)
	if(IsClientInGame(client) && gB_pass)
	{
		Format(sQuery, 512, "SELECT steamid FROM users WHERE steamid = %i", steamid)
		gD_mysql.Query(SQLAddUser, sQuery, GetClientSerial(client))
	}
}*/

void SQLUpdateUsername(Database db, DBResultSet results, const char[] error, any data)
{
}

//void Updateusername(int client)
//{
//}

void SQLAddUser(Database db, DBResultSet results, const char[] error, any data)
{
	int client = data
	if(client == 0)
		return
	int steamid = GetSteamAccountID(client)
	char sQuery[512]
	if(!results.FetchRow())
	{
		Format(sQuery, 512, "INSERT INTO users (steamid) VALUES (%i)", steamid)
		gD_mysql.Query(SQLUserAdded, sQuery, GetClientSerial(data))
	}
	else
	{
		char sName[64]
		GetClientName(client, sName, 64)
		Format(sQuery, 512, "UPDATE users SET username = '%s' WHERE steamid = %i", sName, steamid)
		gD_mysql.Query(SQLUpdateUsername, sQuery)
	}
	//gB_newpass = true
}

void SQLUserAdded(Database db, DBResultSet results, const char[] error, any data)
{
	//int steamid = GetSteamAccountID(GetClientFromSerial(data))
	/*int client = GetClientFromSerial(data)
	int steamid = GetSteamAccountID(client)
	if(IsClientInGame(client))
	{
		char sName[64]
		GetClientName(client, sName, 64)
		char sQuery[512]
		int steamid = GetSteamAccountID(client)
		Format(sQuery, 512, "UPDATE users SET username = '%s' WHERE steamid = %i", sName, steamid)
		gD_mysql.Query(SQLUpdateUsername, sQuery)
	}*/
}

void SDKSkyFix(int client, int other) //client = booster; other = flyer
{
	float vecAbsClient[3]
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", vecAbsClient)
	float vecAbsOther[3]
	GetEntPropVector(other, Prop_Data, "m_vecOrigin", vecAbsOther)
	float vecClientMaxs[3]
	GetEntPropVector(client, Prop_Data, "m_vecMaxs", vecClientMaxs)
	//PrintToServer("delta1: %f %f %f", vecAbsClient[2], vecAbsOther[2], vecClientMaxs[2])
	//PrintToServer("vecMaxs: %f %f %f", vecClientMaxs[0], vecClientMaxs[1], vecClientMaxs[2])
	float delta = vecAbsOther[2] - vecAbsClient[2] - vecClientMaxs[2]
	//SetEntPropVector(other, Prop_Data, "m_vecBaseVelocity", vecAbsOther)
	//PrintToServer("delta: %f", delta)
	//PrintToServer("delta2: %f %f %f", vecAbsClient[2], vecAbsOther[2], vecClientMaxs[2])
	//if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
	if(delta > 0.0 && delta < 2.0)
	{
		//PrintToServer("%i %i ..", client, other)
		//PrintToServer("SDKSkyFix")
		float vecAbs[3]
		GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", vecAbs)
		gF_fallVel[other][0] = vecAbs[0]
		gF_fallVel[other][1] = vecAbs[1]
		vecAbs[2] = FloatAbs(vecAbs[2]) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L84
		//if(vecAbs[2] > 0.0)
		gF_fallVel[other][2] = vecAbs[2] //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L84
		//https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-hud.sp#L918
		//	gI_sky[other] = 1 //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L121
	}
}

Action cmd_trikz(int client, int args)
{
	Trikz(client)
}

void Trikz(int client)
{
	Menu menu = new Menu(trikz_handler)
	menu.SetTitle("Trikz")
	char sDisplay[32]
	//Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
	Format(sDisplay, 32, GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5 ? "Block [v]" : "Block [x]")
	menu.AddItem("block", sDisplay)
	Format(sDisplay, 32, gI_partner[client] ? "Cancel partnership" : "Select partner")
	menu.AddItem("partner", sDisplay)
	menu.AddItem("restart", "Restart")
	menu.Display(client, 20)
}

int trikz_handler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					Block(param1)
					Trikz(param1)
				}
				case 1:
					Partner(param1)
				case 2:
					Restart(param1)
			}
		}
	}
}

//https://forums.alliedmods.net/showthread.php?t=302374

Action cmd_block(int client, int args)
{
	Block(client)
}

Action Block(int client)
{
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
		SetEntityRenderMode(client, RENDER_TRANSALPHA)
		SetEntityRenderColor(client, 255, 255, 255, 75)
		//gB_block[client] = false
		PrintToChat(client, "Block disabled.")
		return Plugin_Handled
	}
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		//gB_block[client] = true
		PrintToChat(client, "Block enabled.")
		return Plugin_Handled
	}
	return Plugin_Continue
}

Action cmd_partner(int client, int args)
{
	Partner(client)
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
						PrintToChat(param1, "Partnersheep agreed with %N.", partner)
						PrintToChat(partner, "You have %N as partner.", param1)
						//Reseta
						Restart(param1)
						Restart(partner) //Expert-Zone idea.
						PrintToServer("partner1: %i %N, partner2: %i %N", gI_partner[param1], gI_partner[param1], gI_partner[partner], gI_partner[partner])
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
				}
			}
		}
	}
}

void Restart(int client)
{
	if(gI_partner[client] != 0)
	{
		//gB_insideZone[client] = true
		//gB_insideZone[gI_partner[client]] = true
		gB_readyToStart[client] = true
		gB_readyToStart[gI_partner[client]] = true
		float vecVel[3]
		//vecVel[0] = 30.0
		//vecVel[1] = 30.0
		//vecVel[2] = 0.0
		TeleportEntity(client, gF_vecStart, NULL_VECTOR, vecVel)
		TeleportEntity(gI_partner[client], gF_vecStart, NULL_VECTOR, vecVel)
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 2)
		SetEntityRenderMode(client, RENDER_TRANSALPHA)
		SetEntityRenderColor(client, 255, 255, 255, 75)
		SetEntProp(gI_partner[client], Prop_Data, "m_CollisionGroup", 2)
		SetEntityRenderColor(gI_partner[client], 255, 255, 255, 75)
		SetEntityRenderMode(gI_partner[client], RENDER_TRANSALPHA)
		CreateTimer(3.0, Timer_BlockToggle, client)
	}
	else
		PrintToChat(client, "You must have a partner.")
}

Action Timer_BlockToggle(Handle timer, int client)
{
	SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
	SetEntityRenderMode(client, RENDER_NORMAL)
	SetEntProp(gI_partner[client], Prop_Data, "m_CollisionGroup", 5)
	//SetEntityRenderColor(gI_partner[client], 255, 255, 255, 75)
	SetEntityRenderMode(gI_partner[client], RENDER_NORMAL)
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
	center[0] = (gF_vec2[0] + gF_vec1[0]) / 2
	center[1] = (gF_vec2[1] + gF_vec1[1]) / 2
	center[2] = (gF_vec2[2] + gF_vec1[2]) / 2
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	mins[0] = FloatAbs((gF_vec1[0] - gF_vec2[0]) / 2.0)
	mins[1] = FloatAbs((gF_vec1[1] - gF_vec2[1]) / 2.0)
	mins[2] = FloatAbs((gF_vec1[2] - gF_vec2[2]) / 2.0)
	mins[0] = mins[0] * 2.0
	mins[0] = -mins[0]
	mins[1] = mins[1] * 2.0
	mins[1] = -mins[1]
	mins[2] = -128.0
	//PrintToServer("mins: %f %f %f", mins[0], mins[1], mins[2])
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	//SetEntPropVector(entity, Prop_Data, "m_vecMins", gF_vec1)
	mins[0] = mins[0] * -1.0
	mins[1] = mins[1] * -1.0
	mins[2] = 128.0
	//PrintToServer("maxs: %f %f %f", mins[0], mins[1], mins[2])
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	//SetEntPropVector(entity, Prop_Data, "m_vecMaxs", gF_vec2)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	SDKHook(entity, SDKHook_EndTouch, SDKEndTouch)
	//PrintToServer("entity start: %i created", entity)
	//return Plugin_Handled
}

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
	center[0] = (gF_vec2[0] + gF_vec1[0]) / 2
	center[1] = (gF_vec2[1] + gF_vec1[1]) / 2
	center[2] = (gF_vec2[2] + gF_vec1[2]) / 2
	TeleportEntity(entity, center, NULL_VECTOR, NULL_VECTOR) ////Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	//TeleportEntity(client, center, NULL_VECTOR, NULL_VECTOR)
	float mins[3]
	mins[0] = FloatAbs((gF_vec1[0] - gF_vec2[0]) / 2.0)
	mins[1] = FloatAbs((gF_vec1[1] - gF_vec2[1]) / 2.0)
	mins[2] = FloatAbs((gF_vec1[2] - gF_vec2[2]) / 2.0)
	mins[0] = mins[0] * 2.0
	mins[0] = -mins[0]
	mins[1] = mins[1] * 2.0
	mins[1] = -mins[1]
	mins[2] = -128.0
	//PrintToServer("mins: %f %f %f", mins[0], mins[1], mins[2])
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	mins[0] = mins[0] * -1.0
	mins[1] = mins[1] * -1.0
	mins[2] = 128.0
	//PrintToServer("maxs: %f %f %f", mins[0], mins[1], mins[2])
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	//PrintToServer("entity end: %i created", entity)
	//return Plugin_Handled
}

Action cmd_vecmins(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	if(steamid == 120192594)
	{
		GetClientAbsOrigin(client, gF_vec1)
		PrintToServer("vec1: %f %f %f", gF_vec1[0], gF_vec1[1], gF_vec1[2])
		char sQuery[512]
		args = 0
		//gI_zonetype = 0
		Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x = '%f', possition_y = '%f', possition_z = '%f' WHERE map = '%s' AND type = '%i';", gS_map, args, gF_vec1[0], gF_vec1[1], gF_vec1[2], gS_map, args)
		gD_mysql.Query(SQLSetZones, sQuery)
	}
	return Plugin_Handled
}

Action cmd_vecminsend(int client, int args)
{
	int steamid = GetSteamAccountID(client)
	if(steamid == 120192594)
	{
		GetClientAbsOrigin(client, gF_vec1)
		//PrintToServer("vec1: %f %f %f", gF_vec1[0], gF_vec1[1], gF_vec1[2])
		char sQuery[512]
		args = 1
		Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec1[0], gF_vec1[1], gF_vec1[2], gS_map, args)
		gD_mysql.Query(SQLSetZones, sQuery)
	}
	return Plugin_Handled
}

Action cmd_maptier(int client, int args)
{
	char sArgString[512]
	GetCmdArgString(sArgString, 512) //https://www.sourcemod.net/new-api/console/GetCmdArgString
	int tier = StringToInt(sArgString)
	PrintToServer("Args: %i", tier)
	char sQuery[512]
	Format(sQuery, 512, "UPDATE zones SET tier = %i WHERE map = '%s' AND type = 0", tier, gS_map)
	gD_mysql.Query(SQLTier, sQuery)
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
	GetClientAbsOrigin(client, gF_vec2)
	//PrintToServer("vec2: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
	char sQuery[512]
	args = 0
	//PrintToServer("%s", gS_map)
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = '%i', possition_x2 = '%f', possition_y2 = '%f', possition_z2 = '%f' WHERE map = '%s' AND type = '%i'", gS_map, args, gF_vec2[0], gF_vec2[1], gF_vec2[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
}

Action cmd_vecmaxsend(int client, int args)
{
	GetClientAbsOrigin(client, gF_vec2)
	//PrintToServer("vec2: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
	char sQuery[512]
	args = 1
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x2 = %f, possition_y2 = %f, possition_z2 = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec2[0], gF_vec2[1], gF_vec2[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
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
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `users` (`id` INT AUTO_INCREMENT, `username` VARCHAR(64), `steamid` INT, `points` INT, PRIMARY KEY(id))")
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
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `records` (`id` INT AUTO_INCREMENT, `playerid` INT, `partnerid` INT, `time` FLOAT, `map` VARCHAR(192), `date` INT, PRIMARY KEY(id))")
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
	//gB_insideZone[other] = false
	//gB_insideZone[other] = false
	//char sTrigger[32]
	//GetEntPropString(entity, Prop_Data, "m_iName", sTrigger, 32)
	//if(StrEqual(sTrigger, "fakeexpert_startzone"))
	{
		//PrintToServer("preStart endtouch.")
		//if(gB_insideZone[other] && gB_insideZone[gI_partner[other]])
		if(gB_readyToStart[other])
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
		}
		//gB_insideZone[other] = false
		//gB_insideZone[gI_partner[other]] = false
	}
}

//void SDKStartTouch(int entity, int other)
Action SDKStartTouch(int entity, int other)
{
	//PrintToServer("%i %i", entity, other)
	//if(0 < other <= MaxClients && !gB_state[other])
		//Restart(other)
	if(0 < other <= MaxClients && gB_passzone[other])
	{
		//if(!gB_state[other])
		//	Restart(other)
		//gB_insideZone[other] = true //Expert-Zone idea.
		//gB_passzone[other] = false
		//PrintToServer("%i", other)
		//PrintToServer("SDKStartTouch %i %i", entity, other)
		
		char sTrigger[32]
		
		GetEntPropString(entity, Prop_Data, "m_iName", sTrigger, 32)
		//if(StrEqual(strigger
		
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
				int hour = RoundToFloor(gF_Time[other])
				hour = hour / 360
				int minute = RoundToFloor(gF_Time[other])
				minute = (minute / 60) % 24
				int second = RoundToFloor(gF_Time[other])
				second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
				//PrintToChat(other, "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], hour, minute, second)
				//PrintToChat(gI_partner[other], "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], hour, minute, second)
				//PrintToChatAll("Time: %02.i:%02.i:%02.i %N and %N finished map.", hour, minute, second, other, gI_partner[other])
				char sQuery[512]
				//Format(sQuerySR, 512, "SELECT time FROM records WHERE ")
				//Format(sQuery, 512, "INSERT
				Format(sQuery, 512, "SELECT map FROM records")
				//DataPack dp3.WriteCell(gF_Time[other])
				//DataPack dp3.WriteCell
				DataPack dp = new DataPack()
				dp.WriteFloat(gF_Time[other])
				dp.WriteCell(GetClientSerial(other))
				gD_mysql.Query(SQLSR, sQuery, dp)
				//PrintTo
				//int clientid = GetSteamAccountID(other)
				//int partnerid = GetSteamAccountID(gI_partner[other])
				//PrintToServer("%i %i", clientid, partnerid)
				//shavit - datapack
				//DataPack dp = new DataPack()
				//dp.WriteCell(GetClientSerial(other))
				//dp.WriteCell(other[)
				//dp.WriteCell(GetClientSerial(gI_partner[other]))
				//PrintToServer("client: %i %N, partner: %i %N", other, other, gI_partner[other], gI_partner[other])
				//dp.WriteFloat(gF_Time[other]) //https://sm.alliedmods.net/new-api/datapack/DataPack
				//char sQuery[512]
				//Format(sQuery, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s'", clientid, partnerid, partnerid, clientid, gS_map)
				//gD_mysql.Query(SQLRecords, sQuery, dp)
				//DataPack dp2 = new DataPack()
				//dp2.WriteCell(clientid)
				//dp2.WriteCell(partnerid)
				//dp2.WriteCell(GetClientSerial(other))
				//PrintToServer("%i other", other)
				Format(sQuery, 512, "SELECT tier FROM zones WHERE map = '%s' AND type = 0", gS_map)
				gD_mysql.Query(SQLGetMapTier, sQuery, GetClientSerial(other))
			}
		}
	}
	//gB_passzone[other] = false
}

void SQLSR(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	float timeClient = dp.ReadFloat()
	int other = GetClientFromSerial(dp.ReadCell())
	int playerid = GetSteamAccountID(other)
	int partnerid = GetSteamAccountID(gI_partner[other])
	//PrintToServer("%i %i %i %N", playerid, partnerid, other, other)
	char sQuery[512]
	if(results.FetchRow())
	{
		//PrintToServer("1")
		char sMap[192]
		results.FetchString(0, sMap, 192)
		if(StrEqual(gS_map, sMap))
		{
			Format(sQuery, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s';", playerid, partnerid, playerid, partnerid, gS_map)
			DataPack dp2 = new DataPack()
			dp2.WriteCell(GetClientSerial(other))
			dp2.WriteFloat(timeClient)
			gD_mysql.Query(SQLUpdateRecord, sQuery, dp2)
		}
	}
	else
	{
		int personalHour = RoundToFloor(timeClient) / 60
		int personalMinute = (RoundToFloor(timeClient) / 60) % 24
		int personalSecond = RoundToFloor(timeClient) % 60
		PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. \0x04(SR -00:00:00)", other, gI_partner[other], personalHour, personalMinute, personalSecond)
		//PrintToServer("2")
		DataPack dp2 = new DataPack()
		dp2.WriteCell(GetClientSerial(other))
		dp2.WriteFloat(timeClient)
		Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, map, date) VALUES (%i, %i, %f, '%s', %i)", playerid, partnerid, timeClient, gS_map, GetTime())
		gD_mysql.Query(SQLInsertRecord, sQuery, dp2)
	}
}

/*Action cmd_fakerecord(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO records (date) VALUES (%i);", GetTime())
	gD_mysql.Query(SQLFakeRecord, sQuery)
}

void SQLFakeRecord(Database db, DBResultSet results, const char[] error, any data)
{
}*/

/*Action cmd_getenginetime(int client, int args)
{
	PrintToServer("%f", GetEngineTime())
	return Plugin_Handled
}*/

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset() //shavit.wr 1395
	int other = GetClientFromSerial(dp.ReadCell()) //shavit.wr 1396
	float timeClient = dp.ReadFloat()
	int playerid = GetSteamAccountID(other)
	int partnerid = GetSteamAccountID(gI_partner[other])
	//PrintToChatAll
	char sQuery[512]
	if(results.FetchRow())
	{
		//float record = results.FetchFloat(0) //https://pastebin.com/nhWqErZc 1667
		//PrintToServer("123xx123xs: %f", record)
		DataPack dp4 = new DataPack()
		dp4.WriteFloat(timeClient)
		dp4.WriteCell(GetClientSerial(other))
		Format(sQuery, 512, "SELECT MIN(time) FROM records")
		gD_mysql.Query(SQLUpdateRecord2, sQuery, dp4)
	}
	else
	{
		int personalHour = RoundToFloor(timeClient) / 60
		int personalMinute = (RoundToFloor(timeClient) / 60) % 24
		int personalSecond = RoundToFloor(timeClient) % 60
		PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -00:00:00)", other, gI_partner[other], personalHour, personalMinute, personalSecond)
		//PrintToServer("x1 %f", timeClient)
		DataPack dp3 = new DataPack()
		dp3.WriteFloat(timeClient)
		dp3.WriteCell(GetClientSerial(other))
		Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, map, date) VALUES (%i, %i, %f, '%s', %i)", playerid, partnerid, timeClient, gS_map, GetTime())
		gD_mysql.Query(SQLUpdateRecordCompelete, sQuery, dp3)
	}
	//PrintToServer("%i %N", other, other)
	//PrintToServer("Record updated.")
}

void SQLUpdateRecord2(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	float timeClient = dp.ReadFloat()
	int other = GetClientFromSerial(dp.ReadCell())
	//PrintToServer("%i %N", other, other)
	int playerid = GetClientFromSerial(other)
	int partnerid = GetClientFromSerial(other)
	char sQuery[512]
	if(results.FetchRow())
	{
		float srTime = results.FetchFloat(0)
		if(timeClient < srTime)
		{
			float timeDiff = FloatAbs(srTime - timeClient)
			//PrintToServer("2x2x2: %f", timeDiff)
			//float timeDiff = FloatAbs(timeClient - srTime)
			int personalHour = RoundToFloor(timeClient) / 60
			int personalMinute = (RoundToFloor(timeClient) / 60) % 24
			int personalSecond = RoundToFloor(timeClient) % 60
			int srHour = RoundToFloor(timeDiff) / 60
			int srMinute = (RoundToFloor(timeDiff) / 60) % 24
			int srSecond = RoundToFloor(timeDiff) % 60
			PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR -%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
			Format(sQuery, 512, "UPDATE records SET time = %f, date = %i WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i)) AND map = '%s'", timeClient, GetTime(), playerid, partnerid, playerid, partnerid, gS_map)
			gD_mysql.Query(SQLUpdateRecordCompelete, sQuery)
		}
		else
		{
			float timeDiff = FloatAbs(srTime - timeClient)
			//float timeDiff = FloatAbs(timeClient - srTime)
			int personalHour = RoundToFloor(timeClient) / 60
			int personalMinute = (RoundToFloor(timeClient) / 60) % 24
			int personalSecond = RoundToFloor(timeClient) % 60
			int srHour = RoundToFloor(timeDiff) / 60
			int srMinute = (RoundToFloor(timeDiff) / 60) % 24
			int srSecond = RoundToFloor(timeDiff) % 60
			PrintToChatAll("%N and %N finished map in %02.i:%02.i:%02.i. (SR +%02.i:%02.i:%02.i)", other, gI_partner[other], personalHour, personalMinute, personalSecond, srHour, srMinute, srSecond)
		}
	}
}

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	//PrintToServer("Record inserted.")
}

void SQLUpdateRecordCompelete(Database db, DBResultSet results, const char[] error, DataPack dp)
{
}

/*Action cmd_testtext(int client, int args)
{
	PrintToChat(client, "%N and %N finished map in 05:04:22. (SR -00:00:00)", client, client)
	PrintToChat(client, "%N and %N finished map in 05:04:22. (SR +00:00:00)", client, client)
	return Plugin_Handled
}*/

void SQLGetMapTier(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	//int clientid = dp.ReadCell()
	//int partnerid = dp.ReadCell()
	int other = dp.ReadCell()
	int clientid = GetSteamAccountID(other)
	int partnerid = GetSteamAccountID(other)
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
	//PrintToServer("Debug")
	dp2.Reset()
	int earnedpoints = dp2.ReadCell()
	int clientid = dp2.ReadCell()
	//int other = GetClientFromSerial(dp2.ReadCell())
	//PrintToServer("SQLGetPoints: %i [%N]", other, other)
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
	ForceZonesSetup()
	gB_pass = true
}

Action cmd_manualinsert(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "INSERT INTO zones (map, type) VALUES ('%', 0)", gS_map)
	gD_mysql.Query(SQLManualInsert, sQuery)
	Format(sQuery, 512, "INSERT INTO zones (map, type) VALUES ('%s', 1)", gS_map)
	gD_mysql.Query(SQLManualInsert, sQuery)
}

void SQLManualInsert(Database db, DBResultSet results, const char[] error, any data)
{
}

//void SQLForceZonesSetup(Database db, DBResultSet results, const char[] error, any data)
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
	gD_mysql.Query(SQLSetZonesEntity, sQuery)
}

void SQLSetZonesEntity(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vec1[0] = results.FetchFloat(0)
		gF_vec1[1] = results.FetchFloat(1)
		gF_vec1[2] = results.FetchFloat(2)
		gF_vec2[0] = results.FetchFloat(3)
		gF_vec2[1] = results.FetchFloat(4)
		gF_vec2[2] = results.FetchFloat(5)
		//cmd_createstart(0, 0)
		createstart()
		//https://stackoverflow.com/questions/4355894/how-to-get-center-of-set-of-points-using-python
		float center[3]
		center[0] = (gF_vec2[0] + gF_vec1[0]) / 2
		center[1] = (gF_vec2[1] + gF_vec1[1]) / 2
		center[2] = (gF_vec2[2] + gF_vec1[2]) / 2
		//gF_vecStart[0] = gF_vec1[0]
		//gF_vecStart[1] = gF_vec1[1]
		gF_vecStart[0] = center[0]
		gF_vecStart[1] = center[1]
		gF_vecStart[2] = center[2]
		PrintToServer("SQLSetZonesEntity successfuly.")
		char sQuery[512]
		Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1", gS_map)
		gD_mysql.Query(SQLSetZoneEnd, sQuery)
	}
}

void SQLSetZoneEnd(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		gF_vec1[0] = results.FetchFloat(0)
		gF_vec1[1] = results.FetchFloat(1)
		gF_vec1[2] = results.FetchFloat(2)
		gF_vec2[0] = results.FetchFloat(3)
		gF_vec2[1] = results.FetchFloat(4)
		gF_vec2[2] = results.FetchFloat(5)
		PrintToServer("SQLSetZoneEnd: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
		//cmd_createend(0, 0)
		createend()
	}
}

public void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Success")
}

Action cmd_tp(int client, int args)
{
	//TeleportEntity(client, gI_trigger, NULL_VECTOR, NULL_VECTOR)
	float vecBase[3]
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vecBase)
	PrintToServer("cmd_tp: vecbase: %f %f %f", vecBase[0], vecBase[1], vecBase[2])
	return Plugin_Handled
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(buttons & IN_JUMP && !(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(client) & FL_INWATER) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && IsPlayerAlive(client)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
		buttons &= ~IN_JUMP //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
	if(buttons & IN_LEFT || buttons & IN_RIGHT)//https://sm.alliedmods.net/new-api/entity_prop_stocks/__raw Expert-Zone idea.
		KickClient(client, "Don't use joystick") //https://sm.alliedmods.net/new-api/clients/KickClient
	//Timer
	//if(gB_state[client] && gB_mapfinished[client] && gB_mapfinished[gI_partner[client]])
	if(gB_state[client])
	{
		gF_Time[client] = GetEngineTime()
		gF_Time[client] = gF_Time[client] - gF_TimeStart[client]
		//if(!gB_mapfinished[client])
			//gB_state[client] = false
	}
	int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity") //Skipper idea.
	if(0 < groundEntity <= MaxClients && IsPlayerAlive(groundEntity)) //client - flyer, booster - groundEntity
	{
		//if(++gI_frame[client] >= 5) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L91
		float fallVel[3]
		fallVel[0] = gF_fallVel[client][0]
		fallVel[1] = gF_fallVel[client][1]
		fallVel[2] = gF_fallVel[client][2] * 4.0
		if(buttons & IN_JUMP)
		{
			if(fallVel[2] > 800.0)
				fallVel[2] = 800.0
			if(fallVel[2] <= 800.0 && !(GetEntityFlags(groundEntity) & FL_ONGROUND) && !(buttons & IN_DUCK))
			{
				if(gB_onGround[client])
				{
					//if(!(GetEntProp(client, Prop_Data, "m_bDucked", 4) > ||  //Log's idea.
					//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fallVel)
					//PrintToServer("%f", fallVel[2])
				}
				if(groundEntity == 0)
					gB_onGround[client] = false
				if(groundEntity > 0) // expert zone idea.
					gB_onGround[client] = true
			}
		}
	}
}

/*Action cmd_gent(int client, int args)
{
	int gEnt = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity")
	PrintToServer("%i", gEnt)
	return Plugin_Handled
}*/

/*Action ProjectileBoostFix1(int entity, int other)
{
	float vecOriginClient[3]
	GetEntPropVector(other, Prop_Data, "m_vecOrigin", vecOriginClient)
	float vecOriginEntity[3]
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vecOriginEntity)
	float deltaOrigin = vecOriginClient[2] - vecOriginEntity[2]
	//PrintToServer("1. %f", deltaOrigin)
	float vecMaxsEntity[3]
	GetEntPropVector(entity, Prop_Data, "m_vecMaxs", vecMaxsEntity)
	PrintToServer("%f", deltaOrigin - vecMaxsEntity[2])
	//if(deltaOrigin - vecMaxsEntity[2] == 0.031250 && deltaOrigin - vecMaxsEntity[2] == 2.031250)
	//if(deltaOrigin - vecMaxsEntity[2] == 0.031250)
	if(0.031250 <= (deltaOrigin - vecMaxsEntity[2]) <= 2.031250)
	{
		float vecVelClient[3]
		GetEntPropVector(other, Prop_Data, "m_vecVelocity", vecVelClient)
		float vecVelEntity[3]
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vecVelEntity)
		PrintToChatAll("vecVelClient: x: %f, y: %f, z: %f", vecVelClient[0], vecVelClient[1], vecVelClient[2])
		PrintToChatAll("vecVelEntity: x: %f, y: %f, z: %f", vecVelEntity[0], vecVelEntity[1], vecVelEntity[2])
		//if(vecVelClient[2] < 0.0)
		//	vecVelClient[2] = vecVelClient[2] * -1.0
		//if(vecVelEntity[2] < 0.0)
		//	vecVelEntity[2] = vecVelEntity[2] * -1.0
		float correctVel[3]
		correctVel[0] = 0.0
		correctVel[1] = 0.0
		correctVel[2] = vecVelClient[2] + vecVelEntity[2]
		if(vecVelClient[0] < 0.0 && vecVelEntity[0] < 0.0)
			vecVelClient[0] = vecVelClient[0] + vecVelEntity[0]
		if(vecVelClient[0] > 0.0 && vecVelEntity[0] > 0.0)
			vecVelClient[0] = vecVelClient[0] - vecVelEntity[0]
		if(vecVelClient[0] < 0.0 && vecVelEntity[0] > 0.0)
			vecVelClient[0] = vecVelClient[0] - vecVelEntity[0] * -1.0
		if(vecVelClient[0] > 0.0 && vecVelEntity[0] < 0.0)
			vecVelClient[0] = vecVelClient[0] + vecVelEntity[0] * -1.0

		if(vecVelClient[1] < 0.0 && vecVelEntity[1] < 0.0)
			vecVelClient[1] = vecVelClient[1] + vecVelEntity[1]
		if(vecVelClient[1] > 0.0 && vecVelEntity[1] > 0.0)
			vecVelClient[1] = vecVelClient[1] - vecVelEntity[1]
		if(vecVelClient[1] < 0.0 && vecVelEntity[1] > 0.0)
			vecVelClient[1] = vecVelClient[1] - vecVelEntity[1] * -1.0
		if(vecVelClient[1] > 0.0 && vecVelEntity[1] < 0.0)
			vecVelClient[1] = vecVelClient[1] + vecVelEntity[1] * -1.0
			
		//if(vecVelClient[2] < 0.0 && vecVelEntity[2] < 0.0)
		//	vecVelClient[2] = vecVelEntity[2]
		//if(vecVelClient[2] > 0.0 && vecVelEntity[2] > 0.0)
		//	vecVelClient[2] = vecVelEntity[2]
		//if(vecVelClient[2] < 0.0 && vecVelEntity[2] > 0.0)
		//	vecVelClient[2] = vecVelEntity[2] * -1.0
		//if(vecVelClient[2] > 0.0 && vecVelEntity[2] < 0.0)
		//	vecVelClient[2] = vecVelEntity[2] * -1.0
		//if(vecVelEntity[2] < 0.0)
		//	vecVelClient[2] = vecVelClient[2]
		//if(vecVelEntity[2] < 0.0)
		//	vecVelEntity[2] = vecVel
		//if(vecVelEntity[2] < 0.0)
		//	vecVelClient[2] = vecEntity
		if(vecVelEntity[2] < 0.0)
			vecVelClient[2] = vecVelEntity[2] * -1.0
		else
			vecVelClient[2] = vecVelEntity[2]
		//vecVelClient[2] = 
		//vecVelClient[2] = 
		//gB_getBoost[other] = true
		//TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, correctVel)
		TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, vecVelClient)
		//PrintToServer("feet collide.")
	}
}*/

Action ProjectileBoostFix(int entity, int other)
{
	float vecOriginOther[3]
	GetEntPropVector(other, Prop_Data, "m_vecOrigin", vecOriginOther)
	float vecOriginEntity[3]
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vecOriginEntity)
	float deltaOrigin = vecOriginOther[2] - vecOriginEntity[2]
	float vecMins[3]
	GetEntPropVector(other, Prop_Data, "m_vecMins", vecMins)
	//PrintToServer("%f", deltaOrigin - vecMins[2])
	if(4.031250 >= (deltaOrigin - vecMins[2]) >= 2.031250)
	{
		float vecVelClient[3]
		GetEntPropVector(other, Prop_Data, "m_vecVelocity", vecVelClient)
		float vecVelEntity[3]
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vecVelEntity)
		//PrintToChatAll("vecVelClient: x: %f, y: %f, z: %f", vecVelClient[0], vecVelClient[1], vecVelClient[2])
		//PrintToChatAll("vecVelEntity: x: %f, y: %f, z: %f", vecVelEntity[0], vecVelEntity[1], vecVelEntity[2])
		if(vecVelClient[0] < 0.0 && vecVelEntity[0] < 0.0)
			vecVelClient[0] = vecVelClient[0] + vecVelEntity[0]
		if(vecVelClient[0] > 0.0 && vecVelEntity[0] > 0.0)
			vecVelClient[0] = vecVelClient[0] - vecVelEntity[0]
		if(vecVelClient[0] < 0.0 && vecVelEntity[0] > 0.0)
			vecVelClient[0] = vecVelClient[0] - vecVelEntity[0] * -1.0
		if(vecVelClient[0] > 0.0 && vecVelEntity[0] < 0.0)
			vecVelClient[0] = vecVelClient[0] + vecVelEntity[0] * -1.0

		if(vecVelClient[1] < 0.0 && vecVelEntity[1] < 0.0)
			vecVelClient[1] = vecVelClient[1] + vecVelEntity[1]
		if(vecVelClient[1] > 0.0 && vecVelEntity[1] > 0.0)
			vecVelClient[1] = vecVelClient[1] - vecVelEntity[1]
		if(vecVelClient[1] < 0.0 && vecVelEntity[1] > 0.0)
			vecVelClient[1] = vecVelClient[1] - vecVelEntity[1] * -1.0
		if(vecVelClient[1] > 0.0 && vecVelEntity[1] < 0.0)
			vecVelClient[1] = vecVelClient[1] + vecVelEntity[1] * -1.0
		
		if(vecVelEntity[2] < 0.0)
			vecVelClient[2] = vecVelEntity[2] * -1.0
		else
			vecVelClient[2] = vecVelEntity[2]
		//TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, vecVelClient)
	}
}

/*Action cmd_vectest2(int client, int args)
{
	PrintToServer("%f", 2.0 * -1.0 - 1.0)
	return Plugin_Handled
}*/

Action cmd_time(int client, int args)
{
	//char sTime[32]
	//FormatTime(sTime, 32, NULL_STRING, )
	//if(gF_Time[client] > 59.9)
	//Format(sTime, 32, "" //https://forums.alliedmods.net/archive/index.php/t-23912.html
	int hour = RoundToFloor(gF_Time[client])
	gI_hour = hour / 360
	int minute = RoundToFloor(gF_Time[client])
	gI_minute = (minute / 60) % 24
	int second = RoundToFloor(gF_Time[client])
	gI_second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
	PrintToChat(client, "Time: %f [%02.i:%02.i:%02.i]", gF_Time[client], gI_hour, gI_minute, gI_second)
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
	{
		SDKHook(entity, SDKHook_Spawn, SDKProjectile)
		SDKHook(entity, SDKHook_StartTouch, ProjectileBoostFix)
	}
}

Action SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	
	if(!IsValidEntity(entity) || !IsPlayerAlive(client))
		return
	//if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo"),
	//GivePlayerItem(client, "weapon_flashbang")
	SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2)
	//GivePlayerAmmo(client, 2, 48, true)
	FakeClientCommand(client, "use weapon_knife")
	ClientCommand(client, "lastinv") //hornet, log idea, main idea Nick Yurevich since 2019, hornet found ClientCommand - lastinv
	CreateTimer(1.5, timer_delete, entity)
}

Action timer_delete(Handle timer, int entity)
{
	if(IsValidEntity(entity))
		RemoveEntity(entity)
}

void SDKPlayerSpawn(int client)
{
	//if(GetEntProp(client, Prop_Data, "m_iAmmo", 
	if(GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4) == 0)
	{
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
		GivePlayerItem(client, "weapon_flashbang")
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
		GivePlayerItem(client, "weapon_flashbang")
		//PrintToServer("%i", GetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4))
	}
	SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2) //https://forums.alliedmods.net/showthread.php?t=114527 https://forums.alliedmods.net/archive/index.php/t-81546.html
	//GivePlayerAmmo(client, 2, 48, true)
}

Action SDKOnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngle", NULL_VECTOR) //https://forums.alliedmods.net/showthread.php?p=1687371
	SetEntPropVector(victim, Prop_Send, "m_vecPunchAngleVel", NULL_VECTOR)
	return Plugin_Handled
}

Action SoundHook(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed) //https://github.com/alliedmodders/sourcepawn/issues/476
{
	if(StrEqual(sample, "weapons/knife/knife_deploy1.wav"))
		return Plugin_Handled
	return Plugin_Continue
}
