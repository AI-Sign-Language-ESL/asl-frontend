import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Logo
              Image.asset(
                'assets/logo.png',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 1),

              // TAFAHOM PNG with optional thin underline
              Image.asset(
                'assets/TAFAHOM TYPO.png',
                width: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              Text(
                local.signUpAs,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 25),
              ),
              const SizedBox(height: 20),

              // User Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_signup');
                  },
                  child: Text(
                    local.user,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Organization Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/org_signup');
                  },
                  child: Text(
                    local.organization,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(height: 250),

              // Footer Text
              Text(
                local.madeWithLove,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
