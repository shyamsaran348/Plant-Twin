import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class DiseaseAnalysisScreen extends StatelessWidget {
  final XFile imageFile;
  final Map<String, dynamic> analysisResult;
  final VoidCallback onRetake;
  final VoidCallback onSave; 

  const DiseaseAnalysisScreen({
    super.key,
    required this.imageFile,
    required this.analysisResult,
    required this.onRetake,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Backend returns 'disease', but DiseaseRecord model uses 'predicted_class'. Handling both helps robustness.
    final String disease = analysisResult['disease'] ?? analysisResult['predicted_class'] ?? "Unknown";
    final double confidence = (analysisResult['confidence'] ?? 0.0) * 100;
    final bool isHealthy = disease.toLowerCase().contains("healthy");

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Analysis Result"),
        backgroundColor: isHealthy ? AppTheme.primaryGreen : Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display
            Container(
              height: 350,
              decoration: BoxDecoration(
                image: DecorationImage(
                   image: NetworkImage(imageFile.path), // Basic usage
                   fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(isHealthy ? Icons.check_circle : Icons.warning, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isHealthy ? "Healthy" : "Attention Needed",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Diagnosis Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Diagnosis".toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Colors.grey[600], letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          disease,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: isHealthy ? AppTheme.primaryGreen : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: confidence / 100,
                            backgroundColor: Colors.grey[100],
                            color: isHealthy ? AppTheme.primaryGreen : Colors.orange,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Confidence: ${confidence.toStringAsFixed(1)}%",
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info / Advice 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isHealthy ? Colors.green.shade100 : Colors.orange.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: isHealthy ? Colors.green : Colors.orange),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Next Steps",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isHealthy ? Colors.green.shade900 : Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isHealthy 
                                    ? "Your plant looks great! Continue with your regular care schedule."
                                    : "Check the 'Care Advice' section for treatment options and isolate this plant if possible.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isHealthy ? Colors.green.shade800 : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             if (Navigator.canPop(context)) {
                               Navigator.pop(context);
                             }
                             onRetake();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Retake", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                             if (Navigator.canPop(context)) {
                               Navigator.pop(context);
                             }
                             onSave();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                            shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
                          ),
                          child: const Text("Complete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}
