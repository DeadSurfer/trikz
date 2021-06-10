<?php
	//Step1
	$db = mysqli_connect('localhost','root','','fakeexpert')
	or die('Error connecting to MySQL server.');
?>

<?php
$name = $_POST['submit']; //https://stackoverflow.com/questions/13447554/how-to-get-input-field-value-using-php
//$name = $_POST
?>
<html>
<head>Trikz Timer</head>
<style>
.styled-table {
    border-collapse: collapse;
    margin: 25px 0;
    font-size: 0.9em;
    font-family: sans-serif;
    min-width: 400px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}
.styled-table thead tr {
    background-color: #009879;
    color: #ffffff;
    text-align: left;
}
.styled-table th,
.styled-table td {
    padding: 12px 15px;
}
.styled-table tbody tr {
    border-bottom: 1px solid #dddddd;
}

.styled-table tbody tr:nth-of-type(even) {
    background-color: #f3f3f3;
}

.styled-table tbody tr:last-of-type {
    border-bottom: 2px solid #009879;
}
</style>
<body>
	<h1>PHP connect to MySQL</h1> <!--//http://www.learningaboutelectronics.com/Articles/How-to-retrieve-data-from-a-textbox-using-PHP.php#:~:text=And%20the%20answer%20is%2C%20we%20can%20do%20this,information%20and%20displaying%20it%20on%20a%20web%20page. -->
	<!--<form action="" method="post">
	<label>Please enter your Name:</label>
	<input type="text" name="Name" value='<?php echo $name; ?>'/>
	<br><br>
	<input name="form" type="submit" value="Submit"/><br><br> //https://www.foxinfotech.in/2019/01/how-to-create-text-box-and-display-its-value-in-php.html
	</form> //https://www.ecomspark.com/how-to-submit-a-form-in-php-and-email/#:~:text=In%20PHP%2C%20isset%20%28%29%20method%20is%20used%20to,%28isset%20%28%24_POST%20%5B%27submit%27%5D%29%29%20%7B%20echo%20%22form%20success%22%3B%20%7D.
	-->
	<table class="styled-table"> //https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l
		<thead>
			<tr>
				<th>Place</th>
				<th>Player 1</th>
				<th>Player 2</th>
				<th>Time</th>
				<th>Map</th>
				<th>Date</th>
			</tr>
		</thead>
		<tbody>
		<tr>
		<td><?php
		//Step2
		$queryx = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $queryx) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$resultx = mysqli_query($db, $queryx);
		$rowx = mysqli_fetch_array($resultx);
		$countx = 1;
		while($row = mysqli_fetch_array($resultx))
		{
			$query2x = "SELECT username FROM users WHERE steamid = ".$rowx['playerid']."";
			mysqli_query($db, $query2x) or die('Error querying in table.');
			$result2x = mysqli_query($db, $query2x);
			$row2x = mysqli_fetch_array($result2x);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query3x = "SELECT username FROM users WHERE steamid = ".$rowx['partnerid']."";
				mysqli_query($db, $query3x) or die('Error querying in table.');
				$result3x = mysqli_query($db, $query3x);
				$row3x = mysqli_fetch_array($result3x);
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
			$formatedDate = date("Y-m-d H:i:s", (int)$rowx['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//$countx = 1;
			echo $countx . '.<br>'; //https://www.php.net/manual/en/function.get-defined-functions.php
			$countx = $countx + 1;
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
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
		<td><?php
		//Step2
		$query = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result = mysqli_query($db, $query);
		$row = mysqli_fetch_array($result);
		//$countx = 1;
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
			//$countx = 1;
			echo $row2['username'] . ' [U:1:' . $row['playerid'] . ']<br>'; //https://www.php.net/manual/en/function.get-defined-functions.php
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
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
		<td><?php
		//Step2
		$query2 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query2) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result2 = mysqli_query($db, $query2);
		$row2 = mysqli_fetch_array($result2);

		while($row2 = mysqli_fetch_array($result2))
		{
			$query22 = "SELECT username FROM users WHERE steamid = ".$row2['playerid']."";
			mysqli_query($db, $query22) or die('Error querying in table.');
			$result22 = mysqli_query($db, $query22);
			$row22 = mysqli_fetch_array($result22);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query32 = "SELECT username FROM users WHERE steamid = ".$row2['partnerid']."";
				mysqli_query($db, $query32) or die('Error querying in table.');
				$result32 = mysqli_query($db, $query32);
				$row32 = mysqli_fetch_array($result32);
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
			$formatedDate = date("Y-m-d H:i:s", (int)$row2['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			//echo $row32['username'] . '<br>';
			echo $row32['username'] . ' [U:1:' . $row2['partnerid'] . ']<br>';
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
		<td><?php
		//Step2
		$query3 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query3) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result3 = mysqli_query($db, $query3);
		$row3 = mysqli_fetch_array($result3);

		while($row3 = mysqli_fetch_array($result3))
		{
			$query23 = "SELECT username FROM users WHERE steamid = ".$row3['playerid']."";
			mysqli_query($db, $query23) or die('Error querying in table.');
			$result23 = mysqli_query($db, $query23);
			$row23 = mysqli_fetch_array($result23);
			//echo $row2['username'] . ' ';
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query33 = "SELECT username FROM users WHERE steamid = ".$row3['partnerid']."";
				mysqli_query($db, $query33) or die('Error querying in table.');
				$result33 = mysqli_query($db, $query33);
				$row33 = mysqli_fetch_array($result33);
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
			//$formatedDate = date("Y-m-d H:i:s", (int)$row3['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			$hours = floor($row3['time'] / 3600);
			$mins = floor($row3['time'] / 60 % 60);
			$secs = floor($row3['time'] % 60);
			$row3x = sprintf('%02d:%02d:%02d', $hours, $mins, $secs);
			
			echo $row3x . '<br>'; //https://stackoverflow.com/questions/3856293/how-to-convert-seconds-to-time-format
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
		<td><?php
		//Step2
		$query4 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query4) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result4 = mysqli_query($db, $query4);
		$row4 = mysqli_fetch_array($result4);

		while($row4 = mysqli_fetch_array($result4))
		{
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
			echo $row4['map'] . '<br>';
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		//mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
		<td><?php
		//Step2
		$query5 = "SELECT * FROM records WHERE map = '".$name."' ORDER BY time";
		mysqli_query($db, $query5) or die('Error querying database.');
		//if(strlen($name) > 0)
			//echo $name . ' ';
		//Step3
		$result5 = mysqli_query($db, $query5);
		$row5 = mysqli_fetch_array($result5);

		while($row5 = mysqli_fetch_array($result5))
		{
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
			$formatedDate = date("Y-m-d H:i:s", (int)$row5['date']);
			//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
			//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
			echo $formatedDate . '<br>';
		}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
		//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
		mysqli_close($db); //https://www.w3schools.com/html/html_tables.asp
	?></td>
	  </tr>
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

	</body>
</html>

//https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html
2021-2021
//https://www.php.net/license/index.php
//https://htmlcodex.com/license/#:~:text=All%20of%20the%20creative%20works%20by%20HTML%20Codex,under%20a%20Creative%20Commons%20Attribution%204.0%20International%20License.
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
