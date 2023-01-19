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
#define IsClientValid(%1) (0 < %1 <= MaxClients && IsClientInGame(%1))

int g_throwTick[MAXPLAYER][2];
float g_projectileVel[MAXPLAYER] = {0.0, ...};
float g_vel[MAXPLAYER] = {0.0, ...};
bool g_boostStats[MAXPLAYER] = {false, ...};
float g_angles[MAXPLAYER][3];
Handle g_cookie = INVALID_HANDLE;
native int Trikz_GetClientPartner(int client);
bool g_duck[MAXPLAYER] = {false, ...};

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh (Niks Jurēvičs)",
	description = "Measures time between attack and jump.",
	version = "0.40",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	LoadTranslations("booststats.phrases");

	RegPluginLibrary("trueexpert-booststats");

	HookEvent("player_jump", OnPlayerJump, EventHookMode_PostNoCopy);

	g_cookie = RegClientCookie("bs", "booststats", CookieAccess_Protected);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i) == true)
		{
			OnClientPutInServer(i);
		}
	}

	RegConsoleCmd("sm_bs", CommandBooststats);

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

	g_throwTick[client][0] = 0;

	return;
}

public void OnClientCookiesCached(int client)
{
	char value[8] = "";
	GetClientCookie(client, g_cookie, value, sizeof(value));
	g_boostStats[client] = view_as<bool>(StringToInt(value));

	return;
}

Action CommandBooststats(int client, int args)
{
	g_boostStats[client] = !g_boostStats[client];

	char value[8] = "";
	IntToString(g_boostStats[client], value, sizeof(value));
	SetClientCookie(client, g_cookie, value);

	char format[256] = "";
	Format(format, sizeof(format), "%T", g_boostStats[client] ? "BSON" : "BSOFF", client);
	SendMessage(client, format);

	return Plugin_Handled;
}

void CalculationProcess(int client)
{
	//g_throwTick[client][0] = GetEngineTime();
	g_throwTick[client][0] = GetGameTickCount();

	float vel[3] = {0.0, ...};
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel, 0);
	vel[2] = 0.0;

	g_vel[client] = GetVectorLength(vel);

	GetClientEyeAngles(client, g_angles[client]);
	g_duck[client] = view_as<bool>(GetEntProp(client, Prop_Data, "m_bDucked", 4, 0));

	return;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile", false) != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKSpawnProjectile);
	}

	return;
}

void SDKSpawnProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);

	RequestFrame(FrameProjectileVel, entity);

	CalculationProcess(client);

	return;
}

void FrameProjectileVel(int entity)
{
	if(IsValidEntity(entity) == true)
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", 0);
		
		if(IsClientValid(client) == true && g_projectileVel[client] == 0.0)
		{
			float vel[3] = {0.0, ...};
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel, 0);

			g_projectileVel[client] = GetVectorLength(vel); //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}

	return;
}

Action SDKStartTouch(int entity, int other)
{
	if(IsClientValid(other) == true && g_projectileVel[other] == 0.0)
	{
		char classname[32] = "";
		GetEntityClassname(entity, classname, sizeof(classname));

		if(StrContains(classname, "projectile", false) != -1)
		{
			float vel[3] = {0.0, ...};
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel, 0);

			g_projectileVel[other] = GetVectorLength(vel); //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		}
	}

	return Plugin_Continue
}

void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	//g_throwTick[client][1] = GetEngineTime();
	g_throwTick[client][1] = GetGameTickCount();

	CreateTimer(0.1, TimerPrint, client, TIMER_FLAG_NO_MAPCHANGE);

	return;
}

Action TimerPrint(Handle timer, int client)
{
	DoPrint(client);

	return Plugin_Continue;
}

