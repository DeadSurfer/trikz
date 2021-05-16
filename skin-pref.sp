#include <morecolors>
//#include <shavit>
#include <clientprefs>
#include <trikz>
#include <sdktools>
#include <cstrike>

//#pragma newdecls required
//#pragma semicolon 1

#define dGIGN "models/expert_zone/player/ct_gign.mdl"
#define dGSG9 "models/expert_zone/player/ct_gsg9.mdl"
#define dSAS "models/expert_zone/player/ct_sas.mdl"
#define dURBAN "models/expert_zone/player/ct_urban.mdl"

enum struct model_t
{
	int iGIGN
	int iGSG9
	int iSAS
	int iURBAN
}
model_t gI_ModelIndex
enum struct skin_t
{
	// cookies
	Handle iType
	Handle iRGB
}
skin_t gH_Skin
enum struct skincolor_t
{
	int iRED
	int iGREEN
	int iBLUE
}
skincolor_t gI_SkinColor[MAXPLAYERS + 1]
enum
{
	Type_Default,
	Type_Lightmap,
	Type_Fullbright
}
int gI_Skin[MAXPLAYERS + 1]
char sType_Default[2]
char sType_Lightmap[2]
char sType_Fullbright[2]
bool gB_Mirror_Trigger[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "Skin preferences",
	author = "Smesh",
	description = "Main idea from Expert-Zone",
	version = "0.2",
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Trikz_GetClientColorR", Native_GetClientColorR)
	CreateNative("Trikz_GetClientColorG", Native_GetClientColorG)
	CreateNative("Trikz_GetClientColorB", Native_GetClientColorB)
	return APLRes_Success
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_skin", Command_SkinMenu)
	RegConsoleCmd("sm_skinrgb", Command_SkinRGB)
	RegConsoleCmd("sm_gsc", Command_GetSkinColor)
	RegConsoleCmd("sm_getskincolor", Command_GetSkinColor)
	RegConsoleCmd("sm_ems", Command_ExamineMySelf)
	RegConsoleCmd("sm_examinemyself", Command_ExamineMySelf)
	HookEvent("player_spawn", Player_Spawn)
	gH_Skin.iType = RegClientCookie("skin_type", "skin type cookie", CookieAccess_Protected)
	gH_Skin.iRGB = RegClientCookie("skin_color_rgb", "skin color rgb cookie", CookieAccess_Protected)
	IntToString(Type_Default, sType_Default, 2)
	IntToString(Type_Lightmap, sType_Lightmap, 2)
	IntToString(Type_Fullbright, sType_Fullbright, 2)
	LoadTranslations("common.phrases")
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			OnClientPutInServer(i)
}

public void OnMapStart()
{
	gI_ModelIndex.iGIGN = PrecacheModel(dGIGN)
	gI_ModelIndex.iGSG9 = PrecacheModel(dGSG9)
	gI_ModelIndex.iSAS = PrecacheModel(dSAS)
	gI_ModelIndex.iURBAN = PrecacheModel(dURBAN)
}

public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client) && IsClientInGame(client))
		OnClientCookiesCached(client)
}

public void OnClientCookiesCached(int client)
{
	if(!IsFakeClient(client) && IsClientInGame(client))
	{		
		char sSkinType[2]
		GetClientCookie(client, gH_Skin.iType, sSkinType, 2)
		if(StrEqual(sSkinType, sType_Default) || (strlen(sSkinType) == 0))
			gI_Skin[client] = Type_Default
		if(StrEqual(sSkinType, sType_Lightmap))
			gI_Skin[client] = Type_Lightmap
		if(StrEqual(sSkinType, sType_Fullbright))
			gI_Skin[client] = Type_Fullbright
		char sSkinColor[12]
		GetClientCookie(client, gH_Skin.iRGB, sSkinColor, 12)
		if(strlen(sSkinColor) == 0)
		{
			SetClientCookie(client, gH_Skin.iRGB, "255;255;255")
			gI_SkinColor[client].iRED = 255
			gI_SkinColor[client].iGREEN = 255
			gI_SkinColor[client].iBLUE = 255
		}
		else
		{
			char sExploded[4][3]
			ExplodeString(sSkinColor, ";", sExploded, 3, 4)
			gI_SkinColor[client].iRED = StringToInt(sExploded[0])
			gI_SkinColor[client].iGREEN = StringToInt(sExploded[1])
			gI_SkinColor[client].iBLUE = StringToInt(sExploded[2])
		}
	}
}

void Player_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"))
	SkinApply(client)
}

