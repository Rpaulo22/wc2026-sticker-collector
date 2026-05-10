import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wc_2026_sticker_collector/app_exception.dart';

class AccountViewModel extends ChangeNotifier {
  bool isLoading = false;

  Future<void> createUser(String email, String username, String password) async {
    // allows the app to display loading circle
    isLoading = true;
    notifyListeners();
    if (email.isEmpty) { // email must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique e-mail");
    }
    if (username.isEmpty) { // name must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique o seu username");
    }
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? newUser = credential.user;

      Map<String,dynamic> userMap = {
        'userName': username,
        'email': email,
        'createdAt': DateTime.now()
      };

      if (newUser != null) {
        // saving the data from auth to firestore database
        await FirebaseFirestore.instance
          .collection('Users')
          .doc(newUser.uid) // uses pre-established UID to bridge between auth and firestore
          .set(userMap);
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'user-disabled':
          throw AppException('Utilizador foi invalidado.');
        case 'phone-number-already-exists':
          throw AppException('Nº de telemóvel já utilizado.');
        case 'weak-password':
          throw AppException("A palavra-passe é demasiado fraca (mínimo 6 caracteres).");
        case 'email-already-in-use':
          throw AppException("Já existe uma conta com este e-mail.");
        case 'invalid-email':
          throw AppException("O formato do e-mail é inválido.");
        case 'invalid-argument':
          throw AppException('E-mail ou nº de telemóvel ou palavra-passe inválidas.');
        case 'network-request-failed':
          throw AppException('Erro de rede. Verifique o seu acesso à internet.');
        default: 
          throw AppException("Erro do Firebase: ${e.code} - ${e.message}");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw AppException("Erro a criar conta. Tente novamente mais tarde - $e");
    }
  }

  Future<void> loginUser(String email, String password) async {
    // allows the app to display loading circle
    isLoading = true;
    notifyListeners();

    // sanitize arguments
    if (email.isEmpty) { // email must be given
      throw AppException("Por favor indique e-mail");
    }
    if (password.isEmpty) { // password must be given
      throw AppException("Por favor indique palavra-passe");
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      // lets screen know that loading is done
      isLoading = false;
      notifyListeners();

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AppException('Nenhum utilizador registado com e-mail fornecido.');
        case 'wrong-password':
          throw AppException('Palavra-passe errada.');
        case 'user-disabled':
          throw AppException('Utilizador foi invalidado.');
        case 'invalid-argument':
          throw AppException('O formato do e-mail ou nº de telemóvel ou palavra-passe são inválidos.');
        case 'invalid-email':
          throw AppException("O formato do e-mail é inválido.");
        case 'invalid-password':
          throw AppException("O formato da palavra-passe é inválido.");
        case 'invalid-phone-number':
          throw AppException('O formato do nº de telemóvel é inválido.');
        case 'invalid-credential':
          throw AppException('Nenhum utilizador encontrado ou palavra-passe incorreta.');
        case 'network-request-failed':
          throw AppException('Erro de rede. Verifique o seu acesso à internet.');
        default: 
          throw AppException('Erro no login (Erro do Firebase): ${e.code} - ${e.message}');
      }
    } catch (e) {
      throw AppException('Erro no login. Tente novamente mais tarde.\n(${e.toString()})');
    }
  }

  // Signs out current user of the app
  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw AppException('Erro a terminar sessão. Por favor tente mais tarde - $e');
    }
  }

  Future<String> getUserName(String userID) async {
    var db = FirebaseFirestore.instance;

    try {
      final userInfo = await db
        .collection('Users')
        .doc(userID)
        .get();
      
      if (userInfo.exists && userInfo.data() != null) {
        final data = userInfo.data() as Map<String, dynamic>;
      
        return data['userName'] as String? ?? 'Utilizador';
      }
      return "Utilizador";

    } catch (e) { // could not retrieve user info
      return "Utilizador";
    }
  }
}