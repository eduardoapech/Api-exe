class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome de usuário';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    // Você pode adicionar uma validação de formato de email aqui, se necessário
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma cidade';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um estado';
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um gênero';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma idade';
    }
    if (int.tryParse(value) == null) {
      return 'Por favor, insira um número válido';
    }
    return null;
  }
}
