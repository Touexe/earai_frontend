import 'dart:async';
import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';

class SoundPage extends StatefulWidget {
  @override
  _SoundPageState createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  bool isEarAIWorking = false;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String detectedSound = '';

  final Logger _logger = Logger('SoundPage');
  StreamSubscription? _recorderSubscription;
  StreamController<Food>? _recordingDataController;

  @override
  void initState() {
    super.initState();
    _setupLogging();
    initializeRecorder(); // Initialize recorder on start
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL; // Set logging level to ALL
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> initializeRecorder() async {
    _logger.info('Initializing recorder');
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _logger.severe('Microphone permission not granted');
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    setState(() {
      _isRecorderInitialized = true;
    });
    _logger.info('Recorder initialized');
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      _recordingDataController = StreamController<Food>();
      _recorderSubscription = _recordingDataController!.stream.listen((buffer) {
        if (buffer is FoodData) {
          _logger.info('Received audio data: ${buffer.data!.length} bytes');
          sendAudioDataToServer(buffer.data!);
        }
      });

      await _recorder.startRecorder(
        toStream: _recordingDataController!.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 44100,
      );

      _logger.info('Recording started');
    } catch (e) {
      _logger.severe('Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      await _recorder.stopRecorder();
      _logger.info('Recording stopped');
      if (_recorderSubscription != null) {
        await _recorderSubscription!.cancel();
        _recorderSubscription = null;
      }
      _recordingDataController?.close();
    } catch (e) {
      _logger.severe('Failed to stop recording: $e');
    }
  }

  void sendAudioDataToServer(List<int> audioData) async {
    // Example function to send audio data to a server
    try {
      var response = await http.post(
        Uri.parse('https://earai.0xtou.live'),
        body: audioData,
        headers: {'Content-Type': 'audio/ogg'}, // Adjust content type as needed
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          detectedSound = jsonResponse['predicted_class']; // Update the detected sound
        });
        _logger.info('Upload successful, detected sound: $detectedSound');
      } else {
        setState(() {
          detectedSound = 'Error detecting sound';
        });
        _logger.severe('Upload failed, status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Failed to upload audio data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(42.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40),
                Text(
                  'Welcome back, William Myers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detectedSound.isNotEmpty ? detectedSound : 'Car Horn', // Display detected sound
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.volume_up, color: Colors.white),
                    ],
                  ),
                ),
                SizedBox(height: 330),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "EarAI's Working",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Switch(
                      value: isEarAIWorking,
                      onChanged: (bool value) {
                        setState(() {
                          isEarAIWorking = value;
                          if (isEarAIWorking) {
                            startRecording(); // Start recording when switch is on
                          } else {
                            stopRecording(); // Stop recording when switch is off
                          }
                        });
                        _logger.info('EarAI\'s Working switch changed to $isEarAIWorking');
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        isEarAIWorking ? 'Detecting...' : 'Paused',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recorderSubscription?.cancel(); // Cancel stream subscription
    _recordingDataController?.close();
    super.dispose();
  }
}
