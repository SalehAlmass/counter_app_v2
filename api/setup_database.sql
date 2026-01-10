-- MySQL database setup for quiz app

-- Create the database
CREATE DATABASE IF NOT EXISTS quiz_app;
USE quiz_app;

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create questions table
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

-- Insert default categories
INSERT IGNORE INTO categories (name) VALUES 
('الرياضيات'),
('الثقافة العامة'),
('الدين الإسلامي'),
('الألغاز');

-- Insert sample questions for Mathematics
SET @math_category_id = (SELECT id FROM categories WHERE name = 'الرياضيات');
INSERT IGNORE INTO questions (question, option1, option2, option3, option4, correct_answer_index, explanation, difficulty, time_limit_seconds, category_id) VALUES
('كم يساوي 2+2؟', '3', '4', '5', '6', 1, '2+2=4', 0, 30, @math_category_id),
('ما هو الجذر التربيعي للعدد 144؟', '10', '11', '12', '13', 2, 'الجذر التربيعي لـ 144 هو 12', 0, 30, @math_category_id),
('ما مساحة مستطيل طوله 5 عرضه 3؟', '8', '12', '15', '20', 2, 'المساحة = الطول × العرض = 5 × 3 = 15', 0, 35, @math_category_id);

-- Insert sample questions for General Knowledge
SET @general_category_id = (SELECT id FROM categories WHERE name = 'الثقافة العامة');
INSERT IGNORE INTO questions (question, option1, option2, option3, option4, correct_answer_index, explanation, difficulty, time_limit_seconds, category_id) VALUES
('ما هي عاصمة السعودية؟', 'جدة', 'الرياض', 'مكة', 'المدينة', 1, 'الرياض هي العاصمة الرسمية للمملكة العربية السعودية', 0, 45, @general_category_id),
('كم عدد الكواكب في النظام الشمسي؟', '7', '8', '9', '10', 1, 'هناك 8 كواكب في النظام الشمسي', 0, 30, @general_category_id);

-- Insert sample questions for Islamic Religion
SET @islamic_category_id = (SELECT id FROM categories WHERE name = 'الدين الإسلامي');
INSERT IGNORE INTO questions (question, option1, option2, option3, option4, correct_answer_index, explanation, difficulty, time_limit_seconds, category_id) VALUES
('كم عدد آيات سورة الفاتحة؟', '5', '6', '7', '8', 2, 'سورة الفاتحة تحتوي على 7 آيات', 0, 30, @islamic_category_id),
('كم عدد أركان الإسلام؟', '4', '5', '6', '7', 1, 'أركان الإسلام الخمسة هي: الشهادة، الصلاة، الزكاة، الصيام، الحج', 0, 25, @islamic_category_id);

-- Insert sample questions for Riddles
SET @riddles_category_id = (SELECT id FROM categories WHERE name = 'الألغاز');
INSERT IGNORE INTO questions (question, option1, option2, option3, option4, correct_answer_index, explanation, difficulty, time_limit_seconds, category_id) VALUES
('أشير إليك ولا تراني، وإذا سمعتني فلا تراني، فمن أنا؟', 'الصدى', 'الظل', 'الصوت', 'الضوء', 0, 'الصدى يشير إليك ولا تراه، وترى الصدى عندما تسمعه', 2, 60, @riddles_category_id),
('له أسنان ولا يعض، له رأس ولا يعقل، فمن هو؟', 'المطر', 'القلم', 'المنشار', 'الثعبان', 2, 'المنشار له أسنان حادة ولا يعض، وله رأس ولا يعقل', 1, 50, @riddles_category_id);

-- Display all categories
SELECT * FROM categories;

-- Display all questions
SELECT * FROM questions;