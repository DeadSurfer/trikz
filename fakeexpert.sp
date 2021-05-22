#include <sdktools>
#include <sdkhooks>

bool gB_block[MAXPLAYERS + 1]
int gI_partner[MAXPLAYERS + 1]
float gF_vec1[3]
float gF_vec2[3]
int gI_beam
int gI_halo
//#pragma dynamic 3000000 //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L35
int gI_trigger
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
int gI_zonetype

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
	RegConsoleCmd("sm_createstart", cmd_createstart)
	RegConsoleCmd("sm_createend", cmd_createend)
	//RegConsoleCmd("sm_1", cmd_create)
	RegConsoleCmd("sm_vecmins", cmd_vecmins)
	RegConsoleCmd("sm_2", cmd_vecmins)
	RegConsoleCmd("sm_vecmaxs", cmd_vecmaxs)
	RegConsoleCmd("sm_3", cmd_vecmaxs)
	RegConsoleCmd("sm_starttouch", cmd_starttouch)
	RegConsoleCmd("sm_4", cmd_starttouch)
	RegConsoleCmd("sm_sum", cmd_sum)
	//RegConsoleCmd("sm_getid", cmd_getid)
	RegConsoleCmd("sm_tptrigger", cmd_tp)
	RegServerCmd("sm_createtable", cmd_createtable)
	RegConsoleCmd("sm_time", cmd_time)
	RegServerCmd("sm_createusertable", cmd_createuser)
	RegServerCmd("sm_createrecordstable", cmd_createrecords)
	RegServerCmd("sm_setup", cmd_setup)
	RegConsoleCmd("sm_vecminsend", cmd_vecminsend)
	RegConsoleCmd("sm_vecmaxsend", cmd_vecmaxsend)
	RegConsoleCmd("sm_maptier", cmd_maptier)
	AddNormalSoundHook(SoundHook)
	GetCurrentMap(gS_map, 192)
	//Database.Connect(SQLConnect, "fakeexpert")
}

public void OnMapStart()
{
	//gI_beam = PrecacheModel("materials/sprites/tp_beam001")
	gI_beam = PrecacheModel("sprites/laserbeam.vmt", true) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L657-L658
	gI_halo = PrecacheModel("sprites/glow01.vmt", true)
	Database.Connect(SQLConnect, "fakeexpert")
	//char sQuery[512]
	//Format(sQuery, 512, "SELECT 
	//CreateTimer(1.0, Timer_ZonesSetup)
}

Action cmd_setup(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, type, possition_x2, possition_y2, possition_z2 WHERE map = %s", gS_map)
	gD_mysql.Query(SQLSetupZones, sQuery)
}

//Action Timer_ZonesSetup(Handle timer)
//{

//}

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
}

public void OnClientPutInServer(int client)
{
	gI_partner[client] = 0
	gI_partner[gI_partner[client]] = 0
	SDKHook(client, SDKHook_SpawnPost, SDKPlayerSpawn)
	SDKHook(client, SDKHook_OnTakeDamage, SDKOnTakeDamage)
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
	Format(sDisplay, 32, gB_block[client] ? "Block [v]" : "Block [x]")
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
			}
		}
	}
}

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
		gB_block[client] = false
		PrintToChat(client, "Block disabled.")
		return Plugin_Handled
	}
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		gB_block[client] = true
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
			if(IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
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
			menu2.AddItem(sItem, "Yes")
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
			char sItem[32]
			menu.GetItem(param2, sItem, 32)
			int partner = StringToInt(sItem)
			switch(param2)
			{
				case 0:
				{
					if(gI_partner[partner] == 0)
					{
						gI_partner[param1] = partner
						gI_partner[partner] = param1
						PrintToChat(param1, "Partnersheep agreed with %N.", partner)
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
				}
			}
		}
	}
}

