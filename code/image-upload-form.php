<?php
include('image-upload-script.php');
?>
<!DOCTYPE html>
<html>
<body>
<form  method="post" enctype="multipart/form-data">
    <input type="file" name="image_gallery[]" multiple>
    <input type="submit" value="Upload Now" name="submit">
</form>
<a href="index.html">Back to Home</a>
</body>
</html>