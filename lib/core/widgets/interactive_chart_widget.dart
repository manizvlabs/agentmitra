import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

/// Interactive Chart Framework
/// Provides touch interactions, drill-down capabilities, and export functionality

enum ChartType { line, bar, pie, area, scatter }

enum ExportFormat { png, pdf, csv }

class InteractiveChartWidget extends StatefulWidget {
  final ChartType chartType;
  final List<ChartDataPoint> data;
  final String title;
  final String? subtitle;
  final Map<String, dynamic>? metadata;
  final Function(ChartDataPoint)? onDataPointTap;
  final Function(ChartDataPoint)? onDataPointDoubleTap;
  final Function(ChartDataPoint)? onDataPointLongPress;
  final Function(String)? onDrillDown;
  final bool enableExport;
  final bool enableTimeFilter;
  final Duration? timeRange;
  final List<String> availableTimeRanges;

  const InteractiveChartWidget({
    Key? key,
    required this.chartType,
    required this.data,
    required this.title,
    this.subtitle,
    this.metadata,
    this.onDataPointTap,
    this.onDataPointDoubleTap,
    this.onDataPointLongPress,
    this.onDrillDown,
    this.enableExport = true,
    this.enableTimeFilter = true,
    this.timeRange,
    this.availableTimeRanges = const ['1H', '24H', '7D', '30D', '90D', '1Y'],
  }) : super(key: key);

  @override
  State<InteractiveChartWidget> createState() => _InteractiveChartWidgetState();
}

class _InteractiveChartWidgetState extends State<InteractiveChartWidget> {
  final GlobalKey _chartKey = GlobalKey();
  String _selectedTimeRange = '30D';
  bool _isExporting = false;
  ChartDataPoint? _selectedDataPoint;
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.availableTimeRanges.contains('30D') ? '30D' : widget.availableTimeRanges.first;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and controls
            _buildHeader(),

            const SizedBox(height: 16),

