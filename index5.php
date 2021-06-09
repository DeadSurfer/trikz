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

		while ($row = mysqli_fetch_array($result))
		{
			echo $row['id'] . ' ' . $row['playerid'] . ': ' . $row['partnerid'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br />';
		}
		//Step 4
		mysqli_close($db);
	?>

	</body>
</html>

//https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html
