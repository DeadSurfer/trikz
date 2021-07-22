/*GNU GENERAL PUBLIC LICENSE

VERSION 2, JUNE 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fith Floor, Boston, MA 02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.*/

/*GNU GENERAL PUBLIC LICENSE VERSION 3, 29 June 2007
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
	your programs, too.*/
#include <cstrike>

#pragma newdecls required

int gI_killCount[MAXPLAYERS + 1]
ConVar gCV_MVPFirst = null
ConVar gCV_MVPLimit = null
ConVar gCV_MVPStep = null

public Plugin myinfo =
{
	name = "MVP by kills",
	author = "Smesh",
	description = "Giving MVP star by kills",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath)
	gCV_MVPFirst = CreateConVar("sm_mvpfirst", "6", "Give mvp star at first number (ex. at 6).")
	gCV_MVPLimit = CreateConVar("sm_mvplimit", "9999", "Stop giving mvp stars (9999 engine limit CS:S OB).")
	gCV_MVPStep = CreateConVar("sm_mvpstep", "6", "Give mvp star each step number (ex. 6, 12, 18).")
	AutoExecConfig(true)
}

Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"))
	if(gI_killCount[victim] != 0)
		gI_killCount[victim] = 0
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"))
	gI_killCount[attacker] = gI_killCount[attacker] + 1
	
	char sFirst[5]
	GetConVarString(gCV_MVPFirst, sFirst, 5)
	int iFirst = StringToInt(sFirst)
	char sLimit[5]
	GetConVarString(gCV_MVPLimit, sLimit, 5)
	int iLimit = StringToInt(sLimit)
	char sStep[5]
	GetConVarString(gCV_MVPStep, sStep, 5)
	int iStep = StringToInt(sStep)
	for(int i = iFirst; i <= iLimit; i += iStep)
	{
		if(gI_killCount[attacker] == i)
		{
			CS_SetMVPCount(attacker, CS_GetMVPCount(attacker) + 1)
			PrintToChat(attacker, "[SM] You received mvp star by %i kills.", gI_killCount[attacker])
		}
	}
}
