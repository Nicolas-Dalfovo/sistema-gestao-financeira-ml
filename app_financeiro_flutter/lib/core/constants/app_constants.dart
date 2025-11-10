class AppConstants {
  static const String appName = 'Finanças Inteligentes';
  static const String appVersion = '1.0.0';
  
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static const int requestTimeout = 30;
  
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  
  static const int paginationLimit = 20;
  
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
  
  static const String currencySymbol = 'R\$';
  static const String currencyLocale = 'pt_BR';
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  static const String transacoes = '/transacoes';
  static const String categorias = '/categorias';
  static const String contas = '/contas';
  static const String metas = '/metas';
  static const String orcamentos = '/orcamentos';
  static const String notificacoes = '/notificacoes';
  
  static const String dashboard = '/relatorios/dashboard';
  static const String gastosCategoria = '/relatorios/gastos-categoria';
  static const String evolucaoMensal = '/relatorios/evolucao-mensal';
  static const String comparativo = '/relatorios/comparativo';
  
  static const String analisesPadroes = '/analises/padroes';
  static const String analisePrevisoes = '/analises/previsoes';
  static const String analiseRecomendacoes = '/analises/recomendacoes';
}

class StorageKeys {
  static const String theme = 'theme_mode';
  static const String language = 'language';
  static const String notifications = 'notifications_enabled';
  static const String biometrics = 'biometrics_enabled';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String transacoes = '/transacoes';
  static const String novaTransacao = '/transacoes/nova';
  static const String editarTransacao = '/transacoes/editar';
  static const String relatorios = '/relatorios';
  static const String metas = '/metas';
  static const String novaMeta = '/metas/nova';
  static const String orcamentos = '/orcamentos';
  static const String novoOrcamento = '/orcamentos/novo';
  static const String configuracoes = '/configuracoes';
  static const String perfil = '/perfil';
  static const String categorias = '/categorias';
  static const String contas = '/contas';
}

