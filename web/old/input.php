<form method=POST action=index5.php>
<input type=text name=submit>
<input type=submit value=Submit ></form>
//https://www.plus2net.com/php_tutorial/pb-text.php
//https://stackoverflow.com/questions/9672228/select-option-from-dropdown-menu-with-php-mysql<br>
<?php
	//Step1
	$db = mysqli_connect('localhost','root','','fakeexpert')
	or die('Error connecting to MySQL server.');
?>
<label for="country">Paese</label><br/>
		<form method = "post" action = "index5.php">
		<select name="country" id="submit">
			<option value="AF"><?php
	//Step2
	$query = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
	mysqli_query($db, $query) or die('Error querying database.');
	//if(strlen($name) > 0)
	//	echo $name . ' ';
	//Step3
	$result = mysqli_query($db, $query);
	$row = mysqli_fetch_array($result);
	echo $row['map'] . ' ';
	while($row = mysqli_fetch_array($result))
	{
		echo $row['map'] . ' ';
		//$query2 = "SELECT username FROM users WHERE steamid = ".$row['playerid']."";
		//mysqli_query($db, $query2) or die('Error querying in table.');
		//$result2 = mysqli_query($db, $query2);
		//$row2 = mysqli_fetch_array($result2);
		//echo $row2['username'] . ' ';
		//$row2 = mysqli_fetch_field($result2);
		//while ($row2 = mysqli_fetch_array($result2))
		{
			//$query3 = "SELECT username FROM users WHERE steamid = ".$row['partnerid']."";
			//mysqli_query($db, $query3) or die('Error querying in table.');
			//$result3 = mysqli_query($db, $query3);
			//$row3 = mysqli_fetch_array($result3);
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
		//$formatedDate = date("Y-m-d H:i:s", (int)$row['date']);
		//echo $row['time'] . ' ' . $row['map'] . ' ' . $row['date'] . '<br>'; //https://code-boxx.com/format-unix-timestamp-date-time-php/#:~:text=We%20can%20use%20the%20date%20function%20to%20format,date%20%28%22D%2C%20j%20F%20Y%20h%3Ai%3As%20A%22%2C%20%24UNIX%29%3B
		//if(strlen($row2['username']) > 0 && strlen($row3['username']) > 0) //https://www.bing.com/search?q=%26%26+php&qs=n&form=QBRE&sp=-1&pq=%26%26+&sc=8-3&sk=&cvid=7A930573B6A242F29BE4D868A8ECA9DE
		//echo $row2['username'] . ' ' . $row3['username'] . ' ' . $row['time'] . ' ' . $row['map'] . ' ' . $formatedDate . '<br>';
	}//https://github.com/egulias/EmailValidator/pull/228/commits/7694cc94bd1e0836051e5542963d08c7976637da
	//Step 4 //https://www.bing.com/search?q=where+username+is+null&cvid=5c73249074f9461ba358fa38f07db88c&aqs=edge..69i57.6008j0j4&FORM=ANAB01&PC=U531
	//mysqli_close($db);
?>
</option>
		</select>
		<input type = "submit" value = "send">
		</form>
<?php
//echo $row['map'] . ' ';
?>


<?php 

?>
<label for="submit">Please choose map</label><br/>
		<form method = "post" action = "">
			<select id="submit" name="submit">
				<option value="">Select Country</option>
				<?php $sql = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
						$rs = mysqli_query($db, $sql);
					while($rows = mysqli_fetch_assoc($rs))
					{
						echo '<option value="'.$rows['map'].'">'.$rows['map'].'</option>';
					}
				?>
			</select>
<input type=submit value=Submit ></form>
https://www.wdb24.com/ajax-dropdown-list-from-database-using-php-and-jquery/

<br>
<?php
$name1 = $_POST['submit'];
echo $name1 . ' ';
echo $name;
?>

<?php 
	/*$host 		= "localhost";
	$user		= "root";
	$password	= "";
	$database	= "demo";
	
	$conn = mysqli_connect($host,$user,$password,$database);
	
	if(!$conn)
	{
		die(mysqli_error());
	}*/
 
?>
//https://stackoverflow.com/questions/14372860/display-mysql-table-field-values-in-select-box
<?php //$con = mysql_connect("localhost","root","root");
//$db = mysql_select_db("Time_sheet",$con);
//$get=mysql_query($db, "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC");
?>
<html>
<body>
<form>
    <select> 
    <option value="0">Please Select</option>
        <?php
            while($row = mysql_fetch_assoc($get))
            {
            ?>
            <option value = "<?php echo($row['map'])?>" >
                <?php echo($row['map']) ?>
            </option>
            <?php
            }               
        ?>
    </select>
</form>
</body>
</html>
//https://stackoverflow.com/questions/16244228/php-submit-on-select
<form method="post" action="index5.php" >

    <table class="form">

            <select name="category" class="formfield" id="category">
                <option value="-1"> Category </option>
                <?php
                    $sql_contry = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
                    $rs_c = mysql_query($db, $sql_contry);
                    while ($row_c = mysql_fetch_array($rs_c)) {
                        echo '<option value="'.$row_c['map'].'">'.$row_c['map'].'</option>';  
                    }
					//mysqli_close($db);
                ?>
             </select>

    </table>

</form>

<?php
if(isset($_POST['gejala1'])) {
    $gejala1 = $_POST['gejala1'];
        //$sql = "INSERT INTO pucuk (gejala1) VALUES ({$gejala2})";
    $dbLink = mysql_connect('localhost', 'root', '') or die(mysql_error());
              mysql_select_db('fakeexpert', $dbLink) or die(mysql_errno());

   // $result = mysql_query($sql);
    if($result) {
        echo "Record successfully inserted!";
    }
    else {
        echo "Record not inserted! (". mysql_error() .")";
    }
}
if(isset($_POST['gejala2'])) {
    $gejala2 = $_POST['gejala2'];
       // $sql = "INSERT INTO pucuk (gejala2) VALUES ({$gejala2})";
    $dbLink = mysql_connect('localhost', 'root', '') or die(mysql_error());
              mysql_select_db('fakeexpert', $dbLink) or die(mysql_errno());

    //$result = mysql_query($sql);
    if($result) {
        echo "Record successfully inserted!";
    }
    else {
        echo "Record not inserted! (". mysql_error() .")";
    }
}

?>
<form action="" method="POST"><!-- add this -->

<?php
$query = "SELECT map FROM zones where type =0 ORDER BY map ASC";
$result = mysql_query($db, $query) or die(mysql_error()."[".$query."]");
?>
<select name="gejala1">
<?php 
while ($row = mysql_fetch_array($result)) {
    echo "<option value='".$row['map']."'>".$row['map']."</option>";
}
?>  
</select>


<p>Subatribut2
<?php
$query = "SELECT map FROM zones where type =0 ORDER BY map ASC";
$result = mysql_query($db, $query) or die(mysql_error()."[".$query."]");
?>
<select name="gejala2">
<?php 
while ($row = mysql_fetch_array($result)) {
    echo "<option value='".$row['map']."'>".$row['map']."</option>";
}
?>
</select>          


<p>
    <label>value
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;          
      <input type="text" name="textfield">
    </label>  
<p>
<input name="submit" type="submit" value="submit">    <!-- changed from type="button" to type="submit"> -->
<p>
</form>
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
