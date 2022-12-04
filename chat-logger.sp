#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
    name = "Chat logger",
    description = "Make chat logging to the sourcemod directory.",
    author = "Niks Jurēvičs",
    version = "0.1",
    url = "http://sourcemod.net/"
};

public void OnPluginStart()
{
    AddCommandListener(chatlog, "");

    return;
}

Action chatlog(int client, const char[] command, int argc)
{
    int steamid = GetSteamAccountID(client, true);

    char buffer[256] = "";
    GetCmdArgString(buffer, sizeof(buffer));

    char bufferTime[256] = "";
    FormatTime(bufferTime, sizeof(bufferTime), "%d-%m-%Y (%H:%M:%S)", GetTime({0, 0}));

    LogToFile("addons/sourcemod/logs/trueexpert-logger.log", "Date: [%s] SteamID: [%i] Command: [%s] Message: [%s]", bufferTime, steamid, command, buffer);

    return Plugin_Continue;
}
