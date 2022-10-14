<?php
$hostname     = "10.88.214.3";
$username     = "test";
$password     = "123"; 
$databasename = "db"; 
// Create connection 
$conn = new mysqli($hostname, $username, $password, $databasename);
 // Check connection 
if ($conn->connect_error) { 
die("Unable to Connect database: " . $conn->connect_error);
 }
?>
