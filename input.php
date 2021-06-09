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
	$query = "SELECT map FROM zones WHERE type = 0";
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
	mysqli_close($db);
?>
</option>
		</select>
		<input type = "submit" value = "send">
		</form>
<?php
//echo $row['map'] . ' ';
?>
<label for="country">Paese</label><br/>
        <form method = "post" action = "index5.php">
		<select name="country" id="submit">
            <option value="AF">Afghanistan</option>
            <option value="AL">Albania</option>
            <option value="DZ">Algeria</option>
            <option value="AS">American Samoa</option>
            <option value="AD">Andorra</option>
            <option value="AO">Angola</option>
        </select>
		<input type = "submit" value = "send">
		</form> //https://bytes.com/topic/php/answers/7317-drop-down-menu-php-submit-form <br>

<label for="country">Map menu</label><br/>
		<form method = "post" action = "index5.php">
<select name=”map”>
<?php
	$sql = “SELECT map FROM zones WHERE type = 0 ORDER BY map ASC”;
	$result = mysqli_query($conn,$sql) or die(mysqli_error());
while($row=mysqli_fetch_assoc($result))
{
?>
<option value=”<?php echo $row[‘sno’];?>”>
	<?php echo $row[‘map’];?>
	</option>
	<?php
	} // while
	?>
</select>
		<input type = "submit" value = "send">
		</form>
https://www.iwebcoding.com/php-drop-down-list-from-a-database/
