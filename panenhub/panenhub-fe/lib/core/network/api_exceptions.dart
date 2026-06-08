class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Sesi telah berakhir. Silakan login kembali.'])
      : super(statusCode: 401);
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.errors})
      : super(statusCode: 400);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Data tidak ditemukan.'])
      : super(statusCode: 404);
}

class ForbiddenException extends ApiException {
  ForbiddenException([super.message = 'Anda tidak memiliki akses.'])
      : super(statusCode: 403);
}
