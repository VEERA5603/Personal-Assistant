import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String ipAddress = "";
  String command = "";
  String responseMessage = "Waiting for your command...";
  late stt.SpeechToText _speech;
  bool isListening = false;
  TextEditingController _commandController = TextEditingController();
  TextEditingController _ipController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool isLoading = false;
  Timer? _autoSendTimer;
  bool showCommandList = false;

  // List of available commands grouped by category
  final Map<String, List<String>> commandCategories = {
    "Web & Browsing": [
      "open browser",
      "close browser",
      "search google [query]",
    ],
    "Media & Entertainment": [
      "play [song/video]",
      "volume up",
      "volume down",
      "mute",
    ],
    "System Controls": [
      "shutdown",
      "restart",
      "lock",
      "screenshot",
      "time",
    ],
    "Programs & Applications": [
      "run program [name]",
      "open notepad",
      "open calculator",
      "open chrome",
      "open file explorer",
    ],
    "Information": [
      "check internet",
      "get ip address",
      "system info",
      "battery status",
    ],
    "Utilities": [
      "take photo",
      "find file [name]",
      "set reminder [text]",
      "tell a joke",
    ],
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicrophonePermission();

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Request microphone permission
  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      setState(() {
        responseMessage = "Microphone permission is required!";
      });
    }
  }

  /// Send command to Flask server
  Future<void> sendCommand() async {
    if (ipAddress.isEmpty || command.isEmpty) {
      setState(() {
        responseMessage = "Please enter IP address and command!";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("http://$ipAddress:5000/execute");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"command": command}),
      );

      if (response.statusCode == 200) {
        setState(() {
          responseMessage = jsonDecode(response.body)['response'] ??
              "No response from server.";
          command = ""; // Clear the command after execution
          _commandController.clear(); // Clear the text field
        });
      } else {
        setState(() {
          responseMessage = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = "Failed to connect: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Start listening to voice command
  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Status: $status");
        if (status == "done") {
          setState(() {
            isListening = false;
            // Auto-send the command after speech recognition is completed
            if (command.isNotEmpty) {
              _autoSendTimer = Timer(Duration(milliseconds: 500), () {
                sendCommand();
              });
            }
          });
        }
      },
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      setState(() {
        isListening = true;
        responseMessage = "Listening...";
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            command = result.recognizedWords;
            _commandController.text = command;
          });
        },
        listenFor: Duration(seconds: 8), // Adjust time as needed
        pauseFor: Duration(seconds: 2),
        partialResults: true,
      );
    } else {
      setState(() {
        responseMessage = "Speech recognition not available.";
      });
    }
  }

  /// Stop listening
  void stopListening() {
    _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  @override
  void dispose() {
    _commandController.dispose();
    _ipController.dispose();
    _animationController.dispose();
    _autoSendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade800, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Personal Assistant",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                showCommandList ? Icons.list_alt : Icons.menu,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  showCommandList = !showCommandList;
                });
              },
            ),
          ],
        ),
        body: showCommandList ? _buildCommandList() : _buildMainInterface(),
      ),
    );
  }

  Widget _buildMainInterface() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF121212)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: "Enter Server IP",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.computer, color: Colors.red),
              ),
              onChanged: (value) {
                setState(() {
                  ipAddress = value.trim();
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    decoration: InputDecoration(
                      labelText: "Command",
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.text_fields, color: Colors.red),
                      suffixIcon: command.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  command = "";
                                  _commandController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        command = value.trim();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: command.isEmpty ? null : sendCommand,
                  child: Text("Send"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey.shade800,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isListening ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: isListening ? stopListening : startListening,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isListening ? Colors.red : Colors.grey.shade800,
                          boxShadow: [
                            BoxShadow(
                              color: isListening
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.transparent,
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade800,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "RESPONSE",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : isListening
                          ? AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Listening...',
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  speed: Duration(milliseconds: 100),
                                ),
                              ],
                              totalRepeatCount: 10,
                              pause: Duration(milliseconds: 500),
                              displayFullTextOnTap: true,
                            )
                          : Text(
                              responseMessage,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF121212)],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "AVAILABLE COMMANDS",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...commandCategories.entries.map((entry) {
            return _buildCategoryCard(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<String> commands) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      elevation: 4,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          category,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconColor: Colors.red,
        collapsedIconColor: Colors.red,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: commands.map((command) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      // Extract the base command without parameters
                      String baseCommand = command.contains("[")
                          ? command.substring(0, command.indexOf("[")).trim()
                          : command;

                      // Set command and go back to main interface
                      _commandController.text = baseCommand;
                      this.command = baseCommand;
                      showCommandList = false;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade800,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            command,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
