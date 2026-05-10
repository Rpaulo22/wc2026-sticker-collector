import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wc_2026_sticker_collector/view/home_page_screen.dart';
import 'package:wc_2026_sticker_collector/viewmodel/account_view_model.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.title});

  final String title;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool obscurePassword = true;
  final accountViewModel = AccountViewModel();

  late TextEditingController emailController;
  late TextEditingController userNameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    userNameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    userNameController.dispose();
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
                  child: Padding(
                    padding: EdgeInsetsGeometry.directional(start: padding, end: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          'assets/images/2026_FIFA_World_Cup_emblem.svg',
                          semanticsLabel: 'WC 2026 Logo',
                          fit: BoxFit.contain
                        ),
                        Text("Cria a tua conta", textScaler: TextScaler.linear(2)),
                        TextField(
                          controller: emailController,
                          obscureText: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'E-mail',
                          ),
                        ),
                        TextField(
                          controller: userNameController,
                          obscureText: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                          ),
                        ),
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
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await accountViewModel.createUser(emailController.text, userNameController.text, passwordController.text);

                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePageScreen(title: widget.title),
                                )
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()))
                              );
                            }
                          }, 
                          child: Text("Criar conta")
                        )
                      ]
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