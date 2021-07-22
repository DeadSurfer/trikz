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
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

bool gB_Viewmodel[MAXPLAYERS + 1];

bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 &&
			client <= MaxClients &&
			IsClientConnected(client) &&
			IsClientInGame(client) &&
			!IsClientSourceTV(client) &&
			(!bAlive || IsPlayerAlive(client)));
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_vm", Command_vm);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if(IsValidClient(client))
	{
		gB_Viewmodel[client] = true;
	}
}

public Action Command_vm(int client, int args)
{
	if(view_as<bool>(GetEntProp(client, Prop_Send, "m_bDrawViewmodel")) == false)
	{
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
		ChangeEdictState(client, FindDataMapInfo(client, "m_bDrawViewmodel"));
		gB_Viewmodel[client] = true;
		CPrintToChat(client, "{white}%s", gB_Viewmodel[client] ? "Viewmodel is on." : "Viewmodel is off.");
		
		return Plugin_Handled;
	}
	
	if(view_as<bool>(GetEntProp(client, Prop_Send, "m_bDrawViewmodel")) == true)
	{
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
		ChangeEdictState(client, FindDataMapInfo(client, "m_bDrawViewmodel"));
		gB_Viewmodel[client] = false;
		CPrintToChat(client, "{white}%s", gB_Viewmodel[client] ? "Viewmodel is on." : "Viewmodel is off.");
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}
