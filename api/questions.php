<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        require_once 'questions/get_questions.php';
        break;
    case 'POST':
        require_once 'questions/create_question.php';
        break;
    case 'PUT':
        require_once 'questions/update_question.php';
        break;
    case 'DELETE':
        require_once 'questions/delete_question.php';
        break;
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
?>