import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // ── Change this IP to your computer's local network IP ──
  // Find it with: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String _lanIp = '192.168.137.42';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    // Physical device uses LAN IP; emulator could use 10.0.2.2
    return 'http://$_lanIp:8000';
  }

  static Future<AnalyzeResponse> analyze(AnalyzeRequest request) async {
    final uri = Uri.parse('$baseUrl/analyze');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AnalyzeResponse.fromJson(json);
      } else if (response.statusCode == 404) {
        throw const ApiException(
          'No suitable areas found within the given budget. Try increasing your budget.',
          statusCode: 404,
        );
      } else {
        final detail = _extractDetail(response.body);
        throw ApiException(detail, statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Could not connect to server. Make sure the backend is running.\n$e',
      );
    }
  }

  static String _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      return json['detail']?.toString() ?? 'Unknown server error';
    } catch (_) {
      return 'Unknown server error';
    }
  }
}
