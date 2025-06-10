import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google - BYPASS ERROR VERSION
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('🚫 Google sign-in aborted by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint("✅ Access Token: ${googleAuth.accessToken}");
      debugPrint("✅ ID Token: ${googleAuth.idToken}");

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        debugPrint("🎉 Firebase Auth Success!");
        debugPrint("👤 Name: ${user.displayName ?? 'No name'}");
        debugPrint("📧 Email: ${user.email ?? 'No email'}");
        debugPrint("🆔 UID: ${user.uid}");
        debugPrint("📱 Phone: ${user.phoneNumber ?? 'No phone'}");
        debugPrint("📸 Photo: ${user.photoURL ?? 'No photo'}");
        
        return userCredential;
      } else {
        debugPrint("🚨 Firebase user is null");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Google Sign-In Error: $e");
      
      // BYPASS: Check if user is actually signed in despite the error
      await Future.delayed(Duration(milliseconds: 500)); // Small delay
      
      if (_auth.currentUser != null) {
        debugPrint("🎯 BYPASS: User is actually signed in despite error!");
        debugPrint("👤 Current User: ${_auth.currentUser!.displayName}");
        debugPrint("📧 Current Email: ${_auth.currentUser!.email}");
        
        // Create a dummy UserCredential-like response
        return DummyUserCredential(_auth.currentUser!);
      }
      
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        debugPrint("🎉 Email/Password Auth Success!");
        debugPrint("📧 Email: ${user.email ?? 'No email'}");
        debugPrint("🆔 UID: ${user.uid}");
        debugPrint("✅ Email Verified: ${user.emailVerified}");
      }
      
      return userCredential;
    } catch (e) {
      debugPrint("🔥 Email/Password Sign-In Error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint("👋 User signed out successfully");
    } catch (e) {
      debugPrint("🔥 Sign out error: $e");
      rethrow;
    }
  }

  // Get user details as a Map (useful for avoiding type issues)
  Map<String, dynamic>? getUserDetails() {
    final User? user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
    };
  }

  // Create a user model class to avoid type issues
  UserModel? getUserModel() {
    final User? user = currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      phoneNumber: user.phoneNumber ?? '',
      emailVerified: user.emailVerified,
    );
  }
}

// Dummy UserCredential class to bypass the error
class DummyUserCredential implements UserCredential {
  @override
  final User user;
  
  DummyUserCredential(this.user);
  
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  
  @override
  AuthCredential? get credential => null;
}

// User model class to handle user data properly
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String phoneNumber;
  final bool emailVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.phoneNumber,
    required this.emailVerified,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
    };
  }

  // Create from Map (for database retrieval)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  // Convert to JSON string
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, phoneNumber: $phoneNumber, emailVerified: $emailVerified)';
  }
}