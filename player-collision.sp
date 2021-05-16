#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <trikz>
#include <shavit>
#include <morecolors>

#define SENDPROXY false //So make it false if it lags (1.1.5)

#if SENDPROXY
#include <sendproxy>
#endif

bool gB_hide[MAXPLAYERS +1]

public Plugin myinfo = 
{
	name = "Player collision for trikz solidity",
	author = "Smesh",
	description = "Make able to collide only with 'teammate'",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_hide", RCM_hide, "Toggle hide")
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i))
			OnClientPutInServer(i)
}

public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client))
	{
		gB_hide[client] = false
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmitHide)
		#if SENDPROXY
		SendProxy_Hook(client, "m_CollisionGroup", Prop_Int, ProxyCallback) //make smooth noblock.
		#endif
	}
}

Action RCM_hide(int client, int args)
{
	gB_hide[client] = !gB_hide[client]
	if(gB_hide[client])
		CPrintToChat(client, "{white}The players are now hidden.")
	else
		CPrintToChat(client, "{white}The players are now visible.")
	return Plugin_Handled
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(IsValidEntity(entity) && StrContains(classname, "_projectile") != -1)
		SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmitHideNade)
}

Action Hook_SetTransmitHide(int entity, int client) //entity - me, client - loop all clients
{	
	if((client != entity) && (0 < entity <= MaxClients) && gB_hide[client] && IsPlayerAlive(client))
	{
		if(Shavit_GetClientTrack(entity) != Track_Solobonus)
		{
			if(Trikz_FindPartner(entity) == client) //make visible partner
				return Plugin_Continue
			if((Trikz_FindPartner(entity) == -1) && (Trikz_FindPartner(client) == -1)) //make visible no mates for no mate
				return Plugin_Continue
			return Plugin_Handled
		}
		else //make invisible all players
			return Plugin_Handled
	}
	return Plugin_Continue
}

Action Hook_SetTransmitHideNade(int entity, int client) //entity - nade, client - loop all clients
{	
	int iEntOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	//if(!IsValidClient(iEntOwner))
	//	return Plugin_Handled
	int iPartner = Trikz_FindPartner(iEntOwner)
	if(gB_hide[client] && IsPlayerAlive(client))
	{		
		if(iEntOwner == client) //make visible own nade
			return Plugin_Continue
		if(iPartner == client) //make visible partner
			return Plugin_Continue
		if((iPartner == -1) && (Trikz_FindPartner(client) == -1)) //make visible nade only for no mates
			return Plugin_Continue
		return Plugin_Handled
	}
	return Plugin_Continue
}

#if SENDPROXY
Action ProxyCallback(int entity, const char[] propname, int &iValue, int element)
{
	iValue = 2 //Set iValue to whatever you want to send to clients
	return Plugin_Changed
}
#endif

public Action Trikz_CheckSolidity(int ent1, int ent2)
{	
	int iPartnerEnt1
	int iPartnerEnt2
	int iEntOwner
	int iPartnetEntOwner
	if((0 < ent1 <= MaxClients) && (0 < ent2 <= MaxClients) && IsFakeClient(ent1) && IsFakeClient(ent2)) //make no collide with bot
		return Plugin_Handled //result = false
	char sClassname[32]
	GetEntityClassname(ent1, sClassname, 32)
	int iPreventNadeBoostAndFallThroughBrush
	if(StrContains(sClassname, "projectile") != -1)
		iPreventNadeBoostAndFallThroughBrush = GetMaxEntities()
	else
		iPreventNadeBoostAndFallThroughBrush = MaxClients
	if(0 < ent1 <= iPreventNadeBoostAndFallThroughBrush)
	{
		if(IsValidClient(ent2) && !IsFakeClient(ent2))
			iPartnerEnt2 = Trikz_FindPartner(ent2)
		iEntOwner = GetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity")
		if(IsValidClient(iEntOwner) && !IsFakeClient(iEntOwner))
			iPartnetEntOwner = Trikz_FindPartner(iEntOwner)
		GetEntityClassname(ent1, sClassname, 32)
		if(StrContains(sClassname, "projectile") != -1)
		{			
			//make nade collide for all nomates.
			if((iPartnetEntOwner == -1) && (iPartnerEnt2 == -1))
			{
				//make nade no collide for owner.
				if(iEntOwner == ent2)
					return Plugin_Handled
				return Plugin_Continue
			}
			//make nade no colide if target is not mate.
			if(iEntOwner != iPartnerEnt2)
				return Plugin_Handled
			//make nade collide for mate.
			if((iPartnetEntOwner != -1) && (iPartnetEntOwner == ent2))
			{
				//make nade no collide for owner.
				if(iEntOwner == ent2)
					return Plugin_Handled
				return Plugin_Continue
			}
		}
		GetEntityClassname(ent2, sClassname, 32)
		if(StrContains(sClassname, "projectile") != -1)
		{
			if(IsValidClient(ent1) && !IsFakeClient(ent1))
				iPartnerEnt1 = Trikz_FindPartner(ent1)
			iEntOwner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity")
			if(IsValidClient(iEntOwner) && !IsFakeClient(iEntOwner))
				iPartnetEntOwner = Trikz_FindPartner(iEntOwner)
			//make nade collide for all nomates.
			if((iPartnetEntOwner == -1) && (iPartnerEnt1 == -1))
			{
				//make nade no collide for owner.
				if(iEntOwner == ent1)
					return Plugin_Handled
				return Plugin_Continue
			}
			//make nade no colide if target is not mate.
			if(iEntOwner != iPartnerEnt1)
				return Plugin_Handled
			//make nade collide for mate.
			if((iPartnetEntOwner != -1) && (iPartnetEntOwner == ent1))
			{
				//make nade no collide for owner.
				if(iEntOwner == ent1)
					return Plugin_Handled
				return Plugin_Continue
			}
		}
	}
	if((0 < ent1 <= MaxClients) && (0 < ent2 <= MaxClients))
	{
		//make collide for mate.
		//make able for nomate to collide with nomate.
		if(!(((iPartnerEnt2 == ent1) && (iPartnerEnt1 == ent2)) || (iPartnerEnt1 == -1 && iPartnerEnt2 == -1)))
			return Plugin_Handled
		//make no collide with all players.
		if(GetEntProp(ent2, Prop_Data, "m_CollisionGroup") == 2)
			return Plugin_Handled
	}
	return Plugin_Continue
}
