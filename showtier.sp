ArrayList g_tier = null;
int g_count = 0;

public void OnMapStart()
{
	Database.Connect(SQLConnect, "trueexpert", 0);

	return;
}

void SQLConnect(Database db, const char[] error, any data)
{
	static char query[256] = "";
	Format(query, sizeof(query), "SELECT tier, map FROM tier");
	db.Query(SQL_GetTier, query, _, DBPrio_Normal);

	return;
}

void SQL_GetTier(Database db, DBResultSet results, const char[] error, any data)
{
	static int tier = 0;
	static char map[192] = "", format[256] = "";

	g_count = 0;
	
	while(results.FetchRow() == true)
	{
		g_count++;
	}

	delete g_tier;
	g_tier = new ArrayList(sizeof(format), 0);

	results.Rewind();

	while(results.FetchRow() == true)
	{
		tier = results.FetchInt(0);
		results.FetchString(1, map, sizeof(map));
		Format(format, sizeof(format), "%s;%i", map, tier);
		g_tier.PushString(format);
	}

	return;
}

char[] ShowTier(const char[] displayName)
{
	static char format[256] = "", exploded[2][192] = {"", ""};
	static const char roman[][] = {"I", "II", "III", "IV", "V", "VI"};

	for(int i = 0; i < g_count; i++)
	{
		g_tier.GetString(i, format, sizeof(format));
		ExplodeString(format, ";", exploded, 2, 192, false);

		if(StrEqual(displayName, exploded[0], false) == true)
		{
			break;
		}
	}
	
	for(int i = 0; i < sizeof(roman); i++)
	{
		if(i + 1 == StringToInt(exploded[1]))
		{
			Format(format, sizeof(format), "[%s] %s", roman[i], displayName);

			break;
		}

		else if(i + 1 != StringToInt(exploded[1]))
		{
			Format(format, sizeof(format), "[?] %s", displayName);
		}
	}

	return format;
}
