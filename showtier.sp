ArrayList g_tier = null;
int g_count = 0;

public void OnMapStart()
{
	Database.Connect(SQLConnect, "trueexpert", 0);

	return;
}

void SQLConnect(Database db, const char[] error, any data)
{
	if(db == INVALID_HANDLE)
	{
		return;
	}
	
	db.Query(SQLGetTier, "SELECT tier, map FROM tier", _, DBPrio_Normal);

	return;
}

void SQLGetTier(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0)
	{
		PrintToServer("SQL_GetTier: %s", error);
	}

	else if(strlen(error) == 0)
	{
		static int tier = 0;
		static char map[192] = "", format[256] = "";

		g_count = 0;

		while(results.FetchRow() == true)
		{
			g_count++;
			
			continue;
		}

		delete g_tier;
		g_tier = new ArrayList(sizeof(format));

		results.Rewind();

		while(results.FetchRow() == true)
		{
			tier = results.FetchInt(0);
			results.FetchString(1, map, sizeof(map));
			Format(format, sizeof(format), "%s;%i", map, tier);
			g_tier.PushString(format);
			
			continue;
		}
	}

	return;
}

char[] ShowTier(const char[] displayName)
{
	static char buffer[256] = "", buffers[2][192] = {"", ""};
	static const char roman[][] = {"I", "II", "III", "IV", "V", "VI"};

	for(int i = 0; i < g_count; i++)
	{
		g_tier.GetString(i, buffer, sizeof(buffer));
		ExplodeString(buffer, ";", buffers, 2, 192, false);

		if(StrEqual(displayName, buffers[0], false) == true)
		{
			break;
		}
		
		continue;
	}
	
	for(int i = 0; i < sizeof(roman); i++)
	{
		if(i + 1 != StringToInt(buffers[1]))
		{
			Format(buffer, sizeof(buffer), "[?] %s", displayName);
			
			break;
		}
		
		else if(i + 1 == StringToInt(buffers[1]))
		{
			Format(buffer, sizeof(buffer), "[%s] %s", roman[i], displayName);

			break;
		}
		
		continue;
	}

	return buffer;
}
