import '../../data/services/auth_service.dart';
import '../../data/services/bootstrap_service.dart';
import '../../data/services/fake_analysis_service.dart';
import '../../data/services/history_service.dart';
import '../app_state.dart';

/// Simple manual service locator for the MVP.
class ServiceLocator {
  ServiceLocator._();

  static final authService = AuthService();
  static final bootstrapService =
      BootstrapService(authService: authService);
  static final historyService = HistoryService();
  static final fakeAnalysisService =
      FakeAnalysisService(historyService: historyService);
  static final appState = AppState(
    authService: authService,
    bootstrapService: bootstrapService,
  );
}
