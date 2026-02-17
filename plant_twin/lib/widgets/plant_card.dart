import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  // We can pass the image URL directly if needed, or just use the plant object
  final String? imageUrl;

  const PlantCard({
    super.key,
    required this.plant,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final health = plant.plantState?.healthScore ?? 100.0;
    final waterStress = plant.plantState?.waterStress ?? 0.0;
    final diseaseRisk = plant.plantState?.diseaseRiskIndex ?? 0.0;

    Color healthColor = health > 80 ? AppTheme.primaryGreen : (health > 50 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left: Image or Placeholder
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: imageUrl != null 
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: imageUrl == null 
                  ? Icon(Icons.local_florist, size: 40, color: Colors.green[300]) 
                  : null,
            ),
            
            // Right: Info & Stats
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plant.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      plant.species,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatBadge(
                            context, 
                            "${health.toInt()}%", 
                            Icons.favorite, 
                            healthColor
                        ),
                        if (waterStress > 0.5)
                          _buildStatBadge(
                            context, 
                            "Thirsty", 
                            Icons.water_drop, 
                            Colors.blue
                          ),
                        if (diseaseRisk > 0.5)
                           _buildStatBadge(
                            context, 
                            "Risk", 
                            Icons.warning, 
                            Colors.orange
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Far Right: Arrow
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
