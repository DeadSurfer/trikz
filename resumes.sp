#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define step 15
#define MAXPLAYER MAXPLAYERS + 1

Handle mp_forcecamera = INVALID_HANDLE;

int g_state[MAXPLAYER] = {0, ...};
int g_r[MAXPLAYER] = {255, ...};
int g_g[MAXPLAYER] = {0, ...};
int g_b[MAXPLAYER] = {0, ...};

int g_entity[MAXPLAYER] = {0, ...};

bool g_rainbow[MAXPLAYER] = {false, ...};

native int Trikz_GetTeamColor(int client, int[] color);

public Plugin myinfo =
{
	name = "TrueExpert - Rainbow",
	author = "Niks Smesh Jurēvičs",
	description = "Allow to make rainbow player and flashbang.",
	version = "0.1",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	mp_forcecamera = FindConVar("mp_forcecamera");

	RegConsoleCmd("sm_testx", cmd_test);
	RegConsoleCmd("sm_rainbow", cmd_rainbow);

	return;
}

//If you declarate a static, it creating once. In memory static can be changed by declarated variable.

/*static void trikz()
{
	static int x = 0; //This line will be created only once while plugin running.
	PrintToServer("A variable number of static integer is "%i".", x); //Here we show a variable to the server console, if this function will be called.
	x++; //Here you always add 1 to "x" variable, so it never gonna craeted again, it never resets while plugin running.

	const int y = 0; //This line will be creating always, if this funtion will be called.
	y + 1; //Here we add 1 to "z" variable, but this will be no effect.
	PrintToServer("A variable of const integer is "%i"", y); //A variable must be 0;

	int z = 0; //This line will be creating always, if this function will be called.
	z + 1; //Here we add 1 to "z" variable.
	PrintToServer("A variable of normal integer "%i"", z); //Here we show to the server console "z" variable. A variable must be 1.

	int i = 0; //Here we creating integer always.
	PrintToServer("%i", i++); //This will be 0;

	int j = 0; //Here we creating integer always.
	PrintToServer("%i", ++j); //Here will be 1.

	//"++" adding 1 to integer variable. Pre increment will add 1 before funtion called, post will add 1 after function called.

	//void return nothing to the funtion.
	//action return integer value to the function.
	//

	//global variables will be saved outside function.

	//

	void foo(int x, float y, const char z) //This is function. Function starts with typeset and name. Also function should have arguments.
	{//Function open here.
		//Function inside.

		int value = 9000000000;

		for(int k = 0; k < sizeof(value); k++)
		{
			//This loop will do cycle, after finish function will be ended. "while(){}" work same but end if u do "break;". "continue;" will start next cycle, if use it somewhere.
		}

		if(value == 1 || value == 101)
		{
			//code read here
		}

		//We can call function "foo(1, 2.3, "A")" inside the "OnPluginStart()". "OnPluginStart()" calls once when plugin get run. "OnPlayerRunCmd(...)" funtion calls 100 times per second.
	}//Function close here.

	//

	static const int k = 0; //This will be created once and this cant be changed.

	//decompiler dont see static things.

	//"cheat engine" is not decompiler, so we can search address of static elements. If you want to search some addresses via "cheat engine", you must try = you could try, type the value of what you want to search.

	//used "youtube".

	//"80.232.242.48" connected to "youtube" ip address.

	//vpn work like you connect to other user and he connect to "vk.com".

	return;
}*/

public void OnClientPutInServer(int client)
{
	g_rainbow[client] = false;

	if(GetGameTime() >= 3600.0)
	{
		int count = 0;

		char map[192] = "";
		GetCurrentMap(map, sizeof(map));

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) == true && IsFakeClient(i) == false)
			{
				count++;
			}
		}

		if(count == 1)
		{
			ForceChangeLevel(map, "tickrate bug");
		}
	}

	return;
}

/*public void OnClientAuthorized(client, const char[] auth)
{
	PrintToServer("%N %s", client, auth);

	return;
}

public void OnClientPostAdminCheck(int client)
{
	PrintToServer("%N", client);

	return;
}*/

