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
#include <trikz>
#include <shavit>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

int gI_Button[MAXPLAYERS + 1];
int gI_SpectatorTarget[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name        = "Button announcer",
	author      = "selja, Smesh",
	description = "Make able to see button activation.",
	version     = "14.01.2021",
	url         = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
	
	RegConsoleCmd("sm_button", Command_Button);
	
	HookEntityOutput("func_button", "OnPressed", UseButton);
	HookEntityOutput("func_button", "OnDamaged", OnButtonDamaged);
}

public void OnClientPutInServer(int client)
{
	gI_Button[client] = 7;
	gI_SpectatorTarget[client] = -1;
}

Action Command_Button(int client, int args)
{	
	if(gI_Button[client] == 0)
	{
		gI_Button[client] = 1;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Own chat only.");
	}
	
	else if(gI_Button[client] == 1)
	{
		gI_Button[client] = 2;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Own chat only. +Fade");
	}
	
	else if(gI_Button[client] == 2)
	{
		gI_Button[client] = 3;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Partner chat only.");
	}
	
	else if(gI_Button[client] == 3)
	{
		gI_Button[client] = 4;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Partner chat only. +Fade");
	}
	
	else if(gI_Button[client] == 4)
	{
		gI_Button[client] = 5;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Only both fades.");
	}
	
	else if(gI_Button[client] == 5)
	{
		gI_Button[client] = 6;
		CPrintToChat(client, "{white}Button announcer is on. Mode: Only both chats.");
	}
	
	else if(gI_Button[client] == 6)
	{
		gI_Button[client] = 7;
		CPrintToChat(client, "{white}Button announcer is on. Mode: All.");
	}
	
	else if(gI_Button[client] == 7)
	{
		gI_Button[client] = 0;
		CPrintToChat(client, "{white}Button announcer is off.");
	}
	
	return Plugin_Handled;
}

void UseButton(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator) && GetClientButtons(activator) & IN_USE)
	{
		if(gI_Button[activator] == 1 || gI_Button[activator] == 5 || gI_Button[activator] == 7)
		{
			Handle hMsg = StartMessageOne("Fade", activator);
			BfWriteShort(hMsg, 100);
			BfWriteShort(hMsg, 0);
			BfWriteShort(hMsg, 1 << 0);
			BfWriteByte(hMsg, 173); //Lightblue
			BfWriteByte(hMsg, 216);
			BfWriteByte(hMsg, 230);
			BfWriteByte(hMsg, 16);
			EndMessage();
		}
		
		if(gI_Button[activator] == 2 || gI_Button[activator] == 6 || gI_Button[activator] == 7)
		{
			CPrintToChat(activator, "{white}You have pressed a button.");
		}
		
		int iPartner = Trikz_FindPartner(activator);
		
		if(iPartner != -1)
		{
			if(gI_Button[iPartner] == 3 || gI_Button[iPartner] == 5 || gI_Button[iPartner] == 7)
			{
				Handle hMsg = StartMessageOne("Fade", iPartner);
				BfWriteShort(hMsg, 100);
				BfWriteShort(hMsg, 0);
				BfWriteShort(hMsg, 1 << 0);
				BfWriteByte(hMsg, 173); //Lightblue
				BfWriteByte(hMsg, 216);
				BfWriteByte(hMsg, 230);
				BfWriteByte(hMsg, 16);
				EndMessage();
			}
			
			if(gI_Button[iPartner] == 4 || gI_Button[iPartner] == 6 || gI_Button[iPartner] == 7)
			{
				CPrintToChat(iPartner, "{white}Your partner have pressed a button.");
			}
		}
	}
}

void OnButtonDamaged(const char[] output, int caller, int activator, float delay)
{
	if(IsValidClient(activator) && GetClientButtons(activator) & IN_ATTACK)
	{
		Handle hMsg = StartMessageOne("Fade", activator);
		BfWriteShort(hMsg, 100);
		BfWriteShort(hMsg, 0);
		BfWriteShort(hMsg, 1 << 0);
		BfWriteByte(hMsg, 255); //Orange
		BfWriteByte(hMsg, 165);
		BfWriteByte(hMsg, 0);
		BfWriteByte(hMsg, 16);
		EndMessage();
	}
}
