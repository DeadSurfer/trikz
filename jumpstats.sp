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
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define MAXPLAYER MAXPLAYERS + 1

bool g_jumped[MAXPLAYER] = {false, ...};
float g_origin[MAXPLAYER][3];
int g_strafeCount[MAXPLAYER] = {0, ...};
bool g_ladder[MAXPLAYER] = {false, ...};
float g_preVel[MAXPLAYER][3];
bool g_jumpstats[MAXPLAYER] = {false, ...};
bool g_strafeFirst[MAXPLAYER] = {false, ...};
int g_tick[MAXPLAYER] = {0, ...};
int g_syncTick[MAXPLAYER] = {0, ...};
int g_tickAir[MAXPLAYER] = {0, ...};
bool g_countjump[MAXPLAYER] = {false, ...};
float g_dot[MAXPLAYER] = {0.0, ...};
bool g_strafeBlockD[MAXPLAYER] = {false, ...};
bool g_strafeBlockA[MAXPLAYER] = {false, ...};
bool g_strafeBlockS[MAXPLAYER] = {false, ...};
bool g_strafeBlockW[MAXPLAYER] = {false, ...};
char g_style[MAXPLAYER][32];
float g_dotTime[MAXPLAYER] = {0.0, ...};
bool g_runboost[MAXPLAYER] = {false, ...};
int g_rbBooster[MAXPLAYER] = {0, ...};
float g_boostTime[MAXPLAYER] = {0.0, ...};
float g_skyOrigin[MAXPLAYER] = {0.0, ...};
int g_entityButtons[MAXPLAYER] = {0, ...};
native int Trikz_GetClientButtons(int client);
bool g_teleported[MAXPLAYER] = {false, ...};
Handle g_cookie = INVALID_HANDLE;
float g_skyAble[MAXPLAYER] = {0.0, ...};
float g_gain[MAXPLAYER] = {0.0, ...};
int g_entityFlags[MAXPLAYER] = {0, ...};
DynamicHook g_teleport = null;

public Plugin myinfo =
{
	name = "Jump stats",
	author = "Smesh",
	description = "Measures distance difference between two vectors",
	version = "0.23",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	HookEvent("player_jump", Event_PlayerJump);

	g_cookie = RegClientCookie("js", "jumpstats", CookieAccess_Protected);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i) == true)
		{
			OnClientPutInServer(i);
		}
	}

	RegConsoleCmd("sm_js", cmd_jumpstats);

	//char output[][] = {"OnStartTouch", "OnEndTouchAll", "OnTouching", "OnStartTouch", "OnTrigger"};

	//for(int i = 0; i < sizeof(output); i++)
	//{
	//	HookEntityOutput("trigger_teleport", output[i], output_teleport); //https://developer.valvesoftware.com/wiki/Trigger_teleport
	//	HookEntityOutput("trigger_teleport_relative", output[i], output_teleport); //https://developer.valvesoftware.com/wiki/Trigger_teleport_relative
	//}

	if(LibraryExists("trueexpert") == false)
	{
		Handle gamedata = LoadGameConfigFile("sdktools.games");

		int offset = GameConfGetOffset(gamedata, "Teleport");

		delete gamedata;
		
		if(offset == -1)
		{
			SetFailState("[DHooks] Offset for Teleport function is not found!");

			return;
		}
		
		g_teleport = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);

		if(g_teleport == INVALID_HANDLE)
		{
			SetFailState("[DHooks] Could not create Teleport hook function!");

			return;
		}
		
		g_teleport.AddParam(HookParamType_VectorPtr);
		g_teleport.AddParam(HookParamType_ObjectPtr);
		g_teleport.AddParam(HookParamType_VectorPtr);
	}

	RegPluginLibrary("trueexpert-jumpstats");

	return;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Trikz_GetClientButtons");

	return APLRes_Success;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_Touch, TouchClient);

	SDKHook(client, SDKHook_StartTouch, SDKSkyJump);

	if(AreClientCookiesCached(client) == false)
	{
		g_jumpstats[client] = false;
	}

	return;
}

