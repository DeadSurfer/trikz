#pragma semicolon 1
#pragma newdecls required

char g_comtolist[][] = {"say", "say_team"};

public Plugin myinfo = 
{
    name = "Chat logger",
    description = "Make chat logging to the sourcemod directory.",
    author = "Niks Jurēvičs",
    version = "0.113",
    url = "http://sourcemod.net/"
};

public void OnPluginStart()
{
    for(int i = 0; i < sizeof(g_comtolist); i++) //We take first cell from array, and ittering to the next cell. "sizeof" function getting all two cells from array.
    {
        AddCommandListener(chatlog, g_comtolist[i]);
    }

    return;
}

Action chatlog(int client, const char[] command, int argc)
{
    if(client == 0) //Server send message from sourcemod as convars sm_, because we listen all possible commands.
    {
        return Plugin_Continue;
    }

    int steamid = GetSteamAccountID(client, true);

    char buffer[256] = "";
    GetCmdArgString(buffer, sizeof(buffer));

    char bufferFirst[3] = "";
    Format(bufferFirst, sizeof(bufferFirst), "%s", buffer);

    //PrintToServer("debug here: %s", bufferFirst);

    if(FindCharInString(bufferFirst, '!', false) > 0)
    {
        return Plugin_Continue;
    }

    char bufferTime[23] = "";
    FormatTime(bufferTime, sizeof(bufferTime), "%Y-%d-%m (%H:%M:%S)", GetTime({0, 0}));

    LogToFile("addons/sourcemod/logs/trueexpert-logger.log", "Date: [%s] SteamID: [U:1:%i] Command: [%s] Message: [%s]", bufferTime, steamid, command, buffer);

    return Plugin_Continue;
}

//04.12.2022, 2022.12.04 : 12:29:38
