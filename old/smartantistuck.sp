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
#include <sdktools>
#include <sdkhooks>
#include <shavit>
#include <trikz>

#pragma semicolon 1
#pragma newdecls required

bool gB_Check[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Smart anti-stuck",
	author = "Smesh, Gurman",
	description = "",
	version = "29.08.2020",
	url = "http://www.sourcemod.net/"
}

stock int IsPlayerStuck(int client)
{
	float vMin[3];
	float vMax[3];
	float vOrigin[3];
	GetClientMins(client, vMin);
	GetClientMaxs(client, vMax);
	GetClientAbsOrigin(client, vOrigin);
	TR_TraceHullFilter(vOrigin, vOrigin, vMin, vMax, MASK_PLAYERSOLID, TR_DontHitSelf, client);
	return TR_GetEntityIndex();
}

public bool TR_DontHitSelf(int entity, int mask, int client) 
{
	return (entity != client && IsValidClient(entity));
}

public Action OnPlayerRunCmd(int client)
{
	int iOther = IsPlayerStuck(client);
	
	if(IsValidClient(iOther) && !IsFakeClient(iOther))
	{
		if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 5)
		{
			SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
			SetEntityRenderMode(client, RENDER_TRANSALPHA);
			//SetEntityRenderColor(client, 255, 255, 255, 100);
			SetEntityRenderColor(client, Trikz_GetClientColorR(client), Trikz_GetClientColorG(client), Trikz_GetClientColorB(client), 100);
			gB_Check[client] = false;
			//PrintCenterText(client, "Вы застряли в игроке %N", iOther);
		}
	}
	else
	{
		if(!gB_Check[client])
		{
			if(GetEntProp(client, Prop_Data, "m_CollisionGroup") == 2)
			{
				SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
				SetEntityRenderMode(client, RENDER_NORMAL);
				gB_Check[client] = true;
				//PrintCenterText(client, "Вы не застряли", iOther);
			}
		}
	}
	
	return Plugin_Continue;
}
