import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Variável para controlar a tela de carregamento e evitar duplo clique
  bool isLoading = false;

  void handleLogin() async {
    // Evita que o usuário tente logar com os campos vazios
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha o e-mail e a senha.")),
      );
      return;
    }

    // Liga a animação de carregamento
    setState(() {
      isLoading = true;
    });

    // Pede para o serviço validar as credenciais lá no Google
    String? erro = await AuthService().signIn(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    //  Desliga o carregamento
    setState(() {
      isLoading = false;
    });

    if (erro == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
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
            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // LOGO + HEADER
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "FloodWatch",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Stay Safe, Stay Informed",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Email",
                          hint: "your.email@example.com",
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Password",
                          hint: "••••••••",
                          controller: passwordController,
                          isPassword: true,
                        ),

                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: implementar recuperação de senha
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // BOTÃO INTELIGENTE
                        // Se isLoading for true, mostra a bolinha girando. Se false, mostra o seu botão original.
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.blue)
                            : SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: "Login",
                            onPressed: handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SIGN UP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🌧ILUSTRAÇÃO
                  const Icon(
                    Icons.cloud,
                    size: 100,
                    color: Colors.blueAccent,
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