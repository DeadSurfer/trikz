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
#include <clientprefs>

bool g_jumped[MAXPLAYERS + 1]
float g_origin[MAXPLAYERS + 1][3]
int g_strafeCount[MAXPLAYERS + 1]
bool g_ladder[MAXPLAYERS + 1]
float g_preVel[MAXPLAYERS + 1][3]
bool g_jumpstats[MAXPLAYERS + 1]
bool g_strafeFirst[MAXPLAYERS + 1]
int g_tick[MAXPLAYERS + 1]
int g_syncTick[MAXPLAYERS + 1]
int g_tickAir[MAXPLAYERS + 1]
bool g_countjump[MAXPLAYERS + 1]
float gF_dot[MAXPLAYERS + 1]
bool g_strafeBlockD[MAXPLAYERS + 1]
bool g_strafeBlockA[MAXPLAYERS + 1]
bool g_strafeBlockS[MAXPLAYERS + 1]
bool g_strafeBlockW[MAXPLAYERS + 1]
char g_style[MAXPLAYERS + 1][32]
float g_dotTime[MAXPLAYERS + 1]
bool gB_runboost[MAXPLAYERS + 1]
int g_rbBooster[MAXPLAYERS + 1]
float g_boostTime[MAXPLAYERS + 1]
float g_skyOrigin[MAXPLAYERS + 1]
int g_entityButtons[MAXPLAYERS + 1]
native int Trikz_GetClientButtons(int client)
bool g_teleported[MAXPLAYERS + 1]
Handle g_cookie
float g_skyAble[MAXPLAYERS + 1]
float g_gain[MAXPLAYERS + 1]
int g_entityFlags[MAXPLAYERS + 1]

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
	g_cookie = RegClientCookie("js", "jumpstats", CookieAccess_Protected)
	for(int i = 1; i <= MaxClients; i++)
		if(IsValidEntity(i))
			OnClientPutInServer(i)
	RegConsoleCmd("sm_js", cmd_jumpstats)
	char output[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger"}
	for(int i = 0; i < sizeof(output); i++)
	{
		HookEntityOutput("trigger_teleport", output[i], output_teleport) //https://developer.valvesoftware.com/wiki/Trigger_teleport
		HookEntityOutput("trigger_teleport_relative", output[i], output_teleport) //https://developer.valvesoftware.com/wiki/Trigger_teleport_relative
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Trikz_GetClientButtons")
	return APLRes_Success
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_Touch, TouchClient)
	SDKHook(client, SDKHook_StartTouch, SDKSkyJump)
	if(!AreClientCookiesCached(client))
		g_jumpstats[client] = false
}

public void OnClientCookiesCached(int client)
{
	char value[16]
	GetClientCookie(client, g_cookie, value, 16)
	g_jumpstats[client] = view_as<bool>(StringToInt(value))
}

