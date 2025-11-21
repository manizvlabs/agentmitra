import 'package:flutter/material.dart';
import '../../data/models/agent_model.dart';

class ProfileHeader extends StatelessWidget {
  final AgentProfile profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1a237e).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF1a237e).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: profile.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
          ),

          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Agent Code
                Text(
                  profile.userId, // TODO: Get actual name from user data
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Agent Code: ${profile.agentCode}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                // Company and Branch
                if (profile.companyName != null) ...[
                  Text(
                    profile.companyName!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],

                if (profile.branchName != null)
                  Text(
                    profile.branchName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                const SizedBox(height: 8),

                // Verification Status
                _buildVerificationStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(
      Icons.person,
      size: 40,
      color: Color(0xFF1a237e),
    );
  }

  Widget _buildVerificationStatus() {
    final isVerified = profile.verificationStatus == 'verified';
    final color = isVerified ? Colors.green : Colors.orange;
    final icon = isVerified ? Icons.verified : Icons.pending;
    final text = isVerified ? 'Verified' : 'Pending Verification';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
