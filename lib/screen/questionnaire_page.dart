import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_survey/flutter_survey.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

final Map<String, List<Question>?> likertScaleOptions = {
  "Strongly Disagree": null,
  "Disagree": null,
  "Neutral": null,
  "Agree": null,
  "Strongly Agree": null,
};

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();
  List<QuestionResult> _questionResults = [];

  final List<Question> psychologicalSafetyQuestions = [
    Question(
      isMandatory: true,
      question:
          "I feel comfortable expressing my opinions and ideas without fear of negative consequences.",
      answerChoices: likertScaleOptions,
    ),
    Question(
      isMandatory: true,
      question: "I feel safe taking risks and making mistakes at work.",
      answerChoices: likertScaleOptions,
    ),
    Question(
      isMandatory: true,
      question:
          "My colleagues treat each other with respect, even when there are disagreements.",
      answerChoices: likertScaleOptions,
    ),
    Question(
      isMandatory: true,
      question:
          "I feel that my contributions are valued, even if they differ from others'.",
      answerChoices: likertScaleOptions,
    ),
    Question(
      isMandatory: true,
      question:
          "NITDA promotes a culture where it’s okay to ask for help or admit a lack of knowledge.",
      answerChoices: likertScaleOptions,
    ),
  ];

  Future<void> _submitAnswers(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not signed in")),
      );
      return;
    }

    final responses = _questionResults;
    if (responses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please answer the questions")),
      );
      return;
    }

    final Map<String, dynamic> answers = {
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    for (final response in responses) {
      answers[response.question] = response.answers;
    }

    try {
      await FirebaseFirestore.instance
          .collection('SurveyResponses')
          .doc(user.uid)
          .set(answers);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Questionnaire',
          style:
              GoogleFonts.lato(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Survey(
            initialData: psychologicalSafetyQuestions,
            onNext: (questionResults) {
              _questionResults = questionResults;
            }),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: screenHeight / 76.6, //10
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:  screenWidth / 45, vertical: screenHeight/95.75), //8
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('AdminSettings')
                  .doc('surveyControl')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return SizedBox.shrink();
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final isEnabled = data['isEnabled'] ?? false;

                return GestureDetector(
                  onTap: isEnabled
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _submitAnswers(context);
                          }
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "The survey cannot be submitted at this time")),
                          );
                          return;
                        },
                  child: Opacity(
                    opacity: isEnabled ? 1 : 0.5,
                    child: Container(
                      width: screenWidth/1.5, //240
                      height: screenHeight /19.5, //40
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.0),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: Text("Submit",
                            style: GoogleFonts.lato(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: screenWidth / 22.5)),//16
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
