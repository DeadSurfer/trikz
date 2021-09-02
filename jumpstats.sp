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
#include <sdkhooks>
#include <sdktools>

bool gB_jumped[MAXPLAYERS + 1]
float gF_origin[MAXPLAYERS + 1][3]
int gI_strafeCount[MAXPLAYERS + 1]
bool gB_ladder[MAXPLAYERS + 1]
float gF_preVel[MAXPLAYERS + 1][3]
bool gB_jumpstats[MAXPLAYERS + 1]
bool gB_strafeFirst[MAXPLAYERS + 1]
int gI_tick[MAXPLAYERS + 1]
int gI_syncTick[MAXPLAYERS + 1]
int gI_tickAir[MAXPLAYERS + 1]
bool gB_isCountJump[MAXPLAYERS + 1]
float gF_dot[MAXPLAYERS + 1]
bool gB_strafeBlockD[MAXPLAYERS + 1]
bool gB_strafeBlockA[MAXPLAYERS + 1]
bool gB_strafeBlockS[MAXPLAYERS + 1]
bool gB_strafeBlockW[MAXPLAYERS + 1]
char gS_style[MAXPLAYERS + 1][32]
float gF_dotTime[MAXPLAYERS + 1]
bool gB_runboost[MAXPLAYERS + 1]
int gI_rbBooster[MAXPLAYERS + 1]
int gI_entityFlags[MAXPLAYERS + 1]
float gF_boostTime[MAXPLAYERS + 1]
float gF_skyOrigin[MAXPLAYERS + 1][3]
int gI_entityButtons[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "Jump stats",
	author = "Smesh",
	description = "Measures distance difference between two vectors",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	HookEvent("player_jump", Event_PlayerJump)
	for(int i = 1; i <= MaxClients; i++)
		if(IsValidEntity(i))
			OnClientPutInServer(i)
	RegConsoleCmd("sm_js", cmd_jumpstats)
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_Touch, TouchClient)
	SDKHook(client, SDKHook_StartTouch, SDKSkyJump)
	gB_jumpstats[client] = false
}

