import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wc_2026_sticker_collector/view/create_account_screen.dart';
import 'package:wc_2026_sticker_collector/view/home_page_screen.dart';
import 'package:wc_2026_sticker_collector/view/splash_screen.dart';
import 'package:wc_2026_sticker_collector/viewmodel/account_view_model.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.title});

  final String title;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool obscurePassword = true;
  final accountViewModel = AccountViewModel();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.widthOf(context)/10;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListenableBuilder(
        listenable: accountViewModel, 
        builder: (BuildContext context, Widget? child) {
           return Stack(
            children: [
              IgnorePointer(
                ignoring: accountViewModel.isLoading,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/2026_FIFA_World_Cup_emblem.svg',
                            semanticsLabel: 'WC 2026 Logo',
                            fit: BoxFit.contain
                          ),
                          SizedBox(height:10.0),
                          Text("Entra na tua conta", textScaler: TextScaler.linear(2)),
                          SizedBox(height:10.0),
                          TextField(
                            controller: emailController,
                            obscureText: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'E-mail',
                            ),
                          ),
                          SizedBox(height:10.0),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Palavra-passe',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility
                                ),
                                onPressed: () => setState(() {
                                  obscurePassword = !obscurePassword;
                                })
                              )
                            ),
                          ),
                          SizedBox(height:15.0),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await accountViewModel.loginUser(emailController.text, passwordController.text);

                                if (!context.mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SplashScreen(title: widget.title),
                                  )
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString()))
                                );
                              }
                            },
                            child: Text("Entrar", textScaler: TextScaler.linear(1.8)),
                          ),
                          SizedBox(height:10.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccountScreen(title: widget.title),
                                ),
                              );
                            },
                            child: Text("Criar conta")
                          )
                        ]
                      )
                    )
                  )
                )
              ),
              if (accountViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5), 
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )
                  )
                )
            ]
          );
        }
      )
    );
  }
}