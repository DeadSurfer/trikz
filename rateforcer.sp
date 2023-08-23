/*
	GNU GENERAL PUBLIC LICENSE
	VERSION 2, JUNE 1991
	Copyright (C) 1989, 1991 Free Software Foundation, Inc.
	51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA
	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.
	GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.
*/
#pragma semicolon 1
#pragma newdecls required

#define MAXPLAYER MAXPLAYERS + 1

bool g_stop[MAXPLAYER];

public Plugin myinfo =
{
	name = "Rate Forcer",
	author = "Nick Jurevics (Smesh, Smesh292)",
	description = "Trying to keep perfect rate values.",
	version = "1.0",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) == true)
        {
            OnClientPutInServer(i);
        }
    }

    RegConsoleCmd("sm_stop", cmd_stop);

    return;
}

public void OnClientPutInServer(int client)
{
    if(IsFakeClient(client) == false)
    {
        g_stop[client] = false;

        CreateTimer(10.0, timer_rate, client, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
    }

    return;
}

public Action cmd_stop(int client, int args)
{
    g_stop[client] = true;

    return Plugin_Handled;
}

public Action timer_rate(Handle timer, int client)
{
    if(IsClientInGame(client) == false)
    {
        return Plugin_Stop;
    }

    if(g_stop[client] == true)
    {
        return Plugin_Stop;
    }
    
    char rate[16] = "";
    char cmdrate[8] = "";
    char updaterate[8] = "";
    char interp[8] = "";
    char interp_ratio[8] = "";

    GetClientInfo(client, "rate", rate, sizeof(rate));
    GetClientInfo(client, "cl_cmdrate", cmdrate, sizeof(cmdrate));
    GetClientInfo(client, "cl_updaterate", updaterate, sizeof(updaterate));
    GetClientInfo(client, "cl_interp", interp, sizeof(interp));
    GetClientInfo(client, "cl_interp_ratio", interp_ratio, sizeof(interp_ratio));

    float iInterp = StringToFloat(interp);

    if(!(StrEqual(rate, "1048576", true) == true) || !(StrEqual(cmdrate, "100", true) == true) || !(StrEqual(updaterate, "100", true) == true) || iInterp < 0.005 || !(StrEqual(interp_ratio, "0", true) == true))
    {
        PrintToChat(client, "Настройки, Клавиатура, Дополнительно, Включить консоль (~)");
    }

    if(!(StrEqual(rate, "1048576", true) == true))
    {
        PrintToChat(client, "spectate; rate 1048576");
    }

    if(!(StrEqual(cmdrate, "100", true) == true))
    {
        PrintToChat(client, "spectate; cl_cmdrate 100");
    }

    if(!(StrEqual(updaterate, "100", true) == true))
    {
        PrintToChat(client, "spectate; cl_updaterate 100");
    }

    if(iInterp < 0.005)
    {
        PrintToChat(client, "spectate; cl_interp 0.005");
    }

    if(!(StrEqual(interp_ratio, "0", true) == true))
    {
        PrintToChat(client, "spectate; cl_interp_ratio 0");
    }

    if(!(StrEqual(rate, "1048576", true) == true) || !(StrEqual(cmdrate, "100", true) == true) || !(StrEqual(updaterate, "100", true) == true) || iInterp < 0.005 || !(StrEqual(interp_ratio, "0", true) == true))
    {
        PrintToChat(client, "Если Вы хотите остановить оповещения, напишите !stop в игровой чат.");
    }

    return Plugin_Continue;
}