Action cmd_jumpstats(int client, int args)
{
	gB_jumpstats[client] = !gB_jumpstats[client]
	PrintToChat(client, gB_jumpstats[client] ? "Jump stats is on." : "Jump stats is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "js"))
			cmd_jumpstats(client, 0)
}

Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(gI_tick[client] == 30 && (GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0))
	{
		gB_jumped[client] = true
		float origin[3]
		if(gB_runboost[client])
			GetClientAbsOrigin(gI_rbBooster[client], origin)
		else
			GetClientAbsOrigin(client, origin)
		gF_origin[client][0] = origin[0]
		gF_origin[client][1] = origin[1]
		gF_origin[client][2] = origin[2]
		float vel[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel) //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
		gF_preVel[client][0] = vel[0]
		gF_preVel[client][1] = vel[1]
		gB_isCountJump[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucking", 1))
		gF_dotTime[client] = GetEngineTime()
	}
	GetClientAbsOrigin(client, gF_skyOrigin[client])
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	gI_entityFlags[client] = GetEntityFlags(client)
	gI_entityButtons[client] = buttons
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(gI_tick[client] < 30)
			gI_tick[client]++
	}
	else
	{
		if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && (gB_jumped[client] || gB_ladder[client]))
		{
			if(GetEngineTime() - gF_dotTime[client] < 0.4)
			{
				float eye[3]
				GetClientEyeAngles(client, eye)
				eye[0] = Cosine(DegToRad(eye[1]))
				eye[1] = Sine(DegToRad(eye[1]))
				eye[2] = 0.0
				float velExtra[3]
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velExtra)
				float length = SquareRoot(Pow(velExtra[0], 2.0) + Pow(velExtra[1], 2.0))
				velExtra[0] /= length
				velExtra[1] /= length
				//velExtra[2] = 0.0
				gF_dot[client] = GetVectorDotProduct(eye, velExtra) //https://onedrive.live.com/?authkey=%21ACwrZlLqDTC92n0&cid=879961B2A0BE0AAE&id=879961B2A0BE0AAE%2116116&parId=879961B2A0BE0AAE%2126502&o=OneUp
				//PrintToServer("%f", gF_dot[client])
			}
			gI_tickAir[client]++
		}
	}
	if(gB_jumped[client])
	{
		if(gF_dot[client] < -0.9) //backward
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVELEFT)
				{
					if(!gB_strafeBlockA[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockD[client] = false
						gB_strafeBlockA[client] = true
					}
					gI_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(!gB_strafeBlockD[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockD[client] = true
						gB_strafeBlockA[client] = false
					}
					gI_syncTick[client]++
				}
			}
			if(!StrEqual(gS_style[client], "Backward"))
				Format(gS_style[client], 32, "Backward")
		}
		else if(gF_dot[client] > 0.9) //forward
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(!gB_strafeBlockD[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockD[client] = true
						gB_strafeBlockA[client] = false
					}
					gI_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_MOVELEFT)
				{
					if(!gB_strafeBlockA[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockD[client] = false
						gB_strafeBlockA[client] = true
					}
					gI_syncTick[client]++
				}
			}
			if(!StrEqual(gS_style[client], "Forward"))
				Format(gS_style[client], 32, "Forward")
		}
		else //sideways
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_BACK)
				{
					if(!gB_strafeBlockS[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockS[client] = true
						gB_strafeBlockW[client] = false
					}
					gI_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_FORWARD)
				{
					if(!gB_strafeBlockW[client])
					{
						gI_strafeCount[client]++
						gB_strafeBlockS[client] = false
						gB_strafeBlockW[client] = true
					}
					gI_syncTick[client]++
				}
			}
			if(!StrEqual(gS_style[client], "Sideways"))
				Format(gS_style[client], 32, "Sideways")
		}
	}
	if(GetEntityFlags(client) & FL_ONGROUND && gB_jumped[client])
	{
		float origin[3]
		GetClientAbsOrigin(client, origin)
		char sZLevel[32]
		if(origin[2] - gF_origin[client][2] > 1.705139) //1.475586 without rb
			Format(sZLevel, 32, "[Rise|%.1f] ", origin[2] - gF_origin[client][2])
		if(origin[2] - gF_origin[client][2] < -1.285155) //0.017089 without rb
			Format(sZLevel, 32, "[Fall|%.1f] ", origin[2] - gF_origin[client][2])
		PrintToServer("jump: %f", origin[2] - gF_origin[client][2])
		float distance = SquareRoot(Pow(gF_origin[client][0] - origin[0], 2.0) + Pow(gF_origin[client][1] - origin[1], 2.0)) + 32.0 //http://mathonline.wikidot.com/the-distance-between-two-vectors
		float pre = SquareRoot(Pow(gF_preVel[client][0], 2.0) + Pow(gF_preVel[client][1], 2.0)) //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		float sync = -1.0
		sync += float(gI_syncTick[client])
		if(sync == -1.0)
			sync = 0.0
		sync /= float(gI_tickAir[client])
		sync *= 100.0
		if(gB_jumpstats[client])
		{
			if(1000.0 > distance >= 230.0 && pre < 280.0)
			{
				PrintToChat(client, "[SM] %s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%, Style: %s", sZLevel, gB_isCountJump[client] ? "[CJ] " : "", distance, gI_strafeCount[client], pre, sync, gS_style[client])
				if(gB_runboost[client])
					PrintToChat(gI_rbBooster[client], "[SM] %s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%, Style: %s", sZLevel, gB_isCountJump[client] ? "[CJ] " : "", distance, gI_strafeCount[client], pre, sync, gS_style[client])
			}
		}
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientObserver(i))
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
				if(observerMode < 7 && observerTarget == client && gB_jumpstats[i])
					if(1000.0 > distance >= 230.0 && pre < 280.0)
						PrintToChat(i, "[SM] %s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%, Style: %s", sZLevel, gB_isCountJump[client] ? "[CJ] " : "", distance, gI_strafeCount[client], pre, sync, gS_style[client])
			}
		}
		ResetFactory(client)
	}
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity")
		if(!groundEntity && gB_runboost[client])
			gB_runboost[client] = false
	}
	if(GetEntityMoveType(client) & MOVETYPE_LADDER && !(GetEntityFlags(client) & FL_ONGROUND)) //ladder bit bugs with noclip
	{
		ResetFactory(client)
		gB_ladder[client] = true
		float origin[3]
		GetClientAbsOrigin(client, origin)
		gF_origin[client][0] = origin[0]
		gF_origin[client][1] = origin[1]
		gF_origin[client][2] = origin[2]
		gB_strafeFirst[client] = true
	}
	if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && gB_ladder[client])
	{
		if(mouse[0] > 0)
		{
			if(buttons & IN_MOVERIGHT)
			{
				if(!gB_strafeBlockD[client])
				{
					gI_strafeCount[client]++
					gB_strafeBlockD[client] = true
					gB_strafeBlockA[client] = false
				}
				gI_syncTick[client]++
			}
		}
		else
		{
			if(buttons & IN_MOVELEFT)
			{
				if(!gB_strafeBlockA[client])
				{
					gI_strafeCount[client]++
					gB_strafeBlockD[client] = false
					gB_strafeBlockA[client] = true
				}
				gI_syncTick[client]++
			}
		}
	}
	if(GetEntityFlags(client) & FL_ONGROUND && gB_ladder[client])
	{
		float origin[3]
		GetClientAbsOrigin(client, origin)
		PrintToServer("ladder: %f", origin[2] - gF_origin[client][2])
		if(4.549926 >= origin[2] - gF_origin[client][2] >= -3.872436)
		{
			float distance = SquareRoot(Pow(gF_origin[client][0] - origin[0], 2.0) + Pow(gF_origin[client][1] - origin[1], 2.0))
			float sync = -1.0
			sync += float(gI_syncTick[client])
			if(sync == -1.0)
				sync = 0.0
			sync /= float(gI_tickAir[client])
			sync *= 100.0
			if(gB_jumpstats[client])
				if(190.0 > distance >= 22.0)
					PrintToChat(client, "[SM] Ladder: %.1f units, Strafes: %i, Sync: %.1f", distance, gI_strafeCount[client], sync)
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsClientObserver(i))
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
					if(observerMode < 7 && observerTarget == client && gB_jumpstats[i])
						if(190.0 > distance >= 22.0)
							PrintToChat(i, "[SM] Ladder: %.1f units, Strafes: %i, Sync: %.1f", distance, gI_strafeCount[client], sync)
				}
			}
		}
		ResetFactory(client)
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile") != -1)
		SDKHook(entity, SDKHook_StartTouch, StartTouchProjectile)
}

