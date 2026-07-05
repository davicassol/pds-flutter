import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  void handleResetPassword() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, digite seu e-mail.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? erro = await AuthService().resetPassword(
      email: emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link de recuperação enviado! Verifique sua caixa de entrada."),
          backgroundColor: AppColors.successMain,
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: AppColors.alertHigh,
        ),
      );
    }
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
                  //header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Recuperar Senha",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  //ícone cadeado
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.surfaceWhite,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  //card com forms
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
                          "Digite o e-mail associado à sua conta e enviaremos um link para você redefinir sua senha (Verifique sua Caixa de Spam).",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textBlack, fontSize: 15),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "seu.email@exemplo.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleResetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2))
                                : const Text(
                              "Enviar Link",
                              style: TextStyle(fontSize: 16, color: AppColors.textWhite, fontWeight: FontWeight.bold),
                            ),
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