Action cmd_createstart(int client, int args)
{
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
	mins[0] = mins[0] * -1.0
	mins[1] = mins[1] * -1.0
	mins[2] = 128.0
	//PrintToServer("maxs: %f %f %f", mins[0], mins[1], mins[2])
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", mins)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	PrintToServer("entity: %i created", entity)
	//PrintToServer("%i", args)
	//char sQuery[512]
	//if(args)
	///	Format(sQuery, 512, "UPDATE zones SET type = %i", args)
	//else
	//	Format(sQuery, 512, "UPDATE zones SET type = %i", args)
	//gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
}

Action cmd_createend(int client, int args)
{
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
	PrintToServer("entity: %i created", entity)
	return Plugin_Handled
}

Action cmd_vecmins(int client, int args)
{
	GetClientAbsOrigin(client, gF_vec1)
	PrintToServer("vec1: %f %f %f", gF_vec1[0], gF_vec1[1], gF_vec1[2])
	char sQuery[512]
	args = 0
	//gI_zonetype = 0
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec1[0], gF_vec1[1], gF_vec1[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
}

Action cmd_vecminsend(int client, int args)
{
	GetClientAbsOrigin(client, gF_vec1)
	PrintToServer("vec2: %f %f %f", gF_vec1[0], gF_vec1[1], gF_vec1[2])
	char sQuery[512]
	args = 1
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec1[0], gF_vec1[1], gF_vec1[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
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
	//char sQuery[512]
	//if(results.FetchRow())
	//{
		//char sMap[192]
		//results.FetchString(0, sMap, 192)
		//if(StrEqual(sMap, gS_map))
		//if(
		//{
			//PrintToServer("Select successfuly completed.")
			//Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x = %f, possition_y = %f, possition_z = %f", gS_map, gI_zonetype, gF_vec1[0], gF_vec1[1], gF_vec1[2])
		//}
	//}
	//else
	//{
		//Format(sQuery, 512, "INSERT INTO zones (map, type, possition_x, possition_y, possition_z) VALUES ('%s', %i, %f, %f, %f)", gS_map, gI_zonetype, gF_vec1[0], gF_vec1[1], gF_vec1[2]) //shavit-zones.sp 2437
		//PrintToServer("Select successufly incompleted.")
	//}
	//gD_mysql.Query(SQLSetZones2, sQuery)
}

//void SQLSetZones2(Database db, DBResultSet results, const char[] error, any data)
//{
//	PrintToServer("Succesfuly zoned.")
//}

Action cmd_vecmaxs(int client, int args)
{
	GetClientAbsOrigin(client, gF_vec2)
	PrintToServer("vec1: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
	char sQuery[512]
	args = 0
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x2 = %f, possition_y2 = %f, possition_z2 = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec2[0], gF_vec2[1], gF_vec2[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
}

Action cmd_vecmaxsend(int client, int args)
{
	GetClientAbsOrigin(client, gF_vec2)
	PrintToServer("vec2: %f %f %f", gF_vec2[0], gF_vec2[1], gF_vec2[2])
	char sQuery[512]
	args = 1
	Format(sQuery, 512, "UPDATE zones SET map = '%s', type = %i, possition_x2 = %f, possition_y2 = %f, possition_z2 = %f WHERE map = '%s' AND type = %i", gS_map, args, gF_vec2[0], gF_vec2[1], gF_vec2[2], gS_map, args)
	gD_mysql.Query(SQLSetZones, sQuery)
	return Plugin_Handled
}

Action cmd_starttouch(int client, int args)
{
	SDKHook(gI_trigger, SDKHook_TouchPost, SDKStartTouch)
	if(IsValidEntity(gI_trigger) && ActivateEntity(gI_trigger) && DispatchSpawn(gI_trigger))
	{
		PrintToServer("Trigger is valid.")
	}
	return Plugin_Handled
}

Action cmd_createuser(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `users` (`id` INT AUTO_INCREMENT, `steamid` INT, `points` INT, PRIMARY KEY(id))")
	gD_mysql.Query(SQLCreateUserTable, sQuery)
}

void SQLCreateUserTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successfuly created user table.")
}

Action cmd_createrecords(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `records` (`id` INT AUTO_INCREMENT, `playerid` INT, `partnerid` INT, `time` FLOAT, `date` INT, PRIMARY KEY(id))")
	gD_mysql.Query(SQLRecordsTable, sQuery)
}

void SQLRecordsTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successfuly created records table.")
}

void SDKStartTouch(int entity, int other)
{
	PrintToServer("Start touch. [entity %i; other: %i]", entity, other)
	char sTriggerName[32]
	GetEntPropString(entity, Prop_Data, "m_iName", sTriggerName, 32)
	PrintToServer("[%s]", sTriggerName)
	if(StrEqual(sTriggerName, "fakeexpert_startzone"))
	{
		gB_state[other] = true
		gB_state[gI_partner[other]] = true
		gF_TimeStart[other] = GetEngineTime()
		//PrintToChat(other, "Your time is: %f"
	}
	if(StrEqual(sTriggerName, "fakeexpert_endzone"))
	{
		gB_state[other] = false
		gB_state[gI_partner[other]] = false
		int hour = RoundToFloor(gF_Time[other])
		gI_hour = hour / 360
		int minute = RoundToFloor(gF_Time[other])
		gI_minute = (minute / 60) % 24
		int second = RoundToFloor(gF_Time[other])
		gI_second = second % 60 //https://forums.alliedmods.net/archive/index.php/t-187536.html
		PrintToChat(other, "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], gI_hour, gI_minute, gI_second)
		PrintToChat(gI_partner[other], "Time: %f [%02.i:%02.i:%02.i]", gF_Time[other], gI_hour, gI_minute, gI_second)
		int client = GetSteamAccountID(other)
		int partner = GetSteamAccountID(gI_partner[other])
		//shavitush - datapack
		DataPack dp = new DataPack()
		dp.WriteCell(GetClientSerial(other))
		dp.WriteCell(GetClientSerial(gI_partner[other]))
		dp.WriteFloat(gF_Time[other]) //https://sm.alliedmods.net/new-api/datapack/DataPack
		char sQuery[512]
		Format(sQuery, 512, "SELECT time FROM records WHERE ((playerid = %i AND partnerid = %i) OR (partnerid = %i AND playerid = %i))", client, partner, partner, client)
		gD_mysql.Query(SQLRecords, sQuery, dp)
		DataPack dp2 = new DataPack()
		Transaction t = new Transaction()
		dp2.WriteCell(client)
		dp2.WriteCell(partner)
		dp2.WriteCell(GetClientSerial(other))
		//gB_other[other]
		
		//t.AddQuery
		Format(sQuery, 512, "SELECT tier FROM zones WHERE map = '%s' AND type = 0", gS_map)
		//gD_mysql.Query(SQLGetMapTier, sQuery, dp)
		t.AddQuery(sQuery, dp2)
		//gD_mysql.Query(SQLTransGetMapTier, h)
		//gD_mysql.Execute(t, sQuery, dp2)
		//gD_mysql.Execute(
		//t.Execute(sQuery, dp2)
		//t.Execute(sQuery, SQLTransGetMapTier)
		//t.Exe
		//gD_mysql.Execute(t, SQLTransGetMapTier)
		//
		gD_mysql.Execute(t, SQLTransGetMapTier)
	}
}

void SQLTransGetMapTier(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	Transaction t = new Transaction()
	for(int i = 0; i <= numQueries; i++)
	{
		if()
		//DataPack dp = new DataPack(queryData[i])
		int client = results[i].FetchInt(0)
		int partner = results[i].FetchInt(1)
		int other = results[i].FetchInt(2)
		PrintToServer("SQLTransGetTier: %i %i %i", client, partner, other)
	}
		
}

//void SQLTransGetMapTier(Handle owner, Handle hndl, const char[] error, any data)
//{
	/**/
//}

void SQLRecords(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	//delete dp
	dp.Reset() //shavit.wr 1395
	int client = GetClientFromSerial(dp.ReadCell()) //shavit.wr 1396
	int partner = GetClientFromSerial(dp.ReadCell())
	float time = dp.ReadFloat()
	//delete dp
	//PrintToServer("%N", client)
	char sQuery[512]
	if(results.FetchRow())
	{
		float fTime = results.FetchFloat(0) //https://pastebin.com/nhWqErZc 1667
		if(gF_Time[client] < fTime)
		{
			//PrintToServer("SQL time: %f", fTime)
			Format(sQuery, 512, "UPDATE records SET time = %f", gF_Time[client]) //https://en.wikipedia.org/wiki/Update_(SQL)#:~:text=An%20SQL%20UPDATE%20statement%20changes%20the%20data%20of,column_name%20%3D%20value%20%20%20column_name%20%3D%20value...%5D
			gD_mysql.Query(SQLUpdateRecord, sQuery)
		}
	}
	else
	{
		Format(sQuery, 512, "INSERT INTO records (playerid, partnerid, time, date) VALUES (%i, %i, %f, %i)", GetSteamAccountID(client), GetSteamAccountID(partner), time, GetTime()) //https://www.w3schools.com/sql/sql_insert.asp
		gD_mysql.Query(SQLInsertRecord, sQuery)
	}
}

void SQLUpdateRecord(Database db, DBResultSet results, const char[] error, any data)
{
	//PrintToServer("Record updated.")
}

void SQLInsertRecord(Database db, DBResultSet results, const char[] error, any data)
{
	//PrintToServer("Record inserted.")
}

void SQLGetMapTier(Database db, DBResultSet results, const char[] error, DataPack dp)
{
	dp.Reset()
	int client = dp.ReadCell()
	int partner = dp.ReadCell()
	int other = GetClientFromSerial(dp.ReadCell())
	PrintToChat(other, "Work")
	PrintToServer("SQLGetMapTier: %i [%N]", other, other)
	if(results.FetchRow())
	{
		int tier = results.FetchInt(0)
		int points = tier * 16
		DataPack dp2 = new DataPack()
		dp2.WriteCell(points)
		dp2.WriteCell(other)
		PrintToServer("SQLGetMapTier: %i [%N]", other, other)
		char sQuery[512]
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", client)
		//DataPack dp = new DataPack()
		//dp.WriteCell(other)
		gD_mysql.Query(SQLGetPoints, sQuery, dp2)
		//DataPack dp3 = new DataPack()
		
		Format(sQuery, 512, "SELECT points FROM users WHERE steamid = %i", partner)
		//DataPack dp = new DataPack()
		//dp.WriteCell(partner)
		gD_mysql.Query(SQLGetPoints, sQuery, dp2)
		//PrintToChat(other, "You recive %i points. You have %i points.", 
	}
}

void SQLGetPoints(Database db, DBResultSet results, const char[] error, DataPack dp2)
{
	PrintToServer("Debug")
	dp2.Reset()
	int earnedpoints = dp2.ReadCell()
	int other = dp2.ReadCell()
	PrintToServer("SQLGetPoints: %i [%N]", other, other)
	if(results.FetchRow())
	{
		int points = results.FetchInt(0)
		char sQuery[512]
		Format(sQuery, 512, "UPDATE users SET points = points + earnedpoints")
		gD_mysql.Query(SQLEarnedPoints, sQuery)
		PrintToChat(other, "Work")
		PrintToChat(other, "You recived %i points. You have %i points.", earnedpoints, points)
		PrintToChat(gI_partner[other], "You recived %i points. You have %i points.", earnedpoints, points)
	}
}

void SQLEarnedPoints(Database db, DBResultSet results, const char[] error, any data)
{
}

Action cmd_sum(int client, int args)
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
}

Action cmd_createtable(int args)
{
	char sQuery[512]
	Format(sQuery, 512, "CREATE TABLE IF NOT EXISTS `zones` (`id` INT AUTO_INCREMENT, `map` VARCHAR(128), `type` INT, `possition_x` FLOAT, `possition_y` FLOAT, `possition_z` FLOAT, `possition_x2` FLOAT, `possition_y2` FLOAT, `possition_z2` FLOAT, `tier` INT, PRIMARY KEY (id))") //https://stackoverflow.com/questions/8114535/mysql-1075-incorrect-table-definition-autoincrement-vs-another-key
	gD_mysql.Query(SQLCreateZonesTable, sQuery)
}

void SQLConnect(Database db, const char[] error, any data)
{
	PrintToServer("Successfuly connected to database.") //https://hlmod.ru/threads/sourcepawn-urok-13-rabota-s-bazami-dannyx-mysql-sqlite.40011/
	gD_mysql = db
	char sQuery[512]
	Format(sQuery, 512, "SELECT map FROM zones")
	gD_mysql.Query(SQLForceDefaultZones, sQuery)
	Format(sQuery, 512, "SELECT map FROM zones")
	gD_mysql.Query(SQLForceZonesSetup, sQuery)
}

void SQLForceDefaultZones(Database db, DBResultSet results, const char[] error, any data)
{
	char sMap[192]
	char sQuery[512]
	while(results.FetchRow())
	{
		results.FetchString(0, sMap, 192)
		if(!StrEqual(gS_map, sMap))
		{
			Format(sQuery, 512, "INSERT INTO zones (map, type) VALUES ('%s', 0)", gS_map)
			gD_mysql.Query(SQLForceDefaultZonesType, sQuery)
			Format(sQuery, 512, "INSERT INTO zones (map, type) VALUES ('%s', 1)", gS_map)
			gD_mysql.Query(SQLForceDefaultZonesType, sQuery)
		}
	}
}

void SQLForceDefaultZonesType(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Successful SQLForceDefaultZonesType.")
}

void SQLForceZonesSetup(Database db, DBResultSet results, const char[] error, any data)
{
	if(results.FetchRow())
	{
		char sQuery[512]
		Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 0", gS_map)
		gD_mysql.Query(SQLSetZonesEntity, sQuery)
		Format(sQuery, 512, "SELECT possition_x, possition_y, possition_z, possition_x2, possition_y2, possition_z2 FROM zones WHERE map = '%s' AND type = 1", gS_map)
		gD_mysql.Query(SQLSetZoneEnd, sQuery)
	}
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
		cmd_createstart(0, 0)
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
		cmd_createend(0, 0)
	}
}

public void SQLCreateZonesTable(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("Success")
}

Action cmd_tp(int client, int args)
{
	//TeleportEntity(client, gI_trigger, NULL_VECTOR, NULL_VECTOR)
	return Plugin_Handled
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(buttons & IN_JUMP && !(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(client) & FL_INWATER) && !(GetEntityMoveType(client) & MOVETYPE_LADDER) && IsPlayerAlive(client)) //https://sm.alliedmods.net/new-api/entity_prop_stocks/GetEntityFlags https://forums.alliedmods.net/showthread.php?t=127948
		buttons &= ~IN_JUMP //https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit https://forums.alliedmods.net/showthread.php?t=192163
	
	//Timer
	if(gB_state[client])
	{
		gF_Time[client] = GetEngineTime()
		gF_Time[client] = gF_Time[client] - gF_TimeStart[client]
	}
}

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
		SDKHook(entity, SDKHook_Spawn, SDKProjectile)
}

Action SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	
	if(!IsValidEntity(entity) || !IsPlayerAlive(client))
		return
	
	GivePlayerItem(client, "weapon_flashbang")
	SetEntData(client, FindDataMapInfo(client, "m_iAmmo") + 12 * 4, 2)
	//GivePlayerAmmo(client, 2, 48, true)
	FakeClientCommand(client, "use weapon_knife")
	ClientCommand(client, "lastinv")
	//ClientCommand(client, "lastinv")
	//RequestFrame(frame, client)
	CreateTimer(1.5, timer_delete, entity)
}

//void frame(int client)
//{
//	ClientCommand(client, "lastinv")
//}

Action timer_delete(Handle timer, int entity)
{
	if(IsValidEntity(entity))
		RemoveEntity(entity)
}

void SDKPlayerSpawn(int client)
{
	GivePlayerItem(client, "weapon_flashbang")
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
	{
		volume = 0.0
		return Plugin_Handled
	}
	return Plugin_Continue
	//PrintToServer("%s", sample)
}

