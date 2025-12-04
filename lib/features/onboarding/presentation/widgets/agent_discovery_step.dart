import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../../data/models/onboarding_step.dart';

/// Agent Discovery Step Widget
class AgentDiscoveryStep extends StatefulWidget {
  const AgentDiscoveryStep({super.key});

  @override
  State<AgentDiscoveryStep> createState() => _AgentDiscoveryStepState();
}

class _AgentDiscoveryStepState extends State<AgentDiscoveryStep> {
  final _formKey = GlobalKey<FormState>();
  final _agentCodeController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OnboardingViewModel>();
      final existingData = viewModel.agentDiscoveryData;
      if (existingData?.agentCode != null) {
        _agentCodeController.text = existingData!.agentCode!;
        _searchAgent(existingData.agentCode!);
      }
    });
  }

  @override
  void dispose() {
    _agentCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchAgent(String agentCode) async {
    if (agentCode.trim().isEmpty) return;

    LoggerService().info('Searching for agent with code: $agentCode', tag: 'AgentDiscovery');

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Make real API call to search for agent
      final response = await ApiService.get('/api/v1/agents/search', queryParameters: {'code': agentCode});

      if (response['success'] == true && response['data'] != null) {
        final agentData = response['data'];
        final realAgentData = AgentDiscoveryData(
          agentCode: agentCode,
          agentName: agentData['name'] ?? 'Unknown Agent',
          agentPhone: agentData['phone'] ?? '',
          agentEmail: agentData['email'] ?? '',
          branchName: agentData['branch_name'] ?? '',
          branchAddress: agentData['branch_address'] ?? '',
        );

        final viewModel = context.read<OnboardingViewModel>();
        await viewModel.updateAgentDiscoveryData(realAgentData);

        LoggerService().info('Agent found successfully: ${agentData['name']}', tag: 'AgentDiscovery');

        setState(() {
          _errorMessage = null;
        });
      } else {
        LoggerService().warning('Agent not found for code: $agentCode', tag: 'AgentDiscovery');
        setState(() {
          _errorMessage = response['message'] ?? 'Agent not found. Please check the agent code and try again.';
        });
      }
    } catch (e) {
      LoggerService().error('Agent search failed: $e', tag: 'AgentDiscovery');
      setState(() {
        _errorMessage = 'Failed to search agent. Please check your internet connection and try again.';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        final agentData = viewModel.agentDiscoveryData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Find Your Insurance Agent',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Enter your agent\'s code to connect with them and start your insurance journey.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Agent Code Input
                TextFormField(
                  controller: _agentCodeController,
                  decoration: InputDecoration(
                    labelText: 'Agent Code',
                    hintText: 'Enter 6-digit agent code',
                    prefixIcon: const Icon(Icons.person_search),
                    suffixIcon: IconButton(
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      onPressed: _isSearching
                          ? null
                          : () => _searchAgent(_agentCodeController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter agent code';
                    }
                    if (value!.length < 6) {
                      return 'Agent code must be 6 digits';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                  onFieldSubmitted: (value) {
                    if (value.length == 6) {
                      _searchAgent(value);
                    }
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Agent Information Card (shown when agent is found)
                if (agentData != null && _errorMessage == null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Agent Found!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildInfoRow('Agent Name', agentData.agentName ?? 'N/A'),
                        _buildInfoRow('Agent Code', agentData.agentCode ?? 'N/A'),
                        _buildInfoRow('Phone', agentData.agentPhone ?? 'N/A'),
                        _buildInfoRow('Email', agentData.agentEmail ?? 'N/A'),
                        _buildInfoRow('Branch', agentData.branchName ?? 'N/A'),

                        if (agentData.branchAddress != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Address: ${agentData.branchAddress}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // Alternative Options
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Don\'t have an agent code?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contact your nearest LIC branch or call our helpline at 1800-123-4567 to get your agent\'s code.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        icon: Icons.verified_user,
                        title: 'Verified Agents',
                        description: 'All LIC agents are verified and licensed',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        icon: Icons.support_agent,
                        title: '24/7 Support',
                        description: 'Get help anytime with our support team',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
