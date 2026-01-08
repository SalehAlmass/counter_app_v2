import 'package:flutter/material.dart';
import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/screens/PointsCounterScreen.dart';
import 'package:counter_app/screens/admin_panel_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  // Question categories
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'الرياضيات',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'description': 'اختبار المهارات الرياضية والحسابية',
      'questions': QuizData.getMathQuestions(),
    },
    {
      'title': 'الثقافة العامة',
      'icon': Icons.public,
      'color': Colors.green,
      'description': 'أسئلة عن التاريخ والجغرافيا والثقافة',
      'questions': QuizData.getGeneralKnowledgeQuestions(),
    },
    {
      'title': 'الدين الإسلامي',
      'icon': Icons.mosque,
      'color': Colors.orange,
      'description': 'أسئلة عن العقيدة والأحكام الشرعية',
      'questions': QuizData.getReligiousQuestions(),
    },
    {
      'title': 'الألغاز',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'description': 'ألغاز ذهنية وتحديات فكرية',
      'questions': QuizData.getRiddlesQuestions(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر القسم'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header Text
              const Text(
                'اختر مجال الاختبار الذي تفضله',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // Categories Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(categories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category['color'].withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'],
                size: 50,
                color: category['color'],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category Title
            Text(
              category['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: category['color'],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                category['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Select Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: category['color'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'اختيار',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(Map<String, dynamic> category) {
    // Navigate to main app with selected category questions
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PointsCounterScreen(
          initialQuestions: category['questions'] as List<Question>,
          categoryName: category['title'] as String,
        ),
      ),
    );
  }
}