import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store additional user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("User signed up successfully: ${user.email}");
        return true;
      } else {
        print("Failed to get user after sign-up");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during sign-up: ${e.code} - ${e.message}");
      // You can handle specific error codes here if needed
      return false;
    } catch (e) {
      print("Unexpected error during sign-up: $e");
      return false;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during sign-in: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error during sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error during sign-out: $e");
    }
  }
}