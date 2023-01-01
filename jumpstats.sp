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
float g_preVel[MAXPLAYER][2][3];
bool g_jumpstats[MAXPLAYER] = {false, ...};
bool g_strafeFirst[MAXPLAYER] = {false, ...};
int g_tick[MAXPLAYER] = {0, ...};
float g_tickTime[MAXPLAYER] = {0.0, ...};
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
float g_oldVel[MAXPLAYER][3];
float g_loss[MAXPLAYER] = {0.0, ...};
float g_maxVel[MAXPLAYER] = {0.0, ...};
bool g_dotNormal[MAXPLAYER] = {false, ...};

public Plugin myinfo =
{
	name = "Jump stats",
	author = "Smesh (Nick Jurevich)",
	description = "Measures distance difference between two vectors.",
	version = "0.272",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	HookEvent("player_jump", OnJump, EventHookMode_Post); //https://hlmod.ru/threads/sourcepawn-urok-3-sobytija-events.36891/

	g_cookie = RegClientCookie("js", "jumpstats", CookieAccess_Protected);

	for(int i = 1; i <= MaxClients; ++i)
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
	char value[8] = "";
	GetClientCookie(client, g_cookie, value, sizeof(value));
	g_jumpstats[client] = view_as<bool>(StringToInt(value));

	return;
}

