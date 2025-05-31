import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/services.dart';
import 'quiz.dart';
import 'quiz-generate.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({Key? key}) : super(key: key);

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  int _currentIndex = 3;
  int _focusDuration = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isFocusRunning = false;
  File? _uploadedFile;
  List<String> _exceptionPackages = ['com.android.dialer'];

  Future<void> ensureDeviceAdminPermission() async {
    const platform = MethodChannel('com.example.project/lock');
    try {
      await platform.invokeMethod('requestAdmin');
    } on PlatformException catch (e) {
      print('Error requesting device admin permission: $e');
    }
  }

  Future<void> startKioskMode() async {
    const platform = MethodChannel('com.example.project/lock');
    try {
      await ensureDeviceAdminPermission();
      await platform.invokeMethod('startKiosk');
    } catch (e) {
      print('Failed to start kiosk mode: $e');
    }
  }

  Future<void> stopKioskMode() async {
    const platform = MethodChannel('com.example.project/lock');
    try {
      await platform.invokeMethod('stopKiosk');
    } catch (e) {
      print('Failed to stop kiosk mode: $e');
    }
  }

  void _pickFocusTime() async {
    int? selectedTime = await showDialog<int>(
      context: context,
      builder: (context) {
        int minutes = 25;
        return AlertDialog(
          title: Text('Set Focus Time (minutes)', style: GoogleFonts.poppins()),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: minutes.toDouble(),
                    min: 1,
                    max: 240,
                    divisions: 24,
                    label: minutes.toString(),
                    onChanged: (value) {
                      setState(() {
                        minutes = value.toInt();
                      });
                    },
                  ),
                  Text('$minutes minutes',
                      style: GoogleFonts.poppins(fontSize: 18))
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, minutes),
              child: Text('Start'),
            ),
          ],
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _focusDuration = selectedTime;
        _remainingSeconds = selectedTime * 60;
        _startFocus();
      });
    }
  }

  void _startFocus() async {
    setState(() {
      _isFocusRunning = true;
    });

    if (!_exceptionPackages
        .any((pkg) => pkg.contains('dialer') || pkg.contains('phone'))) {
      _exceptionPackages.add('com.android.dialer');
    }

    await startKioskMode();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _onFocusEnd();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _onFocusEnd() async {
    setState(() {
      _isFocusRunning = false;
    });
    await stopKioskMode();
    if (_uploadedFile != null) {
      _showQuizDialog();
    }
  }

  void _stopFocus() async {
    _timer?.cancel();
    setState(() {
      _isFocusRunning = false;
      _focusDuration = 0;
      _remainingSeconds = 0;
    });
    await stopKioskMode();
    if (_uploadedFile != null) {
      _showQuizDialog();
    }
    
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result != null) {
      setState(() {
        _uploadedFile = File(result.files.single.path!);
      });
    }
  }

  void _showInstalledAppsDialog() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Exception Apps', style: GoogleFonts.poppins()),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final pkg = app.packageName;

                final isDefaultPhoneApp =
                    pkg.contains('dialer') || pkg.contains('phone');
                final isSelected =
                    _exceptionPackages.contains(pkg) || isDefaultPhoneApp;

                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!,
                          width: 32, height: 32, fit: BoxFit.contain)
                      : null,
                  title: Text(app.name, style: GoogleFonts.poppins()),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: isDefaultPhoneApp
                      ? null
                      : () {
                          setState(() {
                            if (_exceptionPackages.contains(pkg)) {
                              _exceptionPackages.remove(pkg);
                            } else {
                              _exceptionPackages.add(pkg);
                            }
                          });
                          Navigator.pop(context);
                        },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Focus Complete!', style: GoogleFonts.poppins()),
        content: Text('Would you like to take a quiz on your uploaded file?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (_uploadedFile != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(child: CircularProgressIndicator()),
                );

                final quizService = QuizGeneratorService(
                    apiKey: "");
                try {
                  final quizQuestions =
                      await quizService.generateQuizFromPdf(_uploadedFile!);
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizScreen(questions: quizQuestions),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate quiz: $e')),
                  );
                }
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No file uploaded.')),
                );
              }
            },
            child: Text('Start Quiz'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFocusRunning) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Focus mode is active. Cannot exit.')),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text("Focus Mode",
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDuration(_remainingSeconds),
                          style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        SizedBox(height: 20),
                        _isFocusRunning
                            ? ElevatedButton(
                                onPressed: _stopFocus,
                                child: Text('End Focus',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _pickFocusTime,
                                child: Text('Set Focus Time',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isFocusRunning) ...[
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Study Material'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 221, 226, 255),
                    foregroundColor: Colors.indigo,
                  ),
                ),
                if (_uploadedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Uploaded: ${_uploadedFile!.path.split('/').last}',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
              ]
            ],
          ),
        ),
        bottomNavigationBar: !_isFocusRunning
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2), blurRadius: 8),
                  ],
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.indigo,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  iconSize: 28,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    if (index == 0) {
                      Navigator.pushNamed(context, '/dashboard');
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/teams');
                    } else if (index == 2) {
                      Navigator.pushNamed(context, '/calendar');
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.group),
                      label: 'Teams',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Calendar',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book_outlined),
                      label: 'Focus',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
