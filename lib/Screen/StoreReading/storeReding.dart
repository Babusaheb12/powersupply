import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../../../Api/shared_preference.dart';
import 'Bloc/store_meter_reading_bloc.dart';

class AddStoreMeterReadingScreen extends StatefulWidget {

  final String siteName;
  final String siteId;
  final String location;
  final String dateTime;

  const AddStoreMeterReadingScreen({
    super.key,
    required this.siteName,
    required this.siteId,
    required this.location,
    required this.dateTime,
  });

  @override
  State<AddStoreMeterReadingScreen> createState() => _AddStoreMeterReadingScreenState();
}

class _AddStoreMeterReadingScreenState extends State<AddStoreMeterReadingScreen> {

  final TextEditingController kwhController = TextEditingController();
  final TextEditingController kvahController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _kwhImage;
  File? _kvahImage;

  late StoreMeterReadingBloc _readingBloc;

  @override
  void initState() {
    super.initState();
    _readingBloc = StoreMeterReadingBloc();
  }

  @override
  void dispose() {
    kwhController.dispose();
    kvahController.dispose();
    super.dispose();
  }

  /// Convert database datetime to user-friendly format
  String _formatDateTimeForDisplay(String dbDateTime) {
    try {
      // Parse the database format: yyyy-MM-dd HH:mm:ss
      final dateTime = DateTime.parse(dbDateTime);
      // Format to: dd/MM/yyyy hh:mm a
      return DateFormat("dd/MM/yyyy hh:mm a").format(dateTime);
    } catch (e) {
      // If parsing fails, return original string
      return dbDateTime;
    }
  }

