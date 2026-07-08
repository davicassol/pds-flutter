import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha o e-mail e a senha.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? erro = await AuthService().signIn(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (erro == null) {
      Navigator.pushReplacementNamed(context, '/home');
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
        padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  //LOGO + HEADER
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: AppColors.surfaceWhite,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppColors.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Esteja Seguro, Esteja Informado",
                        style: TextStyle(color: AppColors.textGreyMedium),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  //CARD
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
                        CustomTextField(
                          label: "Email",
                          hint: "seu.email@exemplo.com",
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Senha",
                          hint: "••••••••",
                          controller: passwordController,
                          isPassword: true,
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: const Text(
                              "Esqueceu sua senha?",
                              style: TextStyle(color: AppColors.primaryBlue),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        isLoading
                            ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                            : SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: "Entrar",
                            onPressed: handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  //SIGN UP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Não possui uma conta? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Criar Conta",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Icon(
                    Icons.cloud,
                    size: 100,
                    color: AppColors.primaryBlue,
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