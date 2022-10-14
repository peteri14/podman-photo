<!DOCTYPE html>
<html>
<body>
<h1>Installation result:</h1>
<?php
{
  require_once('database.php');
  $db=$conn;

  $saveImage="CREATE TABLE IF NOT EXISTS `gallery` (`id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT, `image_name` varchar(255) DEFAULT NULL) ENGINE=INNODB;";
  $exec= $db->query($saveImage);
  if($exec){
    echo "Successfull DB connection and table is created";
  }else{
    echo  "Error: " .  $saveImage . "<br>" . $db->error;
  }
}
?>
<p>
<a href="index.html">Back to Home</a>
</p>
</body>
</html>