void ResetFactory(int client)
{
	gB_jumped[client] = false
	gB_ladder[client] = false
	gI_strafeCount[client] = 0
	gI_syncTick[client] = 0
	gI_tick[client] = 0
	gI_tickAir[client] = 0
	gB_strafeBlockD[client] = false
	gB_strafeBlockA[client] = false
	gB_strafeBlockS[client] = false
	gB_strafeBlockW[client] = false
	gB_runboost[client] = false
}

Action StartTouchProjectile(int entity, int other)
{
	if(0 < other <= MaxClients && (gB_jumped[other] || gB_ladder[other]))
	{
		//https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L220-L231
		float entityOrigin[3]
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityOrigin)
		float otherOrigin[3]
		GetClientAbsOrigin(other, otherOrigin)
		float entityMaxs[3]
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", entityMaxs)
		float delta = otherOrigin[2] - entityOrigin[2] - entityMaxs[2]
		if(0.0 < delta < 2.0)
		{
			ResetFactory(other)
			gF_boostTime[other] = GetEngineTime()
		}
	}
}

void TouchClient(int client, int other)
{
	if(0 < other <= MaxClients)
	{
		float clientOrigin[3]
		GetClientAbsOrigin(client, clientOrigin)
		float otherOrigin[3]
		GetClientAbsOrigin(other, otherOrigin)
		float clientMaxs[3]
		GetClientMaxs(client, clientMaxs)
		float delta = otherOrigin[2] - clientOrigin[2] - clientMaxs[2]
		if(delta == -124.031250)
		{
			gB_runboost[client] = true
			gI_rbBooster[client] = other
		}
	}
}

void SDKSkyJump(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(gI_entityFlags[other] & FL_ONGROUND) && GetEngineTime() - gF_boostTime[client] > 0.15)
	{
		float originBooster[3]
		GetClientAbsOrigin(client, originBooster)
		float originFlyer[3]
		GetClientAbsOrigin(other, originFlyer)
		float maxs[3]
		GetEntPropVector(client, Prop_Data, "m_vecMaxs", maxs) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71
		float delta = originFlyer[2] - originBooster[2] - maxs[2]
		if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		{
			//if(!(GetEntityFlags(client) & FL_ONGROUND) && !(GetClientButtons(other) & IN_DUCK) && gI_entityButtons[other] & IN_JUMP)
			if(!(GetClientButtons(other) & IN_DUCK) && gI_entityButtons[other] & IN_JUMP)
			{
				float velBooster[3]
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velBooster)
				if(velBooster[2] > 0.0)
				{
					float velFlyer[3]
					GetEntPropVector(other, Prop_Data, "m_vecVelocity", velFlyer)
					velBooster[2] *= 3.0
					if(velFlyer[2] > -700.0)
					{
						if(velBooster[2] > 750.0)
							velFlyer[2] = 750.0
					}
					else
						if(velBooster[2] > 800.0)
							velFlyer[2] = 800.0
					if(gF_skyOrigin[client][2] < gF_skyOrigin[other][2])
					{
						ConVar CV_gravity = FindConVar("sv_gravity")
						if(gB_jumpstats[client])
							PrintToChat(client, "Sky boost: %.1f u/s, ~%.1f units", FloatAbs(velFlyer[2]), Pow(FloatAbs(velFlyer[2]), 2.0) / (1.666666666666 * float(CV_gravity.IntValue))) //https://www.omnicalculator.com/physics/maximum-height-projectile-motion 
						if(gB_jumpstats[other])
							PrintToChat(other, "Sky boost: %.1f u/s, ~%.1f units", FloatAbs(velFlyer[2]), Pow(FloatAbs(velFlyer[2]), 2.0) / (1.666666666666 * float(CV_gravity.IntValue)))
						for(int i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i) && IsClientObserver(i))
							{
								int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
								int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
								if(observerMode < 7 && observerTarget == client && gB_jumpstats[i])
									PrintToChat(i, "Sky boost: %.1f u/s, ~%.1f units", FloatAbs(velFlyer[2]), Pow(FloatAbs(velFlyer[2]), 2.0) / (1.666666666666 * float(CV_gravity.IntValue)))
							}
						}
					}
				}
			}
		}
	}
}
