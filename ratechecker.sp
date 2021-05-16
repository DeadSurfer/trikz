#include <sdktools>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

char sProfile[MAXPLAYERS + 1][64];

public Plugin myinfo =
{
	name = "Rate checker",
	author = "Gurman (Skipper), modified by Smesh",
	description = "You can see player interpolation settings.",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

bool IsValidClient(int client)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_rate", Command_Rate);
	RegConsoleCmd("sm_rates", Command_Rate);
	LoadTranslations("common.phrases");
}
 
Action Command_Rate(int client, int args)
{
	if(args == 1)
	{
		char arg[MAX_NAME_LENGTH + 9]; 
		GetCmdArgString(arg, sizeof(arg));
		int target = FindTarget(client, arg, true, false);
	
		if(IsValidClient(target))
		{
			PrintRateMenu(target, client);
		}
	}
	
	else
	{
		char szInfo[66];
		char szDisplay[MAX_NAME_LENGTH];

		Menu menu = new Menu(Handler_RateMenu);
		//menu.SetTitle("Rates for:\n ");
		menu.SetTitle("Networking for:\n ");
		
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i) && !IsFakeClient(i))
			{
				Format(szInfo, sizeof(szInfo), "%i", GetClientUserId(i));
				GetClientName(i, szDisplay, sizeof(szDisplay));
				menu.AddItem(szInfo, szDisplay);
			}
		}
		
		menu.ExitBackButton = true;
		menu.ExitButton = true;
		
		if(menu.ItemCount != 0)
		{
			menu.Display(client, MENU_TIME_FOREVER);
		}
		
		else
		{
			CPrintToChat(client, "{white}No players to check rates.");
		}
	}
	
	return Plugin_Handled;
}

void PrintRateMenu(int target, int client)
{
	//char sRate[8];
	//char sCmdRate[8];
	//char sUpdateRate[8];
	char sInterp[8];
	char sInterp_ratio[8];
	char sLagCompensation[8];
	
	//GetClientInfo(target, "rate", sRate, sizeof(sRate));
	//GetClientInfo(target, "cl_cmdrate", sCmdRate, sizeof(sCmdRate));
	//GetClientInfo(target, "cl_updaterate", sUpdateRate, sizeof(sUpdateRate));
	GetClientInfo(target, "cl_interp", sInterp, sizeof(sInterp));
	GetClientInfo(target, "cl_interp_ratio", sInterp_ratio, sizeof(sInterp_ratio));
	GetClientInfo(target, "cl_lagcompensation", sLagCompensation, sizeof(sLagCompensation));
	
	//int flRate = StringToInt(sRate);
	//int flCmdRate = StringToInt(sCmdRate);
	//int flUpdateRate = StringToInt(sUpdateRate);
	float fInterp = StringToFloat(sInterp);
	float fInterp_ratio = StringToFloat(sInterp_ratio);
	int fLagCompensation = StringToInt(sLagCompensation);
	
	Menu menu = new Menu(Rate_MenuHandler);
	//menu.SetTitle("Rates for %N\n \nrate %i\ncl_cmdrate %i\ncl_updaterate %i\ncl_interp %.5f\ncl_interp_ratio %.3f\ncl_lagcompensation %i\n \nCurrent lerp: %.1f ms\n ",
	//	target, flRate, flCmdRate, flUpdateRate, fInterp, fInterp_ratio, fLagCompensation, GetEntPropFloat(target, Prop_Data, "m_fLerpTime") * 1000);
	menu.SetTitle("Networking for %N\n \ncl_interp %.5f\ncl_interp_ratio %.3f\ncl_lagcompensation %i\n \nCurrent lerp: %.1f ms\n ", target, fInterp, fInterp_ratio, fLagCompensation, GetEntPropFloat(target, Prop_Data, "m_fLerpTime") * 1000);
	char sTargetID[112];
	GetClientAuthId(target, AuthId_SteamID64, sTargetID, 26, true);
	FormatEx(sProfile[client], 64, "https://steamcommunity.com/profiles/%s", sTargetID);
	menu.AddItem("0", "Open steam profile\n ");
	menu.AddItem("1", "Back");
	menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handler_RateMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[MAX_NAME_LENGTH];
			menu.GetItem(param2, item, sizeof(item));
			int client = GetClientOfUserId(StringToInt(item));

			if(IsValidClient(client))
			{
				PrintRateMenu(client, param1);
			}
		}
		
		case MenuAction_Cancel:
		{
			switch(param2)
			{
				case MenuCancel_ExitBack:
				{
					FakeClientCommandEx(param1, "sm_trikz");
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

int Rate_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64];
			menu.GetItem(param2, item, sizeof(item));
			
			switch(param2)
			{
				case 0:
				{
					ShowMOTDPanel(param1, "Steam profile", sProfile[param1][0], 2);
				}
				
				case 1:
				{
					FakeClientCommandEx(param1, "sm_rate");
				}
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}
