# MindEase

MindEase é um aplicativo desenvolvido em Flutter com foco em [descrição do propósito, ex: saúde mental/bem-estar]. Este projeto utiliza arquitetura limpa e padrões modernos de desenvolvimento.

## 🛠 Tecnologias e Dependências

- **Flutter:** ^3.35.1
- **Dart:** ^3.9.0
- **Gerenciamento de Estado:** `flutter_bloc`
- **Injeção de Dependência:** `get_it`
- **Banco de Dados Local:** `hive`
- **Backend/Auth:** `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Variáveis de Ambiente:** `flutter_dotenv`

## 🚀 Configuração do Ambiente

### Pré-requisitos

- Flutter SDK instalado e configurado no PATH.
- Java JDK 17 (necessário para o build Android).
- VS Code ou Android Studio com plugins Flutter/Dart.

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/mindease.git
cd mindease
```

### 2. Instalar Dependências

```bash
flutter pub get
```

### 3. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com as chaves necessárias (exemplo):

```env
API_KEY=sua_chave_aqui
FIREBASE_ID=seu_id_aqui
```

_O arquivo `.env` já está configurado como asset no `pubspec.yaml`._

### 4. Configurar Android SDK (`local.properties`)

Certifique-se de que o arquivo `android/local.properties` existe e aponta para o seu SDK Android e Flutter. Exemplo:

```properties
sdk.dir=C:/Users/SeuUsuario/AppData/Local/Android/Sdk
flutter.sdk=C:/caminho/para/flutter
```

_Nota: Use barras normais `/` ou barras duplas `\\` no Windows._

## 🏃‍♂️ Executando o Projeto

O projeto utiliza **Flavors** para separar ambientes de desenvolvimento e produção.

### Desenvolvimento

```bash
# Rodar em modo debug
flutter run --flavor development -t lib/app/main_development.dart

# Build APK de debug
flutter build apk --debug --flavor development -t lib/app/main_development.dart
```

### Produção

```bash
# Rodar em modo release
flutter run --release --flavor production -t lib/app/main_production.dart

# Build APK de release
flutter build apk --release --flavor production -t lib/app/main_production.dart
```

## 🧪 Testes e Geração de Código

### Geração de Código (Build Runner)

Sempre que alterar arquivos que usam `hive` ou `mocktail`, regenere os arquivos:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Executar Testes

```bash
flutter test
```

## 🔄 CI/CD (Integração Contínua)

O projeto possui workflows do GitHub Actions configurados na pasta `.github/workflows/`:

1.  **Flutter CI (`flutter_ci.yml`):**
    - Executa em `push` e `pull_request` na `main`.
    - Verifica formatação (`dart format`).
    - Executa análise estática (`flutter analyze`).
    - Roda testes unitários.
    - Gera APK de Debug.

2.  **CodeQL (`codeql.yml`):**
    - Análise de segurança automatizada semanalmente e em PRs.

3.  **Flutter CD (`flutter_cd.yml`):**
    - Executa em `push` na `main`.
    - Gera APK de Release (`app-production-release.apk`).
    - Armazena o APK nos artefatos do GitHub (sem deploy automático para lojas).

## 📂 Estrutura de Pastas (Resumo)

- `lib/app/`: Configurações globais, injeção de dependência e arquivos de entrada (`main_*.dart`).
- `lib/features/`: Módulos do app (telas, cubits, repositórios).
- `test/`: Testes unitários e de widget.
- `android/`: Configurações nativas Android.
- `.github/`: Workflows de CI/CD.
