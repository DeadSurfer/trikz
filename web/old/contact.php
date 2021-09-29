//raghwendra.com //https://www.raghwendra.com/blog/how-to-connect-html-to-database-with-mysql-using-php-example/
<?php
$con = mysqli_connect("localhost", "root", "", "fakeexpert");
$txtPlayerid = $_POST['txtPlayerid'];
$sql = "SELECT playerid FROM records";
$rs = mysqli_query($con, $sql);
?>