            // Chart area
            Expanded(
              child: RepaintBoundary(
                key: _chartKey,
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  child: _buildChart(),
                ),
              ),
            ),

            // Legend and controls
            if (widget.data.isNotEmpty) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Time range selector
        if (widget.enableTimeFilter && widget.availableTimeRanges.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items: widget.availableTimeRanges.map((range) {
                return DropdownMenuItem(
                  value: range,
                  child: Text(range, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTimeRange = value);
                  // Trigger time range change callback if needed
                }
              },
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            ),
          ),

        // Export menu
        if (widget.enableExport)
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.more_vert),
            onPressed: _showExportMenu,
          ),
      ],
    );
  }

  Widget _buildChart() {
    switch (widget.chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.area:
        return _buildAreaChart();
      case ChartType.scatter:
        return _buildScatterChart();
    }
  }

  Widget _buildLineChart() {
    final spots = widget.data.asMap().entries.map((entry) {
      final point = entry.value;
      return FlSpot(entry.key.toDouble(), point.value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: _selectedDataPoint?.id == widget.data[index].id ? 6 : 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  return Text(
                    widget.data[value.toInt()].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dataPoint = widget.data[spot.x.toInt()];
                return LineTooltipItem(
                  '${dataPoint.label}\n${dataPoint.value.toStringAsFixed(2)}',
                  TextStyle(color: Theme.of(context).primaryColor),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapDownEvent && response != null && response.lineBarSpots != null) {
              final spot = response.lineBarSpots!.first;
              final dataPoint = widget.data[spot.x.toInt()];
              _handleDataPointInteraction(dataPoint);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final barGroups = widget.data.asMap().entries.map((entry) {
      final point = entry.value;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: point.value,
            color: _selectedDataPoint?.id == point.id
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Theme.of(context).primaryColor,
            width: 16,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.data.length) {
                  return Text(
                    widget.data[index].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dataPoint = widget.data[groupIndex];
              return BarTooltipItem(
                '${dataPoint.label}\n${dataPoint.value.toStringAsFixed(2)}',
                TextStyle(color: Theme.of(context).primaryColor),
              );
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapDownEvent && response != null && response.spot != null) {
              final dataPoint = widget.data[response.spot!.touchedBarGroupIndex];
              _handleDataPointInteraction(dataPoint);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = widget.data.map((point) {
      final isSelected = _selectedDataPoint?.id == point.id;
      return PieChartSectionData(
        value: point.value,
        title: '${point.value.toStringAsFixed(1)}%',
              color: _getColorForIndex(widget.data.indexOf(point)).withValues(alpha: 1.0),
            radius: isSelected ? 80 : 60,
        titleStyle: TextStyle(
          fontSize: isSelected ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (event is FlTapDownEvent && response != null && response.touchedSection != null) {
              final dataPoint = widget.data[response.touchedSection!.touchedSectionIndex];
              _handleDataPointInteraction(dataPoint);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAreaChart() {
    final spots = widget.data.asMap().entries.map((entry) {
      final point = entry.value;
      return FlSpot(entry.key.toDouble(), point.value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 2,
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  return Text(
                    widget.data[value.toInt()].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildScatterChart() {
    final spots = widget.data.asMap().entries.map((entry) {
      final point = entry.value;
      return FlSpot(entry.key.toDouble(), point.value);
    }).toList();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots.map((spot) {
          final dataPoint = widget.data[spot.x.toInt()];
          final isSelected = _selectedDataPoint?.id == dataPoint.id;
          return ScatterSpot(
            spot.x,
            spot.y,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withValues(alpha: 0.7),
            radius: isSelected ? 8 : 6,
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  return Text(
                    widget.data[value.toInt()].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dataPoint = widget.data[spot.spotIndex];
                return ScatterTooltipItem(
                  '${dataPoint.label}\n${dataPoint.value.toStringAsFixed(2)}',
                  textStyle: TextStyle(color: Theme.of(context).primaryColor),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapDownEvent && response != null && response.touchedSpots != null && response.touchedSpots!.isNotEmpty) {
              final dataPoint = widget.data[response.touchedSpots!.first.spotIndex];
              _handleDataPointInteraction(dataPoint);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Legend
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: widget.data.take(5).map((point) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _getColorForIndex(widget.data.indexOf(point)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      point.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Selected data point info
          if (_selectedDataPoint != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedDataPoint!.label}: ${_selectedDataPoint!.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _touchPosition = details.localPosition;
    });
  }

  void _handleDataPointInteraction(ChartDataPoint dataPoint) {
    setState(() {
      _selectedDataPoint = dataPoint;
    });

    // Call the appropriate callback
    widget.onDataPointTap?.call(dataPoint);

    // Show drill-down options if available
    if (widget.onDrillDown != null) {
      _showDrillDownMenu(dataPoint);
    }
  }

  void _showDrillDownMenu(ChartDataPoint dataPoint) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drill Down: ${dataPoint.label}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('View Trend'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onDrillDown?.call('trend:${dataPoint.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.details),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onDrillDown?.call('details:${dataPoint.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare),
              title: const Text('Compare'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onDrillDown?.call('compare:${dataPoint.id}');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as PNG'),
              onTap: () {
                Navigator.of(context).pop();
                _exportChart(ExportFormat.png);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _exportChart(ExportFormat.pdf);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.of(context).pop();
                _exportChart(ExportFormat.csv);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportChart(ExportFormat format) async {
    setState(() => _isExporting = true);

    try {
      switch (format) {
        case ExportFormat.png:
          await _exportAsPng();
          break;
        case ExportFormat.pdf:
          await _exportAsPdf();
          break;
        case ExportFormat.csv:
          await _exportAsCsv();
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chart exported as ${format.name.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAsPng() async {
    final boundary = _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${widget.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(file.path)], text: '${widget.title} Chart');
  }

  Future<void> _exportAsPdf() async {
    final pdf = pw.Document();

    // Add chart title
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(widget.title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (widget.subtitle != null)
                pw.Text(widget.subtitle!, style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              // Note: In a real implementation, you'd render the chart as an image
              pw.Text('Chart data would be rendered here'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                data: [
                  ['Label', 'Value'],
                  ...widget.data.map((point) => [point.label, point.value.toString()]),
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${widget.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: '${widget.title} Report');
  }

  Future<void> _exportAsCsv() async {
    final csvData = [
      ['Label', 'Value', 'Timestamp'],
      ...widget.data.map((point) => [
        point.label,
        point.value.toString(),
        DateFormat('yyyy-MM-dd HH:mm:ss').format(point.timestamp ?? DateTime.now()),
      ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${widget.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(file.path)], text: '${widget.title} Data');
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}

/// Data model for chart points
class ChartDataPoint {
  final String id;
  final String label;
  final double value;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.id,
    required this.label,
    required this.value,
    this.timestamp,
    this.metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
