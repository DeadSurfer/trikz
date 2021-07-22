/*GNU GENERAL PUBLIC LICENSE

VERSION 2, JUNE 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.*/

/*GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.*/
#include <sdkhooks>
#include <sdktools>

bool gB_jumped[MAXPLAYERS + 1]
float gF_vec1[MAXPLAYERS + 1][3]
int gI_SWcount[MAXPLAYERS + 1]
int gI_ADcount[MAXPLAYERS + 1]
float gF_prevelocity[MAXPLAYERS + 1][3]
bool gB_IsRunboost[MAXPLAYERS + 1]
int gI_booster[MAXPLAYERS + 1]
bool gB_bouncedOff[2048]

public Plugin myinfo =
{
	name = "Runboost stats",
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
	HookEntityOutput("trigger_teleport", "OnStartTouch", OutputTrigger)
	HookEntityOutput("trigger_teleport", "OnEndTouch", OutputTrigger)
	HookEntityOutput("trigger_teleport_relative", "OnStartTouch", OutputTrigger)
	HookEntityOutput("trigger_teleport_relative", "OnEndTouch", OutputTrigger)
	HookEntityOutput("trigger_push", "OnStartTouch", OutputTrigger)
	HookEntityOutput("trigger_push", "OnEndTouch", OutputTrigger)
	HookEntityOutput("trigger_gravity", "OnStartTouch", OutputTrigger)
	HookEntityOutput("trigger_gravity", "OnEndTouch", OutputTrigger)
	//HookEntityOutput("trigger_multiple", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_multiple", "OnEndTouch", OutputTrigger)
}

Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	gB_jumped[client] = true
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_Touch, TouchClient)
}

void TouchClient(int client, int other) //client = flyer, other = booster
{
	if(other == 0)
		gB_jumped[client] = false
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(IsFakeClient(client))
		gB_jumped[client] = false
	int iGroundEntity = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity")
	if((0 < iGroundEntity <= MaxClients) && IsPlayerAlive(iGroundEntity) && IsClientInGame(iGroundEntity) && !IsFakeClient(iGroundEntity) && GetEntProp(iGroundEntity, Prop_Data, "m_CollisionGroup") == 5)
	{
		float vec1[3]
		GetEntPropVector(iGroundEntity, Prop_Send, "m_vecOrigin", vec1)
		gF_vec1[client][0] = vec1[0]
		gF_vec1[client][1] = vec1[1]
		gF_vec1[client][2] = vec1[2]
		float localvel[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", localvel) //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
		gF_prevelocity[client][0] = localvel[0]
		gF_prevelocity[client][1] = localvel[1]
		GetEntPropVector(iGroundEntity, Prop_Data, "m_vecVelocity", localvel) //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
		gF_prevelocity[iGroundEntity][0] = localvel[0]
		gF_prevelocity[iGroundEntity][1] = localvel[1]
		float clientOrigin[3]
		GetClientAbsOrigin(client, clientOrigin)
		float otherOrigin[3]
		GetClientAbsOrigin(iGroundEntity, otherOrigin)
		float clientMaxs[3]
		GetClientMaxs(client, clientMaxs)
		float delta = otherOrigin[2] - clientOrigin[2] - clientMaxs[2]
		if(delta == -124.031250 && (GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0))
		{
			gB_IsRunboost[client] = true
			gI_booster[client] = iGroundEntity
		}
	}
	if(gB_jumped[client] && gB_IsRunboost[client])
	{
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_FORWARD || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_BACK)
			if(gI_ADcount[client] == 0)
				gI_SWcount[client]++
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVELEFT || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVERIGHT)
			if(gI_SWcount[client] == 0)
				gI_ADcount[client]++
	}
	if(gB_jumped[client] && gB_IsRunboost[client] && GetEntityFlags(client) & FL_ONGROUND)
	{
		gB_jumped[client] = false
		gB_IsRunboost[client] = false
		float vec2[3]
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", vec2)
		char sZLevel[9]
		if(vec2[2] - gF_vec1[client][2] > 1.965332)
			Format(sZLevel, 9, "[Rise] ")
		if(vec2[2] - gF_vec1[client][2] < 0.000000)
			Format(sZLevel, 9, "[Fall] ")
		PrintToServer("jump: %f", vec2[2] - gF_vec1[client][2])
		float distance = SquareRoot(Pow(gF_vec1[client][0] - vec2[0], 2.0) + Pow(gF_vec1[client][1] - vec2[1], 2.0)) + 32.0 //http://mathonline.wikidot.com/the-distance-between-two-vectors
		float velocity = SquareRoot(Pow(gF_prevelocity[client][0], 2.0) + Pow(gF_prevelocity[client][1], 2.0)) //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		float velocitybooster = SquareRoot(Pow(gF_prevelocity[gI_booster[client]][0], 2.0) + Pow(gF_prevelocity[gI_booster[client]][1], 2.0)) //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		if(2000.0 > distance >= 460.0 && gI_SWcount[client] == 0 && gI_ADcount[client] == 0)
		{
			PrintToChat(client, "[SM] %sRBJump: %.1f units, Strafes: 0, Pre: %.1f u/s", sZLevel, distance, velocity)
			PrintToChat(gI_booster[client], "[SM] %sRBJump: %.1f units, Strafes: 0, Pre: %.1f u/s", sZLevel, distance, velocitybooster)
		}
		if(2000.0 > distance >= 460.0 && gI_SWcount[client] > 0)
		{
			PrintToChat(client, "[SM] %sRBJump: %.1f units, (S-W) Strafes: %i, Pre: %.1f u/s", sZLevel, distance, gI_SWcount[client], velocity)
			PrintToChat(gI_booster[client], "[SM] %sRBJump: %.1f units, (S-W) Strafes: %i, Pre: %.1f u/s", sZLevel, distance, gI_SWcount[client], velocitybooster)
		}
		if(2000.0 > distance >= 460.0 && gI_ADcount[client] > 0)
		{
			PrintToChat(client, "[SM] %sRBJump: %.1f units, (A-D) Strafes: %i, Pre: %.1f u/s", sZLevel, distance, gI_ADcount[client], velocity)
			PrintToChat(gI_booster[client], "[SM] %sRBJump: %.1f units, (A-D) Strafes: %i, Pre: %.1f u/s", sZLevel, distance, gI_ADcount[client], velocitybooster)
		}
		gI_SWcount[client] = 0
		gI_ADcount[client] = 0
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "projectile") != -1)
	{
		gB_bouncedOff[entity] = false
		SDKHook(entity, SDKHook_StartTouch, StartTouchProjectile)
		SDKHook(entity, SDKHook_EndTouch, EndTouchProjectile)
	}
}

Action StartTouchProjectile(int entity, int other)
{
	if(0 < other <= MaxClients && gB_jumped[other])
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
			gB_jumped[other] = false
	}
}

Action EndTouchProjectile(int entity, int other)
{
	if(!other)
		gB_bouncedOff[entity] = true
}

void OutputTrigger(const char[] output, int caller, int activator, float delay)
{
	if(gB_jumped[activator])
		gB_jumped[activator] = false
}
