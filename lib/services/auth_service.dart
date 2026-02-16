import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/user_model.dart';

class ProfilePhotoUploadResult {
  final String? photoUrl;
  final String? errorMessage;
  final bool syncedToFirestore;

  const ProfilePhotoUploadResult({
    required this.photoUrl,
    required this.errorMessage,
    required this.syncedToFirestore,
  });

  bool get isSuccess => photoUrl != null;
}

/// Authentication service for handling Firebase Auth operations
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String countryCode,
    required String countryDialCode,
    required bool isPhoneVerified,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final now = DateTime.now();
        final userModel = UserModel(
          id: credential.user!.uid,
          name: name.trim(),
          email: email.trim(),
          phoneNumber: phoneNumber.trim(),
          countryCode: countryCode,
          countryDialCode: countryDialCode,
          isPhoneVerified: isPhoneVerified,
          role: 'admin',
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toJson());

        _currentUser = userModel;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      return false;
    } on FirebaseException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up Firebase error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      // Try to extract error code from exception string for web compatibility
      final errorString = e.toString();
      String errorCode = 'unknown';
      if (errorString.contains('email-already-in-use')) {
        errorCode = 'email-already-in-use';
      } else if (errorString.contains('invalid-email')) {
        errorCode = 'invalid-email';
      } else if (errorString.contains('weak-password')) {
        errorCode = 'weak-password';
      } else if (errorString.contains('operation-not-allowed')) {
        errorCode = 'operation-not-allowed';
      } else if (errorString.contains('permission-denied')) {
        errorCode = 'permission-denied';
      }

      _error = _getAuthErrorMessage(errorCode);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      return false;
    } on FirebaseException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in Firebase error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      // Try to extract error code from exception string for web compatibility
      final errorString = e.toString();
      String errorCode = 'unknown';
      if (errorString.contains('invalid-credential')) {
        errorCode = 'invalid-credential';
      } else if (errorString.contains('user-not-found')) {
        errorCode = 'user-not-found';
      } else if (errorString.contains('wrong-password')) {
        errorCode = 'wrong-password';
      } else if (errorString.contains('invalid-email')) {
        errorCode = 'invalid-email';
      } else if (errorString.contains('too-many-requests')) {
        errorCode = 'too-many-requests';
      } else if (errorString.contains('network-request-failed')) {
        errorCode = 'network-request-failed';
      }

      _error = _getAuthErrorMessage(errorCode);
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? countryCode,
    String? countryDialCode,
    bool? isPhoneVerified,
    String? photoUrl,
  }) async {
    if (_currentUser == null || _firebaseUser == null) return false;

    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (countryCode != null) updates['countryCode'] = countryCode;
      if (countryDialCode != null) updates['countryDialCode'] = countryDialCode;
      if (isPhoneVerified != null) updates['isPhoneVerified'] = isPhoneVerified;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        countryCode: countryCode ?? _currentUser!.countryCode,
        countryDialCode: countryDialCode ?? _currentUser!.countryDialCode,
        isPhoneVerified: isPhoneVerified ?? _currentUser!.isPhoneVerified,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  /// Upload profile photo and persist the URL to Auth + Firestore profile data.
  Future<ProfilePhotoUploadResult> uploadProfilePhoto({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (_firebaseUser == null) {
      return const ProfilePhotoUploadResult(
        photoUrl: null,
        errorMessage: 'You must be signed in to upload a photo.',
        syncedToFirestore: false,
      );
    }

    try {
      final sanitizedName = fileName.trim().isEmpty ? 'profile.jpg' : fileName;
      final contentType = _guessContentType(sanitizedName);
      final ref = _storage
          .ref()
          .child('users')
          .child(_firebaseUser!.uid)
          .child('profile_photos')
          .child('${DateTime.now().millisecondsSinceEpoch}_$sanitizedName');

      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: contentType),
      );

      final downloadUrl = await ref.getDownloadURL();
      await _firebaseUser!.updatePhotoURL(downloadUrl);

      bool syncedToFirestore = true;
      try {
        await _firestore.collection('users').doc(_firebaseUser!.uid).set({
          'photoUrl': downloadUrl,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            photoUrl: downloadUrl,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        } else {
          await _loadUserData(_firebaseUser!.uid);
          notifyListeners();
        }
      } catch (e) {
        syncedToFirestore = false;
        debugPrint('Profile photo saved in Auth but Firestore sync failed: $e');
      }

      return ProfilePhotoUploadResult(
        photoUrl: downloadUrl,
        errorMessage: syncedToFirestore
            ? null
            : 'Photo uploaded, but Firestore profile sync failed.',
        syncedToFirestore: syncedToFirestore,
      );
    } on FirebaseException catch (e) {
      debugPrint('Profile photo upload failed: ${e.code} - ${e.message}');
      return ProfilePhotoUploadResult(
        photoUrl: null,
        errorMessage: _mapStorageError(e),
        syncedToFirestore: false,
      );
    } catch (e) {
      debugPrint('Profile photo upload failed: $e');
      return const ProfilePhotoUploadResult(
        photoUrl: null,
        errorMessage: 'Photo upload failed. Please try again.',
        syncedToFirestore: false,
      );
    }
  }

  String _guessContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _mapStorageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
      case 'permission-denied':
        return 'Permission denied for photo upload. Deploy/update Firebase Storage rules.';
      case 'storage/unauthorized':
      case 'storage/permission-denied':
        return 'Permission denied for photo upload. Deploy/update Firebase Storage rules.';
      case 'object-not-found':
      case 'storage/object-not-found':
        return 'Upload path not found in Firebase Storage.';
      case 'bucket-not-found':
      case 'storage/bucket-not-found':
        return 'Storage bucket not found. Check Firebase storageBucket configuration.';
      case 'quota-exceeded':
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded. Increase your Firebase Storage plan/quota.';
      case 'unauthenticated':
      case 'storage/unauthenticated':
        return 'Please sign in again, then retry photo upload.';
      case 'retry-limit-exceeded':
      case 'storage/retry-limit-exceeded':
        return 'Upload timed out. Check network and retry.';
      default:
        return e.message ?? 'Photo upload failed. Please try again.';
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Returns true when no user already owns the provided phone number.
  Future<bool> isPhoneAvailable(String phoneNumber) async {
    // During registration we can be unauthenticated; current rules block
    // collection reads on /users for anonymous clients.
    if (_auth.currentUser == null) {
      return true;
    }

    try {
      final result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return result.docs.isEmpty;
    } catch (e) {
      final error = e.toString();
      if (error.contains('permission-denied')) {
        debugPrint('Phone availability check skipped due to Firestore rules.');
        return true;
      }
      debugPrint('Phone availability check failed: $e');
      return false;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'permission-denied':
        return 'Permission denied. Please contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
