import 'package:flutter/material.dart';
import 'dart:async';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class DataImportProgressScreen extends StatefulWidget {
  final String importId;
  final String fileName;
  final int totalRecords;

  const DataImportProgressScreen({
    super.key,
    required this.importId,
    required this.fileName,
    required this.totalRecords,
  });

  @override
  State<DataImportProgressScreen> createState() => _DataImportProgressScreenState();
}

class _DataImportProgressScreenState extends State<DataImportProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  // Import progress data
  double _progress = 0.0;
  int _processedRecords = 0;
  int _successfulRecords = 0;
  int _failedRecords = 0;
  String _currentStatus = 'Initializing...';
  String _currentStep = 'Preparing data';
  List<String> _errors = [];
  List<Map<String, dynamic>> _recentActivity = [];
  Timer? _progressTimer;
  bool _isCompleted = false;
  bool _hasErrors = false;

  // Performance metrics
  int _recordsPerSecond = 0;
  Duration _estimatedTimeRemaining = Duration.zero;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start import simulation
    _startImportProcess();

    // Start progress updates
    _progressTimer = Timer.periodic(const Duration(seconds: 1), _updateProgress);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startImportProcess() {
    // Simulate import process
    _startTime = DateTime.now();
    _simulateImportProgress();
  }

  void _simulateImportProgress() async {
    const totalSteps = 5;
    final recordsPerStep = widget.totalRecords ~/ totalSteps;

    for (int step = 0; step < totalSteps; step++) {
      switch (step) {
        case 0:
          setState(() {
            _currentStep = 'Validating file format';
            _currentStatus = 'Checking Excel structure...';
          });
          break;
        case 1:
          setState(() {
            _currentStep = 'Reading data';
            _currentStatus = 'Parsing ${widget.totalRecords} records...';
          });
          break;
        case 2:
          setState(() {
            _currentStep = 'Validating data';
            _currentStatus = 'Checking data integrity...';
          });
          break;
        case 3:
          setState(() {
            _currentStep = 'Processing records';
            _currentStatus = 'Importing to database...';
          });
          break;
        case 4:
          setState(() {
            _currentStep = 'Finalizing';
            _currentStatus = 'Completing import...';
          });
          break;
      }

      // Simulate processing time for each step
      await Future.delayed(const Duration(seconds: 2));

      // Simulate some records being processed
      final stepRecords = step == totalSteps - 1 ? widget.totalRecords - _processedRecords : recordsPerStep;
      final successful = (stepRecords * (0.85 + (step * 0.02))).toInt(); // 85-95% success rate
      final failed = stepRecords - successful;

      setState(() {
        _processedRecords += stepRecords;
        _successfulRecords += successful;
        _failedRecords += failed;
        _progress = _processedRecords / widget.totalRecords;

        // Update progress animation
        _progressController.animateTo(_progress);

        // Add to recent activity
        _recentActivity.insert(0, {
          'timestamp': DateTime.now(),
          'action': 'Processed ${stepRecords} records',
          'details': '${successful} successful, ${failed} failed',
          'type': failed > 0 ? 'warning' : 'success',
        });

        // Keep only last 10 activities
        if (_recentActivity.length > 10) {
          _recentActivity = _recentActivity.sublist(0, 10);
        }

        // Simulate some errors
        if (failed > 0) {
          _errors.addAll(List.generate(
            failed > 3 ? 3 : failed,
            (index) => 'Validation error in row ${_processedRecords - stepRecords + index + 1}: Invalid email format'
          ));
          _hasErrors = true;
        }
      });
    }

    // Complete the import
    setState(() {
      _isCompleted = true;
      _currentStatus = 'Import completed successfully!';
      _progress = 1.0;
      _progressController.animateTo(1.0);
    });

    // Show completion dialog after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showCompletionDialog();
      }
    });
  }

  void _updateProgress(Timer timer) {
    if (_isCompleted) {
      timer.cancel();
      return;
    }

    final elapsed = DateTime.now().difference(_startTime);
    if (_processedRecords > 0) {
      _recordsPerSecond = (_processedRecords / elapsed.inSeconds).round();
      final remainingRecords = widget.totalRecords - _processedRecords;
      if (_recordsPerSecond > 0) {
        final remainingSeconds = remainingRecords ~/ _recordsPerSecond;
        _estimatedTimeRemaining = Duration(seconds: remainingSeconds);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _hasErrors ? Icons.warning : Icons.check_circle,
              color: _hasErrors ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(_hasErrors ? 'Import Completed with Errors' : 'Import Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${widget.fileName}'),
            const SizedBox(height: 8),
            Text('Total Records: ${widget.totalRecords}'),
            Text('Successful: $_successfulRecords'),
            Text('Failed: $_failedRecords'),
            if (_hasErrors) ...[
              const SizedBox(height: 16),
              const Text(
                'Some records failed to import. Check the error log for details.',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (_hasErrors) {
                _showErrorDetails();
              } else {
                Navigator.of(context).pop(); // Go back to dashboard
              }
            },
            child: Text(_hasErrors ? 'View Errors' : 'Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Import Errors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${_errors.length} errors found'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _errors.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errors[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Import Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isCompleted)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                // Show cancel confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Import?'),
                    content: const Text('Are you sure you want to cancel this import? Progress will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Continue'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel Import'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.file_present,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.fileName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Records: ${widget.totalRecords}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progress section
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isCompleted ? 1.0 : _pulseAnimation.value,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Circular progress indicator
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: 8,
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isCompleted
                                          ? (_hasErrors ? Colors.orange : Colors.green)
                                          : Theme.of(context).primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Progress text
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _isCompleted
                                    ? (_hasErrors ? Colors.orange : Colors.green)
                                    : Theme.of(context).primaryColor,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Status text
                            Text(
                              _currentStatus,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Current step
                            Text(
                              _currentStep,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Statistics cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Processed',
                      _processedRecords.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Successful',
                      _successfulRecords.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Failed',
                      _failedRecords.toString(),
                      Icons.error_outline,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Speed',
                      '$_recordsPerSecond/sec',
                      Icons.speed,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              if (_estimatedTimeRemaining != Duration.zero && !_isCompleted) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Estimated time remaining: ${_formatDuration(_estimatedTimeRemaining)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_recentActivity.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recentActivity.length,
                      itemBuilder: (context, index) {
                        final activity = _recentActivity[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                activity['type'] == 'success'
                                    ? Icons.check_circle
                                    : Icons.warning,
                                size: 16,
                                color: activity['type'] == 'success'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['action'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      activity['details'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
