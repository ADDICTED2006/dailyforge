import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeProgressGraph extends StatelessWidget {
  const HomeProgressGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final range = provider.graphRangeDays;
    // We typically want a smaller range or cleaner view for home screen, 
    // but using the provider setting for consistency for now.
    
    final stats = provider.getDailyCompletionStats(range);
    
    // Sort dates for the graph
    final sortedDates = stats.keys.toList()..sort();
    
    // Prepare spots
    List<FlSpot> spots = [];
    double maxY = 0;
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final count = stats[date]!.toDouble();
      if (count > maxY) maxY = count;
      spots.add(FlSpot(i.toDouble(), count));
    }
    
    // Ensure accurate scaling
    maxY = (maxY < 5) ? 5 : maxY + 1;

    // Determine interval for X-axis labels to avoid overlapping
    int interval = 1;
    if (sortedDates.length > 20) {
      interval = 5;
    } else if (sortedDates.length > 10) {
      interval = 2;
    }

    return Container(
      height: 250, // Slightly smaller than statistics screen
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: Colors.black), // Requested "box" look in mockup
        boxShadow: const [
           // Mockup shows simpler sharp look, but keeping shadow soft for consistency or removing if user wants strict wireframe
           BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Progress Over Time",
             style: TextStyle(
               fontSize: 16, 
               fontWeight: FontWeight.bold,
             ),
             textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: false, // Cleaner look for home screen
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                           // Show date label based on dynamic interval
                           if (index % interval == 0) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(
                                 DateFormat('MM/dd').format(sortedDates[index]),
                                 style: TextStyle(
                                   color: Colors.grey[600],
                                   fontSize: 10,
                                 ),
                               ),
                             );
                           }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis for cleaner look
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: sortedDates.length.toDouble() - 1,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
