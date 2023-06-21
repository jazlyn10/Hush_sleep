import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void>main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int questionIndex;
  late ValueNotifier<int> number;
  late List<int> numberValues; // Store previous number button values
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void storeNumberValue(int value) {
    final documentRef = firestore.collection('numberValues').doc();
    documentRef.set({'value': value});
  }


  void previousQuestion() {
    setState(() {
      if (questionIndex > 0) {
        numberValues[questionIndex] = number.value; // Store current number button value
        questionIndex--;
        number.value = numberValues[questionIndex]; // Retrieve number button value for the previous case
      }
    });
  }

  @override
  void initState() {
    super.initState();
    questionIndex = 0;
    number = ValueNotifier<int>(0);
    numberValues = List<int>.filled(4, 0); // Initialize list with 4 elements, all set to 0
  }

  void nextQuestion() {
    setState(() {
      if (questionIndex < 3) {
        storeNumberValue(number.value); // Store current number button value
        numberValues[questionIndex] = number.value;
        questionIndex++;
        number.value = numberValues[questionIndex]; // Retrieve number button value for the next case
        number.value = 0;
      } else if (questionIndex == 3) {
        storeNumberValue(number.value); // Store current number button value for the 4th question

        // Store each question's input in specific fields in Firebase
        firestore.collection('numberValues').doc('duration').set({
          'value': numberValues[0],   // Store first question's input in 'duration' field
        }).catchError((error) {
          print('Failed to store duration value in Firebase: $error');
        });

        firestore.collection('numberValues').doc('wakes').set({
          'value': numberValues[1],   // Store second question's input in 'wakes' field
        }).catchError((error) {
          print('Failed to store wakes value in Firebase: $error');
        });

        firestore.collection('numberValues').doc('timeToSleep').set({
          'value': numberValues[2],   // Store third question's input in 'timeToSleep' field
        }).catchError((error) {
          print('Failed to store timeToSleep value in Firebase: $error');
        });

        firestore.collection('numberValues').doc('quality').set({
          'value': numberValues[3],   // Store fourth question's input in 'quality' field
        }).then((value) {
          print('Values stored in Firebase successfully');
        }).catchError((error) {
          print('Failed to store quality value in Firebase: $error');
        });
      }
    });
  }

  void decreaseNumber() {
    setState(() {
      if (number.value > 0) {
        number.value--;
      }
    });
  }

  void increaseNumber() {
    setState(() {
      number.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Assessment',
      home: Scaffold(
        body: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/sleepbg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 324,
                  height: 462,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(33),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: previousQuestion,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              width: 152,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (questionIndex + 1) / 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF233C67),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Perform cross button action
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0),
                      buildQuestion(),
                      SizedBox(height: 7),
                      buildImage(),
                      SizedBox(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RoundedButton(
                            backgroundColor: Color(0xFFFDFCFF),
                            icon: Icons.remove,
                            onPressed: decreaseNumber,
                          ),
                          SizedBox(width: 16),
                          NumberButton(number: number),
                          SizedBox(width: 16),
                          RoundedButton(
                            backgroundColor: Color(0xFFFDFCFF),
                            icon: Icons.add,
                            onPressed: increaseNumber,
                          ),
                        ],
                      ),

                      //NEXT BUTTON

                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (questionIndex == 3) {
                            Text('Continue');
                          } else {
                            nextQuestion();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF233C67),
                          ),
                        ),
                        child: Text(questionIndex == 3 ? 'Continue' : 'Next'),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildQuestion() {
    switch (questionIndex) {
      case 0:
        return Text(
          'How long did you sleep tonight?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      case 1:
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'How many times did you wake',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'up in the middle of the night?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case 2:
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'How well-rested do you feel?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              '    on a scale of 0 to 10?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case 3:
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'How would you rate the quality of',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'your sleep on a scale of 0 to 10',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }






  Widget buildImage() {
    switch (questionIndex) {
      case 0:
        return Image.asset(
          'assets/sleep1.png',
          width: 200,
        );
      case 1:
        return Image.asset(
          'assets/sleep2.png',
          width: 200,
        );
      case 2:
        return Image.asset(
          'assets/sleep3.png',
          width: 200,
        );
      case 3:
        return Image.asset(
          'assets/sleep4.png',
          width: 200,
        );
      default:
        return SizedBox.shrink();
    }
  }
}

class RoundedButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedButton({
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}


class NumberButton extends StatelessWidget {
  final ValueNotifier<int> number;

  NumberButton({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFFFDFCFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: number,
          builder: (context, value, _) {
            return Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
      ),
    );
  }
}