// lib/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(local.subscription),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              local.choosePlan,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildPlanCard(
              context,
              "E£ 100",
              local.for1Month,
              [
                local.plus100Coin,
                local.textToSign,
                local.speech,
              ],
              false,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              "E£ 240",
              local.for3Months,
              [
                local.plus150Coin,
                local.textToSign,
                local.meetings,
              ],
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String price,
    String duration,
    List<String> features,
    bool isPopular,
  ) {
    final local = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isPopular
                ? Border.all(color: AppColors.primaryBlue, width: 3)
                : Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                duration,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      Text(f),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  local.subscribeNow,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: 10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                local.popular,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
