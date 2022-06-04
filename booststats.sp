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

#define semicolon 1
#define newdecls required

#define MAXPLAYER MAXPLAYERS + 1

//float g_boostTimeStart[MAXPLAYER];
//float g_boostTimeEnd[MAXPLAYER];
float g_throwTime[MAXPLAYER][2];
float g_projectileVel[MAXPLAYER];
float g_vel[MAXPLAYER];
//bool g_duck[MAXPLAYER];
bool g_boostStats[MAXPLAYER];
float g_angles[MAXPLAYER][3];
Handle g_cookie;
//bool g_boostProcess[MAXPLAYER];
//float g_boostPerf[MAXPLAYER][2];
bool g_created[MAXPLAYER];
native int Trikz_GetClientPartner(int client);
float g_groundTime[MAXPLAYER];
float g_duckTime[MAXPLAYER];

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh",
	description = "Measures time between attack and jump.",
	version = "0.35",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_bs", cmd_booststats);

	g_cookie = RegClientCookie("bs", "booststats", CookieAccess_Protected);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i) == true)
		{
			OnClientPutInServer(i);
		}
	}

	HookEvent("player_jump", OnJump, EventHookMode_PostNoCopy);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("Trikz_GetClientPartner");

	return APLRes_Success;
}

public void OnClientPutInServer(int client)
{
	if(AreClientCookiesCached(client) == false)
	{
		g_boostStats[client] = false;
	}

	SDKHook(client, SDKHook_StartTouch, SDKStartTouch);
}

public void OnClientCookiesCached(int client)
{
	char value[8] = "";
	GetClientCookie(client, g_cookie, value, sizeof(value));
	g_boostStats[client] = view_as<bool>(StringToInt(value));
}

public Action cmd_booststats(int client, int args)
{
	g_boostStats[client] = !g_boostStats[client];

	char value[8] = "";
	IntToString(g_boostStats[client], value, sizeof(value));
	SetClientCookie(client, g_cookie, value);

	PrintToChat(client, g_boostStats[client] ? "Boost stats is on now." : "Boost stats is off now.");

	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(IsChatTrigger() == false)
	{
		if(StrEqual(sArgs, "bs", false) == true)
		{
			cmd_booststats(client, 0);
		}
	}

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	/*if(g_created[client] == false)
	{
		g_boostProcess[client] = true;
		g_boostTimeStart[client] = GetGameTime();

		float velAbs[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velAbs);
		g_vel[client] = SquareRoot(Pow(velAbs[0], 2.0) + Pow(velAbs[1], 2.0));

		g_duck[client] = view_as<bool>(buttons & IN_DUCK);
		
		g_angles[client][0] = angles[0];
		g_angles[client][1] = angles[1];
	}*/

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_groundTime[client] == 0.0)
		{
			g_groundTime[client] = GetGameTime();
		}
	}

	else if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(GetGameTime() - g_groundTime[client] < 0.15)
		{
			g_groundTime[client] = 0.0;
		}
	}

	return Plugin_Continue;
}

public void CalculationProcess(int client)
{
	//g_boostProcess[client] = true;
	//g_boostTimeStart[client] = GetGameTime();
	g_throwTime[client][0] = GetGameTime();

	float vel[3] = {0.0, 0.0, 0.0};
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);
	g_vel[client] = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0));

	//g_duck[client] = view_as<bool>(buttons & IN_DUCK);
	//g_duck[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucking"));
	//g_angles[client][0] = angles[0];
	//g_angles[client][1] = angles[1];
	GetClientEyeAngles(client, g_angles[client]);
	//PrintToServer("%f", GetEntPropFloat(client, Prop_Data, "m_flDucktime"));
	g_duckTime[client] = GetEntPropFloat(client, Prop_Data, "m_flDucktime");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile", false) == true)
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnProjectile);
	}
}

public void SDKSpawnProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

	//g_boostPerf[client][0] = GetGameTime();

	RequestFrame(frame_projectileVel, entity);

	g_created[client] = true;

	CalculationProcess(client);
}


public void frame_projectileVel(int entity)
{
	if(IsValidEntity(entity) == true)
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		
		if(0 < client <= MaxClients && g_projectileVel[client] == 0.0)
		{
			float vel[3] = {0.0, 0.0, 0.0};
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);

			g_projectileVel[client] = GetVectorLength(vel); //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}
}

public Action SDKStartTouch(int entity, int other)
{
	if(0 < other <= MaxClients && g_projectileVel[other] == 0.0)
	{
		char classname[32] = "";
		GetEntityClassname(entity, classname, sizeof(classname));

		if(StrEqual(classname, "flashbang_projectile", false) == true)
		{
			float vel[3] = {0.0, 0.0, 0.0};
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);

			g_projectileVel[other] = GetVectorLength(vel); //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}

	return Plugin_Continue
}

public void OnJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	//if(g_boostProcess[client] == true)
	{
		//g_boostTimeEnd[client] = GetGameTime();
		g_throwTime[client][1] = GetGameTime();
		//g_boostPerf[client][1] = GetGameTime();

		CreateTimer(0.1, timer_waitSpawn, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action timer_waitSpawn(Handle timer, int client)
{
	if(IsClientInGame(client) == true)
	{
		//float time = g_boostTimeEnd[client] - g_boostTimeStart[client];
		float time = g_throwTime[client][1] - g_throwTime[client][0];

		if(time < 0.3 && g_created[client] == true && g_groundTime[client] > 0.15)
		{
			if(g_boostStats[client] == true)
			{
				//PrintToChat(client, "\x01Time: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", g_boostPerf[client][0] < g_boostPerf[client][1] ? "\x07FF0000" : "\x077CFC00", g_boostTimeEnd[client] - g_boostTimeStart[client], g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
				PrintToChat(client, "\x01Time: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
			}

			if(0 < Trikz_GetClientPartner(client) <= MaxClients && IsClientInGame(Trikz_GetClientPartner(client)) == true && g_boostStats[Trikz_GetClientPartner(client)] == true)
			{
				//PrintToChat(Trikz_GetClientPartner(client), "\x07DCDCDCTime: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", g_boostPerf[client][0] < g_boostPerf[client][1] ? "\x07FF0000" : "\x077CFC00", g_boostTimeEnd[client] - g_boostTimeStart[client], g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
				PrintToChat(Trikz_GetClientPartner(client), "\x07DCDCDCTime: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
			}

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsClientObserver(i) == true)
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget");
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode");

					if(observerMode < 7 && observerTarget == client && g_boostStats[i] == true)
					{
						PrintToChat(i, "\x01Time: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
					}

					else if(0 < Trikz_GetClientPartner(client) <= MaxClients && observerMode < 7 && observerTarget == Trikz_GetClientPartner(client) && g_boostStats[i] == true)
					{
						PrintToChat(i, "\x07DCDCDCTime: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
					}
				}
			}

			//g_boostProcess[client] = false;
			g_created[client] = false;
			g_groundTime[client] = 0.0;
			g_projectileVel[client] = 0.0;
		}
	}

	return Plugin_Continue;
}
