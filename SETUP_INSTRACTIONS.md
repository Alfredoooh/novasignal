# 🚀 Setup NovaSignal - Integração Deriv

## 📋 Pré-requisitos

1. Flutter SDK instalado
2. Android Studio / VS Code
3. Conta no Deriv (https://deriv.com)
4. App ID do Deriv (obtenha em https://app.deriv.com/account/api-token)

---

## 🔧 Configuração Inicial

### 1. Instalar Dependências

```bash
flutter pub get
```

### 2. Configurar App ID do Deriv

Abra o arquivo `lib/services/deriv_auth_service.dart` e substitua o App ID:

```dart
// LINHA 13
static const String APP_ID = 'SEU_APP_ID_AQUI'; // ⚠️ IMPORTANTE: Substitua pelo seu App ID
```

**Como obter seu App ID:**
1. Acesse https://app.deriv.com/account/api-token
2. Faça login na sua conta Deriv
3. Role até "API Token" e clique em "Manage"
4. Copie o número do "App ID" (exemplo: 12345)

---

## 📱 Configuração Android

### 1. AndroidManifest.xml

O arquivo já está configurado em `android/app/src/main/AndroidManifest.xml` com:
- Deep Link: `novasignal://deriv-callback`
- Permissões necessárias

**Personalize o Deep Link (opcional):**

Se quiser usar outro scheme, altere em:
- `AndroidManifest.xml`: linha `android:scheme="novasignal"`
- `deriv_auth_service.dart`: linha `static const String _deepLinkScheme = 'novasignal';`

### 2. Configurar Package Name

No `AndroidManifest.xml`, altere o package:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.novasignal.app">  <!-- ⚠️ Altere para seu package -->
```

E também em `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.novasignal.app"  // ⚠️ Altere para seu package
    }
}
```

---

## 🌐 Configuração Web

### 1. Configurar Base URL

No arquivo `web/index.html`, já está configurado para processar callbacks OAuth.

**Se hospedar em domínio próprio:**

1. Altere a `<base href>` se necessário
2. Configure o redirect URL no Deriv:
   - Acesse https://app.deriv.com/account/api-token
   - Em "OAuth details", adicione: `https://seu-dominio.com/deriv-callback`

**Para desenvolvimento local:**

Use: `http://localhost:8080/deriv-callback`

### 2. Testar Web

```bash
flutter run -d chrome --web-port 8080
```

---

## 🔐 Configurar OAuth no Deriv

### Passos para configurar OAuth App:

1. **Acesse:** https://app.deriv.com/account/api-token
2. **Clique em "Register application"**
3. **Preencha:**
   - **App name:** NovaSignal
   - **Redirect URL:** 
     - Android: `novasignal://deriv-callback`
     - Web: `https://seu-dominio.com/deriv-callback` (ou `http://localhost:8080/deriv-callback` para dev)
   - **Verification URL:** Deixe em branco
   - **Scopes:** Selecione as permissões necessárias:
     - ✅ Read (obrigatório)
     - ✅ Trade (para fazer trades)
     - ✅ Payments (para depósitos/saques)
     - ✅ Trading information (para dados de conta)
     - ✅ Admin (se necessário)

4. **Copie o App ID** gerado e cole em `deriv_auth_service.dart`

---

## 🧪 Testar Integração

### Método 1: OAuth (Recomendado)

1. Abra o app
2. Na tela de perfil, clique em "Conectar Deriv"
3. Escolha "OAuth (Fácil)"
4. Clique em "Conectar com Deriv"
5. Faça login no Deriv
6. Autorize o NovaSignal
7. Você será redirecionado automaticamente

**Android:** O deep link abrirá o app automaticamente
**Web:** O redirect acontecerá na mesma janela

### Método 2: Token API

1. Acesse https://api.deriv.com
2. Faça login
3. Crie um novo token API com as permissões necessárias
4. Copie o token
5. No app, escolha "Token API"
6. Cole o token e clique em "Conectar"

---

## 📦 Estrutura de Arquivos

```
lib/
├── main.dart                          # Inicialização do app
├── services/
│   └── deriv_auth_service.dart       # Serviço de autenticação Deriv
├── widgets/
│   └── deriv_connection_modal.dart   # Modal de conexão
├── screens/
│   ├── login_screen.dart             # Tela de login
│   ├── home_screen.dart              # Tela principal
│   ├── home_page.dart                # Home tab
│   ├── user_profile_page.dart        # Perfil do usuário
│   └── settings_page.dart            # Configurações

android/
└── app/src/main/AndroidManifest.xml  # Configuração Deep Link

web/
└── index.html                         # Configuração Web OAuth
```

---

## 🐛 Troubleshooting

### Deep Link não está funcionando (Android)

1. Verifique se o scheme está correto no `AndroidManifest.xml`
2. Reconstrua o app: `flutter clean && flutter build apk`
3. Teste com: `adb shell am start -W -a android.intent.action.VIEW -d "novasignal://deriv-callback?token1=test"`

### OAuth não redireciona (Web)

1. Verifique se a URL de redirect está correta no Deriv
2. Certifique-se de estar usando a mesma URL (http/https)
3. Verifique o console do navegador para erros

### Token inválido

1. Verifique se o token não expirou
2. Certifique-se de que o token tem as permissões necessárias
3. Gere um novo token no Deriv

### WebSocket não conecta

1. Verifique sua conexão com internet
2. Confirme que o App ID está correto
3. Teste com o token diretamente na API: https://api.deriv.com

---

## 📝 Notas Importantes

1. **Segurança:** Nunca compartilhe seu token API publicamente
2. **Produção:** Use HTTPS para o redirect URL em produção
3. **Testes:** Use a conta demo do Deriv para testes
4. **Rate Limits:** A API do Deriv tem limites de requisições
5. **Conexão:** O WebSocket mantém conexão em tempo real

---

## 🔗 Links Úteis

- **Deriv API Docs:** https://api.deriv.com/
- **Deriv WebSocket:** https://api.deriv.com/docs/websockets
- **OAuth Guide:** https://api.deriv.com/docs/oauth/
- **App Registration:** https://app.deriv.com/account/api-token

---

## 🎯 Próximos Passos

1. ✅ Configurar App ID
2. ✅ Testar OAuth no Android
3. ✅ Testar OAuth na Web
4. ✅ Implementar persistência de token (SharedPreferences)
5. ✅ Adicionar refresh automático de saldo
6. ✅ Implementar trading features
7. ✅ Adicionar analytics e crashlytics

---

## 💡 Dicas

- Use a conta **Demo** do Deriv para testes
- O OAuth é mais seguro que token manual
- Tokens podem ser revogados a qualquer momento no painel do Deriv
- O WebSocket mantém conexão em tempo real sem polling
- Implemente tratamento de erro robusto para perda de conexão

---

**Sucesso! 🚀 Seu app agora está integrado com Deriv!**