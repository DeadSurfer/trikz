/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Admin Help Plugin
 * Displays and searches SourceMod commands and descriptions.
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

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
    version = "0.128",
    url = "http://sourcemod.net/"
};

public void OnPluginStart()
{
    g_prefixPointEnable = CreateConVar("sm_te_log_enable", "0.0", "Enable log message saving.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_prefixPointHide = CreateConVar("sm_te_log_hide", "0.0", "Allow to hide message if they have explamation or slash before all message.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    AutoExecConfig(true, "plugin.trueexpert-logchat", "sourcemod");

    for(int i = 0; i < sizeof(g_comtolist); i++) //We take first cell from array, and ittering to the next cell. "sizeof" function getting all two cells from array.
    {
        AddCommandListener(chatlog, g_comtolist[i]);
    }

    return;
}

/*static private*/ Action chatlog(int client, const char[] command, int argc)
{
    //declaration
    float convarEnable, convarPrefix;
    char name[MAX_NAME_LENGTH], auth[32], type[4 + 1], format[256], buffer[256], /*time[22], */ex, slash;
    int /*stamp, */findEx, findSlash;

    //initialization
    convarEnable = g_prefixPointEnable.FloatValue;
    convarPrefix = g_prefixPointHide.FloatValue;
    //stamp = GetTime({0, 0});
    ex = '!', slash = '/';

    if(convarEnable != 1.0) //If float value not 1.0, plugin going to skip all code under first Plugin_Continue;
    {
        return Plugin_Continue;
    }

    //if(client == 0) //Server send message from sourcemod as convars sm_, because we listen all possible commands. Prevent say from console
    //{
    //    return Plugin_Continue;
    //}

    if(client == 1)
    {
        GetClientAuthId(client, AuthId_SteamID64, auth, sizeof(auth), true); //(first account of SteamID64) + SteamID3 = SteamID64

        GetClientName(client, name, sizeof(name));
    }

    else if(client == 0)
    {
        Format(auth, sizeof(auth), "server");
        Format(name, sizeof(name), "console");
    }

    if(StrEqual(command, "say", true) == true)
    {
        Format(type, sizeof(type), "all");
    }

    else if(StrEqual(command, "say_team", true) == true)
    {
        Format(type, sizeof(type), "team");
    }
    
    GetCmdArgString(format, sizeof(format));
    Format(buffer, sizeof(buffer), "%s", format);
    findEx = FindCharInString(buffer, ex, false);
    findSlash = FindCharInString(buffer, slash, false);

    //PrintToServer("debug here: %s", bufferFirst);

    if(convarPrefix == 1.0 && (findEx != -1 || findSlash != -1)) //float value of convar and char "!" passing values.
    {
        return Plugin_Continue;
    }

    //FormatTime(time, sizeof(time), "%Y-%d-%m (%H:%M:%S)", stamp);
    //LogToFileEx("addons/sourcemod/logs/trueexpert-logger.log", "Date: [%s] SteamID64: [%s] Name: [%s] Message (%s): [%s]", time, auth, name, type, buffer);
    LogToFileEx("addons/sourcemod/logs/trueexpert-logger.log", "SteamID64: [%s] Name: [%s] Message (%s): [%s]", auth, name, type, buffer);

    return Plugin_Continue;
}

//04.12.2022, 2022.12.04 : 12:29:38
