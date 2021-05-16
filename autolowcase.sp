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
