# MySQL API Setup Instructions

This document explains how to set up and use the MySQL API for your Flutter quiz app.

## 1. Database Setup

First, create the MySQL database:

```sql
CREATE DATABASE quiz_app;
USE quiz_app;

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
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
INSERT INTO categories (name) VALUES 
('الرياضيات'),
('الثقافة العامة'),
('الدين الإسلامي'),
('الألغاز');
```

## 2. PHP API Setup

1. Place the PHP files in your web server directory (e.g., in XAMPP's htdocs folder)
2. Update the database connection settings in `config.php`:

```php
$servername = "localhost"; // Your MySQL server address
$username = "root";        // Your MySQL username
$password = "";            // Your MySQL password
$dbname = "quiz_app";      // Your database name
```

3. Make sure your web server (Apache/Nginx) and MySQL are running

## 3. Flutter App Configuration

To switch from local SQLite to MySQL API:

1. Open `lib/main.dart`
2. Uncomment the line that enables API usage:

```dart
// For mobile apps using MySQL API
DatabaseHelper.useApi = true;

// For web apps (automatically enabled in the code)
// DatabaseHelper.useApi = true; // Enable API for web since local DB doesn't work
```

3. Update the API base URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost/counter_app_v2/api'; // Change to your server URL
```

## 4. API Endpoints

The following endpoints are available:

- `GET /categories.php` - Get all categories
- `POST /categories.php` - Create a new category
- `PUT /categories.php` - Update a category
- `DELETE /categories.php` - Delete a category

- `GET /questions.php` - Get all questions (with optional category_id parameter)
- `POST /questions.php` - Create a new question
- `PUT /questions.php` - Update a question
- `DELETE /questions.php` - Delete a question

## 5. Features

- Full CRUD operations for categories and questions
- Cross-platform compatibility (works on mobile and web)
- Fallback to local data when API is unavailable
- Proper error handling
- Admin panel integration

## 6. Troubleshooting

- Ensure your web server and MySQL are running
- Check that the database credentials in `config.php` are correct
- Verify that CORS is properly configured
- Make sure the API URL in `api_service.dart` is correct
- Check PHP error logs if there are issues with the API