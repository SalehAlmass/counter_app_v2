<?php
require_once '../config.php';

function handleUpdateQuestion() {
    global $pdo;
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['id']) || !isset($input['question']) || !isset($input['option1']) || 
        !isset($input['option2']) || !isset($input['option3']) || 
        !isset($input['option4']) || !isset($input['correct_answer_index']) || 
        !isset($input['category_id'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Required fields are missing']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("
            UPDATE questions 
            SET question = ?, option1 = ?, option2 = ?, option3 = ?, option4 = ?, 
                correct_answer_index = ?, explanation = ?, difficulty = ?, 
                time_limit_seconds = ?, category_id = ?
            WHERE id = ?
        ");
        
        $result = $stmt->execute([
            $input['question'],
            $input['option1'],
            $input['option2'],
            $input['option3'],
            $input['option4'],
            $input['correct_answer_index'],
            $input['explanation'] ?? '',
            $input['difficulty'] ?? 1,
            $input['time_limit_seconds'] ?? 30,
            $input['category_id'],
            $input['id']
        ]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'id' => $input['id'],
                'question' => $input['question'],
                'option1' => $input['option1'],
                'option2' => $input['option2'],
                'option3' => $input['option3'],
                'option4' => $input['option4'],
                'correct_answer_index' => $input['correct_answer_index'],
                'explanation' => $input['explanation'] ?? '',
                'difficulty' => $input['difficulty'] ?? 1,
                'time_limit_seconds' => $input['time_limit_seconds'] ?? 30,
                'category_id' => $input['category_id']
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Question not found']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

// If this file is called directly, execute the function
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    handleUpdateQuestion();
}
?>