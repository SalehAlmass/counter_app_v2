<?php
require_once '../config.php';

function handleCreateCategory() {
    global $pdo;
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['name'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Name is required']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("INSERT INTO categories (name) VALUES (?)");
        $stmt->execute([$input['name']]);
        
        $categoryId = $pdo->lastInsertId();
        
        echo json_encode([
            'id' => $categoryId,
            'name' => $input['name']
        ]);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

// If this file is called directly, execute the function
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    handleCreateCategory();
}
?>