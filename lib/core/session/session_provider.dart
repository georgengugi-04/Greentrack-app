import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/models.dart';

// ── Raw Firebase auth state ────────────────────────────────────────────────
// true = signed in to Firebase, false = signed out
final firebaseSignedInProvider = StreamProvider<bool>((ref) {
  return FirebaseAuth.instance
      .authStateChanges()
      .map((user) => user != null);
});

// ── Full session (AppUser with role, loaded from Firestore) ───────────────
class SessionController extends Notifier<AppUser?> {
  StreamSubscription<User?>? _authSub;
  bool _googleInitialized = false;

  @override
  AppUser? build() {
    _authSub =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
    ref.onDispose(() => _authSub?.cancel());
    return null;
  }

  Future<void> _onAuthChange(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = null;
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && (doc.data()?.containsKey('role') ?? false)) {
        // Returning user — load their role from Firestore
        state = AppUser.fromJson({
          ...doc.data()!,
          'id': firebaseUser.uid,
        });
      } else {
        // First time sign-in — needs role selection
        // Leave state null so router redirects to /role-select
        state = null;
      }
    } catch (_) {
      state = null;
    }
  }

  // ── Email / Password ─────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    // _onAuthChange fires automatically
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
    // _onAuthChange fires automatically
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: use popup flow — no google_sign_in package needed
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      // Mobile: use google_sign_in package
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await googleSignIn.initialize();
        _googleInitialized = true;
      }
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    // _onAuthChange fires automatically after sign-in
  }

  // ── Role selection (saves to Firestore) ───────────────────────────────────

  Future<void> setRole(
    UserRole role, {
    String? farmName,
    String? restaurantName,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // Mock mode — just set state directly
      state = MockData.users.firstWhere((u) => u.role == role,
          orElse: () => AppUser(
                id: 'mock',
                name: 'User',
                email: '',
                role: role,
                farmName: farmName,
                restaurantName: restaurantName,
              ));
      return;
    }

    final displayName =
        firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User';

    final data = {
      'id': firebaseUser.uid,
      'name': displayName,
      'email': firebaseUser.email ?? '',
      'role': role.name,
      'photoUrl': firebaseUser.photoURL,
      if (farmName != null) 'farmName': farmName,
      if (restaurantName != null) 'restaurantName': restaurantName,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .set(data, SetOptions(merge: true));

    state = AppUser(
      id: firebaseUser.uid,
      name: displayName,
      email: firebaseUser.email ?? '',
      role: role,
      photoUrl: firebaseUser.photoURL,
      farmName: farmName,
      restaurantName: restaurantName,
    );
  }

  // ── Mock sign-in (dev / testing) ─────────────────────────────────────────

  void signInAs(UserRole role) {
    state = MockData.users.firstWhere((u) => u.role == role);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (!kIsWeb) await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    state = null;
  }

}

final sessionProvider = NotifierProvider<SessionController, AppUser?>(SessionController.new);
