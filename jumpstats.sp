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
float gF_origin[MAXPLAYERS + 1][3]
int gI_SWcount[MAXPLAYERS + 1]
int gI_ADcount[MAXPLAYERS + 1]
bool gB_ladder[MAXPLAYERS + 1]
float gF_preVel[MAXPLAYERS + 1][3]
//float gF_jumpTime[MAXPLAYERS + 1]
bool gB_bouncedOff[2048]
bool gB_jumpstats[MAXPLAYERS + 1]
bool gB_getFirstStrafe[MAXPLAYERS + 1]
int gI_tick[MAXPLAYERS + 1]
int gI_syncTick[MAXPLAYERS + 1][2]
int gI_tickAir[MAXPLAYERS + 1]

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
	//HookEntityOutput("trigger_teleport", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_teleport", "OnEndTouch", OutputTrigger)
	//HookEntityOutput("trigger_teleport_relative", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_teleport_relative", "OnEndTouch", OutputTrigger)
	//HookEntityOutput("trigger_push", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_push", "OnEndTouch", OutputTrigger)
	//HookEntityOutput("trigger_gravity", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_gravity", "OnEndTouch", OutputTrigger)
	//HookEntityOutput("trigger_multiple", "OnStartTouch", OutputTrigger)
	//HookEntityOutput("trigger_multiple", "OnEndTouch", OutputTrigger)
	RegConsoleCmd("sm_js", cmd_jumpstats)
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_Touch, TouchClient)
	gB_jumpstats[client] = false
}

Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	if(gB_jumpstats[client])
	{
		if(gI_tick[client] == 30 && GetEntityGravity(client) == 0.0 || GetEntityGravity(client) == 1.0)
		{
			gB_jumped[client] = true
			gB_getFirstStrafe[client] = true
			gI_syncTick[client][0] = 0
			gI_syncTick[client][1] = 0
			gI_tickAir[client] = 0
			float origin[3]
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin)
			gF_origin[client][0] = origin[0]
			gF_origin[client][1] = origin[1]
			gF_origin[client][2] = origin[2]
			float vel[3]
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel) //https://forums.alliedmods.net/showpost.php?p=2439964&postcount=3
			gF_preVel[client][0] = vel[0]
			gF_preVel[client][1] = vel[1]
		}
	}
}

