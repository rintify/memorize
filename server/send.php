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
    if (isset($data['data'])) {
        // Save the file content
        $saved = false;
        if (file_put_contents($DATA_FILE, $data['data']) !== false) {
             $saved = true;
        } else {
             // Fallback to local data.txt if private folder is not writable
             if (file_put_contents('data.txt', $data['data']) !== false) {
                 $saved = true;
             }
        }

        if ($saved) {
             echo "Data saved successfully";
        } else {
             http_response_code(500);
             echo "Failed to write data file. check permissions.";
        }
    } else {
        http_response_code(400);
        echo "Missing data to save.";
    }
} else {
    http_response_code(403);
    echo "Access Denied. Invalid password.";
}
?>