Action cmd_jumpstats(int client, int args)
{
	g_jumpstats[client] = !g_jumpstats[client];

	char value[8] = "";
	IntToString(g_jumpstats[client], value, sizeof(value));
	SetClientCookie(client, g_cookie, value);

	PrintToChat(client, "Jump stats is %s now.", g_jumpstats[client]  == true ? "on" : "off");

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

void OnJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(g_tickTime[client] >= 0.1 && (GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0))
	{
		g_jumped[client] = true;

		g_teleported[client] = false;

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(g_runboost[client] == true ? g_rbBooster[client] : client, origin);

		g_origin[client][0] = origin[0];
		g_origin[client][1] = origin[1];
		g_origin[client][2] = g_runboost[client] == true ? GetGroundPos(g_rbBooster[client]) : GetGroundPos(client);

		float vel[3] = {0.0, ...};
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel, 0); //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
		vel[2] = 0.0;
		
		g_preVel[client][0] = vel;

		g_countjump[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucking", 1, 0));

		g_dotTime[client] = GetEngineTime();

		float flatVel[3] = {0.0, ...};
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", flatVel, 0);
		flatVel[2] = 0.0;

		g_oldVel[client] = flatVel;

		g_dotNormal[client] = true;
	}

	g_skyOrigin[client] = GetGroundPos(client);

	g_skyAble[client] = GetGameTime();

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsPlayerAlive(client) == false || IsFakeClient(client) == true)
	{
		return Plugin_Continue;
	}

	g_entityButtons[client] = buttons;

	g_entityFlags[client] = GetEntityFlags(client);

	if(GetEntityMoveType(client) == MOVETYPE_NOCLIP) //Is not an bit. https://github.com/alliedmodders/sourcemod/blob/master/plugins/funcommands/noclip.sp#L38
	{
		if(g_jumped[client] == true || g_ladder[client] == true)
		{
			ResetFactory(client);
		}
	}

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(GetEntPropFloat(client, Prop_Send, "m_flStamina", 0) < 675.789428)
		{
			g_tick[client]++;

			g_tickTime[client] = g_tick[client] * GetTickInterval();
		}
	}

	else if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(g_tick[client] > 0)
		{
			g_tick[client] = 0;
		}

		if(g_jumped[client] == true || g_ladder[client] == true)
		{
			if(GetEngineTime() - g_dotTime[client] <= 0.3 || g_dotNormal[client] == false)
			{
				float eye[3] = {0.0, ...};
				GetClientEyeAngles(client, eye);
				eye[0] = Cosine(DegToRad(eye[1]));
				eye[1] = Sine(DegToRad(eye[1]));
				eye[2] = 0.0;

				float velAbs[3] = {0.0, ...};
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velAbs, 0);
				velAbs[2] = 0.0;

				float length = GetVectorLength(velAbs);
				velAbs[0] /= length;
				velAbs[1] /= length;
				
				g_dot[client] = GetVectorDotProduct(eye, velAbs); //https://onedrive.live.com/?authkey=%21ACwrZlLqDTC92n0&cid=879961B2A0BE0AAE&id=879961B2A0BE0AAE%2116116&parId=879961B2A0BE0AAE%2126502&o=OneUp
			}

			g_tickAir[client]++;
		}
	}

	if(g_jumped[client] == true)
	{
		Sync(client, buttons, mouse);

		GainAndLoss(client);

		MaxVel(client);
	}

	if(GetEntityFlags(client) & FL_ONGROUND && g_jumped[client] == true)
	{
		char print[2][256] = {"", ""};

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(client, origin);

		char flat[32] = "";

		if(GetGroundPos(client) - g_origin[client][2] > 0.0)
		{
			Format(flat, sizeof(flat), "[UP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		else if(GetGroundPos(client) - g_origin[client][2] < 0.0)
		{
			Format(flat, sizeof(flat), "[DROP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0)) + 32.0; //http://mathonline.wikidot.com/the-distance-between-two-vectors

		float pre = GetVectorLength(g_preVel[client][0]); //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		float preBooster = GetVectorLength(g_preVel[g_rbBooster[client]][1]);

		char pre_[8] = "";
		Format(pre_, sizeof(pre_), "%.0f", pre);
		char preRB[16] = "";
		Format(preRB, sizeof(preRB), "%.0f/%.0f", pre, preBooster);

		float sync = -1.0;
		sync += float(g_syncTick[client]);

		if(sync == -1.0)
		{
			sync = 0.0;
		}

		sync /= float(g_tickAir[client]);
		sync *= 100.0;

		Format(print[0], 256, "%s%s%s%sJump: %.2f units\nPre: %s u/s\nStrafes: %i\nSync: %.0f％\nGain: %.0f u/s\nLoss: %.0f u/s\nMax: %.0f u/s\nStyle: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, g_runboost[client] == true ? preRB : pre_, g_strafeCount[client], sync, g_gain[client], g_loss[client], g_maxVel[client], g_style[client]); //https://en.wikipedia.org/wiki/Percent_sign U+FF05
		Format(print[1], 256, "%s%s%s%sJump: %.2f units, Pre: %s u/s, Strafes: %i, Sync: %.0f%%, Gain: %.0f u/s, Loss: %.0f u/s, Max: %.0f u/s, Style: %s", g_runboost[client] == true ? "[RB] " : "", g_teleported[client] == true ? "[TP] " : "", flat, g_countjump[client] == true ? "[CJ] " : "", distance, g_runboost[client] == true ? preRB : pre_, g_strafeCount[client], sync, g_gain[client], g_loss[client], g_maxVel[client], g_style[client]);
		
		if(distance >= 230.0 && pre < 280.0)
		{
			if(g_jumpstats[client] == true)
			{
				if(g_teleported[client] == false)
				{
					Handle KeyHintText = StartMessageOne("KeyHintText", client);
					BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
					bfmsg.WriteByte(true);
					bfmsg.WriteString(print[0]);
					EndMessage();
				}

				PrintToConsole(client, "%s", print[1]);
			}

			if(g_runboost[client] == true && g_jumpstats[g_rbBooster[client]] == true)
			{
				if(g_teleported[client] == false)
				{
					Handle KeyHintText = StartMessageOne("KeyHintText", g_rbBooster[client]);
					BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
					bfmsg.WriteByte(true);
					bfmsg.WriteString(print[0]);
					EndMessage();
				}

				PrintToConsole(g_rbBooster[client], "%s", print[1]);
			}
		}

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsClientObserver(i) == true)
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

				if(observerMode < 7 && observerTarget == client && g_jumpstats[i] == true)
				{
					if(distance >= 230.0 && pre < 280.0)
					{
						if(g_teleported[client] == false)
						{
							Handle KeyHintText = StartMessageOne("KeyHintText", i);
							BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
							bfmsg.WriteByte(true);
							bfmsg.WriteString(print[0]);
							EndMessage();
						}

						PrintToConsole(i, "%s", print[1]);
					}
				}
			}
		}

		ResetFactory(client);
	}

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		int groundEntity = GetEntPropEnt(client, Prop_Data, "m_hGroundEntity", 0);

		if((groundEntity == 0 || groundEntity > MaxClients) && g_runboost[client] == true)
		{
			g_runboost[client] = false;
		}
	}

	if(GetEntityMoveType(client) == MOVETYPE_LADDER && !(GetEntityFlags(client) & FL_ONGROUND))
	{
		ResetFactory(client);

		g_ladder[client] = true;

		GetClientAbsOrigin(client, g_origin[client]);

		g_strafeFirst[client] = true;

		g_dotNormal[client] = false;
	}

	if(GetEntityMoveType(client) != MOVETYPE_LADDER && g_ladder[client] == true)
	{
		Sync(client, buttons, mouse);

		GainAndLoss(client);

		MaxVel(client);
	}
	
	if(GetEntityFlags(client) & FL_ONGROUND && g_ladder[client] == true)
	{
		char print[2][256] = {"", ""};

		float origin[3] = {0.0, ...};
		GetClientAbsOrigin(client, origin);

		//PrintToServer("%f", GetGroundPos(client) - g_origin[client][2]);

		char flat[32] = "";

		if(GetGroundPos(client) - g_origin[client][2] > 1.0)
		{
			Format(flat, sizeof(flat), "[UP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		else if(GetGroundPos(client) - g_origin[client][2] < -4.0)
		{
			Format(flat, sizeof(flat), "[DROP|%.0f] ", GetGroundPos(client) - g_origin[client][2]);
		}

		float distance = SquareRoot(Pow(g_origin[client][0] - origin[0], 2.0) + Pow(g_origin[client][1] - origin[1], 2.0));

		float sync = -1.0;
		sync += float(g_syncTick[client]);

		if(sync == -1.0)
		{
			sync = 0.0;
		}

		sync /= float(g_tickAir[client]);
		sync *= 100.0;

		Format(print[0], 256, "%s%sLadder: %.2f units\nStrafes: %i\nSync: %.0f％\nGain: %.0f u/s\nLoss: %.0f u/s\nMax: %.0f u/s", g_teleported[client] == true ? "[TP] " : "", flat, distance, g_strafeCount[client], sync, g_gain[client], g_loss[client], g_maxVel[client]);
		Format(print[1], 256, "%s%sLadder: %.2f units, Strafes: %i, Sync: %.0f%%, Gain: %.0f u/s, Loss: %.0f u/s, Max: %.0f u/s", g_teleported[client] == true ? "[TP] " : "", flat, distance, g_strafeCount[client], sync, g_gain[client], g_loss[client], g_maxVel[client]);

		//PrintToServer("Z differents: %f", GetGroundPos(client) - g_origin[client][2]);

		if(g_jumpstats[client] == true)
		{
			if(distance >= 22.0) //190.0
			{
				Handle KeyHintText = StartMessageOne("KeyHintText", client);
				BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
				bfmsg.WriteByte(true);
				bfmsg.WriteString(print[0]);
				EndMessage();

				PrintToConsole(client, "%s", print[1]);
			}
		}

		for(int i = 1; i <= MaxClients; ++i)
		{
			if(IsClientInGame(i) == true && IsClientObserver(i) == true)
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

				if(observerMode < 7 && observerTarget == client && g_jumpstats[i] == true)
				{
					if(distance >= 22.0)
					{
						Handle KeyHintText = StartMessageOne("KeyHintText", i);
						BfWrite bfmsg = UserMessageToBfWrite(KeyHintText);
						bfmsg.WriteByte(true);
						bfmsg.WriteString(print[0]);
						EndMessage();

						PrintToConsole(i, "%s", print[1]);
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

void ResetFactory(int client)
{
	g_jumped[client] = false;
	g_ladder[client] = false;
	g_strafeCount[client] = 0;
	g_syncTick[client] = 0;
	g_tickAir[client] = 0;
	g_strafeBlockD[client] = false;
	g_strafeBlockA[client] = false;
	g_strafeBlockS[client] = false;
	g_strafeBlockW[client] = false;
	g_runboost[client] = false;
	g_teleported[client] = false;
	g_gain[client] = 0.0;
	g_loss[client] = 0.0;
	g_maxVel[client] = 0.0;

	return;
}

Action StartTouchProjectile(int entity, int other)
{
	if(0 < other <= MaxClients && (g_jumped[other] == true || g_ladder[other] == true))
	{
		//https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L220-L231
		float nadeOrigin[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", nadeOrigin, 0);

		float clientOrigin[3] = {0.0, ...};
		GetClientAbsOrigin(other, clientOrigin);

		float nadeMaxs[3] = {0.0, ...};
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", nadeMaxs, 0);

		float delta = clientOrigin[2] - nadeOrigin[2] - nadeMaxs[2];

		if(0.0 < delta < 2.0)
		{
			ResetFactory(other);

			g_boostTime[other] = GetEngineTime();
		}
	}

	return Plugin_Continue;
}

Action TouchClient(int client, int other)
{
	if(0 < other <= MaxClients && g_tickTime[client] >= 0.1)
	{
		float originClient[3] = {0.0, ...};
		GetClientAbsOrigin(client, originClient);

		float originBooster[3] = {0.0, ...};
		GetClientAbsOrigin(other, originBooster);

		float clientMaxs[3] = {0.0, ...};
		GetClientMaxs(client, clientMaxs);

		float delta = originClient[2] - originBooster[2] - clientMaxs[2];

		//PrintToServer("%f", delta);

		if(delta == 0.031250) //Runboost?
		{
			g_runboost[client] = true;

			g_rbBooster[client] = other;

			float vel[3] = {0.0, ...};
			GetEntPropVector(other, Prop_Data, "m_vecVelocity", vel, 0); //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
			vel[2] = 0.0;

			g_preVel[other][1] = vel;
		}

		if(!(GetEntityFlags(other) & FL_ONGROUND)) //Allow to see sky boost after rb.
		{
			ResetFactory(client);
		}
	}

	return Plugin_Continue;
}

Action SDKSkyJump(int client, int other) //client = booster; other = flyer
{
	if(0 < client <= MaxClients && 0 < other <= MaxClients && !(GetClientButtons(other) & IN_DUCK) && view_as<int>(LibraryExists("trueexpert") ? Trikz_GetClientButtons(other) & IN_JUMP : g_entityButtons[other] & IN_JUMP) && GetEngineTime() - g_boostTime[client] > 0.15)
	{
		float originBooster[3] = {0.0, ...};
		GetClientAbsOrigin(client, originBooster);

		float originFlyer[3] = {0.0, ...};
		GetClientAbsOrigin(other, originFlyer);

		float boosterMaxs[3] = {0.0, ...};
		GetClientMaxs(client, boosterMaxs); //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L71

		float delta = originFlyer[2] - originBooster[2] - boosterMaxs[2];

		if(0.0 < delta < 2.0) //https://github.com/tengulawl/scripting/blob/master/boost-fix.sp#L75
		{
			float velBooster[3] = {0.0, ...};
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velBooster, 0);

			if(velBooster[2] > 0.0)
			{
				if(FloatAbs(g_skyOrigin[client] - g_skyOrigin[other]) > 0.0 || GetGameTime() - g_skyAble[other] > 0.5)
				{
					float velFlyer[3] = {0.0, ...};
					GetEntPropVector(other, Prop_Data, "m_vecAbsVelocity", velFlyer, 0);

					float velNew[3] = {0.0, ...};
					//velNew[0] = velFlyer[0];
					//velNew[1] = velFlyer[1];
					velNew[2] = velBooster[2] * 3.572;

					float midMax = 800.0 - (800.0 - 750.0) / 2.0;

					if(midMax > velNew[2])
					{
						velNew[2] = velNew[2] - (midMax - (velNew[2] / midMax) * midMax) / 2.0;
					}

					else if(midMax <= velNew[2])
					{
						velNew[2] = velNew[2] + (midMax - (velNew[2] / midMax) * midMax) / 2.0;
					}

					if(velNew[2] < 0.0)
					{
						velNew[2] = velNew[2];
					}
					
					else if(!(g_entityFlags[client] & FL_INWATER))
					{
						if(velFlyer[2] > -470.0)
						{
							if(velNew[2] >= 770.0)
							{
								velNew[2] = 770.0;
							}
						}

						else if(velFlyer[2] <= -470.0)
						{
							if(velNew[2] >= 800.0)
							{
								velNew[2] = 800.0;
							}
						}
					}

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

					for(int i = 1; i <= MaxClients; ++i)
					{
						if(IsClientInGame(i) == true && IsClientObserver(i) == true)
						{
							int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
							int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

							if(observerMode < 7 && (observerTarget == client || observerTarget == other) && g_jumpstats[i] == true)
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

float GetGroundPos(int client) //https://forums.alliedmods.net/showpost.php?p=1042515&postcount=4
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

bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	if(entity == data)
	{
		return false;
	}

	return true;
}

void Sync(int client, int buttons, int mouse[2])
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

void GainAndLoss(int client) //https://forums.alliedmods.net/showthread.php?p=2060983
{
	float flatVel[3] = {0.0, ...};
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flatVel, 0);
	flatVel[2] = 0.0;
	
	float velDelta = GetVectorLength(flatVel, false) - GetVectorLength(g_oldVel[client], false);
	
	if(velDelta > 0.0)
	{
		//g_PlayerStates[client][fStrafeGain][g_PlayerStates[client][nStrafes] - 1] += velDelta;
		g_gain[client] += velDelta;
	}

	else if(!(velDelta > 0.0))
	{
		//g_PlayerStates[client][fStrafeLoss][g_PlayerStates[client][nStrafes] - 1] -= velDelta;
		g_loss[client] -= velDelta;
	}

	g_oldVel[client] = flatVel;

	return;
}

void MaxVel(int client)
{
	float vel[3] = {0.0, ...};
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel, 0);
	vel[2] = 0.0;

	float flatVel = GetVectorLength(vel);

	if(g_maxVel[client] < flatVel)
	{
		g_maxVel[client] = flatVel;
	}

	return;
}

MRESReturn DHooks_OnTeleport(int client, Handle hParams) //https://github.com/fafa-junhe/My-srcds-plugins/blob/0de19c28b4eb8bdd4d3a04c90c2489c473427f7a/all/teleport_stuck_fix.sp#L84
{
	bool originNull = DHookIsNullParam(hParams, 1);
	
	if(originNull == true)
	{
		return MRES_Ignored;
	}
	
	float origin[3] = {0.0, ...};
	DHookGetParamVector(hParams, 1, origin);

	GlobalForward hForward = new GlobalForward("JS_OnTeleport", ET_Ignore, Param_Cell, Param_Array); //https://github.com/alliedmodders/sourcemod/blob/master/plugins/basecomm/forwards.sp
	Call_StartForward(hForward);
	Call_PushCell(client);
	Call_PushArray(origin, 3);
	Call_Finish();
	delete hForward;
	
	return MRES_Ignored;
}

public void Trikz_OnTeleport(int client, float origin[3])
{
	g_teleported[client] = true;

	return;
}
