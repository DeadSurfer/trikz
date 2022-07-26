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
#define IsClientValid(%1) (0 < %1 <= MaxClients)

float g_throwTime[MAXPLAYER][2];
float g_projectileVel[MAXPLAYER];
float g_vel[MAXPLAYER];
bool g_boostStats[MAXPLAYER];
float g_angles[MAXPLAYER][3];
Handle g_cookie = INVALID_HANDLE;
native int Trikz_GetClientPartner(int client);
float g_duckTime[MAXPLAYER];

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh",
	description = "Measures time between attack and jump.",
	version = "0.36",
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

	return;
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

	return;
}

public void OnClientCookiesCached(int client)
{
	char value[8] = "";
	GetClientCookie(client, g_cookie, value, sizeof(value));
	g_boostStats[client] = view_as<bool>(StringToInt(value));

	return;
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

public void CalculationProcess(int client)
{
	g_throwTime[client][0] = GetEngineTime();

	float vel[3] = {0.0, 0.0, 0.0};
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);
	g_vel[client] = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0));

	GetClientEyeAngles(client, g_angles[client]);
	g_duckTime[client] = GetEntPropFloat(client, Prop_Data, "m_flDucktime");

	return;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile", false) == true)
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnProjectile);
	}

	return;
}

public void SDKSpawnProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

	RequestFrame(frame_projectileVel, entity);

	CalculationProcess(client);

	return;
}


public void frame_projectileVel(int entity)
{
	if(IsValidEntity(entity) == true)
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		
		if(IsClientValid(client) == true && g_projectileVel[client] == 0.0)
		{
			float vel[3] = {0.0, 0.0, 0.0};
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);

			g_projectileVel[client] = GetVectorLength(vel); //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}

	return;
}

public Action SDKStartTouch(int entity, int other)
{
	if(IsClientValid(other) == true && g_projectileVel[other] == 0.0)
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

	g_throwTime[client][1] = GetEngineTime();

	CreateTimer(0.1, timer_print, client, TIMER_FLAG_NO_MAPCHANGE);

	return;
}

public Action timer_print(Handle timer, int client)
{
	DoPrint(client);

	return Plugin_Continue;
}

stock void DoPrint(int client)
{
	if(IsClientInGame(client) == true)
	{
		float time = g_throwTime[client][1] - g_throwTime[client][0];
		int partner = Trikz_GetClientPartner(client);

		if(time < 0.3)
		{
			if(g_boostStats[client] == true)
			{
				PrintToChat(client, "\x01Time: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
			}

			if(IsClientValid(partner) == true && IsClientInGame(partner) == true && g_boostStats[partner] == true)
			{
				PrintToChat(partner, "\x07DCDCDCTime: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
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

					else if(IsClientValid(partner) == true && observerMode < 7 && observerTarget == partner && g_boostStats[i] == true)
					{
						PrintToChat(i, "\x07DCDCDCTime: %s%.3f\x01, Speed: %.0f, Run: %.0f, Duck: %s, Angles: %.0f/%.0f", time > 0.0 ? "\x07FF0000" : "\x077CFC00", time, g_projectileVel[client], g_vel[client], g_duckTime[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1]);
					}
				}
			}
		}

		g_projectileVel[client] = 0.0;
	}

	return;
}