public void OnClientCookiesCached(int client)
{
	char value[16] = "";
	GetClientCookie(client, g_cookie, value, 16);
	g_jumpstats[client] = view_as<bool>(StringToInt(value));

	return;
}

public Action cmd_jumpstats(int client, int args)
{
	g_jumpstats[client] = !g_jumpstats[client];

	char value[16] = "";
	IntToString(g_jumpstats[client], value, 16);
	SetClientCookie(client, g_cookie, value);

	PrintToChat(client, g_jumpstats[client] ? "Jump stats is on." : "Jump stats is off.");

	return Plugin_Handled;
}

/*public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "js"))
			cmd_jumpstats(client, 0);
	return Plugin_Continue;
}*/

/*void output_teleport(const char[] output, int caller, int activator, float delay)
{
	if(0 < activator <= MaxClients)
		g_teleported[activator] = true;
}*/

public Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(g_tick[client] == 30 && (GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0))
	{
		g_jumped[client] = true;

		g_teleported[client] = false;

		float origin[3] = {0.0, ...};

		if(g_runboost[client] == true)
		{
			GetClientAbsOrigin(g_rbBooster[client], origin);
		}

		else if(g_runboost[client] == false)
		{
			GetClientAbsOrigin(client, origin);
		}

		g_origin[client][0] = origin[0];
		g_origin[client][1] = origin[1];
		g_origin[client][2] = g_runboost[client] == true ? GetGroundPos(g_rbBooster[client]) : GetGroundPos(client);

		float vel[3] = {0.0, ...};
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel); //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3

		g_preVel[client][0] = vel[0];
		g_preVel[client][1] = vel[1];

		g_countjump[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucking", 1));

		g_dotTime[client] = GetEngineTime();
	}

	g_skyOrigin[client] = GetGroundPos(client);

	g_skyAble[client] = GetGameTime();

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	g_entityButtons[client] = buttons;

	g_entityFlags[client] = GetEntityFlags(client);

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_tick[client] < 30)
		{
			g_tick[client]++;
		}
	}

	else if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && (g_jumped[client] == true || g_ladder[client] == true))
		{
			if(GetEngineTime() - g_dotTime[client] < 0.4)
			{
				float eye[3] = {0.0, ...};

				GetClientEyeAngles(client, eye);

				eye[0] = Cosine(DegToRad(eye[1]));
				eye[1] = Sine(DegToRad(eye[1]));
				eye[2] = 0.0;

				float velAbs[3] = {0.0, ...};
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velAbs);

				float length = SquareRoot(Pow(velAbs[0], 2.0) + Pow(velAbs[1], 2.0));

				velAbs[0] /= length;
				velAbs[1] /= length;
				velAbs[2] = 0.0;

				g_dot[client] = GetVectorDotProduct(eye, velAbs); //https://onedrive.live.com/?authkey=%21ACwrZlLqDTC92n0&cid=879961B2A0BE0AAE&id=879961B2A0BE0AAE%2116116&parId=879961B2A0BE0AAE%2126502&o=OneUp
			}

			g_tickAir[client]++;
		}
	}

	if(g_jumped[client] == true)
	{
		Sync(client, buttons, mouse);

		Gain(client, vel, angles);
	}

	if(GetEntityFlags(client) & FL_ONGROUND && g_jumped[client] == true)
	{
		char print[256] = "";

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(client, origin);

		char flat[32] = "";

		if(GetGroundPos(client) - g_origin[client][2] > 0.04)
		{
			Format(flat, 32, "[UP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		else if(GetGroundPos(client) - g_origin[client][2] < -0.04)
		{
			Format(flat, 32, "[DROP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0)) + 32.0; //http://mathonline.wikidot.com/the-distance-between-two-vectors

		float pre = SquareRoot(Pow(g_preVel[client][0], 2.0) + Pow(g_preVel[client][1], 2.0)); //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point

		float sync = -1.0;

		sync += float(g_syncTick[client]);

		if(sync == -1.0)
		{
			sync = 0.0;
		}

		sync /= float(g_tickAir[client]);
		
		sync *= 100.0;

		if(1000.0 > distance >= 230.0 && pre < 280.0)
		{
			if(g_jumpstats[client] == true)
			{
				Format(print, sizeof(print), "%s%s%s%sJump: %.0f units\nPre: %.0f u/s\nStrafes: %i\nSync: %.0f％\nGain: %.0f％\nStyle: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]); //https://en.wikipedia.org/wiki/Percent_sign U+FF05

				Handle KeyHintText = StartMessageOne("KeyHintText", client);

				BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

				bfmsg.WriteByte(true);
				bfmsg.WriteString(print);

				EndMessage();

				PrintToConsole(client, "%s%s%s%sJump: %.0f units, Pre: %.0f u/s, Strafes: %i, Sync: %.0f%%, Gain: %.0f%%, Style: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]);
			}

			if(g_runboost[client] == true && g_jumpstats[g_rbBooster[client]] == true)
			{
				Format(print, sizeof(print), "%s%s%s%sJump: %.0f units\nPre: %.0f u/s\nStrafes: %i\nSync: %.0f％\nGain: %.0f％\nStyle: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]);

				Handle KeyHintText = StartMessageOne("KeyHintText", g_rbBooster[client]);

				BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

				bfmsg.WriteByte(true);
				bfmsg.WriteString(print);

				EndMessage();

				PrintToConsole(g_rbBooster[client], "%s%s%s%sJump: %.0f units, Pre: %.0f u/s, Strafes: %i, Sync: %.0f%%, Gain: %.0f%%, Style: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]);
			}
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsClientObserver(i) == true)
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget");
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode");

				if(observerMode < 7 && observerTarget == client && g_jumpstats[i] == true)
				{
					if(1000.0 > distance >= 230.0 && pre < 280.0)
					{
						Format(print, sizeof(print), "%s%s%s%sJump: %.0f units\nPre: %.0f u/s\nStrafes: %i\nSync: %.0f％\nGain: %.0f％\nStyle: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]);

						Handle KeyHintText = StartMessageOne("KeyHintText", i);

						BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

						bfmsg.WriteByte(true);
						bfmsg.WriteString(print);

						EndMessage();

						PrintToConsole(i, "%s%s%s%sJump: %.0f units, Pre: %.0f u/s, Strafes: %i, Sync: %.0f%%, Gain: %.0f%%, Style: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, pre, g_strafeCount[client], sync, g_gain[client], g_style[client]);
					}
				}
			}
		}

		ResetFactory(client);
	}

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity");

		if(groundEntity == 0 && g_runboost[client] == true)
		{
			g_runboost[client] = false;
		}
	}

	if(GetEntityMoveType(client) & MOVETYPE_LADDER && !(GetEntityFlags(client) & FL_ONGROUND)) //ladder bit bugs with noclip
	{
		ResetFactory(client);

		g_ladder[client] = true;

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(client, origin);

		for(int i = 0; i <= 2; i++)
		{
			g_origin[client][i] = origin[i];
		}

		g_strafeFirst[client] = true;
	}

	if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && g_ladder[client])
	{
		Sync(client, buttons, mouse);
		
		Gain(client, vel, angles);
	}

	if(GetEntityFlags(client) & FL_ONGROUND && g_ladder[client])
	{
		char print[256] = "";

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(client, origin);

		if(-3.0 <= GetGroundPos(client) - g_origin[client][2] <= 3.0)
		{
			float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0));

			float sync = -1.0;

			if(g_syncTick[client] > 0)
			{
				sync += float(g_syncTick[client]);

				if(sync == -1.0)
				{
					sync = 0.0;
				}

				sync /= float(g_tickAir[client]);
				sync *= 100.0;

				//PrintToServer("Z differents: %f", GetGroundPos(client) - g_origin[client][2]);

				if(g_jumpstats[client] == true)
				{
					if(190.0 > distance >= 22.0)
					{
						Format(print, sizeof(print), "%sLadder: %.0f units\nStrafes: %i\nSync: %.0f\nGain: %.0f％", g_teleported[client] == true ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client]);

						Handle KeyHintText = StartMessageOne("KeyHintText", client);

						BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

						bfmsg.WriteByte(true);
						bfmsg.WriteString(print);

						EndMessage();

						PrintToConsole(client, "%sLadder: %.0f units, Strafes: %i, Sync: %.0f, Gain: %.0f%%", g_teleported[client] == true ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client]);
					}
				}

				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) == true && IsClientObserver(i) == true)
					{
						int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget");
						int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode");

						if(observerMode < 7 && observerTarget == client && g_jumpstats[i] == true)
						{
							if(190.0 > distance >= 22.0)
							{
								Format(print, sizeof(print), "%sLadder: %.0f units\nStrafes: %i\nSync: %.0f\nGain: %.0f％", g_teleported[client] == true ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client]);

								Handle KeyHintText = StartMessageOne("KeyHintText", i);

								BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

								bfmsg.WriteByte(true);
								bfmsg.WriteString(print);

								EndMessage();

								PrintToConsole(i, "%sLadder: %.0f units, Strafes: %i, Sync: %.0f, Gain: %.0f%%", g_teleported[client] == true ? "[TP] " : "", distance, g_strafeCount[client], sync, g_gain[client]);
							}
						}
					}
				}
			}
		}

		ResetFactory(client);
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile", true) != -1)
	{
		SDKHook(entity, SDKHook_StartTouch, StartTouchProjectile);
	}

	return;
}

