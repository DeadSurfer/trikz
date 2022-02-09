float g_macroTime[MAXPLAYERS + 1]
bool g_macroOpened[MAXPLAYERS + 1]

public Plugin myinfo =
{
  name = "Macro",
  author = "Nick Jurevich",
  description = "Make trikz game more comfortable."
  version = "0.4",
  url = "http://www.sourcemod.net/"
}

public Action OnPlayerRunCmd(int client, int& buttons)
{
  if(buttons & IN_ATTACK2)
  {
    g_macroTime[client] = GetEngineTime()
    g_macroOpened[client] = true
    buttons |= IN_ATTACK
  }
  if(GetEngineTime() - g_macroTime[client] >= 0.1 && g_macroOpened[client])
  {
    buttons |= IN_JUMP
    g_macroOpened[client] = false
  }
  return Plugin_Continue
}