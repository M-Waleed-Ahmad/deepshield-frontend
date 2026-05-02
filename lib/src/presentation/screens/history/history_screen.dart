import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../core/environment.dart';
import '../../../core/theme.dart';
import '../../../core/utils/authenticated_http.dart';
import '../../../core/utils/service_locator.dart';
import '../../../routes/app_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _analyses = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = ServiceLocator.authProvider;
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not authenticated.';
        });
        return;
      }

      final baseUrl = _resolveBaseUrl(
        Environment.aiServiceUrl,
      ).replaceAll(RegExp(r'/+$'), '');
      final response = await authenticatedGet(
        '$baseUrl/analyses/history',
        token,
        context,
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> analysesRaw = decoded is Map<String, dynamic>
            ? (decoded['analyses'] ?? decoded['items'] ?? decoded['data'] ?? [])
                  as List<dynamic>
            : (decoded is List ? decoded : <dynamic>[]);

        setState(() {
          _analyses = analysesRaw
              .whereType<Map<String, dynamic>>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load history. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not reach the server.';
      });
    }
  }

  String _resolveBaseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final isLocalHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
      if (isLocalHost && Platform.isAndroid) {
        return uri.replace(host: '10.0.2.2').toString();
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  String _formatDate(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return 'Unknown date';
    }
    try {
      final dt = DateTime.parse(rawValue).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return 'Unknown date';
    }
  }

  String _formatConfidence(dynamic confidenceValue) {
    final parsed = (confidenceValue as num?)?.toDouble() ?? 0.0;
    final normalized = parsed <= 1 ? parsed * 100 : parsed;
    return '${normalized.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Padding(padding: AppSpacing.screenPadding, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _fetchHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_analyses.isEmpty) {
      return const Center(
        child: Text(
          'No analyses yet. Upload your first file to get started.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        itemCount: _analyses.length,
        itemBuilder: (context, index) {
          final item = _analyses[index];
          final filename = item['filename']?.toString() ?? 'Unknown file';
          final label = item['prediction']?.toString() ?? 'Unknown';
          final confidence = _formatConfidence(item['confidence']);
          final createdAt = _formatDate(item['created_at']?.toString());
          final mediaType = item['type']?.toString() ?? 'unknown';
          final hasPdf =
              (item['pdf_url']?.toString().isNotEmpty ?? false) ||
              (item['report_url']?.toString().isNotEmpty ?? false);

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardOverlay,
              borderRadius: AppRadii.card,
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              title: Text(
                filename,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Label: $label'),
                    Text('Confidence: $confidence'),
                    Text('Created: $createdAt'),
                    Text('Type: $mediaType'),
                  ],
                ),
              ),
              trailing: hasPdf
                  ? const Icon(Icons.picture_as_pdf, color: Colors.redAccent)
                  : null,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.result,
                arguments: item,
              ),
            ),
          );
        },
      ),
    );
  }
}
