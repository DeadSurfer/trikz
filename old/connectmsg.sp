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
#include <geoip>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Connecting announcer",
	author = "https://forums.alliedmods.net/showthread.php?t=77306 (Arg!), modified by Smesh",
	description = "You can see all connections.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{
	if(HookEventEx("player_connect_client", event_PlayerConnectClient, EventHookMode_Pre) == false) //OB cs:source
	{
		HookEventEx("player_connect", event_PlayerConnect, EventHookMode_Pre);
	}
	
	HookEvent("player_disconnect", event_PlayerDisconnect, EventHookMode_Pre);
}

bool IsLanIP(char src[16])
{
	char sIp4[4][4];

	if(ExplodeString(src, ".", sIp4, 4, 4) == 4)
	{
		int iIpNum = StringToInt(sIp4[0]) * 65536 + StringToInt(sIp4[1]) * 256 + StringToInt(sIp4[2]);
		
		if((iIpNum >= 655360 && iIpNum < 655360 + 65535)
			|| (iIpNum >= 11276288 && iIpNum < 11276288 + 4095)
			|| (iIpNum >= 12625920 && iIpNum < 12625920 + 255))
		{
			return true;
		}
	}

	return false;
}

public void OnClientPutInServer(int client)
{
	if(client > -1 && !IsFakeClient(client) && IsClientInGame(client))
	{
		char sName[33];
		GetClientName(client, sName, sizeof(sName));
		
		char sIp[16];
		GetClientIP(client, sIp, sizeof(sIp));
		
		bool bIsLanIp;
		bIsLanIp = IsLanIP(sIp);
		
		char sCountry[46];
		
		if(!GeoipCountry(sIp, sCountry, sizeof(sCountry)))
		{
			if(bIsLanIp)
			{
				Format(sCountry, sizeof(sCountry), "a local area network");
			}
			
			else
			{
				Format(sCountry, sizeof(sCountry), "an unknown country");
			}
		}
		
		//Add "The" in front of certain countries
		if(StrContains(sCountry, "United", false) != -1 ||
			StrContains(sCountry, "Republic", false) != -1 ||
			StrContains(sCountry, "Federation", false) != -1 ||
			StrContains(sCountry, "Island", false) != -1 ||
			StrContains(sCountry, "Netherlands", false) != -1 ||
			StrContains(sCountry, "Isle", false) != -1 ||
			StrContains(sCountry, "Bahamas", false) != -1 ||
			StrContains(sCountry, "Maldives", false) != -1 ||
			StrContains(sCountry, "Philippines", false) != -1 ||
			StrContains(sCountry, "Vatican", false) != -1)
		{
			Format(sCountry, sizeof(sCountry), "The %s", sCountry);
		}
		
		CPrintToChatAll("{orange}%s {white}connected from %s.", sName, sCountry);
	}
}

Action event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client && !IsFakeClient(client) && !dontBroadcast && IsClientInGame(client))
	{
		char sName[33];
		GetClientName(client, sName, sizeof(sName));
		
		char sIp[16];
		GetClientIP(client, sIp, sizeof(sIp));
		
		char sReason[65];
		GetEventString(event, "reason", sReason, sizeof(sReason));
		
		if(StrContains(sReason, "Disconnect by user", false) != -1)
		{
			sReason = "disconnected";
		}
		
		if(StrContains(sReason, "kick", false) != -1)
		{
			sReason = "kicked";
		}
		
		if(StrContains(sReason, "ban", false) != -1)
		{
			sReason = "banned";
		}
		
		if(StrContains(sReason, "timed out", false) != -1)
		{
			sReason = "timed out";
		}
		
		if(StrContains(sReason, "Couldn't verify your, or the server's connection to Steam..", false) != -1)
		{
			sReason = "couldn't verify";
		}
		
		if(StrContains(sReason, "Client left game (Steam auth ticket has been canceled)", false) != -1)
		{
			sReason = "steam auth ticket has been canceled";
		}
		
		if(StrContains(sReason, "Client not connected to Steam.)", false) != -1)
		{
			sReason = "not connected to steam";
		}
		
		if(StrContains(sReason, "Lost connection.)", false) != -1)
		{
			sReason = "lost connection";
		}
		
		if(StrContains(sReason, "Client not connected to Steam.)", false) != -1)
		{
			sReason = "not connected to steam";
		}
		
		CPrintToChatAll("{orange}%s {white}%s.", sName, sReason);
		
		return Plugin_Handled;
	}
	
	//Dont show default disconnect message
	if(!dontBroadcast)
	{
		char sName[33];
		GetEventString(event, "name", sName, sizeof(sName));
		
		char sNetworkID[22];
		GetEventString(event, "networkid", sNetworkID, sizeof(sNetworkID));
		
		char sReason[65];
		GetEventString(event, "reason", sReason, sizeof(sReason));
		
		Handle hNewEvent = CreateEvent("player_disconnect", true);
		SetEventInt(hNewEvent, "userid", GetEventInt(event, "userid"));
		SetEventString(hNewEvent, "reason", sReason);
		SetEventString(hNewEvent, "name", sName);
		SetEventString(hNewEvent, "networkid", sNetworkID);
		FireEvent(hNewEvent, true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

//For the newer event player_connect_client
Action event_PlayerConnectClient(Handle event, const char[] name, bool dontBroadcast)
{
	if(!dontBroadcast)
	{
		char sName[33];
		GetEventString(event, "name", sName, sizeof(sName));
		
		char sNetworkID[22];
		GetEventString(event, "networkid", sNetworkID, sizeof(sNetworkID));
		
		Handle hNewEvent = CreateEvent("player_connect_client", true);
		SetEventString(hNewEvent, "name", sName);
		SetEventInt(hNewEvent, "index", GetEventInt(event, "index"));
		SetEventInt(hNewEvent, "userid", GetEventInt(event, "userid"));
		SetEventString(hNewEvent, "networkid", sNetworkID);
		FireEvent(hNewEvent, true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

//For the older event player_connect
Action event_PlayerConnect(Handle event, const char[] name, bool dontBroadcast)
{
	if(!dontBroadcast)
	{
		char sName[33];
		GetEventString(event, "name", sName, sizeof(sName));
		
		char sNetworkID[22];
		GetEventString(event, "networkid", sNetworkID, sizeof(sNetworkID));
		
		char sAddress[32];
		GetEventString(event, "address", sAddress, sizeof(sAddress));
		
		Handle hNewEvent = CreateEvent("player_connect", true);
		SetEventString(hNewEvent, "name", sName);
		SetEventInt(hNewEvent, "index", GetEventInt(event, "index"));
		SetEventInt(hNewEvent, "userid", GetEventInt(event, "userid"));
		SetEventString(hNewEvent, "networkid", sNetworkID);
		SetEventString(hNewEvent, "address", sAddress);
		FireEvent(hNewEvent, true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