stock void ResetFactory(int client)
{
	g_jumped[client] = false;
	g_ladder[client] = false;
	g_strafeCount[client] = 0;
	g_syncTick[client] = 0;
	g_tick[client] = 0;
	g_tickAir[client] = 0;
	g_strafeBlockD[client] = false;
	g_strafeBlockA[client] = false;
	g_strafeBlockS[client] = false;
	g_strafeBlockW[client] = false;
	g_runboost[client] = false;
	g_teleported[client] = false;
	g_gain[client] = 0.0;

	return;
}

public Action StartTouchProjectile(int entity, int other)
{
	if(0 < other <= MaxClients && (g_jumped[other] == true || g_ladder[other] == true))
	{
		//https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L220-L231
		float entityOrigin[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityOrigin);

		float otherOrigin[3] = {0.0, ...};
		GetClientAbsOrigin(other, otherOrigin);

		float entityMaxs[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", entityMaxs);

		float delta = otherOrigin[2] - entityOrigin[2] - entityMaxs[2];

		if(0.0 < delta < 2.0)
		{
			ResetFactory(other);

			g_boostTime[other] = GetEngineTime();
		}
	}

	return Plugin_Continue;
}

public void TouchClient(int client, int other)
{
	if(0 < other <= MaxClients && g_tick[client] == 30)
	{
		float clientOrigin[3] = {0.0, ...};
		GetClientAbsOrigin(client, clientOrigin);

		float otherOrigin[3] = {0.0, ...};
		GetClientAbsOrigin(other, otherOrigin);

		float clientMaxs[3] = {0.0, ...};
		GetClientMaxs(client, clientMaxs);

		float delta = clientOrigin[2] - otherOrigin[2] - clientMaxs[2];

		//PrintToServer("%f", delta);

		//if(delta == -124.031250)
		if(delta == 0.031250)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				g_runboost[i] = false;

				g_rbBooster[i] = 0;
			}
			
			g_runboost[client] = true;

			g_rbBooster[client] = other;
		}
	}

	return;
}

