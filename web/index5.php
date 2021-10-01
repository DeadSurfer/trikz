<?php
	session_start(); //https://stackoverflow.com/questions/4146647/destroy-php-session-on-closing
?>
<html>
<style>
.styled-table
{
	border-collapse: collapse;
	margin: 25px 0;
	font-size: 0.9em;
	font-family: sans-serif;
	min-width: 64px;
	box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}

.styled-table thead tr
{
	background-color: #009879;
	color: #ffffff;
	text-align: left;
}

.styled-table th,
.styled-table td
{
	text-align: left;
	padding: 12px 15px;
}

.styled-table tbody tr
{
	background-color: #ffffff;
	border-bottom: 1px solid #dddddd;
}

.styled-table tbody tr:nth-of-type(even) <!--https://css-tricks.com/almanac/selectors/n/nth-of-type/--> <!--https://www.w3schools.com/cssref/sel_nth-of-type.asp--> <!--https://developer.mozilla.org/en-US/docs/Web/CSS/:nth-of-type#basic_example-->
{
	background-color: #f3f3f3;
}

.styled-table tbody tr:last-of-type
{
	border-bottom: 2px solid #009879;
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
<body style="background-color:#ffffff"> <!--https://www.w3docs.com/snippets/html/how-to-set-background-color-in-html.html-->
	<h1>Trikz Timer</h1> 
	<?php
		$db = mysqli_connect('78.84.184.120','fakeexpert','','fakeexpert') or die ('Error connecting to MySQL server.');
	?>
		<form method = "post" action = ""> <!--//http://www.learningaboutelectronics.com/Articles/How-to-retrieve-data-from-a-textbox-using-PHP.php#:~:text=And%20the%20answer%20is%2C%20we%20can%20do%20this,information%20and%20displaying%20it%20on%20a%20web%20page. --> <!-- //https://www.foxinfotech.in/2019/01/how-to-create-text-box-and-display-its-value-in-php.html--> <!-- https://www.ecomspark.com/how-to-submit-a-form-in-php-and-email/#:~:text=In%20PHP%2C%20isset%20%28%29%20method%20is%20used%20to,%28isset%20%28%24_POST%20%5B%27submit%27%5D%29%29%20%7B%20echo%20%22form%20success%22%3B%20%7D. -->
			<select id="submit" name="submit">
				<option value="">Select a map</option> <!--//https://www.wdb24.com/ajax-dropdown-list-from-database-using-php-and-jquery/-->
				<?php
					$sql = "SELECT map FROM zones WHERE type = 0 ORDER BY map ASC";
					$rs = mysqli_query($db, $sql);
					while($rows = mysqli_fetch_assoc($rs))
						echo '<option value="'.$rows['map'].'">'.$rows['map'].'</option>';
				?>
			</select>
		<input type = submit value = Submit></form>
	<?php
		if(isset($_GET['map'])) //https://www.w3schools.com/PHP/php_superglobals_get.asp https://stackoverflow.com/questions/7014146/how-to-remember-input-data-in-the-forms-even-after-refresh-page https://www.w3schools.com/PHP/php_superglobals_get.asp
			$_SESSION['map'] = $_GET['map'];
		if(!isset($_SESSION['map']))
			$_SESSION['map'] = "trikz_adventure";
		if(isset($_POST['submit'])) //https://stackoverflow.com/questions/65603660/beginner-php-warning-undefined-array-key
		{	
			$name = $_POST['submit']; //https://stackoverflow.com/questions/13447554/how-to-get-input-field-value-using-php
			$_SESSION['map'] = $_POST['submit'];
		}
		else
			$name = "trikz_adventure";
		echo "<table class='styled-table'><thead><tr><th>Map: $_SESSION[map]</th></tr></thead></table>";
	?>
	<table class="styled-table"> <!--//https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l-->
		<thead>
			<tr>
				<?php
					$page = basename($_SERVER['PHP_SELF']);
					if(isset($_GET['l']))
					{
						if($_GET['l'] == 1)
							echo "<th><center>Place <a href=$page?start=$_GET[start]&l=0><img src=/sort/sort-amount-down-solid_icon.png></a></center></th>";
						else if($_GET['l'] == 0)
							echo "<th><center>Place <a href=$page?start=0&l=1><img src=/sort/sort-amount-down-alt-solid_icon.png></a></center></th>";
						else
							echo "<th><center>Place <a href=$page?start=0&l=1><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					}
					else
						echo "<th><center>Place <a href=$page?start=0&l=1><img src=/sort/sort-amount-down-alt-solid_icon.png></a></center></th>";
					echo "<th>Team</th>"; //<!--https://www.w3resource.com/html/attributes/html-align-attribute.php-->
					echo "<th><center>Time</center></th>";
					if(isset($_GET['l']))
					{
						if($_GET['l'] == 3)
							echo "<th><center>Finishes <a href=$page?start=$_GET[start]&l=2><img src=/sort/sort-amount-down-solid_icon.png></a></center></th>";
						else if($_GET['l'] == 2)
							echo "<th><center>Finishes <a href=$page?start=$_GET[start]&l=3><img src=/sort/sort-amount-down-alt-solid_icon.png></a></center></th>";
						else
							echo "<th><center>Finishes <a href=$page?start=0&l=3><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					}
					else
						echo "<th><center>Finishes <a href=$page?start=0&l=3><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					if(isset($_GET['l']))
					{
						if($_GET['l'] == 5)
							echo "<th><center>Tries <a href=$page?start=$_GET[start]&l=4><img src=/sort/sort-amount-down-solid_icon.png></a></center></th>";
						else if($_GET['l'] == 4)
							echo "<th><center>Tries <a href=$page?start=$_GET[start]&l=5><img src=/sort/sort-amount-down-alt-solid_icon.png></a></center></th>";
						else
							echo "<th><center>Tries <a href=$page?start=0&l=5><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					}
					else
						echo "<th><center>Tries <a href=$page?start=0&l=5><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					if(isset($_GET['l']))
					{
						if($_GET['l'] == 7)
							echo "<th><center>Date <a href=$page?start=$_GET[start]&l=6><img src=/sort/sort-amount-down-solid_icon.png></a></center></th>";
						else if($_GET['l'] == 6)
							echo "<th><center>Date <a href=$page?start=0&l=7><img src=/sort/sort-amount-down-alt-solid_icon.png></a></center></th>";
						else
							echo "<th><center>Date <a href=$page?start=0&l=7><img src=/sort/sort-amount-down_icon.png></a></center></th>";
					}
					else
						echo "<th><center>Date <a href=$page?start=0&l=7><img src=/sort/sort-amount-down_icon.png></a></center></th>";
				?>
			</tr>
		</thead>
		<tbody>
		<?php
			$page = basename($_SERVER['PHP_SELF']); //https://www.bing.com/search?q=get+page+name+php&cvid=ac271473acee453cbb249156e9bac152&aqs=edge..69i57.4032j0j1&pglt=299&FORM=ANNTA1&PC=U531 https://www.tutorialrepublic.com/faq/how-to-get-current-page-url-in-php.php#:~:text=Answer%3A%20Use%20the%20PHP%20%24_SERVER%20Superglobal%20Variable%20You,%28or%20protocol%29%2C%20whether%20it%20is%20http%20or%20https.
			if(isset($_GET['start'])) //https://www.stechies.com/undefined-index-error-php/
				$start = (int) $_GET['start']; //https://www.tutorialkart.com/php/php-convert-string-to-int/
			else
				$start = 0;
			if(isset($_POST['submit']))
				$start = 0;
			$limit = 10;
			$thisp = $start + $limit;
			$back = $start - $limit;
			$next = $start + $limit;
			if(isset($_GET['l']))
				$l = (int) $_GET['l'];
			else
				$l = 0;
			$query0 = "SELECT COUNT(*) FROM records WHERE map = '$_SESSION[map]'";
			$getSR = "SELECT time FROM records WHERE map = '$_SESSION[map]' ORDER BY time LIMIT 1";
			$queryRank = "SELECT @rownum := @rownum + 1 as rank, p.id FROM (SELECT @rownum := 0) v, (SELECT * FROM records WHERE map = '$_SESSION[map]' GROUP BY id ORDER BY time) p"; //https://stackoverflow.com/questions/10286418/mysql-ranking-by-count-and-group-by
			if($l == 1)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY time DESC LIMIT $start, $limit";
			else if(!$l)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY time ASC LIMIT $start, $limit";
			else if($l == 3)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY finishes DESC LIMIT $start, $limit";
			else if($l == 2)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY finishes ASC LIMIT $start, $limit";
			else if($l == 5)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY tries DESC LIMIT $start, $limit";
			else if($l == 4)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY tries ASC LIMIT $start, $limit";
			else if($l == 7)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY date DESC LIMIT $start, $limit";
			else if($l == 6)
				$query = "SELECT * FROM records WHERE map = '$_SESSION[map]' ORDER BY date ASC LIMIT $start, $limit"; ///https://meeraacademy.com/select-query-in-php-mysql-with-example/
			mysqli_query($db, $queryRank) or die('Error querying database. [1rank]');
			mysqli_query($db, $query) or die('Error querying database. [1]');
			mysqli_query($db, $getSR) or die('Error querying database. [getSR]');
			mysqli_query($db, $query0) or die('Error querying database. [2]');
			$resultRank = mysqli_query($db, $queryRank);
			$result = mysqli_query($db, $query);
			$result0 = mysqli_query($db, $query0);
			$resultGetSR = mysqli_query($db, $getSR);
			$rowGetSR = mysqli_fetch_array($resultGetSR);
			$row0 = mysqli_fetch_array($result0); //https://technosmarter.com/php/total-number-of-rows-mysql-table-count.php#:~:text=Count%20the%20number%20of%20rows%20using%20two%20methods.,rows%20using%20the%20PHP%20count%20%28%29%20function%2C%20
			$serverRecord = 0;
			// set the default timezone to use.
			date_default_timezone_set('UTC'); //https://www.php.net/manual/en/function.date.php
			if(!mysqli_num_rows($result)) //https://stackoverflow.com/questions/4286586/best-way-to-check-if-mysql-query-returned-any-results/4286606#4286606 https://stackoverflow.com/questions/13478206/checking-for-empty-result-php-pdo-and-mysql https://technosmarter.com/php/total-number-of-rows-mysql-table-count.php#:~:text=Count%20the%20number%20of%20rows%20using%20two%20methods.,rows%20using%20the%20PHP%20count%20%28%29%20function%2C%20
				echo "<td><center>No records found!</center></td>";
			while($row = mysqli_fetch_assoc($result))
			{
				$rank;
				$resultRank = mysqli_query($db, $queryRank);
				while($rank = mysqli_fetch_assoc($resultRank))
					if($rank['id'] == $row['id'])
						break;
				$query2 = "SELECT username FROM users WHERE steamid = $row[playerid]";
				mysqli_query($db, $query2) or die('Error querying in table. [3]');
				$result2 = mysqli_query($db, $query2);
				$row2 = mysqli_fetch_array($result2);
				$query3 = "SELECT username FROM users WHERE steamid = $row[partnerid]";
				mysqli_query($db, $query3) or die('Error querying in table. [4]');
				$result3 = mysqli_query($db, $query3);
				$row3 = mysqli_fetch_array($result3);
				$hours = floor($row['time'] / 3600);
				$mins = floor($row['time'] / 60 % 60);
				$secs = floor($row['time'] % 60);
				$time = sprintf("%02d:%02d:%02d", $hours, $mins, $secs);
				if(!$serverRecord)
					$serverRecord = $rowGetSR['time'];
				$timeDiff = $row['time'] - $serverRecord;
				$timeDiffHours = floor($timeDiff / 3600);
				$timeDiffMins = floor($timeDiff / 60 % 60);
				$timeDiffSecs = floor($timeDiff % 60);
				$timeDiffFormated = sprintf("%02d:%02d:%02d", $timeDiffHours, $timeDiffMins, $timeDiffSecs);
				$formatedDateYmd = date("Y-m-d", $row["date"]);
				$formatedDateHis = date("H:i:s", $row['date']);
				//https://www.w3schools.com/html/html_colors.asp
				//https://www.tutorialspoint.com/html/html_colors.htm
				$stamid64beforefirstuser = 76561197960265728; //so first user will be with + 1
				$player1steamid64 = $stamid64beforefirstuser + $row['playerid'];
				$player2steamid64 = $stamid64beforefirstuser + $row['partnerid'];
				//https://www.sitepoint.com/community/t/insert-an-image-into-index-php-file/8545
				if($rank['rank'] == 1)
					echo "<tr><td><center><img src=/topplace/gold_icon.png></center></td><td><a href=https://steamcommunity.com/profiles/$player1steamid64 target=_blank rel='noopener noreferrer'>$row2[username]</a><br><a href=https://steamcommunity.com/profiles/$player2steamid64 target=_blank rel='noopener noreferrer'>$row3[username]</a></td><td class='active-row'><center>$time <font color='#980000'>(+$timeDiffFormated)</font></center></td><td><center>$row[finishes]</center></td><td><center>$row[tries]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>"; //https://www.freecodecamp.org/news/how-to-use-html-to-open-link-in-new-tab/
				else if($rank['rank'] == 2)
					echo "<tr><td><center><img src=/topplace/silver_icon.png></center></td><td><a href=https://steamcommunity.com/profiles/$player1steamid64 target=_blank rel='noopener noreferrer'>$row2[username]</a><br><a href=https://steamcommunity.com/profiles/$player2steamid64 target=_blank rel='noopener noreferrer'>$row3[username]</a></td><td class='active-row'><center>$time <font color='#980000'>(+$timeDiffFormated)</font></center></td><td><center>$row[finishes]</center></td><td><center>$row[tries]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>"; //https://www.freecodecamp.org/news/how-to-use-html-to-open-link-in-new-tab/
				else if($rank['rank'] == 3)
					echo "<tr><td><center><img src=/topplace/bronze_icon.png></center></td><td><a href=https://steamcommunity.com/profiles/$player1steamid64 target=_blank rel='noopener noreferrer'>$row2[username]</a><br><a href=https://steamcommunity.com/profiles/$player2steamid64 target=_blank rel='noopener noreferrer'>$row3[username]</a></td><td class='active-row'><center>$time <font color='#980000'>(+$timeDiffFormated)</font></center></td><td><center>$row[finishes]</center></td><td><center>$row[tries]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>"; //https://www.freecodecamp.org/news/how-to-use-html-to-open-link-in-new-tab/
				else
					echo "<tr><td><center>$rank[rank]</center></td><td><a href=https://steamcommunity.com/profiles/$player1steamid64 target=_blank rel='noopener noreferrer'>$row2[username]</a><br><a href=https://steamcommunity.com/profiles/$player2steamid64 target=_blank rel='noopener noreferrer'>$row3[username]</a></td><td class='active-row'><center>$time <font color='#980000'>(+$timeDiffFormated)</font></center></td><td><center>$row[finishes]</center></td><td><center>$row[tries]</center></td><td><center>$formatedDateYmd<br>$formatedDateHis</center></td></tr>"; //https://www.freecodecamp.org/news/how-to-use-html-to-open-link-in-new-tab/
			}
		?>
	</tbody>
	</table>
	<?php
		echo "<table class='styled-table'><thead><tr>";
		if($back >= 0)
			print "<th><center><a href='$page?start=$back&l=$l' style='color:#ffffff'>Previous</a></center></th>"; //https://www.codegrepper.com/code-examples/html/how+to+change+color+in+html https://stackoverflow.com/questions/10436017/previous-next-buttons
		if($start + $limit < $row0[0])
			print "<th><center><a href='$page?start=$next&l=$l' style='color:#ffffff'>Next</a></center></th>"; //https://stackoverflow.com/questions/18737303/how-to-not-make-text-colored-within-a-href-link-but-the-text-is-also-within-div
		echo "</tr></thead></table>";
		$year = "Copyleft fakeexpert 2021 -";
		echo $year . ' ' . date("Y") . ' year.'; //https://www.geeksforgeeks.org/how-to-get-current-year-in-php
	?>
</body>
<!--https://www.wdb24.com/ajax-dropdown-list-from-database-using-php-and-jquery/
https://dev.to/dcodeyt/creating-beautiful-html-tables-with-css-428l
https://stackoverflow.com/questions/9494209/how-to-link-mysql-to-html-->
<!--Copyleft 2021-2021 year.-->
<!--https://www.php.net/license/index.php
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
GTK-->
</html>
