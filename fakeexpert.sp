#include <sdktools>
#include <sdkhooks>

bool gB_block[MAXPLAYERS + 1]
int gI_partner[MAXPLAYERS + 1]
//float gF_vec1[3]
//float gF_vec2[3]
int gI_beam
int gI_halo
//#pragma dynamic 3000000 //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L35
int gI_trigger
int gI_entity

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
	RegConsoleCmd("sm_create", cmd_create)
	RegConsoleCmd("sm_1", cmd_create)
	RegConsoleCmd("sm_vecmins", cmd_vecmins)
	RegConsoleCmd("sm_2", cmd_vecmins)
	RegConsoleCmd("sm_vecmaxs", cmd_vecmaxs)
	RegConsoleCmd("sm_3", cmd_vecmaxs)
	RegConsoleCmd("sm_starttouch", cmd_starttouch)
	RegConsoleCmd("sm_4", cmd_starttouch)
	RegConsoleCmd("sm_sum", cmd_sum)
	RegConsoleCmd("sm_getid", cmd_getid)
	RegConsoleCmd("sm_tptrigger", cmd_tp)
	AddNormalSoundHook(SoundHook)
}

public void OnMapStart()
{
	//gI_beam = PrecacheModel("materials/sprites/tp_beam001")
	gI_beam = PrecacheModel("sprites/laserbeam.vmt", true) //https://github.com/shavitush/bhoptimer/blob/master/addons/sourcemod/scripting/shavit-zones.sp#L657-L658
	gI_halo = PrecacheModel("sprites/glow01.vmt", true)
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
		return Plugin_Handled
	}
	if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
	{
		SetEntProp(client, Prop_Data, "m_CollisionGroup", 5)
		SetEntityRenderMode(client, RENDER_NORMAL)
		gB_block[client] = true
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

Action cmd_create(int client, int args)
{
	int entity = CreateEntityByName("trigger_multiple")
	float vec[3]
	//GetClientAbsOrigin(client, vec)
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR)
	DispatchKeyValueVector(entity, "origin", vec) //Thanks to https://amx-x.ru/viewtopic.php?f=14&t=15098 http://world-source.ru/forum/102-3743-1
	DispatchKeyValue(entity, "spawnflags", "1") //https://github.com/shavitush/bhoptimer
	DispatchKeyValue(entity, "wait", "0")
	//ActivateEntity(entity)
	DispatchSpawn(entity)
	SetEntityModel(entity, "models/player/t_arctic.mdl")
	//SetEntProp(entity, Prop_Send, "m_fEffects", 32)
	//GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	//TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR)
	vec[0] = -128.0
	vec[1] = -128.0
	vec[2] = -128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vec) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	vec[0] = 128.0
	vec[1] = 128.0
	vec[2] = 128.0
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec)
	//SetEntPropVector(entity, Prop_Send, "m_vecPosition1", vec)
	//TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR)
	//GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec)
	//PrintToServer("| %f %f %f", vec[0], vec[1], vec[2])
	//int spawnflags = GetEntProp(entity, Prop_Send, "m_spawnflags")
	//PrintToServer("| %i", spawnflags)
	//float wait = GetEntPropFloat(entity, Prop_Send, "m_flWait")
	//PrintToServer("| %f", wait)
	//ActivateEntity(entity)
	SetEntProp(entity, Prop_Send, "m_nSolidType", 2)
	SDKHook(entity, SDKHook_StartTouch, SDKStartTouch)
	//DispatchKeyValue(entity, "targetname", "test")
	PrintToServer("entity: %i created", entity)
	return Plugin_Handled
}

Action cmd_vecmins(int client, int args)
{
	float vec[3]
	//GetClientAbsOrigin(client, vec)
	//vec[2] = vec[2] += 64.0
	vec[0] = -128.0
	vec[1] = -128.0
	vec[2] = -128.0
	//SetEntPropVector(gI_trigger, Prop_Send, "m_vecMins", vec) //https://forums.alliedmods.net/archive/index.php/t-301101.html
	SetEntPropVector(gI_trigger, Prop_Data, "m_vecPosition1", vec)
	PrintToServer("%f %f %f", vec[0], vec[1], vec[2])
	return Plugin_Handled
}

Action cmd_vecmaxs(int client, int args)
{
	float vec[3]
	//GetClientAbsOrigin(client, vec)
	//vec[2] = vec[2] -= 64.0
	vec[0] = 128.0
	vec[1] = 128.0
	vec[2] = 128.0
	//SetEntPropVector(gI_trigger, Prop_Send, "m_vecMaxs", vec)
	SetEntPropVector(gI_trigger, Prop_Data, "m_vecPosition2", vec)
	//ActivateEntity(gI_trigger)
	PrintToServer("%f %f %f", vec[0], vec[1], vec[2])
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

void SDKStartTouch(int entity, int other)
{
	PrintToServer("Start touch.")
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

Action cmd_getid(int client, int args)
{
	char sName[32]
	//int entity
	while((gI_entity = FindEntityByClassname(gI_entity, "trigger_multiple")) != -1) //https://forums.alliedmods.net/showthread.php?t=290655
	{
		char sName[32]
		if(IsValidEntity(gI_entity))
		{
			GetEntPropString(gI_entity, Prop_Data, "m_iGlobalname", sName, 32)
			//PrintToServer("1. %i %i [%s]", gI_entity, GetEntProp(gI_entity, Prop_Data, "m_iHammerID"), sName)
			PrintToServer("1. %i [%i]", gI_entity, GetEntProp(gI_entity, Prop_Data, "m_iHammerID"))
			float vec[3]
			GetEntPropVector(gI_entity, Prop_Data, "m_vecMins", vec)
			PrintToServer("%f %f %f", vec[0], vec[1], vec[2])
		}
	}
	return Plugin_Handled
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
