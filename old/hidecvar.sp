#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Hide cvar (sm_nextmap)",
	author = "https://hlmod.ru/threads/kak-ubrat-otobrazhenie-izmenenija-peremennyx-servera.5317/#post-38223 (FrozDark)",
	description = "You can hide the cvar via sourcepawn code",
	version = "14.01.2021",
	url = "https://steamcommunity.com/id/smesh292/"
};

public void OnPluginStart()
{
    Handle hCvar = FindConVar("sm_nextmap");
    SetConVarFlags(hCvar, GetConVarFlags(hCvar) &~ FCVAR_NOTIFY);
}
