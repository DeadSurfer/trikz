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
#include <clientprefs>

float g_boostTimeStart[MAXPLAYERS + 1]
float g_boostTimeEnd[MAXPLAYERS + 1]
float g_projectileVel[MAXPLAYERS + 1]
float g_vel[MAXPLAYERS + 1]
bool g_duck[MAXPLAYERS + 1]
bool g_boostStats[MAXPLAYERS + 1]
float g_angles[MAXPLAYERS + 1][3]
Handle g_cookie
bool g_boostProcess[MAXPLAYERS + 1]
bool g_boostPerf[MAXPLAYERS + 1][2]
bool g_created[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh",
	description = "Measures time between attack and jump",
	version = "0.2",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_bs", cmd_booststats)
	g_cookie = RegClientCookie("bs", "booststats", CookieAccess_Protected)
	for(int i = 1; i <= MaxClients; i++)
		if(IsValidEntity(i))
			OnClientPutInServer(i)
	HookEvent("player_jump", OnJump, EventHookMode_PostNoCopy)
}

public void OnClientPutInServer(int client)
{
	if(!AreClientCookiesCached(client))
		g_boostStats[client] = false
	SDKHook(client, SDKHook_StartTouch, SDKStartTouch)
}

public void OnClientCookiesCached(int client)
{
	char value[16]
	GetClientCookie(client, g_cookie, value, 16)
	g_boostStats[client] = view_as<bool>(StringToInt(value))
}

Action cmd_booststats(int client, int args)
{
	g_boostStats[client] = !g_boostStats[client]
	char value[16]
	IntToString(g_boostStats[client], value, 16)
	SetClientCookie(client, g_cookie, value)
	PrintToChat(client, g_boostStats[client] ? "Boost stats is on." : "Boost stats is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "bs"))
			cmd_booststats(client, 0)
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(GetEntityFlags(client) & FL_ONGROUND && buttons & IN_ATTACK)
	{
		g_boostProcess[client] = true
		g_boostTimeStart[client] = GetGameTime()
		float velAbs[3]
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velAbs)
		g_vel[client] = SquareRoot(Pow(velAbs[0], 2.0) + Pow(velAbs[1], 2.0))
		g_duck[client] = view_as<bool>(buttons & IN_DUCK)
		g_angles[client][0] = angles[0]
		g_angles[client][1] = angles[1]
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnProjectile)
}

void SDKSpawnProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
	if(!g_boostPerf[client][1])
		g_boostPerf[client][0] = true
	RequestFrame(frame_projectileVel, entity)
	g_created[client] = true
}

void frame_projectileVel(int entity)
{
	if(IsValidEntity(entity))
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
		float vel[3]
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel)
		g_projectileVel[client] = GetVectorLength(vel) //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		CreateTimer(0.4, timer_clear, client, TIMER_FLAG_NO_MAPCHANGE)
	}
}

Action timer_clear(Handle timer, int client)
{
	if(IsClientInGame(client))
		g_boostPerf[client][0] = false
}

Action SDKStartTouch(int entity, int other)
{
	if(0 < other <= MaxClients && !g_projectileVel[other])
	{
		char classname[32]
		GetEntityClassname(entity, classname, 32)
		if(StrEqual(classname, "flashbang_projectile"))
		{
			float vel[3]
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel)
			g_projectileVel[other] = GetVectorLength(vel) //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}
}

void OnJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(g_boostProcess[client])
	{
		g_boostTimeEnd[client] = GetGameTime()
		if(!g_boostPerf[client][0])
			g_boostPerf[client][1] = true
		CreateTimer(0.1, timer_waitSpawn, client, TIMER_FLAG_NO_MAPCHANGE)
	}
}

Action timer_waitSpawn(Handle timer, int client)
{
	if(IsClientInGame(client) && 0.0 < g_boostTimeEnd[client] - g_boostTimeStart[client] < 0.3 && g_created[client])
	{
		if(IsClientInGame(client) && g_boostStats[client])
			PrintToChat(client, "\x01Time: %s%.3f\x01, Speed: %.1f, Run: %.1f, Duck: %s, Angles: %.0f/%.0f", g_boostPerf[client][0] ? "\x07FF0000" : "\x077CFC00", g_boostTimeEnd[client] - g_boostTimeStart[client], g_projectileVel[client], g_vel[client], g_duck[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1])
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientObserver(i))
			{
				int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
				int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
				if(observerMode < 7 && observerTarget == client && g_boostStats[i])
					PrintToChat(i, "\x01Time: %s%.3f\x01, Speed: %.1f, Run: %.1f, Duck: %s, Angles: %.0f/%.0f", g_boostPerf[client][0] ? "\x07FF0000" : "\x077CFC00", g_boostTimeEnd[client] - g_boostTimeStart[client], g_projectileVel[client], g_vel[client], g_duck[client] ? "Yes" : "No", g_angles[client][0], g_angles[client][1])
			}
		}
		g_boostProcess[client] = false
		g_boostPerf[client][0] = false
		g_boostPerf[client][1] = false
		g_created[client] = false
	}	
}
