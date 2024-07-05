<?php
// 例として、保存されたファイルからデータを読み込みます
$filename = '../private/data.txt';

if (file_exists($filename)) {
    $data = file_get_contents($filename);
    echo $data;
} else {
    echo 'No data found';
}
?>