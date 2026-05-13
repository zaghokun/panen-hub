/// PanenHub Environment Configuration
class Env {
  Env._();

  static const appName = 'PanenHub';

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.panenhub.example',
  );

  static const useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );
}
