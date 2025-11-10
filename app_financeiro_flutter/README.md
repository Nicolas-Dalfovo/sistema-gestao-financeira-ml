# Aplicativo Financeiro - Flutter

Aplicativo inteligente para gerenciamento financeiro pessoal com análise de hábitos de consumo.

## Descrição

Este é o frontend mobile do sistema de gerenciamento financeiro, desenvolvido em Flutter/Dart. O aplicativo oferece uma interface intuitiva para controle de receitas, despesas, metas financeiras e visualização de relatórios com insights personalizados.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **Provider**: Gerenciamento de estado
- **HTTP/Dio**: Requisições HTTP
- **SharedPreferences**: Armazenamento local
- **FL Chart**: Gráficos e visualizações
- **Intl**: Formatação de datas e valores

## Pré-requisitos

- Flutter SDK 3.0.0 ou superior
- Dart SDK 3.0.0 ou superior
- Android Studio / VS Code
- Emulador Android ou dispositivo físico
- Xcode (para iOS - apenas macOS)

## Instalação do Flutter

### Windows

1. Baixe o Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Extraia o arquivo ZIP
3. Adicione o Flutter ao PATH
4. Execute `flutter doctor` para verificar dependências

### macOS

```bash
brew install flutter
flutter doctor
```

### Linux

```bash
sudo snap install flutter --classic
flutter doctor
```

## Configuração do Projeto

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd app_financeiro_flutter
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure a URL da API

Edite o arquivo `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://SEU_IP:8000/api';
```

**Importante**: Para testar em dispositivo físico, use o IP da sua máquina na rede local (ex: `http://192.168.1.100:8000/api`). Não use `localhost` ou `127.0.0.1`.

### 4. Execute o aplicativo

```bash
flutter run
```

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do app
├── core/
│   ├── constants/               # Constantes e configurações
│   │   ├── app_constants.dart
│   │   └── app_colors.dart
│   ├── utils/                   # Utilitários
│   └── services/                # Serviços (API, Auth)
│       ├── api_service.dart
│       └── auth_service.dart
├── models/                      # Modelos de dados
│   ├── usuario.dart
│   ├── transacao.dart
│   ├── categoria.dart
│   └── meta.dart
├── providers/                   # Gerenciamento de estado
│   ├── auth_provider.dart
│   ├── transacao_provider.dart
│   └── categoria_provider.dart
├── screens/                     # Telas do aplicativo
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── registro_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── transacoes/
│   ├── relatorios/
│   ├── metas/
│   └── configuracoes/
└── widgets/                     # Widgets reutilizáveis
    ├── common/
    ├── charts/
    └── cards/
```

## Funcionalidades Implementadas

### ✅ Autenticação
- Login de usuários
- Gerenciamento de token JWT
- Persistência de sessão

### ✅ Dashboard
- Visualização de saldo atual
- Total de receitas e despesas
- Transações recentes

### ✅ Gerenciamento de Estado
- Provider para autenticação
- Provider para transações
- Provider para categorias

### ⏳ Em Desenvolvimento
- Cadastro de transações
- Edição e exclusão de transações
- Gráficos e relatórios
- Gerenciamento de metas
- Orçamentos mensais
- Notificações
- Análises com ML

## Comandos Úteis

### Verificar instalação do Flutter

```bash
flutter doctor
```

### Listar dispositivos disponíveis

```bash
flutter devices
```

### Executar em dispositivo específico

```bash
flutter run -d <device-id>
```

### Build para Android (APK)

```bash
flutter build apk --release
```

### Build para iOS

```bash
flutter build ios --release
```

### Limpar build

```bash
flutter clean
flutter pub get
```

### Analisar código

```bash
flutter analyze
```

### Executar testes

```bash
flutter test
```

## Configuração de Ícones

Para gerar os ícones do aplicativo:

1. Adicione sua imagem em `assets/icons/app_icon.png` (1024x1024)
2. Execute:

```bash
flutter pub run flutter_launcher_icons
```

## Temas

O aplicativo suporta tema claro e escuro, que se adapta automaticamente às configurações do sistema.

Para forçar um tema específico, edite `main.dart`:

```dart
themeMode: ThemeMode.light,  // ou ThemeMode.dark
```

## Internacionalização

O aplicativo está configurado para português brasileiro (pt-BR). Para adicionar outros idiomas, configure o pacote `flutter_localizations`.

## Debugging

### Android

```bash
flutter run --debug
adb logcat | grep flutter
```

### iOS

```bash
flutter run --debug
```

Use o DevTools do Flutter para debugging avançado:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Performance

### Análise de Performance

```bash
flutter run --profile
```

### Build Otimizado

```bash
flutter build apk --release --shrink
flutter build appbundle --release
```

## Troubleshooting

### Erro de dependências

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Erro de conexão com API

1. Verifique se o backend está rodando
2. Confirme a URL da API em `app_constants.dart`
3. Teste a API com curl ou Postman
4. Verifique permissões de internet no AndroidManifest.xml

### Erro de build Android

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## Licença

Este projeto foi desenvolvido como Trabalho de Conclusão de Curso.

## Autor

Nicolas Marquez Dalfovo
Centro Universitário para o Desenvolvimento do Alto Vale do Itajaí - UNIDAVI
2025

## Suporte

Para dúvidas ou problemas:
- Documentação Flutter: https://flutter.dev/docs
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Flutter Community: https://flutter.dev/community

