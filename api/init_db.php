<?php
require_once 'config.php';

$sql = "
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL,
    option1 TEXT NOT NULL,
    option2 TEXT NOT NULL,
    option3 TEXT NOT NULL,
    option4 TEXT NOT NULL,
    correct_answer_index INT NOT NULL,
    explanation TEXT,
    difficulty INT DEFAULT 1, -- 0: easy, 1: medium, 2: hard
    time_limit_seconds INT DEFAULT 30,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

INSERT IGNORE INTO categories (id, name) VALUES 
(1, 'الرياضيات'),
(2, 'الثقافة العامة'),
(3, 'الدين الإسلامي'),
(4, 'الألغاز');
";

try {
    $pdo->exec($sql);
    echo json_encode(["success" => true, "message" => "Database initialized successfully"]);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>