  /// Capture → Crop → OCR
  Future<void> scanMeterReading(TextEditingController controller, bool isKWH) async {

    try {
      print('🔵 Step 1: Opening camera...');

      /// Capture Image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      print('🔵 Step 2: Image captured: ${image?.path}');

      if (image == null) {
        print('⚠️ User cancelled camera');
        return;
      }

      /// Crop Image
      print('🔵 Step 3: Starting crop...');

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Meter Reading",
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: "Crop Meter Reading",
            resetAspectRatioEnabled: true,
          ),
        ],
      );

      print('🔵 Step 4: Crop completed: ${croppedFile?.path}');

      if (croppedFile == null) {
        print('⚠️ User cancelled crop');
        return;
      }

      /// Store the cropped image
      setState(() {
        if (isKWH) {
          _kwhImage = File(croppedFile.path);
        } else {
          _kvahImage = File(croppedFile.path);
        }
      });

      /// OCR Process
      print('🔵 Step 5: Starting OCR...');

      final inputImage = InputImage.fromFile(File(croppedFile.path));
      final textRecognizer = TextRecognizer();

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String detectedText = "";

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          detectedText += "${line.text} ";
        }
      }

      print('🔵 Step 6: Detected text: $detectedText');

      /// Extract Numbers
      final numbers = RegExp(r'\d+').allMatches(detectedText);

      if (numbers.isNotEmpty) {

        String meterReading = numbers.first.group(0)!;

        print('✅ Step 7: Extracted number: $meterReading');

        setState(() {
          controller.text = meterReading;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meter reading detected successfully!"),
            backgroundColor: Colors.green,
          ),
        );

      } else {

        print('❌ No numbers found in detected text');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meter reading not detected. Please try again."),
            backgroundColor: Colors.orange,
          ),
        );

      }

      textRecognizer.close();

    } catch (e) {
      print('❌ Error in scanMeterReading: $e');
      print('❌ Error stack trace: ${StackTrace.current}');

      String errorMessage = e.toString();

      // Provide user-friendly error messages
      if (errorMessage.contains('Permission')) {
        errorMessage = 'Camera permission denied. Please enable camera permission in settings.';
      } else if (errorMessage.contains('ActivityNotFoundException')) {
        errorMessage = 'Crop activity not found. Please restart the app.';
      } else if (errorMessage.contains('SecurityException')) {
        errorMessage = 'Storage permission denied. Please grant storage permission.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $errorMessage"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    const primaryColor = Color(0xFF1F4FA3);

    return Scaffold(

      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Enter Meter Reading",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// Project Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Project: ${widget.siteName}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Location: ${widget.location}",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Date: ${_formatDateTimeForDisplay(widget.dateTime)}",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54),
                      )

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// KWH
                meterReadingCard(
                  title: "KWH Reading",
                  controller: kwhController,
                  isKWH: true,
                ),

                const SizedBox(height: 20),

                /// KVAH
                meterReadingCard(
                  title: "KVAH Reading",
                  controller: kvahController,
                  isKWH: false,
                ),

                const SizedBox(height: 120),

              ],
            ),
          ),

          /// Submit Button with Bloc Listener
          BlocListener<StoreMeterReadingBloc, StoreMeterReadingState>(
            bloc: _readingBloc,
            listener: (context, state) {
              if (state is StoreMeterReadingLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
              } else if (state is StoreMeterReadingSuccess) {
                // Close loading dialog first
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Meter reading submitted successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );

                // Clear fields after success
                setState(() {
                  kwhController.clear();
                  kvahController.clear();
                  _kwhImage = null;
                  _kvahImage = null;
                });

                // Wait a moment then close the screen
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    Navigator.pop(context); // 👈 Screen close
                  }
                });
              } else if (state is StoreMeterReadingFailure) {
                // Close loading dialog
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: ${state.message}"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is StoreMeterReadingNoInternet) {
                // Close loading dialog if open
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ No internet connection. Please check your network."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate inputs
                      if (kwhController.text.isEmpty && kvahController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter at least one meter reading"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Get user ID from shared preferences
                      final userId = Prefs.userId;

                      if (userId == null || userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User not logged in. Please login again."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validate reading values (max 20 digits)
                      if (kwhController.text.length > 20 || kvahController.text.length > 20) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("⚠️ Meter reading value too large. Maximum 20 digits allowed."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Log detailed submission info
                      developer.log('📤 === METER READING SUBMISSION START ===', name: 'AddMeterReading');
                      developer.log('👤 User ID: $userId', name: 'AddMeterReading');
                      developer.log('🏭 Site ID: ${widget.siteId}', name: 'AddMeterReading');
                      developer.log('⚡ KWH Reading: "${kwhController.text}"', name: 'AddMeterReading');
                      developer.log('⚡ KVAH Reading: "${kvahController.text}"', name: 'AddMeterReading');

                      if (_kwhImage != null) {
                        final kwhExists = await _kwhImage!.exists();
                        final kwhSize = await _kwhImage!.length();
                        developer.log('📸 KWH Image: EXISTS=$kwhExists', name: 'AddMeterReading');
                        developer.log('📸 KWH Path: ${_kwhImage!.path}', name: 'AddMeterReading');
                        developer.log('📸 KWH Size: $kwhSize bytes', name: 'AddMeterReading');
                      } else {
                        developer.log('📸 KWH Image: NOT CAPTURED', name: 'AddMeterReading');
                      }

                      if (_kvahImage != null) {
                        final kvahExists = await _kvahImage!.exists();
                        final kvahSize = await _kvahImage!.length();
                        developer.log('📸 KVAH Image: EXISTS=$kvahExists', name: 'AddMeterReading');
                        developer.log('📸 KVAH Path: ${_kvahImage!.path}', name: 'AddMeterReading');
                        developer.log('📸 KVAH Size: $kvahSize bytes', name: 'AddMeterReading');
                      } else {
                        developer.log('📸 KVAH Image: NOT CAPTURED', name: 'AddMeterReading');
                      }
                      developer.log('📤 === SUBMISSION END ===', name: 'AddMeterReading');

                      // Submit to bloc
                      _readingBloc.add(MeterReadingEvent(
                        userId: userId,
                        siteId: widget.siteId,
                        location: widget.location,
                        dateTime: widget.dateTime,
                        kwhReading: kwhController.text,
                        kvahReading: kvahController.text,
                        kwhImage: _kwhImage,
                        kvahImage: _kvahImage,
                      ));
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      "Submit Reading",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),

                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  /// Meter Card
  Widget meterReadingCard({
    required String title,
    required TextEditingController controller,
    required bool isKWH,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          /// Captured Image Preview
          if (isKWH && _kwhImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _kwhImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ] else if (!isKWH && _kvahImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _kvahImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],

          /// Input Field
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter reading",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// Capture Button
          OutlinedButton.icon(
            onPressed: () {
              scanMeterReading(controller, isKWH);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("Capture Meter Reading"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )

        ],
      ),
    );
  }
}