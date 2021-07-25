<html>
<!--<head>Trikz Timer</head>-->
<style>
.styled-table2
{
    border-collapse: collapse;
	<!--border-collapse: seperate;-->
    margin: 25px 0;
    font-size: 0.9em;
    font-family: sans-serif;
    min-width: 64px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
	<!--background-color: rgba(0,0,0,.5);--> <!--// Sets to 50% transparent https://stackoverflow.com/questions/3222961/how-to-make-a-transparent-background-without-background-image-->
	<!--border-radius: 25px;-->
	<!--border: 2px solid #73AD21;-->
	<!--padding: 20px;-->
	<!--width: 200px;-->
	<!--height: 150px;-->
}
.styled-table2 thead tr
{
    background-color: #009879;
    color: #ffffff;
    text-align: center;
}
.styled-table2 th,
.styled-table2 td
{
    padding: 12px 15px;
	<!--aligin: center;-->
	<!--color: #ffffff;-->
	<!--background-color: #ffffff;-->
}
.styled-table2 tbody tr
{
    border-bottom: 1px solid #dddddd;
	<!--background-color: #00CCA2;-->
	<!--background-color: rgba(0.0,204.0,162.0,0.5);
	background-color: transparent-->
}

.styled-table2 tbody tr:nth-of-type(even)
{
    background-color: #f3f3f3;
}

.styled-table2 tbody tr:last-of-type
{
    border-bottom: 2px solid #009879;
}
.styled-table2 tbody tr.active-row
{
    font-weight: bold;
    color: #009879;
}
.styled-table
{
    border-collapse: collapse;
	<!--border-collapse: seperate;-->
    margin: 25px 0;
    font-size: 0.9em;
    font-family: sans-serif;
    min-width: 400px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
	<!--background-color: rgba(0,0,0,.5);--> <!--// Sets to 50% transparent https://stackoverflow.com/questions/3222961/how-to-make-a-transparent-background-without-background-image-->
	<!--border-radius: 25px;-->
	<!--border: 2px solid #73AD21;-->
	<!--padding: 20px;-->
	<!--width: 200px;-->
	<!--height: 150px;-->
	<!--background-color: #009879;-->
}
.styled-table thead tr
{
    background-color: #009879;
    color: #ffffff;
	<!--color: #009879;-->
    text-align: left;
}
.styled-table th,
.styled-table td
{
    padding: 12px 15px;
	<!--background-color: #009879;-->
	<!--background-color: #f30000;-->
}
.styled-table tbody tr
{
	background-color: #ffffff;
    border-bottom: 1px solid #dddddd;
	<!--background-color: #00CCA2;-->
	<!--background-color: rgba(0.0,204.0,162.0,0.5);
	background-color: transparent-->
	<!--background-color: #F30000;-->
	<!--background-color: #009879;-->
	<!--background-color: #009879;-->
}

<!--.styled-table tbody tr:nth-of-type(even)
{
}-->
<!--https://css-tricks.com/almanac/selectors/n/nth-of-type/-->
<!--.styled-table tbody tr
{
	background-color: #009879;
}-->

.styled-table tbody tr:nth-of-type(even)
{
    background-color: #f3f3f3;
}

<!--https://developer.mozilla.org/en-US/docs/Web/CSS/:nth-of-type#basic_example-->
<!--.styled-table tbody tr:nth-child(odd)
{
    background-color: #009879;
}-->

<!--https://www.w3schools.com/cssref/sel_nth-of-type.asp-->
<!--.styled-table tbody tr:nth-of-type(odd)
{
    background-color: #009879;
}-->

<!--.styled-table tbody tr:nth-of-type(an-plus-b)
{
    background-color: #009879;
}-->

