<?php
//https://www.plus2net.com/php_tutorial/php_paging2.php
//$page_name="php_paging.php"; // If you use this code with adifferent page ( or file ) name then change this
$page_name="index6.php";
$start=$_GET['start'];// To take care global variable if OFF

if(strlen($start) > 0 and !is_numeric($start))
{
	echo "Data Error";
	exit;
}
//Now we will set some more variables which will check from which record to start and up to which record we will display. We will be using SQL limit command to do this. We will set the variable $limit to the number of records per page to be displayed. Ten records per page is a standard way of displaying and you can change this any value. 
$eu = ($start - 0);
$limit = 10; // No of records to be shown per page.

$this1 = $eu + $limit;

$back = $eu - $limit;

$next = $eu + $limit;
//We have to find out the total number of records exists in our table with the condition specified in the query. Based on this number we can break the pages
//Step1
$dbo = mysqli_connect('78.84.184.120','root','SaulesStars292mysql','fakeexpert')
or die('Error connecting to MySQL server.');
$nume = $dbo->query("SELECT COUNT(id) FROM records")->fetchColumn();
//Now let us do some formatting and display the table headers. We have used style sheet you can edit that to match your requirments

echo "<TABLE class='t1'>";
echo  "<tr><th>ID</th><th>Name</th><th>Class</th><th>Mark</th></tr>";
//Now let us start collecting the records from the table based on the starting and ending marks decided by the variables above. We will use SQL limit command to manage the starting and ending location of the records and that will break the records into pages.

$query="SELECT * FROM records limit $eu, $limit";
//The above function will apply the query to MySQL database and if any error is there will print out. Now we will display the records returned by MySQL table inside rows of a formatted table. The header of the table is already displayed above.

foreach ($dbo->query($query) as $row)
{
	$m=$i%2; // required for alternate color of rows matching to style class 
	$i=$i+1;   //  increment for alternate color of rows

	echo "<tr class='r$m'><td>$row[id]</td><td>$row[playerid]</td><td>$row[partnerid]</td><td>$row[time]</td></tr>";
}
echo "</table>";
//We have displayed the records inside the rows of the table and you can see we have used the foreach loop along with php array to display the records.
//Displaying records per Page
//Now let us go to the bottom of the page where we will be displaying the links to different part of the page with next and previous link to navigate. Here we will use different if conditions to check and display the links.
//If our variable $back is equal to 0 or more then only we will display the link to move back
echo "<table align = 'center' width='50%'><tr><td
align='left' width='30%'>";
if($back >=0)
{
	print "<a href='$page_name?start=$back'><font face='Verdana'
	size='2'>PREV</font></a>";
}

//Let us display the page links at center. We will not display the current page as a link and we will give it red color with a higher size font


echo "</td><td align=center width='30%'>";
$i=0;
$l=1;
for($i=0;$i < $nume;$i=$i+$limit)
{
	if($i <>$eu)
	{
		echo " <a href='$page_name?start=$i'><font face='Verdana'
		size='2'>$l</font></a> ";
	}
	else
	{
		echo "<font face='Verdana' size='4'
		color=red>$l</font>";
	} // Current page is not displayed as link
	//and given font color red
	$l=$l+1;
}
//Now let us check for the NEXT link at the right side on our condition and accordingly display. If we are in the last page then we will not display the NEXT link


echo "</td><td align='right' width='30%'>";
if($this1 < $nume)
{
	print "<a href='$page_name?start=$next'><font face='Verdana'
	size='2'>NEXT</font></a>";
}
echo "</td></tr></table>";
?>