void SkinApply(int client)
{
	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		char sModelPath[64]
		GetClientModel(client, sModelPath, 32)
		if(StrEqual(sModelPath, "models/player/ct_gign.mdl"))
			SetEntProp(client, Prop_Send, "m_nModelIndex", gI_ModelIndex.iGIGN)
		if(StrEqual(sModelPath, "models/player/ct_gsg9.mdl"))
			SetEntProp(client, Prop_Send, "m_nModelIndex", gI_ModelIndex.iGSG9)
		if(StrEqual(sModelPath, "models/player/ct_sas.mdl"))
			SetEntProp(client, Prop_Send, "m_nModelIndex", gI_ModelIndex.iSAS)
		if(StrEqual(sModelPath, "models/player/ct_urban.mdl"))
			SetEntProp(client, Prop_Send, "m_nModelIndex", gI_ModelIndex.iURBAN)
		char sSkinType[2]
		GetClientCookie(client, gH_Skin.iType, sSkinType, 2)
		if(StrEqual(sSkinType, sType_Default))
			SetEntProp(client, Prop_Send, "m_nSkin", Type_Default)
		if(StrEqual(sSkinType, sType_Lightmap))
			SetEntProp(client, Prop_Send, "m_nSkin", Type_Lightmap)
		if(StrEqual(sSkinType, sType_Fullbright))
			SetEntProp(client, Prop_Send, "m_nSkin", Type_Fullbright)
		SetEntityRenderColor(client, gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE, 255)
	}
}

Action Command_SkinMenu(int client, int args)
{
	SkinMenu(client)
	return Plugin_Handled
}

void SkinMenu(int client)
{
	Menu menu = new Menu(Skin_MenuHandler)
	menu.SetTitle("Skin preferences\n \nNotice: For 'lightmap' or 'fullbright' skin use cl_minmodels 0.\nTo change skin color, use, for ex. /skinrgb 255 165 0.\nRandom skin color /skinrgb -1 -1 -1\nExtra /gsc and /ems\n ")
	menu.AddItem("skin_color", "Color\n ")
	if(gI_Skin[client] == Type_Default)
	{
		menu.AddItem("skin_type_default", "[+] Default", ITEMDRAW_DISABLED)
		menu.AddItem("skin_type_lightmap", "Lightmap")
		menu.AddItem("skin_type_fullbright", "Fullbright")
	}
	if(gI_Skin[client] == Type_Lightmap)
	{
		menu.AddItem("skin_type_default", "Default")
		menu.AddItem("skin_type_lightmap", "[+] Lightmap", ITEMDRAW_DISABLED)
		menu.AddItem("skin_type_fullbright", "Fullbright")
	}
	if(gI_Skin[client] == Type_Fullbright)
	{
		menu.AddItem("skin_type_default", "Default")
		menu.AddItem("skin_type_lightmap", "Lightmap")
		menu.AddItem("skin_type_fullbright", "[+] Fullbright", ITEMDRAW_DISABLED)
	}
	menu.Pagination = MENU_NO_PAGINATION
	menu.ExitButton = true
	menu.Display(client, MENU_TIME_FOREVER)
}

int Skin_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[64]
			menu.GetItem(param2, item, sizeof(item))
			if(StrEqual(item, "skin_color"))
				SkinColorMenu(param1)
			if(StrEqual(item, "skin_type_default"))
			{
				gI_Skin[param1] = Type_Default
				SetClientCookie(param1, gH_Skin.iType, sType_Default)
				SkinApply(param1)
				Mirror_Trigger(param1)
				SkinMenu(param1)
			}
			if(StrEqual(item, "skin_type_lightmap"))
			{
				gI_Skin[param1] = Type_Lightmap
				SetClientCookie(param1, gH_Skin.iType, sType_Lightmap)
				SkinApply(param1)
				Mirror_Trigger(param1)
				SkinMenu(param1)
			}
			if(StrEqual(item, "skin_type_fullbright"))
			{
				gI_Skin[param1] = Type_Fullbright
				SetClientCookie(param1, gH_Skin.iType, sType_Fullbright)
				SkinApply(param1)
				Mirror_Trigger(param1)
				SkinMenu(param1)
			}
		}
		case MenuAction_End:
			delete menu
	}
	return view_as<int>(Plugin_Continue)
}

void SkinColorMenu(int client) 
{
	Menu menu = new Menu(SkinColor_MenuHandler)
	menu.SetTitle("Skin preferences - Color")
	menu.AddItem("0", "Default\n ")
	menu.AddItem("1", "Red")
	menu.AddItem("2", "Green")
	menu.AddItem("3", "Yellow")
	menu.AddItem("4", "Blue")
	menu.AddItem("5", "Aqua")
	menu.AddItem("6", "Pink")
	menu.ExitBackButton = true
	menu.ExitButton = true
	menu.Display(client, MENU_TIME_FOREVER)
}

