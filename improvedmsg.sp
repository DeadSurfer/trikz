#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Hurting sounds",
	author = "https://forums.alliedmods.net/showpost.php?p=1728529&postcount=8 (Bacardi), modofied by Smesh",
	description = "Make able to customize chat messages.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{
	HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true);
	RegConsoleCmd("say", RCC_say);
}

//Thanks to https://forums.alliedmods.net/showpost.php?p=1728529&postcount=8
Action TextMsg(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init)
{
	if(reliable)
	{
		char sBuffer[256];
		BfReadString(bf, sBuffer, sizeof(sBuffer));
		
		if(StrContains(sBuffer, "\x03[SM]") == 0)
		{
			Handle hPack;
			CreateDataTimer(0.0, timer_strip, hPack);
			WritePackCell(hPack, playersNum);
			
			for(int i = 0; i < playersNum; i++)
			{
				WritePackCell(hPack, players[i]);
			}
			
			WritePackString(hPack, sBuffer);
			ResetPack(hPack);
			
			return Plugin_Handled;
        }
    }
	
	return Plugin_Continue;
}

Action timer_strip(Handle timer, Handle pack)
{
	int playersNum = ReadPackCell(pack);
	int[] iPlayers = new int[playersNum];
	int iCount;
	
	for(int i = 1; i <= playersNum; i++)
	{
		int client = ReadPackCell(pack);
		
		if(IsClientInGame(client))
		{
			iPlayers[iCount++] = client;
		}
	}
	
	if(iCount > 0)
	{		
		playersNum = iCount;
		
		//Thanks to https://hlmod.ru/threads/sm-prefix-changer.18250/
		Handle hBf = StartMessage("SayText2", iPlayers, playersNum, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		BfWriteByte(hBf, -1);
		BfWriteByte(hBf, true);
		char sBuffer[256];
		ReadPackString(pack, sBuffer, sizeof(sBuffer));
		ReplaceString(sBuffer, sizeof(sBuffer), "[SM] ", "\x07FFFFFF");
		BfWriteString(hBf, sBuffer);
		EndMessage();
	}
}

//Thanks to https://forums.alliedmods.net/showthread.php?p=2375139
Action RCC_say(int client, int args)
{
	if(client == 0)
	{
		char sBuffer[256];
		GetCmdArgString(sBuffer, sizeof(sBuffer));
		CPrintToChatAll("{dimgray}[{white}ADVERT{dimgray}] {white}%s", sBuffer);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
