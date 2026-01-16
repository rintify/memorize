<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Password to verify against (Should match the one in the app)
$VALID_PASSWORD = 'wvLb5bkBkDgK2UfTXYhAtHEJyNqtaZUf';
$DATA_FILE = '../private/data.txt';

// Get JSON input
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Check if password is provided and correct
if (isset($data['password']) && $data['password'] === $VALID_PASSWORD) {
    if (file_exists($DATA_FILE)) {
        // Return the file content
        echo file_get_contents($DATA_FILE);
    } else {
        http_response_code(404);
        echo "Data file not found.";
    }
} else {
    http_response_code(403);
    echo "Access Denied. Invalid password.";
}
?>