int SkinColor_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	char sItem[64]
	menu.GetItem(param2, sItem, sizeof(sItem))
	switch(action)
	{		
		case MenuAction_Select:
		{
			if(StrEqual(sItem, "0"))
			{
				gI_SkinColor[param1].iRED = 255
				gI_SkinColor[param1].iGREEN = 255
				gI_SkinColor[param1].iBLUE = 255
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "255;255;255")
			}
			if(StrEqual(sItem, "1"))
			{
				gI_SkinColor[param1].iRED = 255
				gI_SkinColor[param1].iGREEN = 0
				gI_SkinColor[param1].iBLUE = 0
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "255;0;0")
			}
			if(StrEqual(sItem, "2"))
			{
				gI_SkinColor[param1].iRED = 0
				gI_SkinColor[param1].iGREEN = 255
				gI_SkinColor[param1].iBLUE = 0
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "0;255;0")
			}
			if(StrEqual(sItem, "3"))
			{
				gI_SkinColor[param1].iRED = 255
				gI_SkinColor[param1].iGREEN = 255
				gI_SkinColor[param1].iBLUE = 0
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "255;255;0")
			}
			if(StrEqual(sItem, "4"))
			{
				gI_SkinColor[param1].iRED = 0
				gI_SkinColor[param1].iGREEN = 0
				gI_SkinColor[param1].iBLUE = 255
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "0;0;255")
			}
			if(StrEqual(sItem, "5"))
			{
				gI_SkinColor[param1].iRED = 0
				gI_SkinColor[param1].iGREEN = 250
				gI_SkinColor[param1].iBLUE = 250
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "0;250;250")
			}
			if(StrEqual(sItem, "6"))
			{				
				gI_SkinColor[param1].iRED = 255
				gI_SkinColor[param1].iGREEN = 145
				gI_SkinColor[param1].iBLUE = 255
				SetEntityRenderColor(param1, gI_SkinColor[param1].iRED, gI_SkinColor[param1].iGREEN, gI_SkinColor[param1].iBLUE, 255)
				SetClientCookie(param1, gH_Skin.iRGB, "255;145;255")
			}
			Mirror_Trigger(param1)
			SkinColorMenu(param1)
		}
		case MenuAction_Cancel:
			switch(param2)
			{
				case MenuCancel_ExitBack:
					SkinMenu(param1)
			}
		case MenuAction_End:
			delete menu
	}
	return view_as<int>(Plugin_Continue)
}

//https://forums.alliedmods.net/showpost.php?p=2329062&postcount=3
Action Command_SkinRGB(int client, int args)
{
	char value[15]
	GetCmdArgString(value, sizeof(value))
	char buffer[3][15]
	if(ExplodeString(value, " ", buffer, sizeof(buffer), sizeof(buffer[])) < 3)
		return Plugin_Handled
	gI_SkinColor[client].iRED = StringToInt(buffer[0])
	gI_SkinColor[client].iGREEN = StringToInt(buffer[1])
	gI_SkinColor[client].iBLUE = StringToInt(buffer[2])
	//Random color
	if(gI_SkinColor[client].iRED == -1 && gI_SkinColor[client].iGREEN == -1 && gI_SkinColor[client].iBLUE == -1)
	{
		gI_SkinColor[client].iRED = GetRandomInt(0, 255)
		gI_SkinColor[client].iGREEN = GetRandomInt(0, 255)
		gI_SkinColor[client].iBLUE = GetRandomInt(0, 255)
		CPrintToChat(client, "{white}Your new color is: {darkred}%i {darkgreen}%i {darkblue}%i", gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE)
	}
	if(gI_SkinColor[client].iRED == -1 && gI_SkinColor[client].iGREEN == -1)
	{
		gI_SkinColor[client].iRED = GetRandomInt(0, 255)
		gI_SkinColor[client].iGREEN = GetRandomInt(0, 255)
		CPrintToChat(client, "{white}Your new color is: {darkred}%i {darkgreen}%i {darkblue}%i", gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE)
	}
	if(gI_SkinColor[client].iRED == -1 && gI_SkinColor[client].iBLUE == -1)
	{
		gI_SkinColor[client].iRED = GetRandomInt(0, 255)
		gI_SkinColor[client].iBLUE = GetRandomInt(0, 255)
		CPrintToChat(client, "{white}Your new color is: {darkred}%i {darkgreen}%i {darkblue}%i", gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE)
	}
	if(gI_SkinColor[client].iGREEN == -1 && gI_SkinColor[client].iBLUE == -1)
	{
		gI_SkinColor[client].iGREEN = GetRandomInt(0, 255)
		gI_SkinColor[client].iBLUE = GetRandomInt(0, 255)
		CPrintToChat(client, "{white}Your new color is: {darkred}%i {darkgreen}%i {darkblue}%i", gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE)
	}
	SetEntityRenderColor(client, gI_SkinColor[client].iRED, gI_SkinColor[client].iGREEN, gI_SkinColor[client].iBLUE, 255)
	char sSkinColor[3][4]
	IntToString(gI_SkinColor[client].iRED, sSkinColor[0], 4)
	IntToString(gI_SkinColor[client].iGREEN, sSkinColor[1], 4)
	IntToString(gI_SkinColor[client].iBLUE, sSkinColor[2], 4)
	char sColorCookie[12]
	FormatEx(sColorCookie, 12, "%s;%s;%s", sSkinColor[0], sSkinColor[1], sSkinColor[2])
	SetClientCookie(client, gH_Skin.iRGB, sColorCookie)
	Mirror_Trigger(client)
	return Plugin_Handled
}

