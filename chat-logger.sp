#pragma semicolon 1
#pragma newdecls required

char g_comtolist[][] = {"say", "say_team"};
ConVar g_prefixPointEnable = null;
ConVar g_prefixPointHide = null;

public Plugin myinfo = 
{
    name = "Chat logger",
    description = "Make chat logging to the sourcemod directory.",
    author = "Niks Jurēvičs",
    version = "0.121",
    url = "http://sourcemod.net/"
};

public void OnPluginStart()
{
    g_prefixPointEnable = CreateConVar("sm_te_log_enable", "0.0", "Enable log message saving.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_prefixPointHide = CreateConVar("sm_te_log_hide", "0.0", "Allow to hide message if they have explamation or slash before all message.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    AutoExecConfig(true, "plugin.trueexpert-logchat.cfg", "sourcemod");

    for(int i = 0; i < sizeof(g_comtolist); i++) //We take first cell from array, and ittering to the next cell. "sizeof" function getting all two cells from array.
    {
        AddCommandListener(chatlog, g_comtolist[i]);
    }

    return;
}

Action chatlog(int client, const char[] command, int argc)
{
    float convarEnable = g_prefixPointEnable.FloatValue;

    if(convarEnable != 1.0) //If float value not 1.0, plugin going to skip all code under first Plugin_Continue;
    {
        return Plugin_Continue;
    }

    if(client == 0) //Server send message from sourcemod as convars sm_, because we listen all possible commands.
    {
        return Plugin_Continue;
    }

    char auth[64] = "";
    GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true); //(first account of SteamID64) + SteamID3 = SteamID64

    char name[MAX_NAME_LENGTH] = "";
    GetClientName(client, name, sizeof(name));

    char type[6] = "";

    if(StrEqual(command, "say", true) == true)
    {
        Format(type, sizeof(type), "all");
    }

    else if(StrEqual(command, "say_team", true) == true)
    {
        Format(type, sizeof(type), "team");
    }

    char buffer[256] = "";
    GetCmdArgString(buffer, sizeof(buffer));

    char bufferFirst[3] = "";
    Format(bufferFirst, sizeof(bufferFirst), "%s", buffer);

    //PrintToServer("debug here: %s", bufferFirst);

    float convarPrefix = g_prefixPointHide.FloatValue;

    char ex = '!', slash = '/';

    if(convarPrefix == 1.0 && (FindCharInString(bufferFirst, ex, false) > 0 || FindCharInString(bufferFirst, slash, false) > 0)) //float value of convar and char "!" passing values.
    {
        return Plugin_Continue;
    }

    char bufferTime[23] = "";
    FormatTime(bufferTime, sizeof(bufferTime), "%Y-%d-%m (%H:%M:%S)", GetTime({0, 0}));

    LogToFile("addons/sourcemod/logs/trueexpert-logger.log", "Date: [%s] SteamID64: [%s] Name: [%s] Message (%s): [%s]", bufferTime, auth, name, type, buffer);

    return Plugin_Continue;
}

//04.12.2022, 2022.12.04 : 12:29:38