Action cmd_jumpstats(int client, int args)
{
	gB_jumpstats[client] = !gB_jumpstats[client]
	if(gB_jumpstats[client])
		PrintToChat(client, "Jump stats is on.")
	else
		PrintToChat(client, "Jump stats is off.")
	return Plugin_Handled
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!IsChatTrigger())
		if(StrEqual(sArgs, "js"))
			cmd_jumpstats(client, 0)
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(gI_tick[client] < 30)
			gI_tick[client]++
	}
	else
		gI_tickAir[client]++
	if(gB_jumped[client])
	{
		if(gB_getFirstStrafe[client])
		{
			if(buttons & IN_FORWARD || buttons & IN_BACK)
				gI_SWcount[client]++
			if(buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT)
				gI_ADcount[client]++
			gB_getFirstStrafe[client] = false
		}
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_FORWARD || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_BACK)
			gI_SWcount[client]++
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVELEFT || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVERIGHT)
			gI_ADcount[client]++
		//{
		if(mouse[0] > 0)
		{
			if(buttons & IN_MOVERIGHT)
				gI_syncTick[client][0]++
			if(buttons & IN_BACK)
				gI_syncTick[client][1]++
		}
		if(mouse[0] < 0)
		{
			if(buttons & IN_MOVELEFT)
				gI_syncTick[client][0]++
			if(buttons & IN_FORWARD)
				gI_syncTick[client][1]++
		}
		/*if()
			if(mouse[0] < 0) //moving to left.
				gI_syncTick[client][0]++
		if(buttons & IN_BACK)
			if(mouse[0] > 0) //moving to right.
				gI_syncTick[client][1]++
		if(buttons & IN_FORWARD)
			if(mouse[0] < 0) //moving to left.
				gI_syncTick[client][1]++*/
		/*}
		else //moving to left.
			if(buttons & IN_MOVELEFT)
				gI_syncTick[client][0]++
		if(mouse[1] > 0) //moving to right.
		{
			if(buttons & IN_FORWARD)
				gI_syncTick[client][1]++
		}
		else //moving to left.
			if(buttons & IN_BACK)
				gI_syncTick[client][1]++*/
	}
	if(GetEntityFlags(client) & FL_ONGROUND && gB_jumped[client])
	{
		gB_jumped[client] = false
		float origin[3]
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin)
		char sZLevel[9]
		if(origin[2] - gF_origin[client][2] > 1.475586)
			Format(sZLevel, 9, "[Rise] ")
		if(origin[2] - gF_origin[client][2] < 0.793945)
			Format(sZLevel, 9, "[Fall] ")
		PrintToServer("jump: %f", origin[2] - gF_origin[client][2])
		float distance = SquareRoot(Pow(gF_origin[client][0] - origin[0], 2.0) + Pow(gF_origin[client][1] - origin[1], 2.0)) + 32.0 //http://mathonline.wikidot.com/the-distance-between-two-vectors
		float pre = SquareRoot(Pow(gF_preVel[client][0], 2.0) + Pow(gF_preVel[client][1], 2.0)) //https://math.stackexchange.com/questions/1448163/how-to-calculate-velocity-from-speed-current-location-and-destination-point
		float sync
		if(gI_SWcount[client] < gI_ADcount[client])
			sync += float(gI_syncTick[client][0])
		else if(gI_SWcount[client] > gI_ADcount[client])
			sync += float(gI_syncTick[client][1])
		sync /= float(gI_tickAir[client])
		sync *= 100.0
		if(1000.0 > distance > 230.0 && !gI_SWcount[client] && !gI_ADcount[client] && pre < 280.0)
			PrintToChat(client, "[SM] %sJump: %.1f units, Strafes: 0, Pre: %.01f u/s, Sync: %.1f%", sZLevel, distance, pre, sync)
		if(1000.0 > distance >= 230.0 && gI_SWcount[client] > gI_ADcount[client] && pre < 280.0)
			PrintToChat(client, "[SM] %sJump: %.1f units, (S-W) Strafes: %i, Pre: %.01f u/s, Sync: %.1f%", sZLevel, distance, gI_SWcount[client]++, pre, sync)
		if(1000.0 > distance >= 230.0 && gI_ADcount[client] > gI_SWcount[client] && pre < 280.0)
			PrintToChat(client, "[SM] %sJump: %.1f units, (A-D) Strafes: %i, Pre: %.01f u/s, Sync: %.1f%", sZLevel, distance, gI_ADcount[client]++, pre, sync)
		gI_SWcount[client] = 0
		gI_ADcount[client] = 0
	}
	if(GetEntityMoveType(client) == MOVETYPE_LADDER && !(GetEntityFlags(client) & FL_ONGROUND)) //ladder bit bugs with noclip
	{
		gB_ladder[client] = true
		float origin[3]
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin)
		gF_origin[client][0] = origin[0]
		gF_origin[client][1] = origin[1]
		gF_origin[client][2] = origin[2]
	}
	if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && gB_ladder[client])
	{
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_FORWARD || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_BACK)
			gI_SWcount[client]++
		if(GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVELEFT || GetEntProp(client, Prop_Data, "m_afButtonPressed") & IN_MOVERIGHT)
			gI_ADcount[client]++
	}
	if(GetEntityFlags(client) & FL_ONGROUND && gB_ladder[client])
	{
		gB_ladder[client] = false
		float origin[3]
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", origin)
		PrintToServer("ladder: %f", origin[2] - gF_origin[client][2])
		if(4.549926 >= origin[2] - gF_origin[client][2] >= -3.872436)
		{
			PrintToServer("ladder: success")
			float distance = SquareRoot(Pow(gF_origin[client][0] - origin[0], 2.0) + Pow(gF_origin[client][1] - origin[1], 2.0))
			if(190.0 > distance >= 22.0 && !gI_SWcount[client] && !gI_ADcount[client])
				PrintToChat(client, "[SM] Ladder: %.1f units!", distance)
			if(190.0 > distance >= 22.0 && gI_SWcount[client] > gI_ADcount[client])
				PrintToChat(client, "[SM] Ladder: %.1f units, (S-W) Strafes: %i", distance, gI_SWcount[client]++)
			if(190.0 > distance >= 22.0 && gI_ADcount[client] > gI_SWcount[client])
				PrintToChat(client, "[SM] Ladder: %.1f units, (A-D) Strafes: %i", distance, gI_ADcount[client]++)
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

void ResetFactory(int client)
{
	gB_jumped[client] = false
	gB_ladder[client] = false
	gI_SWcount[client] = 0
	gI_ADcount[client] = 0
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
			ResetFactory(other)
	}
}

Action EndTouchProjectile(int entity, int other)
{
	if(!other)
		gB_bouncedOff[entity] = true
}

void TouchClient(int client, int other)
{
	if(!other && (gB_jumped[client] || !gB_ladder[client]))
		ResetFactory(client)
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
			ResetFactory(client)
	}
}

void OutputTrigger(const char[] output, int caller, int activator, float delay)
{
	if(gB_jumped[activator] || gB_ladder[activator])
		ResetFactory(activator)
}
