import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MultimediaScreen extends StatefulWidget {
  const MultimediaScreen({super.key});

  @override
  _MultimediaScreenState createState() => _MultimediaScreenState();
}

class _MultimediaScreenState extends State<MultimediaScreen> {
  File? _photo;
  File? _video;
  VideoPlayerController? _videoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedMedia();
  }

  Future<void> _loadSavedMedia() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final photoPath = prefs.getString('profile_selfie');
      if (photoPath != null && File(photoPath).existsSync()) {
        _photo = File(photoPath);
      }
      _isLoading = false;
    });
  }

  Future<bool> _requestPermission(Permission permission, String feature) async {
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission for $feature denied. Please enable it in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _updateProfilePicture({required bool fromCamera}) async {
    setState(() => _isLoading = true);
    if (kIsWeb) {
      // On web: only allow picking from files, no permissions needed
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_selfie_web', base64Image);
          setState(() {
            _photo = File(''); // Not used on web, but triggers UI update
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }
    // Mobile logic (with permissions)
    final permissionType =
        fromCamera
            ? Permission.camera
            : (Platform.isAndroid ? Permission.storage : Permission.photos);
    final permissionName = fromCamera ? 'camera' : 'gallery/files';
    final mediaGranted = await _requestPermission(
      permissionType,
      permissionName,
    );
    if (!mediaGranted) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        final dir = await getApplicationDocumentsDirectory();
        final newPath =
            '${dir.path}/profile_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final copiedFile = await File(pickedFile.path).copy(newPath);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_selfie', newPath);
        setState(() {
          _photo = File(newPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showProfilePictureOptions() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF003D4C),
                  ),
                  title: Text('Take a Selfie', style: GoogleFonts.roboto()),
                  onTap: () {
                    Navigator.pop(context);
                    _updateProfilePicture(fromCamera: true);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF003D4C),
                  ),
                  title: Text('Choose from Files', style: GoogleFonts.roboto()),
                  onTap: () {
                    Navigator.pop(context);
                    _updateProfilePicture(fromCamera: false);
                  },
                ),
                if (_photo != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: Text(
                      'Remove Current Photo',
                      style: GoogleFonts.roboto(color: Colors.redAccent),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('profile_selfie');
                      setState(() => _photo = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture removed.'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _recordVideo() async {
    setState(() => _isLoading = true);
    final cameraGranted = await _requestPermission(Permission.camera, 'camera');
    final microphoneGranted = await _requestPermission(
      Permission.microphone,
      'microphone',
    );
    if (!cameraGranted || !microphoneGranted) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.camera);
      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);
        setState(() {
          _video = videoFile;
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_video!)
            ..initialize()
                .then((_) {
                  setState(() {});
                  _videoController!.play();
                })
                .catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to initialize video: $e')),
                  );
                });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video recorded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No video recorded.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to record video: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multimedia',
          style: GoogleFonts.montserrat(color: const Color(0xFFF5F6F5)),
        ),
      ),
      backgroundColor: const Color.fromARGB(163, 79, 102, 108),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF003D4C)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Profile Picture',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F6F5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _showProfilePictureOptions,
                        child:
                            kIsWeb
                                ? FutureBuilder<String?>(
                                  future: SharedPreferences.getInstance().then(
                                    (prefs) =>
                                        prefs.getString('profile_selfie_web'),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircleAvatar(
                                        radius: 60,
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final base64Image = snapshot.data;
                                    if (base64Image != null &&
                                        base64Image.isNotEmpty) {
                                      return CircleAvatar(
                                        radius: 60,
                                        backgroundImage: MemoryImage(
                                          base64Decode(base64Image),
                                        ),
                                      );
                                    }
                                    return const CircleAvatar(
                                      radius: 60,
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                                : CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      _photo != null
                                          ? FileImage(_photo!)
                                          : null,
                                  child:
                                      _photo == null
                                          ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showProfilePictureOptions,
                        icon: const Icon(Icons.edit, color: Color(0xFF003D4C)),
                        label: Text(
                          'Edit Profile Picture',
                          style: GoogleFonts.roboto(color: Color(0xFF003D4C)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Record a Video',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F6F5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _recordVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D4C),
                        foregroundColor: const Color(0xFFF5F6F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Record Video', style: GoogleFonts.roboto()),
                    ),
                    const SizedBox(height: 8),
                    if (_videoController != null &&
                        _videoController!.value.isInitialized)
                      Column(
                        children: [
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _videoController!.value.isPlaying
                                    ? _videoController!.pause()
                                    : _videoController!.play();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003D4C),
                              foregroundColor: const Color(0xFFF5F6F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _videoController!.value.isPlaying
                                  ? 'Pause'
                                  : 'Play',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No video recorded',
                        style: GoogleFonts.roboto(
                          color: const Color(0xFFF5F6F5),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
