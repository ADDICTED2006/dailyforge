import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final range = provider.graphRangeDays;
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Activity Trend",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last $range Days",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            
            // Chart Container
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0) {
                             return Text(
                               value.toInt().toString(),
                               style: TextStyle(
                                 color: Colors.grey[600],
                                 fontSize: 10,
                               ),
                             );
                          }
                           return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
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
                      barWidth: 4,
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
            
            const SizedBox(height: 30),
            
            // Stats Summary
            _buildStatCard(
              context,
              'Total Activities', 
              '${provider.getDailyCompletionStats(365).values.reduce((a, b) => a + b)}', 
              Icons.check_circle_outline,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Current Streak', 
              '${provider.currentStreak} Days', 
              Icons.local_fire_department,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: Theme.of(context).shadowColor.withOpacity(0.1),
             blurRadius: 8,
             offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