Action cmd_jumpstats(int client, int args)
{
	g_jumpstats[client] = !g_jumpstats[client]
	char value[16]
	IntToString(g_jumpstats[client], value, 16)
	SetClientCookie(client, g_cookie, value)
	PrintToChat(client, g_jumpstats[client] ? "Jump stats is on." : "Jump stats is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "js"))
			cmd_jumpstats(client, 0)
}

void output_teleport(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
		g_teleported[activator] = true
}

Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(g_tick[client] == 30 && (GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0))
	{
		g_jumped[client] = true
		g_teleported[client] = false
		float origin[3]
		if(gB_runboost[client])
			GetClientAbsOrigin(g_rbBooster[client], origin)
		else
			GetClientAbsOrigin(client, origin)
		g_origin[client][0] = origin[0]
		g_origin[client][1] = origin[1]
		g_origin[client][2] = gB_runboost[client] ? GetGroundPos(g_rbBooster[client]) : GetGroundPos(client)
		float vel[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel) //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
		g_preVel[client][0] = vel[0]
		g_preVel[client][1] = vel[1]
		g_countjump[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucking", 1))
		g_dotTime[client] = GetEngineTime()
	}
	g_skyOrigin[client] = GetGroundPos(client)
	g_skyAble[client] = GetGameTime()
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	g_entityButtons[client] = buttons
	g_entityFlags[client] = GetEntityFlags(client)
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_tick[client] < 30)
			g_tick[client]++
	}
	else
	{
		if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && (g_jumped[client] || g_ladder[client]))
		{
			if(GetEngineTime() - g_dotTime[client] < 0.4)
			{
				float eye[3]
				GetClientEyeAngles(client, eye)
				eye[0] = Cosine(DegToRad(eye[1]))
				eye[1] = Sine(DegToRad(eye[1]))
				eye[2] = 0.0
				float velAbs[3]
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velAbs)
				float length = SquareRoot(Pow(velAbs[0], 2.0) + Pow(velAbs[1], 2.0))
				velAbs[0] /= length
				velAbs[1] /= length
				velAbs[2] = 0.0
				gF_dot[client] = GetVectorDotProduct(eye, velAbs) //https://onedrive.live.com/?authkey=%21ACwrZlLqDTC92n0&cid=879961B2A0BE0AAE&id=879961B2A0BE0AAE%2116116&parId=879961B2A0BE0AAE%2126502&o=OneUp
			}
			g_tickAir[client]++
		}
	}
	if(g_jumped[client])
	{
		Sync(client, buttons, mouse)
		Gain(client, vel, angles)
	}
	if(GetEntityFlags(client) & FL_ONGROUND && g_jumped[client])
	{
		float origin[3]
		GetClientAbsOrigin(client, origin)
		char flat[32]
		if(GetGroundPos(client) - g_origin[client][2] > 0.04)
			Format(flat, 32, "[Rise|%.1f] ", GetGroundPos(client) - g_origin[client][2])
		if(GetGroundPos(client) - g_origin[client][2] < -0.04)
			Format(flat, 32, "[Fall|%.1f] ", GetGroundPos(client) - g_origin[client][2])
		float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0)) + 32.0 //http://mathonline.wikidot.com/the-distance-between-two-vectors
		float pre = SquareRoot(Pow(g_preVel[client][0], 2.0) + Pow(g_preVel[client][1], 2.0)) //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		float sync = -1.0
		sync += float(g_syncTick[client])
		if(sync == -1.0)
			sync = 0.0
		sync /= float(g_tickAir[client])
		sync *= 100.0
		if(1000.0 > distance >= 230.0 && pre < 280.0)
		{
			if(g_jumpstats[client])
				PrintToChat(client, "%s%s%s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%%, Gain: %.1f%%, Style: %s", gB_runboost[client] ? "[RB] " : "", g_teleported[client] ? "[TP] " : "", flat, g_countjump[client] ? "[CJ] " : "", distance, g_strafeCount[client], pre, sync, g_gain[client], g_style[client])
			if(gB_runboost[client] && g_jumpstats[g_rbBooster[client]])
				PrintToChat(g_rbBooster[client], "%s%s%s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%%, Gain: %.1f%%, Style: %s", gB_runboost[client] ? "[RB] " : "", g_teleported[client] ? "[TP] " : "", flat, g_countjump[client] ? "[CJ] " : "", distance, g_strafeCount[client], pre, sync, g_gain[client], g_style[client])
		}
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientObserver(i))
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
				if(observerMode < 7 && observerTarget == client && g_jumpstats[i])
					if(1000.0 > distance >= 230.0 && pre < 280.0)
						PrintToChat(i, "%s%s%s%sJump: %.1f units, Strafes: %i, Pre: %.1f u/s, Sync: %.1f%%, Gain: %.1f%%, Style: %s", gB_runboost[client] ? "[RB] " : "", g_teleported[client] ? "[TP] " : "", flat, g_countjump[client] ? "[CJ] " : "", distance, g_strafeCount[client], pre, sync, g_gain[client], g_style[client])
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
		g_ladder[client] = true
		float origin[3]
		GetClientAbsOrigin(client, origin)
		g_origin[client][0] = origin[0]
		g_origin[client][1] = origin[1]
		g_origin[client][2] = GetGroundPos(client)
		g_strafeFirst[client] = true
	}
	if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && g_ladder[client])
	{
		Sync(client, buttons, mouse)
		Gain(client, vel, angles)
	}
	if(GetEntityFlags(client) & FL_ONGROUND && g_ladder[client])
	{
		float origin[3]
		GetClientAbsOrigin(client, origin)
		if(GetGroundPos(client) - g_origin[client][2] == 0.0)
		{
			float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0))
			float sync = -1.0
			if(g_syncTick[client])
			{
				sync += float(g_syncTick[client])
				if(sync == -1.0)
					sync = 0.0
				sync /= float(g_tickAir[client])
				sync *= 100.0
				if(g_jumpstats[client])
					if(190.0 > distance >= 22.0)
						PrintToChat(client, "%sLadder: %.1f units, Strafes: %i, Sync: %.1f, Gain: %.1f%%", g_teleported[client] ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client])
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && IsClientObserver(i))
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
						if(observerMode < 7 && observerTarget == client && g_jumpstats[i])
							if(190.0 > distance >= 22.0)
								PrintToChat(i, "%sLadder: %.1f units, Strafes: %i, Sync: %.1f, Gain: %.1f%%", g_teleported[client] ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client])
					}
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
	g_jumped[client] = false
	g_ladder[client] = false
	g_strafeCount[client] = 0
	g_syncTick[client] = 0
	g_tick[client] = 0
	g_tickAir[client] = 0
	g_strafeBlockD[client] = false
	g_strafeBlockA[client] = false
	g_strafeBlockS[client] = false
	g_strafeBlockW[client] = false
	gB_runboost[client] = false
	g_teleported[client] = false
	g_gain[client] = 0.0
}