Action Command_GetSkinColor(int client, int args)
{
	if(args == 1)
	{
		char arg[MAX_NAME_LENGTH + 9] 
		GetCmdArgString(arg, sizeof(arg))
		int target = FindTarget(client, arg, true, false)
		if(IsClientInGame(target))
		{
			int r, g, b, a
			GetEntityRenderColor(target, r, g, b, a)
			CPrintToChat(target, "{orange}%N {white}currect skin color is: {darkred}%i {darkgreen}%i {darkblue}%i", target, r, g, b)
		}
	}
	else
	{
		char sInfo[66]
		char sDisplay[MAX_NAME_LENGTH]
		Menu menu = new Menu(Handler_GetSkinColorMenu)
		menu.SetTitle("Get skin color from:\n ")
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				Format(sInfo, sizeof(sInfo), "%i", GetClientUserId(i))
				GetClientName(i, sDisplay, sizeof(sDisplay))
				menu.AddItem(sInfo, sDisplay)
			}
		}
		menu.ExitBackButton = true
		menu.ExitButton = true
		if(menu.ItemCount != 0)
			menu.Display(client, MENU_TIME_FOREVER)
		else
			CPrintToChat(client, "{white}No players to get his/her skin color.")
	}
	return Plugin_Handled
}

int Handler_GetSkinColorMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[MAX_NAME_LENGTH]
			menu.GetItem(param2, item, sizeof(item))
			int client = GetClientOfUserId(StringToInt(item))
			if(IsClientInGame(client))
			{
				int r, g, b, a
				GetEntityRenderColor(client, r, g, b, a)
				CPrintToChat(param1, "{orange}%N {white}currect skin color is: {darkred}%i {darkgreen}%i {darkblue}%i", client, r, g, b)
			}
		}
		case MenuAction_End:
			delete menu
	}
}

void Mirror_Trigger(int client)
{
	if(IsPlayerAlive(client) && GetEntityFlags(client) & FL_ONGROUND) //check if player is on ground
	{		
		//https://github.com/dvarnai/store-plugin/blob/master/addons/sourcemod/scripting/thirdperson.sp#L166-L179
		//SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0) 
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1)
		//SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0)   
		SetEntProp(client, Prop_Send, "m_iFOV", 120)
		gB_Mirror_Trigger[client] = true
	}
}

Action Command_ExamineMySelf(int client, int args)
{
	Mirror_Trigger(client)
	return Plugin_Handled
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3])
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && gB_Mirror_Trigger[client])
	{
		float fSpeed[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fSpeed)
		if(fSpeed[0] != 0.0 || fSpeed[1] != 0.0 || fSpeed[2] != 0.0)
		{
			//https://github.com/dvarnai/store-plugin/blob/master/addons/sourcemod/scripting/thirdperson.sp#L166-L179
			//SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1)
			SetEntProp(client, Prop_Send, "m_iObserverMode", 0)  
			//SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1)
			SetEntProp(client, Prop_Send, "m_iFOV", 90)
			gB_Mirror_Trigger[client] = false
		}
	}
}

int Native_GetClientColorR(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int r, g, b, a
	GetEntityRenderColor(client, r, g, b, a)
	return r
}

int Native_GetClientColorG(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int r, g, b, a
	GetEntityRenderColor(client, r, g, b, a)
	return g
}

int Native_GetClientColorB(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int r, g, b, a
	GetEntityRenderColor(client, r, g, b, a)
	return b
}
