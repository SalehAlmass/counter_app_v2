# MySQL Only Database Configuration

This document explains how the app has been configured to use only MySQL database via PHP API.

## Changes Made

1. **Removed sqflite dependency** - No longer using local SQLite database
2. **Updated DatabaseHelper** - Now exclusively uses API service to communicate with MySQL
3. **Updated pubspec.yaml** - Removed sqflite and path dependencies, kept only http
4. **Simplified main.dart** - Removed database initialization code, only set API usage flag

## Configuration

The app now connects directly to MySQL database through the PHP API located at:
- `http://10.2.2.2/counter_app_v2/api` (for Android emulator)
- Change to `http://localhost/counter_app_v2/api` for web or actual device

## Requirements

- XAMPP with Apache and MySQL running
- MySQL database named `quiz_app` with proper tables
- PHP API files in the correct directory structure
- Network connectivity between Flutter app and XAMPP server

## Troubleshooting

- Make sure XAMPP Apache and MySQL services are running
- Verify the database connection in `api/config.php`
- Check that the API endpoint is accessible from your device/emulator
- For Android emulator, use IP 10.2.2.2 to access localhost
- For physical devices, use your computer's IP address on the same network

## API Endpoints

All database operations now go through these PHP API endpoints:
- `GET /categories.php` - Get all categories
- `POST /categories.php` - Create a new category
- `PUT /categories.php` - Update a category
- `DELETE /categories.php` - Delete a category
- `GET /questions.php` - Get all questions
- `POST /questions.php` - Create a new question
- `PUT /questions.php` - Update a question
- `DELETE /questions.php` - Delete a question