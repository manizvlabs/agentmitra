import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mocks/mock_claims_viewmodel_simple.dart';
import '../widgets/claim_form.dart';
import '../widgets/claims_history.dart';

class ClaimsPage extends StatefulWidget {
  final String? policyId;

  const ClaimsPage({
    super.key,
    this.policyId,
  });

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If policy ID is provided, switch to file claim tab
    if (widget.policyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.animateTo(1);
        context.read<MockClaimsViewModel>().setPolicyId(widget.policyId!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Claims',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1a237e),
          labelColor: const Color(0xFF1a237e),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'My Claims'),
            Tab(text: 'File Claim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Claims History Tab
          Consumer<MockClaimsViewModel>(
            builder: (context, viewModel, child) {
              if (widget.policyId != null && viewModel.claims.isEmpty) {
                // Load claims for the specific policy
                viewModel.loadClaims(widget.policyId!);
              }

              return ClaimsHistory(
                claims: viewModel.claims,
                isLoading: viewModel.isLoading,
                error: viewModel.error,
                onRefresh: viewModel.refreshClaims,
              );
            },
          ),

          // File Claim Tab
          const ClaimForm(),
        ],
      ),
    );
  }
}