void DoPrint(int client)
{
	if(IsClientInGame(client) == true)
	{
		float time = (float(g_throwTick[client][1]) - float(g_throwTick[client][0])) * (GetTickInterval() + 0.000000001);

		if(time < 0.3)
		{
			char format[256] = "";
			char color[8 + 1] = "";
			char duck[256] = "";

			char colorBuffer[53 + 1] = "";
			Format(colorBuffer, sizeof(colorBuffer), "%T", "TimeColor", client);
			char buffers[6][8 + 1];
			ExplodeString(colorBuffer, ",", buffers, 6, 9, false);

			if(time <= -0.100)
			{
				Format(color, sizeof(color), "%s", buffers[0]);
			}

			else if(-0.070 >= time > -0.100)
			{
				Format(color, sizeof(color), "%s", buffers[1]);
			}

			else if(-0.050 >= time > -0.070)
			{
				Format(color, sizeof(color), "%s", buffers[2]);
			}

			else if(-0.030 >= time > -0.050)
			{
				Format(color, sizeof(color), "%s", buffers[3]);
			}

			else if(0.000 >= time > -0.030)
			{
				Format(color, sizeof(color), "%s", buffers[4]);
			}

			else if(time > 0.0)
			{
				Format(color, sizeof(color), "%s", buffers[5]);
			}

			int partner = LibraryExists("trueexpert") ? Trikz_GetClientPartner(client) : 0;

			if(g_boostStats[client] == true)
			{
				Format(duck, sizeof(duck), "%T", g_duck[client] == true ? "DuckYes" : "DuckNo", client);
				Format(format, sizeof(format), "%T", "Message", client, color, time, g_projectileVel[client], g_vel[client], duck, g_angles[client][0], g_angles[client][1]);
				SendMessage(client, format);
			}

			if(IsClientValid(partner) == true && IsClientInGame(partner) == true && g_boostStats[partner] == true)
			{
				Format(duck, sizeof(duck), "%T", g_duck[client] == true ? "DuckYes" : "DuckNo", partner);
				Format(format, sizeof(format), "%T", "MessagePartner", partner, color, time, g_projectileVel[client], g_vel[client], duck, g_angles[client][0], g_angles[client][1]);
				SendMessage(partner, format);
			}

			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) == true && IsClientObserver(i) == true)
				{
					int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget", 0);
					int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode", 4, 0);

					if(observerMode < 7 && observerTarget == client && g_boostStats[i] == true)
					{
						Format(duck, sizeof(duck), "%T", g_duck[client] == true ? "DuckYes" : "DuckNo", i);
						Format(format, sizeof(format), "%T", "Message", i, color, time, g_projectileVel[client], g_vel[client], duck, g_angles[client][0], g_angles[client][1]);
						SendMessage(i, format);
					}

					else if(IsClientValid(partner) == true && observerMode < 7 && observerTarget == partner && g_boostStats[i] == true)
					{
						Format(duck, sizeof(duck), "%T", g_duck[client] == true ? "DuckYes" : "DuckNo", i);
						Format(format, sizeof(format), "%T", "MessagePartner", i, color, time, g_projectileVel[client], g_vel[client], duck, g_angles[client][0], g_angles[client][1]);
						SendMessage(i, format);
					}
				}
			}
		}

		g_projectileVel[client] = 0.0;
	}

	return;
}

void SendMessage(int client, const char[] text)
{
	char name[MAX_NAME_LENGTH] = "";
	GetClientName(client, name, sizeof(name));

	int team = GetClientTeam(client);

	char teamColor[32] = "";

	switch(team)
	{
		case 1:
		{
			Format(teamColor, sizeof(teamColor), "\x07CCCCCC");
		}

		case 2:
		{
			Format(teamColor, sizeof(teamColor), "\x07FF4040");
		}

		case 3:
		{
			Format(teamColor, sizeof(teamColor), "\x0799CCFF");
		}
	}

	char textReplaced[256] = "";
	Format(textReplaced, sizeof(textReplaced), "\x01%s", text);

	ReplaceString(textReplaced, sizeof(textReplaced), ";#", "\x07");
	ReplaceString(textReplaced, sizeof(textReplaced), "{default}", "\x01");
	ReplaceString(textReplaced, sizeof(textReplaced), "{teamcolor}", teamColor);

	if(IsClientValid(client) == true)
	{
		Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS); //https://github.com/JoinedSenses/SourceMod-IncludeLibrary/blob/master/include/morecolors.inc#L195
		BfWrite bf = UserMessageToBfWrite(buf); //dont show color codes in console.
		bf.WriteByte(client); //Message author
		bf.WriteByte(true); //Chat message
		bf.WriteString(textReplaced); //Message text
		EndMessage();
	}

	return;
}
