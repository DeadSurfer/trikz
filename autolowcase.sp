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
#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>

#pragma newdecls required
 
public Plugin myinfo =
{
	name        = "Auto lower case commands",
	author      = "Zipcore, modified by Smesh",
	description = "Auto. converts chat triggers to lower case.",
	version     = "0.1",
	url         = "forums.alliedmods.net/showthread.php?p=2074699"
};
 
public void OnPluginStart()
{
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_SayTeam, "say_team");
}
 
public Action Command_Say(int client, const char[] command, int argc)
{
	char sText[300];
	GetCmdArgString(sText, sizeof(sText));
	StripQuotes(sText);
	
	if((sText[0] == '!') || (sText[0] == '/'))
	{
		if(IsCharUpper(sText[1]))
		{
			for(int i = 0; i <= strlen(sText); ++i)
			{
				sText[i] = CharToLower(sText[i]);
			}

			FakeClientCommand(client, "say %s", sText);
			
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
 
public Action Command_SayTeam(int client, const char[] command, int argc)
{
	char sText[300];
	GetCmdArgString(sText, sizeof(sText));
	StripQuotes(sText);
	
	if((sText[0] == '!') || (sText[0] == '/'))
	{
		if(IsCharUpper(sText[1]))
		{
			for(int i = 0; i <= strlen(sText); ++i)
			{
				sText[i] = CharToLower(sText[i]);
			}

			FakeClientCommand(client, "say_team %s", sText);
			
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
