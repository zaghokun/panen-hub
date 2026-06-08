/// PanenHub Environment Configuration
class Env {
  Env._();

  static const appName = 'PanenHub';

  // Alamat IP Gateway Hotspot Windows (biasanya 192.168.137.1)
  // Gunakan 10.0.2.2 jika kembali menggunakan Emulator
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.137.1:3000/api/v1',
  );

  static const useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
}
