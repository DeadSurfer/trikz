<?php
	//Step1
	$db = mysqli_connect('localhost','root','','fakeexpert')
	or die('Error connecting to MySQL server.');
?>

<html>
<head>Trikz Timer</head>
<body>
	<h1>PHP connect to MySQL</h1>

	<?php
		//Step2
		$query = "SELECT * FROM records ORDER BY time";
		mysqli_query($db, $query) or die('Error querying database.');

		//Step3
		$result = mysqli_query($db, $query);
		$row = mysqli_fetch_array($result);

		while($row = mysqli_fetch_array($result))
		{
			$query2 = "SELECT username FROM users WHERE steamid = ".$row['playerid']."";
			mysqli_query($db, $query2) or die('Error querying in table.');
			$result2 = mysqli_query($db, $query2);
			$row2 = mysqli_fetch_array($result2);
			//$row2 = mysqli_fetch_field($result2);
			//while ($row2 = mysqli_fetch_array($result2))
			{
				$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
				mysqli_query($db, $query3);
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				//$row3 = mysqli_fetch_field($result3);
				//while($row3 = mysqli_fetch_array($result3))
				{
					echo $row2['username'] . ' ' . $row3['username'] . ' ';
					//printf("%s %s" $row2, $row3);
					//printf("%s", mysqli_fetch_field($result2));
				}
			}
			
			//echo $row['id'] . ' ' . $row['playerid'] . ' ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
			echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>';
		}
		//Step 4
		mysqli_close($db);
	?>

	</body>
</html>

//https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html
