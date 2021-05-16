#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Silent commands",
	author = "https://forums.alliedmods.net/showpost.php?p=1965979&postcount=11 MasterOfTheXP",
	description = "Hide all commands for !.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{
	AddCommandListener(HookPlayerChat, "say");
	AddCommandListener(HookPlayerChat, "say_team"); 
}

//Thanks to https://forums.alliedmods.net/showthread.php?t=217597&page=2
public Action HookPlayerChat(int client, const char[] command, int args)
{
	char sText[2];
	GetCmdArg(1, sText, sizeof(sText));
	
	return (sText[0] == '/' || sText[0] == '!') ? Plugin_Handled : Plugin_Continue;
}
