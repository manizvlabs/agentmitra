import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/agent_profile_viewmodel.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/performance_card.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  @override
  void initState() {
    super.initState();
    // TODO: Get agent ID from authentication context
    // const agentId = 'test-agent-id'; // Placeholder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProfileViewModel>().loadAgentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1a237e)),
            onPressed: () => _navigateToEditProfile(),
          ),
        ],
      ),
      body: Consumer<AgentProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.profile == null) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshProfile,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  ProfileHeader(profile: viewModel.profile!),

                  const SizedBox(height: 24),

                  // Profile Completion Status
                  if (!viewModel.isProfileComplete)
                    _buildCompletionCard(viewModel),

                  const SizedBox(height: 24),

                  // License Status
                  if (viewModel.isLicenseExpired || viewModel.isLicenseExpiringSoon)
                    _buildLicenseAlert(viewModel),

                  const SizedBox(height: 24),

                  // Profile Information Cards
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a237e),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ProfileInfoCard(
                    title: 'Professional Details',
                    icon: Icons.business,
                    children: [
                      _buildInfoRow('Agent Code', viewModel.profile!.agentCode),
                      if (viewModel.profile!.companyName != null)
                        _buildInfoRow('Company', viewModel.profile!.companyName!),
                      if (viewModel.profile!.branchName != null)
                        _buildInfoRow('Branch', viewModel.profile!.branchName!),
                      if (viewModel.profile!.designation != null)
                        _buildInfoRow('Designation', viewModel.profile!.designation!),
                      if (viewModel.profile!.joiningDate != null)
                        _buildInfoRow('Joining Date', _formatDate(viewModel.profile!.joiningDate!)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ProfileInfoCard(
                    title: 'License Information',
                    icon: Icons.verified_user,
                    children: [
                      if (viewModel.profile!.licenseNumber != null)
                        _buildInfoRow('License Number', viewModel.profile!.licenseNumber!),
                      if (viewModel.profile!.licenseIssuingAuthority != null)
                        _buildInfoRow('Issuing Authority', viewModel.profile!.licenseIssuingAuthority!),
                      if (viewModel.profile!.licenseExpiryDate != null)
                        _buildInfoRow(
                          'Expiry Date',
                          _formatDateString(viewModel.profile!.licenseExpiryDate!),
                          valueColor: _getLicenseColor(viewModel),
                        ),
                      _buildInfoRow('Status', viewModel.licenseStatus, valueColor: _getLicenseColor(viewModel)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Performance Card
                  if (viewModel.performance != null)
                    PerformanceCard(performance: viewModel.performance!),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a237e),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Edit Profile',
                          Icons.edit,
                          Colors.blue,
                          _navigateToEditProfile,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Change Password',
                          Icons.lock,
                          Colors.orange,
                          _navigateToChangePassword,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Upload Documents',
                          Icons.upload_file,
                          Colors.green,
                          _navigateToDocuments,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Settings',
                          Icons.settings,
                          Colors.purple,
                          _navigateToSettings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionCard(AgentProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Incomplete',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete your profile to unlock all features',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseAlert(AgentProfileViewModel viewModel) {
    final isExpired = viewModel.isLicenseExpired;
    final color = isExpired ? Colors.red : Colors.orange;
    final icon = isExpired ? Icons.error : Icons.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isExpired
                  ? 'Your license has expired. Please renew immediately.'
                  : 'Your license expires soon. Please renew to continue.',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(AgentProfileViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.refreshProfile,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getLicenseColor(AgentProfileViewModel viewModel) {
    if (viewModel.isLicenseExpired) return Colors.red;
    if (viewModel.isLicenseExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateString(String dateString) {
    try {
      // Try parsing various date formats
      DateTime? date;
      if (dateString.contains('-')) {
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        // Handle DD/MM/YYYY format
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }

      if (date != null) {
        return _formatDate(date);
      }
      return dateString; // Return original if parsing fails
    } catch (e) {
      return dateString; // Return original on error
    }
  }

  void _navigateToEditProfile() {
    // TODO: Navigate to edit profile screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => EditProfilePage(agentId: 'test-agent-id'),
    //   ),
    // );
  }

  void _navigateToChangePassword() {
    // TODO: Navigate to change password screen
  }

  void _navigateToDocuments() {
    // TODO: Navigate to documents screen
  }

  void _navigateToSettings() {
    // TODO: Navigate to settings screen
  }
}
