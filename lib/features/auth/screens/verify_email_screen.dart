import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isResending = false;

  void handleResendEmail() async {
    setState(() {
      isResending = true;
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link de verificação reenviado com sucesso!"),
          backgroundColor: AppColors.successMain,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao reenviar: $e"),
          backgroundColor: AppColors.alertHigh,
        ),
      );
    }

    setState(() {
      isResending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //icone de envelope
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_rounded,
                      color: AppColors.surfaceWhite,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Quase lá!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  //card com instruções
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: AppColors.shadowColor,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Enviamos um link de confirmação para o seu e-mail. Verifique sua Caixa de Entrada e Spam.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        //volta para o login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Ir para o Login",
                              style: TextStyle(fontSize: 16, color: AppColors.textWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        //reenviar email
                        isResending
                            ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                            : TextButton.icon(
                          onPressed: handleResendEmail,
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                          label: const Text(
                            "Não recebi o e-mail (Reenviar)",
                            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}