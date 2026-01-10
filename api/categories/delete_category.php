<?php
require_once '../config.php';

function handleDeleteCategory() {
    global $pdo;
    
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        http_response_code(400);
        echo json_encode(['error' => 'ID is required']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM categories WHERE id = ?");
        $result = $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode(['message' => 'Category deleted successfully']);
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
    handleDeleteCategory();
}
?>