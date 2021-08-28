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

#include <sdkhooks>

float gF_boostTimeStart[MAXPLAYERS + 1]
float gF_boostTimeEnd[MAXPLAYERS + 1]
bool gB_boostRead[MAXPLAYERS + 1]
float gF_projectileVel[MAXPLAYERS + 1]
float gF_unitVel[MAXPLAYERS + 1]
int gI_duck[MAXPLAYERS + 1]

public Plugin myinfo =
{
	name = "Boost stats",
	author = "Smesh",
	description = "Measures time between attack and jump",
	version = "0.1",
	url = "http://www.sourcemod.net/"
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	char sWeapon[32]
	int activeWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon")
	if(IsValidEntity(activeWeapon))
		GetEntityClassname(activeWeapon, sWeapon, 32)
	if(StrEqual(sWeapon, "weapon_flashbang"))
	{
		if(GetEntProp(client, Prop_Data, "m_afButtonReleased") & IN_ATTACK)
		{
			gF_boostTimeStart[client] = GetEngineTime()
			gB_boostRead[client] = true
			float vel[3]
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel)
			gF_unitVel[client] = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0))
			gI_duck[client] = GetEntProp(client, Prop_Data, "m_bDucking")
		}
		if(GetEntityFlags(client) & FL_ONGROUND && buttons & IN_JUMP && gB_boostRead[client])
		{
			gF_boostTimeEnd[client] = GetEngineTime()
			//PrintToServer("Time: %f, Speed: %f", gF_boostTimeEnd[client] - gF_boostTimeStart[client], gF_projectileVel[client])
			gB_boostRead[client] = false
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "flashbang_projectile"))
		SDKHook(entity, SDKHook_Spawn, SDKSpawnProjectile)
}

Action SDKSpawnProjectile(int entity)
{
	//float vel[3]
	//GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel)
	//float unitVel = SquareRoot(Pow(vel[0], 2.0) + Pow(vel[1], 2.0))
	//float unitVel = GetVectorLength(vel) //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
	//PrintToServer("%f", unitVel)
	RequestFrame(frame_projectileVel, EntIndexToEntRef(entity))
	//CreateTimer(0.2, timer_projectileVel, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE)
}

//Action timer_projectileVel(Handle timer, int ref)
void frame_projectileVel(int ref)
{
	int entity = EntRefToEntIndex(ref)
	if(IsValidEntity(entity))
	{
		float vel[3]
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel)
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity")
		gF_projectileVel[client] = GetVectorLength(vel) //https://github.com/shavitush/bhoptimer/blob/36a468615d0cbed8788bed6564a314977e3b775a/addons/sourcemod/scripting/shavit-hud.sp#L1470
		char sDuck[16]
		Format(sDuck, 16, gI_duck[client] ? "Yes" : "No")
		//PrintToServer("%f", gF_projectileVel[client])
		PrintToServer("Time: %f, Speed: %f, Run: %f, Duck: %s", gF_boostTimeEnd[client] - gF_boostTimeStart[client], gF_projectileVel[client], gF_unitVel[client], sDuck)
	}
//	return Plugin_Stop
}
