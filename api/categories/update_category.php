<?php
require_once '../config.php';

function handleUpdateCategory() {
    global $pdo;
    
    parse_str(file_get_contents('php://input'), $post_vars);
    $input = json_decode($post_vars['_method'] ?? file_get_contents('php://input'), true);
    
    if (!isset($input['id']) || !isset($input['name'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID and name are required']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("UPDATE categories SET name = ? WHERE id = ?");
        $result = $stmt->execute([$input['name'], $input['id']]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'id' => $input['id'],
                'name' => $input['name']
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Category not found']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

// If this file is called directly, execute the function
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    handleUpdateCategory();
}
?>