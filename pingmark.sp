#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <trikz>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

#define ping_path				"models/expert_zone/pingtool/pingtool"
#define circle_arrow_path		"materials/expert_zone/pingtool/circle_arrow"
#define circle_point_path		"materials/expert_zone/pingtool/circle_point"
#define grad_path				"materials/expert_zone/pingtool/grad"
#define click_path				"expert_zone/pingtool/click.wav"

#define	OBS_MODE_IN_EYE 4	// follow a player in first person view
#define	OBS_MODE_CHASE 5	// follow a player in third person view

int client_pings[MAXPLAYERS];
int partner_pings[MAXPLAYERS];
int stored_partnered[MAXPLAYERS];

Handle timer_handle[MAXPLAYERS];
Handle delay_handle[MAXPLAYERS];

bool client_can_ping[MAXPLAYERS] = {true, ...};	

int gI_tick[MAXPLAYERS] = 0;

public Plugin myinfo =
{
	name = "ping",
	author = "rumour",
	description = "",
	version = "let's players use a ping system",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_ping", SM_Ping, "pings a position");
}

public void OnMapStart()
{
	char path[256];
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".mdl");
	PrecacheModel(path);
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".dx80.vtx");
	AddFileToDownloadsTable(path);
	
	Format(path, 256, "sound/%s", click_path);
	AddFileToDownloadsTable(path);
	PrecacheSound(click_path);
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".dx90.vtx");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".mdl");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".sw.vtx");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, ping_path);
	StrCat(path,255,".vvd");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, circle_arrow_path);
	StrCat(path,255,".vmt");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, circle_arrow_path);
	StrCat(path,255,".vtf");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, circle_point_path);
	StrCat(path,255,".vmt");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, circle_point_path);
	StrCat(path,255,".vtf");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, grad_path);
	StrCat(path,255,".vmt");
	AddFileToDownloadsTable(path);
	
	strcopy(path,255, grad_path);
	StrCat(path,255,".vtf");
	AddFileToDownloadsTable(path);
}

public Action SM_Ping(int client, int args)
{
	PING(client);
	
	return Plugin_Handled;
}

Action PING(int client)
{
	if(!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{white}You need to be alive to use this command!");
		return Plugin_Handled;
	}
	
	if(Trikz_FindPartner(client) < 1)
	{
		CPrintToChat(client, "{white}You need a partner to use this command!");
		return Plugin_Handled;
	}
	
	float ang[3], src[3], dst[3];
	
	GetClientEyePosition(client, src);
	
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, ang, NULL_VECTOR, NULL_VECTOR);
	
	ang[0] *= 8192.0;
	ang[1] *= 8192.0;
	ang[2] *= 8192.0;
	
	dst[0] = src[0] + ang[0];
	dst[1] = src[1] + ang[1];
	dst[2] = src[2] + ang[2];
	
	TR_TraceRayFilter(src, dst, MASK_ALL, RayType_EndPoint, is_player, client);
	
	if(TR_DidHit(null))
	{
		float end_pos[3];
		TR_GetEndPosition(end_pos, null);
		
		float end_plane[3];
		TR_GetPlaneNormal(null, end_plane);
		
		GetVectorAngles(end_plane, end_plane);
		
		float fwd[3];
		GetAngleVectors(end_plane, fwd, NULL_VECTOR, NULL_VECTOR);
		
		end_pos[0] += fwd[0] * 1.0;
		end_pos[1] += fwd[1] * 1.0;
		end_pos[2] += fwd[2] * 1.0;
		
		end_plane[0] -= 270.0;
		
		spawn_ping(client, end_pos, end_plane);
	}
	
	return Plugin_Continue;
}

public bool is_player(int entity, int mask, any data)
{
	if(entity == data || entity <= MaxClients)
	{
		return false;
	}
	return true;
}

public void spawn_ping(int client, float origin[3], float rotation[3])
{
	if(!client_can_ping[client])
	{
		return;
	}
	
	if(client_pings[client] > 0 && timer_handle[client] != null)
	{
		KillTimer(timer_handle[client]);
		AcceptEntityInput(client_pings[client], "Kill");
		AcceptEntityInput(partner_pings[Trikz_FindPartner(client)], "Kill");
		//RemoveEntity(client_pings[client]);
		//RemoveEntity(partner_pings[Timer_GetPartner(client)]);
		client_pings[client] = 0;
		partner_pings[Trikz_FindPartner(client)] = -1;
	}
	
	char path[255];
	strcopy(path,255,ping_path);
	StrCat(path,255,".mdl");
	
	int client_ping_idx = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(client_ping_idx, path);
	DispatchSpawn(client_ping_idx);
	ActivateEntity(client_ping_idx);
	SetEntPropVector(client_ping_idx, Prop_Data, "m_angRotation", rotation);
	SetEntityRenderMode(client_ping_idx, RENDER_TRANSALPHA);
	SetEntityRenderColor(client_ping_idx, 134, 226, 213, 150);
	TeleportEntity(client_ping_idx, origin, NULL_VECTOR, NULL_VECTOR);
	
	int partner_ping_idx = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(partner_ping_idx, path);
	DispatchSpawn(partner_ping_idx);
	ActivateEntity(partner_ping_idx);
	SetEntPropVector(partner_ping_idx, Prop_Data, "m_angRotation", rotation);
	SetEntityRenderMode(partner_ping_idx, RENDER_TRANSALPHA);
	SetEntityRenderColor(partner_ping_idx, 0, 230, 64, 150);
	TeleportEntity(partner_ping_idx, origin, NULL_VECTOR, NULL_VECTOR);
	
	client_pings[client] = client_ping_idx;
	partner_pings[Trikz_FindPartner(client)] = partner_ping_idx;
	
	float client_origin[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", client_origin);
	
	SDKHook(client_ping_idx, SDKHook_SetTransmit, ping_transmit);
	SDKHook(partner_ping_idx, SDKHook_SetTransmit, ping_transmit);
	
	EmitSoundToClient(Trikz_FindPartner(client), click_path);
	EmitSoundToClient(client, click_path);
	
	client_can_ping[client] = false;
	
	stored_partnered[client] = Trikz_FindPartner(client);
	
	timer_handle[client] = CreateTimer(3.0, ping_timer, client);
	delay_handle[client] = CreateTimer(0.5, ping_delay, client);
}

public Action ping_transmit(int ping_entity, int others)
{
	int spec_mode = GetEntProp(others, Prop_Send, "m_iObserverMode");
	if(spec_mode == OBS_MODE_IN_EYE || spec_mode == OBS_MODE_CHASE)
	{
		others = GetEntPropEnt(others, Prop_Send, "m_hObserverTarget");
	}
	
	if(ping_entity != client_pings[others] && ping_entity != partner_pings[others])
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
} 

Action ping_delay(Handle timer, any data)
{
	client_can_ping[data] = true;
}

Action ping_timer(Handle timer, any data)
{
	AcceptEntityInput(client_pings[data], "Kill");
	AcceptEntityInput(partner_pings[stored_partnered[data]], "Kill");
	//RemoveEntity(client_pings[data]);
	//RemoveEntity(partner_pings[Timer_GetPartner(data)]);
	client_pings[data] = 0;
	partner_pings[stored_partnered[data]] = 0;
	stored_partnered[data] = 0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(buttons & IN_USE)
	{
		gI_tick[client]++;
		
		if(gI_tick[client] == 50)
		{
			PING(client);
		}
	}
	
	else
	{
		if(gI_tick[client] != 0)
		{
			gI_tick[client] = 0;
		}
	}
}
