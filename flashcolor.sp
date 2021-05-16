#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#pragma newdecls required

int gI_CustomModel;
int gI_ColorFB[MAXPLAYERS + 1][7 + 1];
int gI_ColorRED[MAXPLAYERS + 1];
int gI_ColorGREEN[MAXPLAYERS + 1];
int gI_ColorBLUE[MAXPLAYERS + 1];
Handle gH_ColorFB;

public Plugin myinfo =
{
	name = "Flashbang color",
	author = "Smesh",
	description = "Allows to change flashbang color.",
	version = "0.1",
	url = ""
}

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
	RegConsoleCmd("sm_fb", Command_FlashBangColorMenu);
	RegConsoleCmd("sm_fl", Command_FlashBangColorMenu);
	gH_ColorFB = RegClientCookie("flashbang_color", "flashbang colors", CookieAccess_Protected);
}

public void OnMapStart()
{
	// set custom model
	gI_CustomModel = PrecacheModel("models/nushoprivet/flashbang/flashbang.mdl");

	// download files
	AddFileToDownloadsTable("materials/nushoprivet/flashbang/noshadows.vmt");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.mdl");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.dx80.vtx");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.dx90.vtx");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.phy");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.sw.vtx");
	AddFileToDownloadsTable("models/nushoprivet/flashbang/flashbang.vvd");
}

public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client) && IsClientInGame(client))
	{
		OnClientCookiesCached(client);
	}
}

public void OnClientCookiesCached(int client)
{
	if(!IsFakeClient(client) && IsClientInGame(client))
	{		
		char sFLcolor[13];
		GetClientCookie(client, gH_ColorFB, sFLcolor, 13);
		
		if(strlen(sFLcolor) != 0)
		{
			char sExploded[4][3];
			ExplodeString(sFLcolor, ";", sExploded, 3, 4);
			gI_ColorRED[client] = StringToInt(sExploded[0]);
			gI_ColorGREEN[client] = StringToInt(sExploded[1]);
			gI_ColorBLUE[client] = StringToInt(sExploded[2]);
			gI_ColorFB[client][1] = true;
		}
		
		else
		{
			SetClientCookie(client, gH_ColorFB, "255;255;255");
			gI_ColorRED[client] = 255;
			gI_ColorGREEN[client] = 255;
			gI_ColorBLUE[client] = 255;
		}
	}
}

Action Command_FlashBangColorMenu(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	gI_ColorFBMenu(client);
	
	return Plugin_Handled;
}

void gI_ColorFBMenu(int client)
{
	Menu FBMenu = new Menu(FBMenuHandler);
	FBMenu.SetTitle("Flashbang color menu\n ", client);
	FBMenu.AddItem("0", "Default\n ");
	FBMenu.AddItem("1", "Red");
	FBMenu.AddItem("2", "White");
	FBMenu.AddItem("3", "Green");
	FBMenu.AddItem("4", "Yellow");
	FBMenu.AddItem("5", "Blue");
	FBMenu.AddItem("6", "Aqua");
	FBMenu.AddItem("7", "Pink");
	FBMenu.Display(client, MENU_TIME_FOREVER);
}

int FBMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	char sItem[64];
	menu.GetItem(param2, sItem, sizeof(sItem));
	int iItem = StringToInt(sItem);
	
	switch(action)
	{		
		case MenuAction_Select:
		{
			if(StrEqual(sItem, "0"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				SetClientCookie(param1, gH_ColorFB, "0;0;0");
			}
			
			else if(StrEqual(sItem, "1"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 255;
				gI_ColorGREEN[param1] = 0;
				gI_ColorBLUE[param1] = 0;
				SetClientCookie(param1, gH_ColorFB, "255;0;0");
			}
			
			else if(StrEqual(sItem, "2"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 255;
				gI_ColorGREEN[param1] = 255;
				gI_ColorBLUE[param1] = 255;
				SetClientCookie(param1, gH_ColorFB, "255;255;255");
			}
			
			else if(StrEqual(sItem, "3"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 0;
				gI_ColorGREEN[param1] = 255;
				gI_ColorBLUE[param1] = 0;
				SetClientCookie(param1, gH_ColorFB, "0;255;0");
			}
			
			else if(StrEqual(sItem, "4"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 255;
				gI_ColorGREEN[param1] = 255;
				gI_ColorBLUE[param1] = 0;
				SetClientCookie(param1, gH_ColorFB, "255;255;0");
			}
			
			else if(StrEqual(sItem, "5"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 0;
				gI_ColorGREEN[param1] = 0;
				gI_ColorBLUE[param1] = 255;
				SetClientCookie(param1, gH_ColorFB, "0;0;255");
			}
			
			else if(StrEqual(sItem, "6"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 0;
				gI_ColorGREEN[param1] = 250;
				gI_ColorBLUE[param1] = 250;
				SetClientCookie(param1, gH_ColorFB, "0;250;250");
			}
			
			else if(StrEqual(sItem, "7"))
			{
				for(int i = 0; i <= 7; i++)
				{
					gI_ColorFB[param1][i] = false;
				}
				
				gI_ColorFB[param1][iItem] = true;
				gI_ColorRED[param1] = 255;
				gI_ColorGREEN[param1] = 145;
				gI_ColorBLUE[param1] = 255;
				SetClientCookie(param1, gH_ColorFB, "255;145;255");
			}
			
			gI_ColorFBMenu(param1);
		}
	}
	
	return view_as<int>(Plugin_Continue);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
	{
		SDKHook(entity, SDKHook_SpawnPost, ProjectileSpawned);
	}
}

void ProjectileSpawned(int entity)
{
	int iEntOwner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	
	for(int j = 1; j <= 7; j++)
	{		
		if(gI_ColorFB[iEntOwner][j])
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndex", gI_CustomModel);
			SetEntityRenderColor(entity, gI_ColorRED[iEntOwner], gI_ColorGREEN[iEntOwner], gI_ColorBLUE[iEntOwner], 255);
		}
	}
}
