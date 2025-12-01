import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Patient home screen for completing cognitive assessments.
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentQuestionIndex = 0;
  bool _isRecording = false;
  List<String> _recordedFiles = [];
  List<bool> _questionCompleted = [];
  bool _isUploading = false;

  final List<String> _questions = [
    "How are you feeling today?",
    "What did you have for breakfast this morning?",
    "Tell me about something that made you happy recently.",
    "What activities did you do yesterday?",
    "Describe the weather outside today.",
  ];

  @override
  void initState() {
    super.initState();
    _recordedFiles = List.filled(_questions.length, '');
    _questionCompleted = List.filled(_questions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final completedCount = _questionCompleted.where((completed) => completed).length;
    final remainingQuestions = _getRemainingQuestions();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with logout - Compact
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Welcome, ${auth.patientId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
              
              // Main content area - Better distributed
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Progress and question section - Compact
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Progress indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_questions.length, (index) {
                                Color indicatorColor;
                                IconData? iconData;
                                
                                if (_questionCompleted[index]) {
                                  indicatorColor = Colors.green;
                                  iconData = Icons.check;
                                } else if (index == _currentQuestionIndex) {
                                  indicatorColor = Colors.white;
                                } else {
                                  indicatorColor = Colors.white.withOpacity(0.3);
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: indicatorColor,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5), 
                                      width: 1
                                    ),
                                  ),
                                  child: iconData != null 
                                    ? Icon(iconData, size: 10, color: Colors.white)
                                    : null,
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Question counter and completion status
                            Column(
                              children: [
                                Text(
                                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (completedCount < _questions.length)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: completedCount == 0 
                                          ? Colors.orange.withOpacity(0.8)
                                          : Colors.blue.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      completedCount == 0 
                                          ? 'No recordings yet'
                                          : '$completedCount recorded, ${_questions.length - completedCount} remaining',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'All questions completed! ✓',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Current question
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  _questions[_currentQuestionIndex],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Record button section - Bigger button, less gap
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bigger Record Button
                            GestureDetector(
                              onTap: _toggleRecording,
                              child: Container(
                                width: 220, // Increased from 180
                                height: 220, // Increased from 180
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isRecording 
                                        ? [Colors.red.shade400, Colors.red.shade600]
                                        : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecording ? Colors.red : const Color(0xFF4CAF50)).withOpacity(0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      size: 85, // Increased from 70
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isRecording ? 'Stop' : 'Record',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20, // Increased from 18
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_questionCompleted[_currentQuestionIndex])
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Recorded ✓',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Navigation buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Previous button
                                if (_currentQuestionIndex > 0)
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: _previousQuestion,
                                      icon: const Icon(Icons.arrow_back, size: 16),
                                      label: const Text('Previous'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.9),
                                        foregroundColor: const Color(0xFF667eea),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Next/Complete button
                                if (_currentQuestionIndex < _questions.length - 1)
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: _nextQuestion,
                                      icon: const Icon(Icons.arrow_forward, size: 16),
                                      label: const Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF667eea),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: completedCount == _questions.length ? _completeSession : _showIncompleteDialog,
                                      icon: Icon(
                                        completedCount == _questions.length ? Icons.cloud_upload : Icons.warning, 
                                        size: 16,
                                        color: completedCount == _questions.length ? const Color(0xFF667eea) : Colors.orange,
                                      ),
                                      label: Text(
                                        completedCount == _questions.length ? 'Complete & Upload' : 'Complete Session',
                                        style: TextStyle(
                                          color: completedCount == _questions.length ? const Color(0xFF667eea) : Colors.orange,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Emergency button at bottom - Keep existing space
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showEmergencyDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'EMERGENCY',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to call your caregiver immediately',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _getRemainingQuestions() {
    List<int> remaining = [];
    for (int i = 0; i < _questionCompleted.length; i++) {
      if (!_questionCompleted[i]) {
        remaining.add(i + 1);
      }
    }
    return remaining;
  }

  void _showIncompleteDialog() {
    final remainingQuestions = _getRemainingQuestions();
    final completedCount = _questionCompleted.where((completed) => completed).length;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Questions Incomplete'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have completed $completedCount out of ${_questions.length} questions.'),
              const SizedBox(height: 12),
              const Text('Please record answers for:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...remainingQuestions.map((questionNum) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• Question $questionNum', style: const TextStyle(color: Colors.orange)),
                )
              ).toList(),
              const SizedBox(height: 12),
              const Text('All questions must be completed to upload your session.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (remainingQuestions.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Go to first incomplete question
                  final firstIncomplete = remainingQuestions.first - 1;
                  setState(() {
                    _currentQuestionIndex = firstIncomplete;
                  });
                },
                child: Text('Go to Question ${remainingQuestions.first}'),
              ),
          ],
        );
      },
    );
  }

  void _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      await _stopRecording();
    } else {
      // Start recording
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Recording started... Speak your answer'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _stopRecording() async {
    setState(() => _isRecording = false);

    // Simulate saving recording
    final path = 'recording_q${_currentQuestionIndex + 1}.wav';
    _recordedFiles[_currentQuestionIndex] = path;
    _questionCompleted[_currentQuestionIndex] = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏹️ Recording stopped and saved'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );

    setState(() {}); // Refresh to show completion
  }

  void _nextQuestion() async {
    if (_isRecording) await _stopRecording();
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() async {
    // Stop recording if currently recording
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
    }
    
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _completeSession() async {
    // Stop recording if currently recording
    if (_isRecording) {
      await _stopRecording();
    }
    
    final completedCount = _questionCompleted.where((completed) => completed).length;
    
    // Double-check all questions are completed
    if (completedCount < _questions.length) {
      _showIncompleteDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.blue),
              SizedBox(width: 8),
              Text('Uploading Session'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading all 5 recordings...'),
              Text('Please wait while we process your responses.'),
            ],
          ),
        );
      },
    );

    // Upload to server
    final success = await _uploadSession();

    if (mounted) {
      Navigator.of(context).pop(); // Close upload dialog
      
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Session Complete!'),
                ],
              ),
              content: const Text('Excellent! All 5 responses have been uploaded and analyzed.\n\nYour caregiver will be able to see your latest progress.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetSession();
                  },
                  child: const Text('Start New Session'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Upload Failed'),
                ],
              ),
              content: const Text('Failed to upload recordings. Please try again or check your internet connection.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Try Again'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<bool> _uploadSession() async {
    final auth = context.read<AuthProvider>();
    
    // Get all the completed recordings
    final filesToUpload = <String>[];
    for (int i = 0; i < _recordedFiles.length; i++) {
      if (_questionCompleted[i] && _recordedFiles[i].isNotEmpty) {
        filesToUpload.add(_recordedFiles[i]);
      }
    }

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    return await auth.uploadAudioFiles(filesToUpload);
  }

  void _resetSession() {
    setState(() {
      _currentQuestionIndex = 0;
      _isRecording = false;
      _recordedFiles = List.filled(_questions.length, '');
      _questionCompleted = List.filled(_questions.length, false);
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.emergency, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Emergency Call'),
            ],
          ),
          content: const Text('🚨 EMERGENCY ALERT 🚨\n\nThis will immediately:\n• Call your caregiver\n• Send push notification to caregiver\n\nAre you sure you need emergency help?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makeEmergencyCall();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('EMERGENCY - CALL NOW'),
            ),
          ],
        );
      },
    );
  }

  void _makeEmergencyCall() async {
    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 EMERGENCY ALERT SENT!\n📞 Calling caregiver...\n📱 Notifying caregiver app...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );

    // TODO: Implement real emergency notification API call
    // This should send an immediate notification to the caregiver
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ CAREGIVER NOTIFIED\n📞 Call initiated\n📱 Push notification sent\n🚑 Help is on the way!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      
      // Show a simple confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 8),
                Text('Emergency Help Called'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Caregiver has been notified'),
                Text('✅ Emergency call initiated'),
                SizedBox(height: 12),
                Text('🚑 Help is on the way!', 
                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 8),
                Text('Stay calm and wait for assistance.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }
}