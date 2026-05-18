import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/firebase/firebase_config.dart';

class ContactInquiry {
  const ContactInquiry({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String name;
  final String email;
  final String subject;
  final String message;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class ContactSubmissionException implements Exception {
  const ContactSubmissionException({
    this.firestoreError,
    this.emailEndpointError,
  });

  final Object? firestoreError;
  final Object? emailEndpointError;

  bool get hasFirestoreError => firestoreError != null;
  bool get hasEmailEndpointError => emailEndpointError != null;

  @override
  String toString() {
    final messages = <String>[];
    if (firestoreError != null) {
      messages.add('Firestore: $firestoreError');
    }
    if (emailEndpointError != null) {
      messages.add('Email endpoint: $emailEndpointError');
    }
    return messages.isEmpty
        ? 'Contact submission failed.'
        : 'Contact submission failed (${messages.join(' | ')}).';
  }
}

class PortfolioBackend {
  PortfolioBackend._();

  static final instance = PortfolioBackend._();

  bool get isConfigured => Firebase.apps.isNotEmpty;

  bool get hasEmailEndpoint => FirebaseConfig.contactEmailEndpoint.isNotEmpty;
  bool get hasWeb3FormsAccessKey =>
      FirebaseConfig.web3FormsAccessKey.isNotEmpty;
  bool get isContactFirestoreEnabled => FirebaseConfig.contactFirestoreEnabled;
  bool get hasDirectEmailDelivery => hasEmailEndpoint || hasWeb3FormsAccessKey;

  Stream<User?> get authStateChanges {
    if (!isConfigured) {
      return const Stream<User?>.empty();
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser {
    if (!isConfigured) {
      return null;
    }
    return FirebaseAuth.instance.currentUser;
  }

  Future<bool> isAdmin() async {
    final user = currentUser;
    if (!isConfigured || user == null) {
      return false;
    }

    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();
    return adminDoc.exists;
  }

  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      throw StateError('Firebase is not configured.');
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final allowed = await isAdmin();
    if (!allowed) {
      await FirebaseAuth.instance.signOut();
      throw StateError('This account is not allowed to access admin.');
    }
  }

  Future<void> signOut() async {
    if (!isConfigured) {
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<Map<String, Object?>?> loadPortfolioContent() async {
    if (!isConfigured) {
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('siteContent')
          .doc('main')
          .get();
      return snapshot.data();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> savePortfolioContent(Map<String, Object?> content) async {
    if (!isConfigured) {
      return;
    }

    await FirebaseFirestore.instance.collection('siteContent').doc('main').set({
      ...content,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': currentUser?.uid,
    }, SetOptions(merge: true));
  }

  Future<String> uploadProfileImage({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (!isConfigured) {
      throw StateError('Firebase is not configured.');
    }

    final safeFileName = fileName.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
    final reference = FirebaseStorage.instance.ref(
      'portfolio/profile/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
    );
    await reference.putData(bytes, SettableMetadata(contentType: mimeType));
    return reference.getDownloadURL();
  }

  Future<void> submitInquiry(ContactInquiry inquiry) async {
    Object? firestoreError;
    Object? emailEndpointError;
    Object? web3FormsError;
    var delivered = false;

    if (hasEmailEndpoint) {
      try {
        final response = await http.post(
          Uri.parse(FirebaseConfig.contactEmailEndpoint),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': inquiry.name,
            'email': inquiry.email,
            'subject': inquiry.subject,
            'message': inquiry.message,
          }),
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw StateError(
            'Email endpoint returned HTTP ${response.statusCode}.',
          );
        }
        delivered = true;
      } on Object catch (error) {
        emailEndpointError = error;
      }
    }

    if (hasWeb3FormsAccessKey) {
      try {
        final response = await http.post(
          Uri.parse('https://api.web3forms.com/submit'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'access_key': FirebaseConfig.web3FormsAccessKey,
            'name': inquiry.name,
            'email': inquiry.email,
            'subject': inquiry.subject,
            'message': inquiry.message,
          }),
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw StateError('Web3Forms returned HTTP ${response.statusCode}.');
        }
        delivered = true;
      } on Object catch (error) {
        web3FormsError = error;
      }
    }

    if (isConfigured && isContactFirestoreEnabled) {
      try {
        await FirebaseFirestore.instance
            .collection('contactInquiries')
            .add(inquiry.toJson());
      } on Object catch (error) {
        firestoreError = error;
      }
    }

    if (delivered) {
      return;
    }

    if (firestoreError != null ||
        emailEndpointError != null ||
        web3FormsError != null) {
      throw ContactSubmissionException(
        firestoreError: firestoreError,
        emailEndpointError:
            emailEndpointError ?? web3FormsError ?? firestoreError,
      );
    }
  }
}
