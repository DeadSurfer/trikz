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
<body>
	<h1>PHP connect to MySQL</h1> <!--//http://www.learningaboutelectronics.com/Articles/How-to-retrieve-data-from-a-textbox-using-PHP.php#:~:text=And%20the%20answer%20is%2C%20we%20can%20do%20this,information%20and%20displaying%20it%20on%20a%20web%20page. -->
	<!--<form action="" method="post">
	<label>Please enter your Name:</label>
	<input type="text" name="Name" value='<?php echo $name; ?>'/>
	<br><br>
	<input name="form" type="submit" value="Submit"/><br><br> //https://www.foxinfotech.in/2019/01/how-to-create-text-box-and-display-its-value-in-php.html
	</form> //https://www.ecomspark.com/how-to-submit-a-form-in-php-and-email/#:~:text=In%20PHP%2C%20isset%20%28%29%20method%20is%20used%20to,%28isset%20%28%24_POST%20%5B%27submit%27%5D%29%29%20%7B%20echo%20%22form%20success%22%3B%20%7D.
	-->
	<?php
		//Step2
		$query = "SELECT * FROM records WHERE map = "$name" ORDER BY time";
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
		mysqli_close($db);
	?>

	</body>
</html>

//https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html
