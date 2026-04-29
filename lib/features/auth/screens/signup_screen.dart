import 'package:flutter/material.dart';
import '../services/auth_service.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Variável para controlar o carregamento
  bool isLoading = false;

  // Transformamos a função em assíncrona
  void handleSignUp() async {
    // Verifica se tem algum campo vazio
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos")),
      );
      return;
    }

    // Verifica as senhas
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    //  Ativa o carregamento na tela
    setState(() {
      isLoading = true;
    });

    //  Chama o serviço de autenticação
    String? erro = await AuthService().signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    //  Verifica se a tela ainda está aberta antes de atualizar (boa prática)
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    //  Trata o resultado
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

  InputDecoration buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
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
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // LOGO
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Join FloodWatch today",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              //CARD
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
                child: SingleChildScrollView( // Ajuda em telas menores
                  child: Column(
                    children: [
                      //NAME
                      TextField(
                        controller: nameController,
                        decoration: buildInputDecoration("Full Name", "John Doe"),
                      ),
                      const SizedBox(height: 16),

                      //EMAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress, // Mostra o @ no teclado
                        decoration: buildInputDecoration("Email", "your.email@example.com"),
                      ),
                      const SizedBox(height: 16),

                      //PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: buildInputDecoration("Password", "••••••••"),
                      ),
                      const SizedBox(height: 16),

                      //CONFIRM PASSWORD
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: buildInputDecoration("Confirm Password", "••••••••"),
                      ),

                      const SizedBox(height: 24),

                      //BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          //Se estiver carregando, desativa o botão
                          onPressed: isLoading ? null : handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          //Mostra o spinner se estiver carregando, ou o texto se não
                          child: isLoading
                              ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                              : const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              //FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}