import 'package:flutter/material.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final List<String> _todoTasks = [
    "Water in the evening",
    "Apply organic fungicide",
    "Move to partial shade",
    "Improve airflow around base",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Health Insights"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PRIORITY ALERTS =================
            _sectionTitle("Priority Alerts"),

            _alertCard(
              title: "High heat stress expected tomorrow",
              subtitle: "Increase irrigation cycles to prevent wilting.",
              color: Colors.orange,
              tag: "WARNING",
            ),

            _alertCard(
              title: "Fungal risk increasing",
              subtitle: "Humidity above 80%. Improve airflow.",
              color: Colors.red,
              tag: "CRITICAL",
            ),

            _alertCard(
              title: "Good conditions for growth today",
              subtitle: "Ideal light and moisture levels.",
              color: Colors.green,
              tag: "OPTIMAL",
            ),

            const SizedBox(height: 20),

            // ================= PERFORMANCE TRENDS =================
            _sectionTitle("Performance Trends"),

            Row(
              children: [
                Expanded(
                  child: _trendCard(
                    title: "Health Index",
                    value: "84 / 100",
                    change: "+12%",
                    up: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _trendCard(
                    title: "Stress Level",
                    value: "22%",
                    change: "-5%",
                    up: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= RECOMMENDATIONS TODO =================
            _sectionTitle("Recommendations"),

            const SizedBox(height: 8),

            ..._todoTasks.map((task) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.task_alt, color: Colors.green),
                  title: Text(task),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        _todoTasks.remove(task);
                      });
                    },
                  ),
                ),
              );
            }).toList(),

            if (_todoTasks.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "🎉 All tasks completed!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _alertCard({
    required String title,
    required String subtitle,
    required Color color,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _trendCard({
    required String title,
    required String value,
    required String change,
    required bool up,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                up ? Icons.trending_up : Icons.trending_down,
                color: up ? Colors.green : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: up ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
