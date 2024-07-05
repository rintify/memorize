<?php
$json = file_get_contents('php://input');
$data = json_decode($json, true);

$correctPassword = 'wvLb5bkBkDgK2UfTXYhAtHEJyNqtaZUf';

if (isset($data['password']) && $data['password'] === $correctPassword) {
    if (isset($data['data'])) {
        $filename = '../private/data.txt';
        file_put_contents($filename, $data['data']);
        echo 'Data saved successfully';
    } else {
        echo 'No data to save';
    }
} else {
    echo 'Invalid password';
}
?>
