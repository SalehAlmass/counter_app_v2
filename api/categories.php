<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        require_once 'categories/get_categories.php';
        break;
    case 'POST':
        require_once 'categories/create_category.php';
        break;
    case 'PUT':
        require_once 'categories/update_category.php';
        break;
    case 'DELETE':
        require_once 'categories/delete_category.php';
        break;
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
?>