/// PanenHub Environment Configuration
class Env {
  Env._();

  static const appName = 'PanenHub';

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.137.1:3000/api/v1',
  );

  static const useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
}
