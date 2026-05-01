class HealthStatus {
  HealthStatus({
    required this.status,
    required this.ucfLoaded,
    required this.xceptionLoaded,
    required this.aiService,
    this.lastChecked,
  });

  final String status;
  final bool ucfLoaded;
  final bool xceptionLoaded;
  final String aiService;
  final DateTime? lastChecked;

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      ucfLoaded: json['ucf_loaded'] as bool? ?? false,
      xceptionLoaded: json['xception_loaded'] as bool? ?? false,
      aiService: json['ai_service'] as String? ?? 'none',
      lastChecked: DateTime.now(),
    );
  }
}
