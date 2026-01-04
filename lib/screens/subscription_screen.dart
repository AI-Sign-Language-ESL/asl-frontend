import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:tafahom_english_light/core/constants/colors.dart';
import 'package:tafahom_english_light/services/billing_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final BillingService _billingService = BillingService();

  bool _isLoading = true;
  List<dynamic> _plans = [];
  Map<String, dynamic>? _mySubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final plans = await _billingService.getPlans();
      final sub = await _billingService.getMySubscription();

      setState(() {
        _plans = plans;
        _mySubscription = sub;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Subscription load error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _subscribe(int planId) async {
    try {
      await _billingService.subscribe(planId);
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscribed successfully")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscription failed")),
      );
    }
  }

  Future<void> _cancelSubscription() async {
    try {
      await _billingService.cancelSubscription();
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscription cancelled")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cancel failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(local.subscription),
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_mySubscription != null) _buildMySubscription(local),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _plans.length,
                itemBuilder: (_, index) {
                  final plan = _plans[index];
                  return _buildPlanCard(
                    planId: plan["id"],
                    price: plan["price"].toString(),
                    duration: plan["duration"],
                    features: List<String>.from(plan["features"]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySubscription(AppLocalizations local) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.lightGray,
      child: ListTile(
        title: Text(
          local.subscription,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Expires: ${_mySubscription!['expires_at']}",
        ),
        trailing: TextButton(
          onPressed: _cancelSubscription,
          child: Text(
            local.cancel,
            style: const TextStyle(color: AppColors.accentRed),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required int planId,
    required String price,
    required String duration,
    required List<String> features,
  }) {
    final local = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "E£ $price",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            Text(duration, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ...features.map(
              (f) => Row(
                children: [
                  const Icon(Icons.check, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(f),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _subscribe(planId),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(local.subscribeNow),
            ),
          ],
        ),
      ),
    );
  }
}
