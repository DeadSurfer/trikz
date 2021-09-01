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

float gF_boostTimeStart[MAXPLAYERS + 1]
float gF_boostTimeEnd[MAXPLAYERS + 1]
bool gB_boostRead[MAXPLAYERS + 1]
float gF_projectileVel[MAXPLAYERS + 1]
float gF_vel[MAXPLAYERS + 1]
float gF_duck[MAXPLAYERS + 1]
bool gB_boostStats[MAXPLAYERS + 1]
float gF_angles[MAXPLAYERS + 1][3]

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh",
	description = "Measures time between attack and jump",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_bs", cmd_booststats)
}

public void OnClientPutInServer(int client)
{
	gB_boostStats[client] = false
}

Action cmd_booststats(int client, int args)
{
	gB_boostStats[client] = !gB_boostStats[client]
	PrintToChat(client, gB_boostStats[client] ? "Boost stats is on." : "Boost stats is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "bs"))
			cmd_booststats(client, 0)
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
		SDKHook(entity, SDKHook_Spawn, SDKSpawnProjectile)
}

Action SDKSpawnProjectile(int entity)
{
	RequestFrame(frame_projectileVel, EntIndexToEntRef(entity))
}

void frame_projectileVel(int ref)
{
	int entity = EntRefToEntIndex(ref)
	if(IsValidEntity(entity))
	{
		float vel[3]
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel)
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
		gF_projectileVel[client] = GetVectorLength(vel) //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	char sWeapon[32]
	int activeWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon")
	if(IsValidEntity(activeWeapon))
		GetEntityClassname(activeWeapon, sWeapon, 32)
	if(StrEqual(sWeapon, "weapon_flashbang"))
	{
		if(GetEntProp(client, Prop_Data, "m_afButtonReleased") & IN_ATTACK)
		{
			gF_boostTimeStart[client] = GetEngineTime()
			gB_boostRead[client] = true
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel)
			gF_vel[client] = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0))
			gF_duck[client] = GetEntPropFloat(client, Prop_Data, "m_flDucktime")
			gF_angles[client][0] = angles[0]
			gF_angles[client][1] = angles[1]
		}
		if(GetEntityFlags(client) & FL_ONGROUND && buttons & IN_JUMP && gB_boostRead[client])
		{
			gF_boostTimeEnd[client] = GetEngineTime()
			if(gF_boostTimeEnd[client] - gF_boostTimeStart[client] < 2.0)
				CreateTimer(0.1, timer_finalMSG, client, TIMER_FLAG_NO_MAPCHANGE)
			gB_boostRead[client] = false
		}
	}
}

Action timer_finalMSG(Handle timer, int client)
{
	if(gB_boostStats[client])
		PrintToChat(client, "Time: %.3f, Speed: %.1f, Run: %.1f, Duck: %s, Angles: %.0f/%.0f", gF_boostTimeEnd[client] - gF_boostTimeStart[client], gF_projectileVel[client], gF_vel[client], gF_duck[client] ? "Yes" : "No", gF_angles[client][0], gF_angles[client][1])
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsClientObserver(i))
		{
			int observerTarget = GetEntPropEnt(i, Prop_Data, "m_hObserverTarget")
			int observerMode = GetEntProp(i, Prop_Data, "m_iObserverMode")
			if(observerMode < 7 && observerTarget == client && gB_boostStats[i])
				PrintToChat(i, "Time: %.3f, Speed: %.1f, Run: %.1f, Duck: %s, Angles: %.0f/%.0f", gF_boostTimeEnd[client] - gF_boostTimeStart[client], gF_projectileVel[client], gF_vel[client], gF_duck[client] ? "Yes" : "No", gF_angles[client][0], gF_angles[client][1])
		}
	}
}
