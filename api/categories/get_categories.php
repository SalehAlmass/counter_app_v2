<?php
require_once '../config.php';

function handleGetCategories() {
    global $pdo;
    
    try {
        $stmt = $pdo->query("SELECT * FROM categories");
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode($categories);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

// If this file is called directly, execute the function
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    handleGetCategories();
}
?>