.styled-table tbody tr:last-of-type
{
    border-bottom: 2px solid #009879;
	<!--background-color: #F30000;-->
}
.styled-table tbody tr.active-row
{
    font-weight: bold;
    color: #009879;
}
.styled-table tbody td.active-row
{
    font-weight: bold;
    color: #009879;
}
</style>
<!--https://www.w3docs.com/snippets/html/how-to-set-background-color-in-html.html-->
<body style="background-color:#ffffff">
	<h1>Trikz Timer</h1> <!--//http://www.learningaboutelectronics.com/Articles/How-to-retrieve-data-from-a-textbox-using-PHP.php#:~:text=And%20the%20answer%20is%2C%20we%20can%20do%20this,information%20and%20displaying%20it%20on%20a%20web%20page. -->
	<!--<form action="" method="post">
	<label>Please enter your Name:</label>
	<input type="text" name="Name" value='<?php// echo $name; ?>'/>
	<br><br>
	<input name="form" type="submit" value="Submit"/><br><br> //https://www.foxinfotech.in/2019/01/how-to-create-text-box-and-display-its-value-in-php.html
	</form> //https://www.ecomspark.com/how-to-submit-a-form-in-php-and-email/#:~:text=In%20PHP%2C%20isset%20%28%29%20method%20is%20used%20to,%28isset%20%28%24_POST%20%5B%27submit%27%5D%29%29%20%7B%20echo%20%22form%20success%22%3B%20%7D.
	
	<form method="post">
	Enter Map name : <input type="text" name="id"><br/>
	<input type="submit" value="SELECT" name="Submit1"> <br/>-->
	<!--<a href = "index.php?page=<?//= $page + 20 ?>">Next</a><br>--> <!--https://stackoverflow.com/questions/10436017/previous-next-buttons-->
	<!--<?// if ($page > 1) : ?>
	   <a href="index.php?page=<?//= $page - 25 ?>">Prev</a>
	<? //endif ?>
	<?// if (//$page != $maxPages) : ?>
	   <a href="index.php?page=<?//= $page + 25 ?>">Next</a>
	<? //endif ?>-->
	<!--<a <?php //$next = $next + 25; echo $next; ?> class = "next">Next</a>-->
	<?php
	//session_start();
	//$url = basename($_SERVER['PHP_SELF']);
	//$query = $_SERVER['QUERY_STRING'];
	//$queryurl = 1
	//if($queryurl)
	//{
		//$url .= "?".$queryurl;
	//}
	//$_SESSION['current_page'] = $url;
	//if(isset($_POST['Submit1']))
	//{ 
	//$username = "root";
	//$password = "";
	//$hostname = "localhost"; 
	//$database="fakexpert";

	//connection to the mysql database,
	//$dbhandle = mysqli_connect($hostname, $username, $password,$database);

	//if(!empty($_POST["id"]))
	//{
	//$result = mysqli_query($db, "SELECT * FROM records where ORDER BY map ASC map=".$_POST["id"]);
	//}
	//else
	//{ 
	//$result = mysqli_query($dbhandle, "SELECT ID, Name, City FROM StudentMst" );
	//}


	//fetch tha data from the database 
	//while ($row = mysqli_fetch_array($result)) {
	//echo "ID:" .$row{'ID'}." Name:".$row{'Name'}." City: ". $row{'City'}."<br>";
	//}
	//close the connection
	//mysqli_close($dbhandle);
	//}
	//<a href = 
	//https://codetyrant.wordpress.com/2015/07/22/go-back-to-the-previous-page-in-php/
	?>
	<!--<a href="<?php //echo $current_page;?>"><button>Next</button></a>
	<a href="<?php //echo $previous_page;?>"><button>BACK</button></a>-->
	<?php
		//Step1
		$db = mysqli_connect('78.84.184.120','root','SaulesStars292mysql','fakeexpert')
		or die('Error connecting to MySQL server.');
	?>
		<!--<form method="post">
		Enter map name : <input type="text" name="submit"><br/>
		<input type="submit" value="SELECT" name="Submit1"> <br/>
		</form>-->
		<!--<label for="submit">Please choose map</label><br/>-->
				<form method = "post" action = "">
					<select id="submit" name="submit">
						<option value="">Select a map</option>
						<?php
							$sql = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
							$rs = mysqli_query($db, $sql);
							while($rows = mysqli_fetch_assoc($rs))
							{
								echo '<option value="'.$rows['map'].'">'.$rows['map'].'</option>';
							}
						?>
					</select>
		<input type = submit value = Submit></form>
		<!--https://www.wdb24.com/ajax-dropdown-list-from-database-using-php-and-jquery/<br>-->
	<?php
	//$next = $_POST['next'];
	//$next = 0;
	//$prev = $_POST['prev'];
	//if($_POST['submit'] != NULL)
	if(isset($_POST['submit'])) //https://stackoverflow.com/questions/65603660/beginner-php-warning-undefined-array-key
		$name = $_POST['submit']; //https://stackoverflow.com/questions/13447554/how-to-get-input-field-value-using-php
	else
		$name = "trikz_adventure";
	//$name = $_POST
	?>
	<?php
	//echo "Map: $name";
	echo "<table class='styled-table2'><thead><tr><th>Map: $name</th></tr></thead></table>";
	?>
	<table class="styled-table"> <!--//https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l-->
		<thead>
			<tr>
				<th><center>Place</center></th>
				<th>Team</th>
				<th><center>Time</center></th>
				<th><center>Completions</center></th>
				<!--<th>Map</th>-->
				<th><center>Date</center></th>
			</tr>
		</thead>
		<tbody>
		<!--<tr>-->
		<!--<td>-->
		<!--<td>-->
		<?php
		//Step2
		//https://www.bing.com/search?q=get+page+name+php&cvid=ac271473acee453cbb249156e9bac152&aqs=edge..69i57.4032j0j1&pglt=299&FORM=ANNTA1&PC=U531
		//$page = basename($_SERVER[PHP_SELF]);
		//$start = $_GET[start];
		//echo $page;
		//$eu = $start - 0;
		//$limit = 10;
		//$thisp = $eu + $limit;
		//$back = $eu - $limit;
		//$next = $eu + $limit;
		//$row0 = $db->query("SELECT COUNT(id) FROM records WHERE map = '$name' ORDER BY time ASC")->fetchColumn();
		//$query = "SELECT * FROM records WHERE map = '$name' ORDER BY time ASC LIMIT $eu, $limit";
		$query = "SELECT * FROM records WHERE map = '$name' ORDER BY time ASC";
		//$queryx = "SELECT * FROM records WHERE map = ".$_POST['id']"' ORDER BY time ASC"; //https://meeraacademy.com/select-query-in-php-mysql-with-example/
		mysqli_query($db, $query) or die('Error querying database. [1]');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result = mysqli_query($db, $query);
		//$rowx = mysqli_fetch_assoc($resultx);
		$count = 1;
		//echo "<table class='styled-table'>";
		//echo "<thead><tr>";
		//echo "<th>Place</th>";
		//echo "<th>Team</th>";
		//echo "<th>Time</th>";
		//echo "<th>Completions</th>";
		//echo "<th>Date</th>";
		//echo "</tr></thead>";
		//echo "<tbody><tr>";
		//echo "<td>$countx</td>";
		//echo "<tbody><tr><td>$countx</td></tr></tbody>";
		//echo "<tbody><tr>";
		//echo "<td>";
		//$countx = $countx + 1;
		//$countx++;
		$serverRecord = 0;
		//$query0 = "SELECT COUNT(id) FROM records WHERE map = '$name'";
		//mysqli_query($db, $query0) or die('Error querying in table. [2]');
		//$result0 = mysqli_query($db, $query0);
		//$row0 = mysqli_fetch_array($result0);
		//$row0 = mysqli_fet
		//$num = 
		//$row0 = $db->query0("SELECT COUNT(id) FROM records WHERE map = '$name'")->fetchColumn();
		while($row = mysqli_fetch_assoc($result))
		{
			$query2 = "SELECT username FROM users WHERE steamid = $row[playerid]";
			mysqli_query($db, $query2) or die('Error querying in table. [3]');
			$result2 = mysqli_query($db, $query2);
			$row2 = mysqli_fetch_array($result2);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query3 = "SELECT username FROM users WHERE steamid = $row[partnerid]";
				mysqli_query($db, $query3) or die('Error querying in table. [4]');
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
					//echo "<td>$countx</td>";
					//$countx = $countx + 1;
					$hours = floor($row[time] / 3600);
					$mins = floor($row[time] / 60 % 60);
					$secs = floor($row[time] % 60);
					$time = sprintf("%02d:%02d:%02d", $hours, $mins, $secs);
					$timeDiff;
					if($serverRecord == 0)
						$serverRecord = $row[time];
					$timeDiff = $row[time] - $serverRecord;
					$timeDiffHours = floor($timeDiff / 3600);
					$timeDiffMins = floor($timeDiff / 60 % 60);
					$timeDiffSecs = floor($timeDiff % 60);
					$timeDiffFormated = sprintf("%02d:%02d:%02d", $timeDiffHours, $timeDiffMins, $timeDiffSecs);
					$formatedDateYmd = date("Y-m-d", (int)$row[date]);
					$formatedDateHis = date("H:i:s", (int)$row[date]);
					//if($count == 1)
						//echo "<tr><td><center>$count</center></td><td>$row2[username] [U:1:$row[playerid]]<br>$row3[username] [U:1:$row[partnerid]]</td><td><center>$time</center></td><td><center>$row[completions]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>";
					//else
					//https://www.w3schools.com/html/html_colors.asp
					//https://www.tutorialspoint.com/html/html_colors.htm
					echo "<tr><td><center>$count</center></td><td>$row2[username] [U:1:$row[playerid]]<br>$row3[username] [U:1:$row[partnerid]]</td><td class='active-row'><center>$time <font color='#980000'>(+$timeDiffFormated)</font></center></td><td><center>$row[completions]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>";
					//$countx = $countx + 1;
					$count++;
					//echo "<td>$row2x[username]</td>";
					//echo "<tbody><tr><td>$row2x[username]</td></tr></tbody>";
				}
			}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$rowx['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//$countx = 1;
			//echo $countx . '.<br>'; //https://www.php.net/manual/en/function.get-defined-functions.php
			//echo "<td>$countx</td>";
			//$countx = $countx + 1;
			//$countx++;
			//$someVar="value";
			//echo shell_exec("echo " . escapeshellarg($someVar) . " | clip");
			/*function clipboard_copy($text) //https://stackoverflow.com/questions/33926038/copy-to-clipboard-from-php-command-line-script-in-windows-7 //bugs.php.net/bug.php?id=19545
			{
				$ie = new COM('InternetExplorer.Application');
				$ie->Navigate('about:blank');
				while ($ie->ReadyState != 4)
				{
					sleep(0.1);
				}
				$ie->document->ParentWindow->ClipboardData->SetData("text", 
		$text);
				$ie->Quit();
			}

			clipboard_copy("foo\r\nbar");*/
			//echo copy("1.txt", "2.txt"); //bind copy text function php txt with coppy function //https://stackoverflow.com/questions/50729670
			//function active($currect_page)
			//{
			 // $url_array =  explode('/', $_SERVER['REQUEST_URI']) ;
			//  $url = $row['playerid'] . ' ';  
			 // if($currect_page == $url)
				//{
				//  echo 'active'; //class name in css 
			  //} 
			//}//https://stackoverflow.com/questions/15963757/how-to-set-current-page-active-in-php

			// ALL USER DEFINED FUNCTIONS
			/*$arr = get_defined_functions();
			foreach ($arr['user'] as $key => $value){
			echo $value.'<br />';
			}
			// ALL USER DEFINED FUNCTIONS

			// ALL INTERNAL FUNCTIONS
			$arr = get_defined_functions();
			foreach ($arr['internal'] as $key => $value){
			echo $value.'<br />';
			}*/ //https://gtk.php.net/manual/en/html/ //https://gtk.php.net/manual/en/html/gtk/gtk.gtkcombobox.method.get_active_text.html //https://fmhelp.filemaker.com/help/15/fmp/en/index.html#page/FMP_Help/get-activeselectionstart.html
			// ALL INTERNAL FUNCTIONS
			//<script type="text/javascript" language="JavaScript">
			//document.forms['myform'].elements['mytextfield'].focus();
			//</script> //https://www.mediacollege.com/internet/javascript/form/focus.html
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//if($back >= 0)
		//	print "<a href='$page?start=$back'>Previous</a>";
			//print "test";
		//if($thisp < $row0)
		//	print "<a href='$page?start=$next'>Next</a>";
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</center></td>-->
		<!--<td>--><!--<img width="20px" src="country-flags-main/country-flags-main/svg/<?php
		//$query = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//mysqli_query($db, $query) or die('Error querying database.');
		//$result = mysqli_query($db, $query);
		//while($row = mysqli_fetch_array($result))
		//{
			//$query2 = "SELECT * FROM users WHERE steamid = ".$row['playerid']."";
			//mysqli_query($db, $query2) or die('Error querying in table.');
			//$result2 = mysqli_query($db, $query2);
			//$row2 = mysqli_fetch_array($result2);
			//$ip = $row2['ip'];
			// Use JSON encoded string and converts
			// it into a PHP variable
			//$ipdat = @json_decode(file_get_contents("http://www.geoplugin.net/json.gp?ip=" . $ip));
			//echo strtolower($ipdat->geoplugin_countryCode);
		//}
		?>.svg">-->
		<?php
		//Step2
		//$query = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result = mysqli_query($db, $query);
		//$row = mysqli_fetch_array($result);
		//$countx = 1;
		//while($row = mysqli_fetch_array($result))
		//{
			//$query2 = "SELECT * FROM users WHERE steamid = ".$row['playerid']."";
			//mysqli_query($db, $query2) or die('Error querying in table.');
			//$result2 = mysqli_query($db, $query2);
			//$row2 = mysqli_fetch_array($result2);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			//{
				//$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
				//mysqli_query($db, $query3) or die('Error querying in table.');
				//$result3 = mysqli_query($db, $query3);
				//$row3 = mysqli_fetch_array($result3);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				//{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				//}
			//}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//$countx = 1;
			//https://ourcodeworld.com/articles/read/51/how-to-detect-the-country-of-a-visitor-in-php-or-javascript-for-free-with-the-request-ip
			//$ip = $_SERVER['REMOTE_ADDR']; // This will contain the ip of the request
			//$ip = $row2['ip'];
			// You can use a more sophisticated method to retrieve the content of a webpage with php using a library or something
			// We will retrieve quickly with the file_get_contents
			//$dataArray = json_decode(file_get_contents("http://www.geoplugin.net/json.gp?ip=".$ip));

			//var_dump($dataArray);

			// outputs something like (obviously with the data of your IP) :

			// geoplugin_countryCode => "DE",
			// geoplugin_countryName => "Germany"
			// geoplugin_continentCode => "EU"

			//echo "Hello visitor from: ".$dataArray["geoplugin_countryCode"];
			//https://www.geeksforgeeks.org/how-to-get-visitors-country-from-their-ip-in-php/
			// PHP code to obtain country, city, 
			// continent, etc using IP Address

			//$ip = '52.25.109.230';
			//$ip = $row2['ip'];

			// Use JSON encoded string and converts
			// it into a PHP variable
			//$ipdat = @json_decode(file_get_contents(
			//    "http://www.geoplugin.net/json.gp?ip=" . $ip));

			//echo 'Country Name: ' . $ipdat->geoplugin_countryName . "\n";
			//echo 'City Name: ' . $ipdat->geoplugin_city . "\n";
			//echo 'Continent Name: ' . $ipdat->geoplugin_continentName . "\n";
			//echo 'Latitude: ' . $ipdat->geoplugin_latitude . "\n";
			//echo 'Longitude: ' . $ipdat->geoplugin_longitude . "\n";
			//echo 'Currency Symbol: ' . $ipdat->geoplugin_currencySymbol . "\n";
			//echo 'Currency Code: ' . $ipdat->geoplugin_currencyCode . "\n";
			//echo 'Timezone: ' . $ipdat->geoplugin_timezone;
			//https://www.bing.com/search?q=small+latters+php&cvid=7365f1771b474dfd8b5a19044ad9e1f3&aqs=edge..69i57.2719j0j1&pglt=43&FORM=ANNTA1&PC=U531
			//$flag;
			//$dir = strtolower($ipdat->geoplugin_countryCode) . '.svg';
			//echo $dir . '';
			//$test;
			//echo ;
			//echo 
			//$test = "de";
			//echo "<img width=20px src=country-flags-main/country-flags-main/svg/".strtolower($ipdat->geoplugin_countryCode).".svg>" . ' ' . $row2['username'] . ' [U:1:' . $row['playerid'] . ']<br>'; //https://www.php.net/manual/en/function.get-defined-functions.php
			//https://github.com/hampusborgos/country-flags
			//.svg">' . $row2['username'] . ' [U:1:' . $row['playerid'] . '] ' . $ipdat->geoplugin_countryCode . '<br>'; //https://www.php.net/manual/en/function.get-defined-functions.php
			//$countx = $countx + 1;
			//$someVar="value";
			//echo shell_exec("echo " . escapeshellarg($someVar) . " | clip");
			/*function clipboard_copy($text) //https://stackoverflow.com/questions/33926038/copy-to-clipboard-from-php-command-line-script-in-windows-7 //bugs.php.net/bug.php?id=19545
			{
				$ie = new COM('InternetExplorer.Application');
				$ie->Navigate('about:blank');
				while ($ie->ReadyState != 4)
				{
					sleep(0.1);
				}
				$ie->document->ParentWindow->ClipboardData->SetData("text", 
		$text);
				$ie->Quit();
			}

			clipboard_copy("foo\r\nbar");*/
			//echo copy("1.txt", "2.txt"); //bind copy text function php txt with coppy function //https://stackoverflow.com/questions/50729670
			//function active($currect_page)
			//{
			 // $url_array =  explode('/', $_SERVER['REQUEST_URI']) ;
			//  $url = $row['playerid'] . ' ';  
			 // if($currect_page == $url)
				//{
				//  echo 'active'; //class name in css 
			  //} 
			//}//https://stackoverflow.com/questions/15963757/how-to-set-current-page-active-in-php

			// ALL USER DEFINED FUNCTIONS
			/*$arr = get_defined_functions();
			foreach ($arr['user'] as $key => $value){
			echo $value.'<br />';
			}
			// ALL USER DEFINED FUNCTIONS

			// ALL INTERNAL FUNCTIONS
			$arr = get_defined_functions();
			foreach ($arr['internal'] as $key => $value){
			echo $value.'<br />';
			}*/ //https://gtk.php.net/manual/en/html/ //https://gtk.php.net/manual/en/html/gtk/gtk.gtkcombobox.method.get_active_text.html //https://fmhelp.filemaker.com/help/15/fmp/en/index.html#page/FMP_Help/get-activeselectionstart.html
			// ALL INTERNAL FUNCTIONS
			//<script type="text/javascript" language="JavaScript">
			//document.forms['myform'].elements['mytextfield'].focus();
			//</script> //https://www.mediacollege.com/internet/javascript/form/focus.html
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</td>
		<td>--><!--<img width="20px" src="country-flags-main/country-flags-main/svg/<?php
		//$query = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//mysqli_query($db, $query) or die('Error querying database.');
		//$result = mysqli_query($db, $query);
		//while($row = mysqli_fetch_array($result))
		//{
			//$query2 = "SELECT * FROM users WHERE steamid = ".$row['partnerid']."";
			//mysqli_query($db, $query2) or die('Error querying in table.');
			//$result2 = mysqli_query($db, $query2);
			//$row2 = mysqli_fetch_array($result2);
			//$ip = $row2['ip'];
			// Use JSON encoded string and converts
			// it into a PHP variable
			//$ipdat = @json_decode(file_get_contents("http://www.geoplugin.net/json.gp?ip=" . $ip));
			//echo strtolower($ipdat->geoplugin_countryCode);
		//}
		?>.svg">-->
		<?php
		//<img width="20px" src="country-flags-main/country-flags-main/svg/de.svn">
		//Step2
		//$query2 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query2 = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query2) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result2 = mysqli_query($db, $query2);
		//$row2 = mysqli_fetch_array($result2);

		//while($row2 = mysqli_fetch_array($result2))
		//{
			//$query22 = "SELECT * FROM users WHERE steamid = ".$row2['playerid']."";
			//mysqli_query($db, $query22) or die('Error querying in table.');
			//$result22 = mysqli_query($db, $query22);
			//$row22 = mysqli_fetch_array($result22);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			//{
				//$query32 = "SELECT * FROM users WHERE steamid = ".$row2['partnerid']."";
				//mysqli_query($db, $query32) or die('Error querying in table.');
				//$result32 = mysqli_query($db, $query32);
				//$row32 = mysqli_fetch_array($result32);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				//{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				//}
			//}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row2['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//echo $row32['username'] . '<br>';
			//$ip = $row32['ip'];

			// Use JSON encoded string and converts
			// it into a PHP variable
			//$ipdat = @json_decode(file_get_contents(
			//    "http://www.geoplugin.net/json.gp?ip=" . $ip)); //https://www.sitepoint.com/community/t/insert-an-image-into-index-php-file/8545
			//https://stackoverflow.com/questions/26065495/php-echo-to-display-image-html
			//echo "<img width=20px src=country-flags-main/country-flags-main/svg/".strtolower($ipdat->geoplugin_countryCode).".svg>" . ' ' . $row32['username'] . ' [U:1:' . $row2['partnerid'] . ']<br>';
			//https://github.com/hampusborgos/country-flags
			//https://www.codespeedy.com/display-the-country-flag-of-visitors-in-php/
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</td>
		<td>--><?php
		//Step2
		//$query3 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query3 = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query3) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result3 = mysqli_query($db, $query3);
		//$row3 = mysqli_fetch_array($result3);

		//while($row3 = mysqli_fetch_array($result3))
		//{
			//$query23 = "SELECT username FROM users WHERE steamid = ".$row3['playerid']."";
			//mysqli_query($db, $query23) or die('Error querying in table.');
			//$result23 = mysqli_query($db, $query23);
			//$row23 = mysqli_fetch_array($result23);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			//{
				//$query33 = "SELECT username FROM users WHERE steamid = ".$row3['partnerid']."";
				//mysqli_query($db, $query33) or die('Error querying in table.');
				//$result33 = mysqli_query($db, $query33);
				//$row33 = mysqli_fetch_array($result33);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				//{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				//}
			//}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row3['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//$hours = floor($row3['time'] / 3600);
			//$mins = floor($row3['time'] / 60 % 60);
			//$secs = floor($row3['time'] % 60);
			//$row3x = sprintf('%02d:%02d:%02d', $hours, $mins, $secs);
			
			//echo $row3x . '<br>'; //https://stackoverflow.com/questions/3856293/how-to-convert-seconds-to-time-format
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</td>
		<td><center>--><?php
		//Step2
		//$query3 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query3 = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query3) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result3 = mysqli_query($db, $query3);
		//$row3 = mysqli_fetch_array($result3);

		//while($row3 = mysqli_fetch_array($result3))
		//{
			//$query23 = "SELECT username FROM users WHERE steamid = ".$row3['playerid']."";
			//mysqli_query($db, $query23) or die('Error querying in table.');
			//$result23 = mysqli_query($db, $query23);
			//$row23 = mysqli_fetch_array($result23);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			//{
				//$query33 = "SELECT username FROM users WHERE steamid = ".$row3['partnerid']."";
				//mysqli_query($db, $query33) or die('Error querying in table.');
				//$result33 = mysqli_query($db, $query33);
				//$row33 = mysqli_fetch_array($result33);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				//{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				//}
			//}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row3['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//$hours = floor($row3['time'] / 3600);
			//$mins = floor($row3['time'] / 60 % 60);
			//$secs = floor($row3['time'] % 60);
			//$row3x = sprintf('%02d:%02d:%02d', $hours, $mins, $secs);
			//$completions = $row3['completions']; //https://www.bing.com/search?q=set+where+is+null+sql&cvid=3134695c3d564421aec72036422c503c&aqs=edge..69i57j0l3.7648j0j1&pglt=299&FORM=ANNTA1&PC=U531
			//echo $completions . '<br>'; //https://stackoverflow.com/questions/3856293/how-to-convert-seconds-to-time-format
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</center></td>
		<td>--><?php
		//Step2
		//$query4 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query4 = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query4) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result4 = mysqli_query($db, $query4);
		//$row4 = mysqli_fetch_array($result4);

		//while($row4 = mysqli_fetch_array($result4))
		//{
			/*$query2 = "SELECT username FROM users WHERE steamid = ".$row['playerid']."";
			mysqli_query($db, $query2) or die('Error querying in table.');
			$result2 = mysqli_query($db, $query2);
			$row2 = mysqli_fetch_array($result2);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
				mysqli_query($db, $query3) or die('Error querying in table.');
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				}
			}*/
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//echo $row4['map'] . '<br>';
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</td>
		<td>--><?php
		//Step2
		//$query5 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time ASC";
		//$query5 = "SELECT * FROM records WHERE map = '"$_POST['id']"' ORDER BY time ASC";
		//mysqli_query($db, $query5) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		//$result5 = mysqli_query($db, $query5);
		//$row5 = mysqli_fetch_array($result5);

		//while($row5 = mysqli_fetch_array($result5))
		//{
			/*$query2 = "SELECT username FROM users WHERE steamid = ".$row['playerid']."";
			mysqli_query($db, $query2) or die('Error querying in table.');
			$result2 = mysqli_query($db, $query2);
			$row2 = mysqli_fetch_array($result2);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			//{
				$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
				mysqli_query($db, $query3) or die('Error querying in table.');
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				//{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				//}
			//}*/
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			//$formatedDate = date("Y-m-d H:i:s", (int)$row5['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//echo $formatedDate . '<br>';
		//}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?><!--</td>-->
	  <!--</tr>-->
	</tbody>
	</table>
	<?php
		/*//Step2
		$query = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query) or die('Error querying database.');
		//if(strlen($name) > 0)
			echo $name . ' ';
		//Step3
		$result = mysqli_query($db, $query);
		$row = mysqli_fetch_array($result);

		while($row = mysqli_fetch_array($result))
		{
			$query2 = "SELECT username FROM users WHERE steamid = ".$row['playerid']."";
			mysqli_query($db, $query2) or die('Error querying in table.');
			$result2 = mysqli_query($db, $query2);
			$row2 = mysqli_fetch_array($result2);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
				mysqli_query($db, $query3) or die('Error querying in table.');
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				//echo $row3['username'] . ' ';
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				{
					//echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				}
			}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			$formatedDate = date("Y-m-d H:i:s", (int)$row['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			echo $row2['username'] . ' ' . $row3['username'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $formatedDate . '<br>';
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp*/
	?>
	<!--</form>-->
		<!--<label for="submit">Please choose map</label><br/>-->
				<!--<form method = "post" action = "">-->
					<!--<select id="submit" name="submit">-->
						<!--<option value="">Select map</option>-->
						<?php //$sql = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
								//$rs = mysqli_query($db, $sql);
							//while($rows = mysqli_fetch_assoc($rs))
							//{
								//echo '<option value="'.$rows['map'].'">'.$rows['map'].'</option>';
							//}
							//echo $next;
						?>
					<!--</select>-->
		<!--<input type = submit value = submit name = next></form>-->
	<?php $year = "Copyleft fakeexpert 2021 -"; echo $year . ' ' . date("Y") . ' year.<br>';?> <!--https://www.geeksforgeeks.org/how-to-get-current-year-in-php/-->
	</body>
</html>
https://www.wdb24.com/ajax-dropdown-list-from-database-using-php-and-jquery/
https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l
https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html
<html><!--Copyleft 2021-2021 year.--></html>
https://www.php.net/license/index.php
https://htmlcodex.com/license/#:~:text=All%20of%20the%20creative%20works%20by%20HTML%20Codex,under%20a%20Creative%20Commons%20Attribution%204.0%20International%20License.
License
Creative Commons License
All of the creative works by HTML Codex are licensed under a Creative Commons Attribution 4.0 International License.

Legal Attribution
HTML Codex creates and publishes free HTML website templates, landing page templates, email templates, and snippets. When you download or use our creative works, it will attribute the following conditions.

You are allowed
You are allowed to use for personal and commercial purposes.
You are allowed to modify/customize however you like.
You are allowed to convert/port for use for any CMS.
You are allowed to share/distribute under the HTML Codex brand name.
You are allowed to put a screenshot or a link on your blog posts or any other websites.
You are not allowed
You are not allowed to remove the author’s credit link/backlink without a donation.
You are not allowed to sell, resale, rent, lease, license, or sub-license.
You are not allowed to upload on your template websites or template collection websites or any other third party websites without our permission.

PHP Licensing
PHP Codebase
PHP 4, PHP 5 and PHP 7 are distributed under the PHP License v3.01, copyright (c) the PHP Group.
This is an Open Source license, certified by the Open Source Initiative.
The PHP license is a BSD-style license which does not have the "copyleft" restrictions associated with GPL.
Some files have been contributed under other (compatible) licenses and carry additional requirements and copyright information.
This is indicated in the license + copyright comment block at the top of the source file.
Practical Guidelines:
Distributing PHP
Contributing to PHP
PHP Documentation
The PHP manual text and comments are covered by the Creative Commons Attribution 3.0 License, copyright (c) the PHP Documentation Group
Summary in human-readable form
Practical Information: Documentation HOWTO
PHP Website
The Website copyright can be viewed here: Website Copyright
PHP Logo
The Logo license terms can be viewed on the Logo and Icon Download page
Frequently Asked Questions
Use of the "PHP" name
Q. I've written a project in PHP that I'm going to release as open source, and I'd like to call it PHPTransmogrifier. Is that OK?

A. We cannot really stop you from using PHP in the name of your project unless you include any code from the PHP distribution, in which case you would be violating the license. See Clause 4 in the PHP License v3.01.
But we would really prefer if people would come up with their own names independent of the PHP name.

"Why?" you ask. You are only trying to contribute to the PHP community. That may be true, but by using the PHP name you are explicitly linking your efforts to those of the entire PHP development community and the years of work that has gone into the PHP project. Every time a flaw is found in one of the thousands of applications out there that call themselves "PHP-Something" the negative karma that generates reflects unfairly on the entire PHP project. We had nothing to do with PHP-Nuke, for example, and every bugtraq posting on that says "PHP" in it. Your particular project may in fact be the greatest thing ever, but we have to be consistent in how we handle these requests and we honestly have no way of knowing whether your project is actually the greatest thing ever.

So, please, pick a name that stands on its own merits. If your stuff is good, it will not take long to establish a reputation for yourselves. Look at Zope, for example, that is a framework for Python that doesn't have Python in the name. Smarty as well doesn't have PHP in the name and does quite well.

Change in licensing from PHP 4 onwards
Q. Why is PHP 4 not dual-licensed under the GNU General Public License (GPL) like PHP 3 was?

A. GPL enforces many restrictions on what can and cannot be done with the licensed code. The PHP developers decided to release PHP under a much more loose license (Apache-style), to help PHP become as popular as possible.

Licensing information for related projects
For related projects, please refer to licensing information on the Project websites:

PECL
PEAR
GTK