public Action SDKSkyJump(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(GetClientButtons(other) & IN_DUCK) && view_as<int>(LibraryExists("trueexpert") ? Trikz_GetClientButtons(other) & IN_JUMP : g_entityButtons[other] & IN_JUMP) && GetEngineTime() - g_boostTime[client] > 0.15)
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
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velBooster);

			if(velBooster[2] > 0.0)
			{
				float velFlyer[3] = {0.0, ...};
				GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", velFlyer);

				float velNew[3] = {0.0, ...};
				//velNew[0] = velFlyer[0];
				//velNew[1] = velFlyer[1];
				velNew[2] = velBooster[2] * 3.15;

				//PrintToServer("b: %f f: %f", velBooster[2], velFlyer[2]);

				if(g_entityFlags[client] & FL_INWATER)
				{
					velNew[2] = velBooster[2] * 5.0;
				}
				
				else if(!(g_entityFlags[client] & FL_INWATER))
				{
					if(velFlyer[2] > -770.0)
					{
						if(velNew[2] >= 770.0)
						{
							velNew[2] = 770.0;
						}
					}

					else if(velFlyer[2] <= -770.0)
					{
						if(velNew[2] >= 800.0)
						{
							velNew[2] = 800.0;
						}
					}
				}

				if(FloatAbs(g_skyOrigin[client] - g_skyOrigin[other]) > 0.04 || GetGameTime() - g_skyAble[other] > 0.5)
				{
					char print[256] = "";

					ConVar gravity = FindConVar("sv_gravity");

					if(g_jumpstats[client] == true)
					{
						Format(print, sizeof(print), "Sky boost:\n%.0f u/s\n~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2]));

						Handle KeyHintText = StartMessageOne("KeyHintText", client);

						BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

						bfmsg.WriteByte(true);
						bfmsg.WriteString(print);

						EndMessage();

						PrintToConsole(client, "Sky boost: %.0f u/s, ~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2])); //https://www.omnicalculator.com/physics/maximum-height-projectile-motion
					} 

					if(g_jumpstats[other] == true)
					{
						Format(print, sizeof(print), "Sky boost:\n%.0f u/s\n~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2]));

						Handle KeyHintText = StartMessageOne("KeyHintText", other);

						BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

						bfmsg.WriteByte(true);
						bfmsg.WriteString(print);

						EndMessage();

						PrintToConsole(other, "Sky boost: %.0f u/s, ~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2]));
					}

					for(int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) == true && IsClientObserver(i) == true)
						{
							int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget");
							int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode");

							if(observerMode < 7 && observerTarget == client && g_jumpstats[i] == true)
							{
								Format(print, sizeof(print), "Sky boost:\n%.0f u/s\n~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2]));

								Handle KeyHintText = StartMessageOne("KeyHintText", i);

								BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);

								bfmsg.WriteByte(true);
								bfmsg.WriteString(print);

								EndMessage();
								
								PrintToConsole(i, "Sky boost: %.0f u/s, ~%.0f units", velNew[2], Pow(velNew[2], 2.0) / (1.91 * float(gravity.IntValue)) + FloatAbs(originFlyer[2] - originBooster[2]));
							}
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
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

	TR_TraceHullFilter(origin, originDir, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);

	float pos[3] = {0.0, ...};

	if(TR_DidHit(INVALID_HANDLE) == true)
	{
		TR_GetEndPosition(pos);
	}

	return pos[2];
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	if(entity == data)
	{
		return false;
	}

	return true;
}

stock void Sync(int client, int buttons, int mouse[2])
{
	if(g_dot[client] < -0.9) //backward
	{
		if(g_jumped[client] == true || g_ladder[client] == true)
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVELEFT)
				{
					if(g_strafeBlockA[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockD[client] = false;

						g_strafeBlockA[client] = true;
					}

					g_syncTick[client]++;
				}
			}

			else if(!(mouse[0] > 0))
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(g_strafeBlockD[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockD[client] = true;

						g_strafeBlockA[client] = false;
					}

					g_syncTick[client]++;
				}
			}

			if(StrEqual(g_style[client], "Backward", true) == false)
			{
				Format(g_style[client], 32, "Backward");
			}
		}
	}

	else if(g_dot[client] > 0.9) //forward
	{
		if(g_jumped[client] == true || g_ladder[client] == true)
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_MOVERIGHT)
				{
					if(g_strafeBlockD[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockD[client] = true;

						g_strafeBlockA[client] = false;
					}

					g_syncTick[client]++;
				}
			}

			else if(!(mouse[0] > 0))
			{
				if(buttons & IN_MOVELEFT)
				{
					if(g_strafeBlockA[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockD[client] = false;

						g_strafeBlockA[client] = true;
					}

					g_syncTick[client]++;
				}
			}

			if(StrEqual(g_style[client], "Forward", true) == false)
			{
				Format(g_style[client], 32, "Forward");
			}
		}
	}

	else if(!(g_dot[client] < -0.9) && !(g_dot[client] > 0.9)) //sideways
	{
		if(g_jumped[client] == true || g_ladder[client] == true)
		{
			if(mouse[0] > 0)
			{
				if(buttons & IN_BACK)
				{
					if(g_strafeBlockS[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockS[client] = true;

						g_strafeBlockW[client] = false;
					}

					g_syncTick[client]++;
				}
			}

			else if(!(mouse[0] > 0))
			{
				if(buttons & IN_FORWARD)
				{
					if(g_strafeBlockW[client] == false)
					{
						g_strafeCount[client]++;

						g_strafeBlockS[client] = false;

						g_strafeBlockW[client] = true;
					}

					g_syncTick[client]++;
				}
			}

			if(StrEqual(g_style[client], "Sideways", true) == false)
			{
				Format(g_style[client], 32, "Sideways");
			}
		}
	}

	return;
}

stock void Gain(int client, float vel[3], float angles[3])
{
	//https://forums.alliedmods.net/showthread.php?t=287039 gain calculations
	float velocity[3] = {0.0, ...};
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);
	velocity[2] = 0.0;

	float gaincoeff = 0.0;
	float fore[3] = {0.0, ...}, side[3] = {0.0, ...}, wishvel[3] = {0.0, ...}, wishdir[3] = {0.0, ...};
	float wishspeed = 0.0, wishspd = 0.0, currentgain = 0.0;

	GetAngleVectors(angles, fore, side, NULL_VECTOR);
	fore[2] = 0.0;
	side[2] = 0.0;
	NormalizeVector(fore, fore);
	NormalizeVector(side, side);

	for(int i = 0; i < 2; i++)
	{
		wishvel[i] = fore[i] * vel[0] + side[i] * vel[1];
	}

	wishspeed = NormalizeVector(wishvel, wishdir);

	if(wishspeed > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") && GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") != 0.0)
	{
		wishspeed = GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");
	}

	if(wishspeed > 0.0)
	{
		wishspd = (wishspeed > 30.0) ? 30.0 : wishspeed;

		currentgain = GetVectorDotProduct(velocity, wishdir);

		if(currentgain < 30.0)
		{
			gaincoeff = (wishspd - FloatAbs(currentgain)) / wishspd;
		}

		g_gain[client] += gaincoeff;
	}

	return;
}

stock MRESReturn DHooks_OnTeleport(int client, Handle hParams) //https://github.com/fafa-junhe/My-srcds-plugins/blob/0de19c28b4eb8bdd4d3a04c90c2489c473427f7a/all/teleport_stuck_fix.sp#L84
{
	bool originNull = DHookIsNullParam(hParams, 1);
	
	if(originNull == true)
	{
		return MRES_Ignored;
	}
	
	float origin[3] = {0.0, ...};
	DHookGetParamVector(hParams, 1, origin);

	static GlobalForward hForward = null; //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp

	hForward = new GlobalForward("JS_OnTeleport", ET_Ignore, Param_Cell, Param_Array);

	Call_StartForward(hForward);
	
	Call_PushCell(client);
	Call_PushArray(origin, 3);

	Call_Finish();
	
	return MRES_Ignored;
}

public void Trikz_OnTeleport(int client, float origin[3], float vel[3])
{
	g_teleported[client] = true;

	return;
}