Action cmd_test(int client, int args)
{
	//SetThirdPersonView(client, args);

	//PrintToServer("%.20f", GetEntPropFloat(client, Prop_Data, "m_fLerpTime", 0));

	/*char sInterp[8] = "";
	char sInterp_ratio[8] = "";
	GetClientInfo(client, "cl_interp", sInterp, sizeof(sInterp));
	GetClientInfo(client, "cl_interp_ratio", sInterp_ratio, sizeof(sInterp_ratio));

	float interp = StringToFloat(sInterp);
	float interp_ratio = StringToFloat(sInterp_ratio);

	PrintToServer("%f %f", interp, interp_ratio);

	interp *= 1000.0;
	interp_ratio *= 10.0;

	PrintToServer("%f %f", interp, interp_ratio);

	if(interp < interp_ratio)
	{
		interp = interp_ratio;
	}

	PrintToServer("%f %f", interp, interp_ratio);*/

	//SetEntPropFloat(client, Prop_Data, "m_fLerpTime", 0.0, 0);
	
	//g_rainbow[client] = !g_rainbow[client];

	return Plugin_Handled;
}

Action cmd_rainbow(int client, int args)
{
	g_rainbow[client] = !g_rainbow[client];

	int color[3] = {0, ...};
	Trikz_GetTeamColor(client, color);

	int cgroup = GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0);
	SetEntityRenderColor(client, color[0], color[1], color[2], cgroup == 5 ? 255 : 125);

	PrintToChat(client, g_rainbow[client] == true ? "You got rainbow now!" : "You lost rainbow!");

	return Plugin_Handled;
}

stock void SetThirdPersonView(int client, bool third)
{
	//if(g_bThirdPerson == false || IsPlayerAlive(client) == false)
	//{
		//return;
	//}
	
	if(third == true)
	{
		
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0); 
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 120);
		SendConVarValue(client, mp_forcecamera, "1");
		//SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		
		//SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
		//SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_CROSSHAIR_CSGO);
	}

	else if(third == false)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
		char valor[6] = "";
		GetConVarString(mp_forcecamera, valor, 6);
		SendConVarValue(client, mp_forcecamera, valor);
		//SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
		//SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~HIDE_RADAR_CSGO);
		//SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~HIDE_CROSSHAIR_CSGO);
	}

	return;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile", true) == true)
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKProjectile);
	}

	return;
}

void SDKProjectile(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", 0);

	if(IsValidEntity(entity) == true && IsValidEntity(client) == true && g_rainbow[client] == true)
	{
		g_entity[client] = EntIndexToEntRef(entity);
	}

	return;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	/*if(buttons > 0)
	{
		PrintToServer("%i", buttons);
	}*/

	/*if(impulse > 0)
	{
		PrintToServer("%i", impulse);
	}*/

	if(g_rainbow[client] == true) //https://stackoverflow.com/questions/31784658/how-can-i-loop-through-all-rgb-combinations-in-rainbow-order-in-java
	{
		SetEntityRenderColor(client, g_r[client], g_g[client], g_b[client], GetEntProp(client, Prop_Data, "m_CollisionGroup", 4, 0) == 5 ? 255 : 125);

		if(IsValidEntity(g_entity[client]) == true)
		{
			SetEntityRenderColor(g_entity[client], g_g[client], g_b[client], g_r[client], 255);
		}

		switch(g_state[client])
		{
			case 0:
			{
				g_g[client] += step;

				if(g_g[client] == 255)
				{
					g_state[client] = 1;
				}
			}

			case 1:
			{
				g_r[client] -= step;

				if(g_r[client] == 0)
				{
					g_state[client] = 2;
				}
			}

			case 2:
			{
				g_b[client] += step;

				if(g_b[client] == 255)
				{
					g_state[client] = 3;
				}
			}

			case 3:
			{
				g_g[client] -= step;

				if(g_g[client] == 0)
				{
					g_state[client] = 4;
				}
			}

			case 4:
			{
				g_r[client] += step;

				if(g_r[client] == 255)
				{
					g_state[client] = 5;
				}
			}

			case 5:
			{
				g_b[client] -= step;

				if(g_b[client] == 0)
				{
					g_state[client] = 0;
				}
			}
		}		
	}

	return Plugin_Continue;
}

/*public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	PrintToServer("%N %s %s", client, command, sArgs);

	return Plugin_Continue;
}*/
