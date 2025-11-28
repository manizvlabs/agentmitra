import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/constants/api_constants.dart';

/// Enhanced Agent Discovery Page with debounced search, filters, ratings, and agent details
class EnhancedAgentDiscoveryPage extends StatefulWidget {
  const EnhancedAgentDiscoveryPage({super.key});

  @override
  State<EnhancedAgentDiscoveryPage> createState() => _EnhancedAgentDiscoveryPageState();
}

class _EnhancedAgentDiscoveryPageState extends State<EnhancedAgentDiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  List<Map<String, dynamic>> _agents = [];
  List<Map<String, dynamic>> _filteredAgents = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _selectedRegion;
  String? _selectedSpecialization;
  String? _selectedRating;
  String? _sortBy = 'rating'; // rating, name, experience
  
  final List<String> _regions = ['All', 'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Hyderabad', 'Pune'];
  final List<String> _specializations = ['All', 'Life Insurance', 'Health Insurance', 'General Insurance', 'Term Plans', 'ULIP'];
  final List<String> _ratings = ['All', '4+ Stars', '3+ Stars', '2+ Stars'];
  final List<String> _sortOptions = ['Rating', 'Name', 'Experience'];

  @override
  void initState() {
    super.initState();
    _loadAgents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final queryParams = <String, String>{
        'limit': '50',
        'status': 'active',
        'verification_status': 'verified',
      };
      
      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text;
      }
      
      if (_selectedRegion != null && _selectedRegion != 'All') {
        queryParams['territory'] = _selectedRegion!;
      }

      final response = await ApiService.get(
        ApiConstants.agents,
        queryParameters: queryParams,
      );

      // Backend returns a list directly or wrapped in data
      // ApiService.get() always returns Map<String, dynamic>
      List<dynamic> agentsList = [];
      if (response['data'] is List) {
        agentsList = response['data'] as List<dynamic>;
      } else if (response['agents'] is List) {
        agentsList = response['agents'] as List<dynamic>;
      } else if (response is List) {
        // Fallback: if response is somehow a list (shouldn't happen with ApiService)
        agentsList = response as List<dynamic>;
      }

      setState(() {
        _agents = agentsList.map((agent) {
          // Map backend response to frontend format
          final userInfo = agent['user_info'] as Map<String, dynamic>?;
          return {
            'agent_id': agent['agent_id']?.toString(),
            'name': userInfo?['full_name'] ?? agent['business_name'] ?? 'Unknown',
            'agent_code': agent['agent_code'],
            'rating': (agent['customer_satisfaction_score'] ?? 0.0) as num,
            'reviews_count': 0, // Not available in backend
            'experience_years': agent['experience_years'] ?? 0,
            'specialization': (agent['specializations'] as List<dynamic>?)?.first ?? 'General',
            'region': agent['territory'] ?? agent['operating_regions']?.first ?? 'Unknown',
            'verified': agent['verification_status'] == 'verified',
            'policies_sold': agent['total_policies_sold'] ?? 0,
            'image_url': null,
          };
        }).toList();
        _applyFilters();
      });
    } catch (e) {
      LoggerService().error('Failed to load agents: $e');
      setState(() {
        _error = 'Failed to load agents. Please try again.';
        _agents = [];
        _applyFilters();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_agents);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((agent) {
        return agent['name']?.toString().toLowerCase().contains(query) == true ||
               agent['agent_code']?.toString().toLowerCase().contains(query) == true ||
               agent['specialization']?.toString().toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply region filter
    if (_selectedRegion != null && _selectedRegion != 'All') {
      filtered = filtered.where((agent) => agent['region'] == _selectedRegion).toList();
    }

    // Apply specialization filter
    if (_selectedSpecialization != null && _selectedSpecialization != 'All') {
      filtered = filtered.where((agent) => agent['specialization'] == _selectedSpecialization).toList();
    }

    // Apply rating filter
    if (_selectedRating != null && _selectedRating != 'All') {
      final minRating = double.parse(_selectedRating!.replaceAll('+ Stars', '').replaceAll(' Stars', ''));
      filtered = filtered.where((agent) {
        final rating = (agent['rating'] as num?)?.toDouble() ?? 0.0;
        return rating >= minRating;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          final aRating = (a['rating'] as num?)?.toDouble() ?? 0.0;
          final bRating = (b['rating'] as num?)?.toDouble() ?? 0.0;
          return bRating.compareTo(aRating);
        case 'name':
          return (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
        case 'experience':
          final aExp = (a['experience_years'] as num?)?.toInt() ?? 0;
          final bExp = (b['experience_years'] as num?)?.toInt() ?? 0;
          return bExp.compareTo(aExp);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredAgents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Find Your Insurance Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, code, or specialization...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Filter Chips
          if (_selectedRegion != null || _selectedSpecialization != null || _selectedRating != null)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedRegion != null && _selectedRegion != 'All')
                    _buildFilterChip('Region: $_selectedRegion', () {
                      setState(() => _selectedRegion = null);
                      _applyFilters();
                    }),
                  if (_selectedSpecialization != null && _selectedSpecialization != 'All')
                    _buildFilterChip('Type: $_selectedSpecialization', () {
                      setState(() => _selectedSpecialization = null);
                      _applyFilters();
                    }),
                  if (_selectedRating != null && _selectedRating != 'All')
                    _buildFilterChip('Rating: $_selectedRating', () {
                      setState(() => _selectedRating = null);
                      _applyFilters();
                    }),
                ],
              ),
            ),

          // Sort & Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredAgents.length} agents found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option.toLowerCase(),
                      child: Text(
                        'Sort: $option',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _sortBy = value);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),

          // Agents List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _filteredAgents.isEmpty
                    ? _buildErrorView()
                    : _filteredAgents.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadAgents,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredAgents.length,
                              itemBuilder: (context, index) {
                                return _buildAgentCard(_filteredAgents[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final rating = (agent['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewsCount = agent['reviews_count'] ?? 0;
    final experience = agent['experience_years'] ?? 0;
    final verified = agent['verified'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAgentDetails(agent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Agent Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: agent['image_url'] != null
                    ? ClipOval(
                        child: Image.network(
                          agent['image_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildAvatarIcon(agent['name']),
                        ),
                      )
                    : _buildAvatarIcon(agent['name']),
              ),
              const SizedBox(width: 16),
              // Agent Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            agent['name'] ?? 'Unknown Agent',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (verified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.white, size: 12),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${agent['agent_code'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating & Reviews
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : (index < rating ? Icons.star_half : Icons.star_border),
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($reviewsCount reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Specialization & Experience
                    Row(
                      children: [
                        Icon(Icons.work, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          agent['specialization'] ?? 'Insurance Agent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '$experience years exp.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          agent['region'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Select Button
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () => _showAgentDetails(agent),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarIcon(String? name) {
    final initial = name?.isNotEmpty == true ? name![0].toUpperCase() : 'A';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No agents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedRegion = null;
                _selectedSpecialization = null;
                _selectedRating = null;
              });
              _applyFilters();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Failed to load agents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAgents,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Agents'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Region Filter
                const Text(
                  'Region',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _regions.map((region) {
                    final isSelected = _selectedRegion == region;
                    return FilterChip(
                      label: Text(region),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedRegion = selected ? region : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Specialization Filter
                const Text(
                  'Specialization',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _specializations.map((spec) {
                    final isSelected = _selectedSpecialization == spec;
                    return FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedSpecialization = selected ? spec : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Rating Filter
                const Text(
                  'Minimum Rating',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _ratings.map((rating) {
                    final isSelected = _selectedRating == rating;
                    return FilterChip(
                      label: Text(rating),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedRating = selected ? rating : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedRegion = null;
                  _selectedSpecialization = null;
                  _selectedRating = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentDetails(Map<String, dynamic> agent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Agent Details',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agent Header
                      _buildAgentDetailsHeader(agent),
                      const SizedBox(height: 24),
                      // Rating & Reviews Section
                      _buildRatingSection(agent),
                      const SizedBox(height: 24),
                      // Experience & Stats
                      _buildStatsSection(agent),
                      const SizedBox(height: 24),
                      // Reviews List
                      _buildReviewsSection(agent),
                      const SizedBox(height: 24),
                      // Action Buttons
                      _buildActionButtons(agent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentDetailsHeader(Map<String, dynamic> agent) {
    final rating = (agent['rating'] as num?)?.toDouble() ?? 0.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: agent['image_url'] != null
              ? ClipOval(
                  child: Image.network(
                    agent['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildAvatarIcon(agent['name']),
                  ),
                )
              : _buildAvatarIcon(agent['name']),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent['name'] ?? 'Unknown Agent',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agent Code: ${agent['agent_code'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : (index < rating ? Icons.star_half : Icons.star_border),
                      size: 20,
                      color: Colors.amber,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(Map<String, dynamic> agent) {
    final rating = (agent['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewsCount = agent['reviews_count'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating & Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor()
                              ? Icons.star
                              : (index < rating ? Icons.star_half : Icons.star_border),
                          size: 24,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on $reviewsCount reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> agent) {
    final experience = agent['experience_years'] ?? 0;
    final policiesSold = agent['policies_sold'] ?? 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Experience',
            '$experience years',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Policies Sold',
            policiesSold.toString(),
            Icons.policy,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> agent) {
    // Mock reviews
    final reviews = [
      {
        'reviewer': 'Customer A',
        'rating': 5,
        'comment': 'Excellent service! Very helpful and professional.',
        'date': '2 weeks ago',
      },
      {
        'reviewer': 'Customer B',
        'rating': 4,
        'comment': 'Good agent, explains everything clearly.',
        'date': '1 month ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review['reviewer'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review['date'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> agent) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to agent selection/onboarding
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected agent: ${agent['name']}')),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Select This Agent'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Call agent
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Message agent
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

