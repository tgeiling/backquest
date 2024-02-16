import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_updatePage);
  }

  void _updatePage() {
    if (_pageController.page!.toInt() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    }
  }

  void _finishQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('questionnaireCompleted', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainScaffold()),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          QuestionPage1(),
          QuestionPage2(),
          QuestionPage3(),
          QuestionPage4(onFinish: _finishQuestionnaire),
        ],
      ),
      floatingActionButton: _currentPage < 3
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              child: Icon(Icons.navigate_next),
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class QuestionPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 1 Content"));
    // Add your custom widgets for Page 1 here
  }
}

class QuestionPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 2 Content"));
    // Add your custom widgets for Page 2 here
  }
}

class QuestionPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 3 Content"));
    // Add your custom widgets for Page 3 here
  }
}

class QuestionPage4 extends StatelessWidget {
  final VoidCallback onFinish;

  QuestionPage4({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Congratulations!"),
              content: Text("You're all set to start."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    onFinish(); // Call the onFinish callback
                  },
                  child: Text("Start"),
                ),
              ],
            ),
          );
        },
        child: Text("Finish"),
      ),
    );
  }
}
