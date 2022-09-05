# trikz g
So you can hold F1 F2 E R buttons to make some options.<br>
Database is fakeepxert. Sourcemod.net<br>
New database is trueexpert.<br>
Thanks to DeadSurfer for points system idea.<br>
Boost fix from Tengu.<br>
Macro idea from Log server TrikzTime<br>
George entity filtring idea from Github repository. (Ciallo-Ani) (Ciallo)<br>
Models from rar *(fakeexper.rar) is from Expert-Zone.<br>
Ping tool code from rumour. FakeExpert is good but Expert-Zone better.<br>
Also you have "I" button for extra options.<br>
Thanks to LOn for first george source "trikz_solid.sp" code gaving and Bop cooperating from LOn, LOn found Bop and give me He discord, Bop gives me "trikz_solid.sp" used screen demonstratin and chat messaging.<br>
Thanks to Shavit trikz plugin as template for beggining.<br>
Most expensive bug was fixed by hornet and ed in 2019 discovered by me. It flashbang disapear from render.<br>
These all stories about Counter-Strike: Source by Valve company.<br>
Modification of game calls as "trikz" or trick.<br>
Flashbang and two players gameplay together via speed in the time.<br>
Stackboost discovered by Gaaamer on youtube.com<br>
Boost from "sky" is discovored by ED as correct way. But first was Tengulawl in public access or MLG in 2016 year public server in Game Counter-Strike: Source trikz playgame.<br>
As i heard MLG begining in 2015 year.<br>
I started play trikz in 2012 year with friend from own server.<br>
We used alliedmodders.com plugins from forum.<br>
Sega was good friend we played trikz all night together.<br>
We can use open-source code from Valve as Source Engine to improve programming skills and motivet to learn.<br>
Man patīk rakt kartupeļus.<br>
Tomāti bija ļoti svaigi sāti gardi.<br>
Gurķi bija labi svaigi sātigi sulīgi.<br>
Zemenes bija saldas un svaigas.<br>
Bedre bija izrakta sunim, lai to noglabātu laicīgi.<br>
Domas jāatdala ar komatu. Smiltis sunim mutē.<br>
Es riju smiltis. Es riju ābolus. Es riju gaļu.<br>
Es riju smiltis bērnudārzā.<br>
Datorā atrodas pornogrāfija.<br>
Modificēts flashbang no valve arhīviem.<br>
Swoobles.com model editor 1.7 versija. Un izmontojot gcfscape programatūru. Atļauja tika iedota no EDa puses. Izmantot visus materiālus un modeļus ieskaitot eglīšu dāvanas un citus rotājumus. Gamebana.com bsp faili satur pornogrāfiju. Un vēl daudz ponografiskus materiālus satur gamebanana.com bsp faili un citi. bsp var atvērt ar pakratu un mdl var nolasīt ar blender programatūru. Favorīt mape ir trikz_kyoto_final to var spēlēt ar macro no sourcemod. UN trikz plaginiem. Used to microsoft blogs to learn c++ and sizeof
Izmantots arī ir hlmod.ru un ws.org.<br>
Ņagas vairāk nav. Xampp programatūra ir izmantota kā mysql datubāze.<br>
GNU OPENSOURCE LICENSE. PUBLIC. Used tengulawl or tengu zones for trueexpert so calculate vectors bettwen two points and make corners of calculation.<br>

Natives:<br>
native int Trikz_GetClientPartner(int client); //Get partner<br>
native int Trikz_SetPartner(int client, int partner); //Set partner<br>
native int Trikz_Restart(int client); //Do restart<br>
native bool Trikz_GetTimerState(int client); //Is timer runing (true/false)<br>
native int Trikz_GetDevmap(); //Is devmap now (true/false)<br>

Forwards:<br>
public void Trikz_ColorTeam(int client, int partner, int red, int green, int blue) //On do color for skin<br>
{
<br>
}

public void Trikz_ColorFlashbang(int client, int red, int green, int blue) //On do color for flashbang<br>
{
<br>
}

public void Trikz_Start(int client, int partner) //On timer start<br>
{
<br>
}

public void Trikz_Record(int client, int partner, float time, float differ) //On new server record<br>
{
<br>
}

public void Trikz_Finish(int client, int partner, float time, float differ) //On finish map<br>
{
<br>
}

public void Trikz_Restart(int client, int partner) //On try to restart timer<br>
{
<br>
}

public void Trikz_Checkpoint(int client, int partner, float time, float differ, int type) //On checkpoint finish (type: 0 - first checkpoint record, 1 - deprove, 2 - improve)<br>
{
<br>
}

public void Trikz_Partner(int client, int partner) //On get partner<br>
{
<br>
}

public void Trikz_Breakup(int client, int partner) //On breakup<br>
{
<br>
}

public void Trikz_Teleport(int client) //On teleport<br>
{
<br>
}
