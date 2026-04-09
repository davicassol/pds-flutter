import 'package:flutter/material.dart';
import '../widgets/report_header.dart';
import '../widgets/flood_level_selector.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/info_card.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/primary_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final streetController = TextEditingController();
  String floodLevel = "medium";
  String? photo;

  void handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Flood report submitted successfully!")),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ReportHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Street Name",
                          hint: "Enter street name",
                          controller: streetController,
                        ),

                        const SizedBox(height: 20),

                        FloodLevelSelector(
                          selected: floodLevel,
                          onChanged: (value) {
                            setState(() {
                              floodLevel = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        PhotoUploadWidget(
                          photo: photo,
                          onChanged: (value) {
                            setState(() {
                              photo = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        PrimaryButton(
                          text: "Report Flood",
                          onPressed: handleSubmit,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const InfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}