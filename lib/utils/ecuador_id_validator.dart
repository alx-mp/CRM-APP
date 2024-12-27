class EcuadorIdValidator {
  static String? validate(String value) {
    if (!_isNumeric(value)) {
      return 'La cédula solo debe contener números';
    }

    // Always validate as digits are entered
    if (value.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }

    // Validate province code
    int provinceCode = int.parse(value.substring(0, 2));
    if (!((provinceCode >= 1 && provinceCode <= 24) || provinceCode == 30)) {
      return 'Cédula inválida';
    }

    // Validate third digit
    int thirdDigit = int.parse(value[2]);
    if (thirdDigit > 5) {
      return 'Cédula inválida';
    }

    return _validateLuhn(value);
  }

  static bool _isNumeric(String str) {
    return RegExp(r'^\d+$').hasMatch(str);
  }

  static String? _validateLuhn(String value) {
    int sum = 0;

    // Calculate sum using Luhn algorithm
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(value[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }

    // Calculate verifier digit
    int firstDigit = int.parse(sum.toString()[0]);
    int dozen = (firstDigit + 1) * 10;
    int validatorDigit = dozen - sum;
    if (validatorDigit >= 10) validatorDigit = 0;

    // Compare with actual last digit
    int lastDigit = int.parse(value[9]);
    return validatorDigit == lastDigit ? null : 'Cédula inválida';
  }
}
