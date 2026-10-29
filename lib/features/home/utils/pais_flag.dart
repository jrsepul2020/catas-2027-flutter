abstract final class PaisFlag {
  static String emoji(String? paisCodigo) {
    switch (paisCodigo?.toUpperCase()) {
      case 'ES':
        return '🇪🇸';
      case 'PT':
        return '🇵🇹';
      case 'FR':
        return '🇫🇷';
      case 'IT':
        return '🇮🇹';
      case 'DE':
        return '🇩🇪';
      case 'GB':
        return '🇬🇧';
      case 'AR':
        return '🇦🇷';
      case 'MX':
        return '🇲🇽';
      case 'US':
        return '🇺🇸';
      default:
        return '🌍';
    }
  }
}
