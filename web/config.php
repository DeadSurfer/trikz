<?php
$host_name = "78.84.184.120";
$database = "fakeexpert"; // Change your database nae
$username = "root";          // Your database user id 
$password = "SaulesStars292mysql";          // Your password

//////// Do not Edit below /////////
try
{
	$dbo = new PDO('mysql:host='.$host_name.';dbname='.$database, $username, $password);
}
catch (PDOException $e)
{
	print "Error!: " . $e->getMessage() . "<br/>";
	die();
}
?>
