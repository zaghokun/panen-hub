/// PanenHub form validators
class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak sama';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Nilai']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName harus lebih dari 0';
    }
    return null;
  }

  static String? maxQuantity(String? value, double maxKg) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah wajib diisi';
    }
    final qty = double.tryParse(value);
    if (qty == null || qty <= 0) {
      return 'Jumlah harus lebih dari 0';
    }
    if (qty > maxKg) {
      return 'Jumlah tidak boleh melebihi kuota (${maxKg.toStringAsFixed(0)} kg)';
    }
    return null;
  }

  static String? futureDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal wajib dipilih';
    }
    if (date.isBefore(DateTime.now())) {
      return 'Tanggal tidak boleh tanggal lampau';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (value.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? maxWithdrawal(String? value, int availableBalance) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal wajib diisi';
    }
    final amount = int.tryParse(value.replaceAll('.', ''));
    if (amount == null || amount <= 0) {
      return 'Nominal harus lebih dari 0';
    }
    if (amount > availableBalance) {
      return 'Nominal tidak boleh melebihi saldo tersedia';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor rekening wajib diisi';
    }
    final numericRegex = RegExp(r'^[0-9]{8,20}$');
    if (!numericRegex.hasMatch(value.trim())) {
      return 'Nomor rekening harus angka (8-20 digit)';
    }
    return null;
  }
}
