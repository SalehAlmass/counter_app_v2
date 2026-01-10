<?php
require_once '../config.php';

function handleGetQuestions() {
    global $pdo;
    
    $categoryId = $_GET['category_id'] ?? null;
    
    try {
        if ($categoryId) {
            $stmt = $pdo->prepare("
                SELECT q.*, c.name as category_name 
                FROM questions q 
                JOIN categories c ON q.category_id = c.id 
                WHERE q.category_id = ?
                ORDER BY q.id
            ");
            $stmt->execute([$categoryId]);
        } else {
            $stmt = $pdo->prepare("
                SELECT q.*, c.name as category_name 
                FROM questions q 
                JOIN categories c ON q.category_id = c.id 
                ORDER BY q.category_id, q.id
            ");
            $stmt->execute();
        }
        
        $questions = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($questions);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

// If this file is called directly, execute the function
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    handleGetQuestions();
}
?>