Action StartTouchProjectile(int entity, int other)
{
	if(0 < other <= MaxClients && (g_jumped[other] || g_ladder[other]))
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
			g_boostTime[other] = GetEngineTime()
		}
	}
}

void TouchClient(int client, int other)
{
	if(0 < other <= MaxClients && g_tick[client] == 30)
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
			for(int i = 1; i <= MaxClients; i++)
			{
				gB_runboost[i] = false
				g_rbBooster[i] = 0
			}
			gB_runboost[client] = true
			g_rbBooster[client] = other
		}
	}
}

void SDKSkyJump(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(GetClientButtons(other) & IN_DUCK) && view_as<int>(LibraryExists("fakeexpert") ? Trikz_GetClientButtons(other) & IN_JUMP : g_entityButtons[other] & IN_JUMP) && GetEngineTime() - g_boostTime[client] > 0.15)
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
				velBooster[2] *= 3.0
				float velNew[3]
				velNew[0] = velFlyer[0]
				velNew[1] = velFlyer[1]
				velNew[2] = velBooster[2]
				if(velFlyer[2] > -700.0)
				{
					if((g_entityFlags[client] & FL_INWATER))
					{
						if(velBooster[2] > 300.0)
							velNew[2] = 500.0
					}
					else
					{
						if(velBooster[2] > 750.0)
							velNew[2] = 750.0
					}
				}
				else
					if(velBooster[2] > 800.0)
						velNew[2] = 800.0
				if(g_entityFlags[client] & FL_INWATER ? velNew[2] > 0.0 : FloatAbs(g_skyOrigin[client] - g_skyOrigin[other]) > 0.04 || GetGameTime() - g_skyAble[other] > 0.5)
				{
					ConVar gravity = FindConVar("sv_gravity")
					if(g_jumpstats[client])
						PrintToChat(client, "Sky boost: %.1f u/s, ~%.1f units", velNew[2], Pow(velNew[2], 2.0) / (1.666666666666 * float(gravity.IntValue))) //https://www.omnicalculator.com/physics/maximum-height-projectile-motion 
					if(g_jumpstats[other])
						PrintToChat(other, "Sky boost: %.1f u/s, ~%.1f units", velNew[2], Pow(velNew[2], 2.0) / (1.666666666666 * float(gravity.IntValue)))
					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && IsClientObserver(i))
						{
							int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
							int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
							if(observerMode < 7 && observerTarget == client && g_jumpstats[i])
								PrintToChat(i, "Sky boost: %.1f u/s, ~%.1f units", velNew[2], Pow(velNew[2], 2.0) / (1.666666666666 * float(gravity.IntValue)))
						}
					}
				}
			}
		}
	}
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

bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false
	return true
}

void Sync(int client, int buttons, int mouse[2])
{
	if(gF_dot[client] < -0.9) //backward
	{
		if(g_jumped[client] || g_ladder[client])
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVELEFT)
				{
					if(!g_strafeBlockA[client])
					{
						g_strafeCount[client]++
						g_strafeBlockD[client] = false
						g_strafeBlockA[client] = true
					}
					g_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(!g_strafeBlockD[client])
					{
						g_strafeCount[client]++
						g_strafeBlockD[client] = true
						g_strafeBlockA[client] = false
					}
					g_syncTick[client]++
				}
			}
			if(!StrEqual(g_style[client], "Backward"))
				Format(g_style[client], 32, "Backward")
		}
	}
	else if(gF_dot[client] > 0.9) //forward
	{
		if(g_jumped[client])
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(!g_strafeBlockD[client])
					{
						g_strafeCount[client]++
						g_strafeBlockD[client] = true
						g_strafeBlockA[client] = false
					}
					g_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_MOVELEFT)
				{
					if(!g_strafeBlockA[client])
					{
						g_strafeCount[client]++
						g_strafeBlockD[client] = false
						g_strafeBlockA[client] = true
					}
					g_syncTick[client]++
				}
			}
			if(!StrEqual(g_style[client], "Forward"))
				Format(g_style[client], 32, "Forward")
		}
	}
	else //sideways
	{
		if(g_jumped[client])
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_BACK)
				{
					if(!g_strafeBlockS[client])
					{
						g_strafeCount[client]++
						g_strafeBlockS[client] = true
						g_strafeBlockW[client] = false
					}
					g_syncTick[client]++
				}
			}
			else
			{
				if(buttons & IN_FORWARD)
				{
					if(!g_strafeBlockW[client])
					{
						g_strafeCount[client]++
						g_strafeBlockS[client] = false
						g_strafeBlockW[client] = true
					}
					g_syncTick[client]++
				}
			}
			if(!StrEqual(g_style[client], "Sideways"))
				Format(g_style[client], 32, "Sideways")
		}
	}
}

void Gain(int client, float vel[3], float angles[3])
{
	//https://forums.alliedmods.net/showthread.php?t=287039 gain calculations
	float velocity[3]
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity)
	velocity[2] = 0.0
	float gaincoeff
	float fore[3], side[3], wishvel[3], wishdir[3]
	float wishspeed, wishspd, currentgain
	GetAngleVectors(angles, fore, side, NULL_VECTOR)
	fore[2] = 0.0
	side[2] = 0.0
	NormalizeVector(fore, fore)
	NormalizeVector(side, side)
	for(int i = 0; i < 2; i++)
		wishvel[i] = fore[i] * vel[0] + side[i] * vel[1]
	wishspeed = NormalizeVector(wishvel, wishdir)
	if(wishspeed > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") && GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") != 0.0)
		wishspeed = GetEntPropFloat(client, Prop_Send, "m_flMaxspeed")
	if(wishspeed)
	{
		wishspd = (wishspeed > 30.0) ? 30.0 : wishspeed
		currentgain = GetVectorDotProduct(velocity, wishdir)
		if(currentgain < 30.0)
			gaincoeff = (wishspd - FloatAbs(currentgain)) / wishspd
		g_gain[client] += gaincoeff
	}
}
