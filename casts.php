<?php
/**
 * Cast List API
 * Returns active casts in JSON format
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Database configuration
$config = [
    'host' => 'localhost',
    'user' => 'otserver',
    'password' => 'otserver123',
    'database' => 'nostalrius'
];

try {
    // Connect to database
    $mysqli = new mysqli($config['host'], $config['user'], $config['password'], $config['database']);
    
    if ($mysqli->connect_error) {
        throw new Exception('Database connection failed: ' . $mysqli->connect_error);
    }
    
    // Query to get active casts
    // For now, we'll simulate by getting online players who might be casting
    $query = "
        SELECT 
            p.name,
            p.level,
            p.vocation
        FROM players p
        INNER JOIN players_online po ON p.id = po.player_id
        WHERE p.group_id = 1
        LIMIT 20
    ";
    
    $result = $mysqli->query($query);
    
    $casts = [];
    
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $casts[] = [
                'name' => $row['name'],
                'viewers' => rand(0, 15), // Mock viewers for now
                'description' => 'Level ' . $row['level'] . ' - Online',
                'password' => false
            ];
        }
    }
    
    // If no casts, return empty array
    echo json_encode([
        'success' => true,
        'casts' => $casts,
        'count' => count($casts)
    ]);
    
    $mysqli->close();
    
} catch (Exception $e) {
    // Return error as JSON
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'casts' => []
    ]);
}
?>

