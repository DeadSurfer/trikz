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
#include <sdktools>
#include <dhooks>

public Plugin myinfo =
{
	name = "Remove the flashbang on detoante",
	author = "Smesh, thanks to https://forums.alliedmods.net/showthread.php?t=159876 (Dr!fter), thanks to george",
	description = "Remove the flashabang on detonate.",
	version = "26.02.2021",
	url = "https://www.sourcemod.net/"
}

public void OnPluginStart()
{
	Handle hGamedata = LoadGameConfigFile("fbtools.games")
	if(!hGamedata)
	{
		SetFailState("Failed to load fbtools.games!")
		delete hGamedata
	}
	Handle hFunctions = DHookCreateFromConf(hGamedata, "OnFlashDetonate")
	if(!hFunctions)
	{
		delete hGamedata
		delete hFunctions
		SetFailState("Failed to setup detour for OnFlashDetonate")
	}
	if(!DHookEnableDetour(hFunctions, false, OnFlashDetonate))
	{
		delete hGamedata;
		delete hFunctions;
		SetFailState("Failed to detour OnFlashDetonate.");
	}
	delete hGamedata
	delete hFunctions //the Functions section is now cached which is all we need for the next bit.
}

MRESReturn OnFlashDetonate(int pThis, Handle hReturn)
{
	if(IsValidEntity(pThis))
	{
		AcceptEntityInput(pThis, "Kill")
		return MRES_Supercede
	}
	return MRES_Ignored
}
