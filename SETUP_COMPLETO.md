# 🚀 Setup Completo NovaSignal + Firebase + Deriv

## 📋 Arquivos Criados

### 1. Arquivos HTML de Redirect do Deriv
- ✅ `deriv-redirect-android.html` - Redirect para Android (Deep Link)
- ✅ `deriv-redirect-web.html` - Redirect para Web

### 2. Arquivos Flutter
- ✅ `lib/main.dart` - Inicialização com Firebase
- ✅ `lib/firebase_options.dart` - Configurações Firebase
- ✅ `lib/services/deriv_auth_service.dart` - Serviço Deriv (App ID: 71954)

### 3. Arquivos de Configuração
- ✅ `web/index.html` - Index com Firebase integrado
- ✅ `android/app/src/main/AndroidManifest.xml` - Manifest com Deep Links

---

## 🔧 Configuração Passo a Passo

### PASSO 1: Hospedar Arquivos HTML de Redirect

Você precisa hospedar os 2 arquivos HTML em um servidor web:

**Opções de hospedagem gratuita:**
- **GitHub Pages** (recomendado)
- **Netlify**
- **Vercel**
- **Firebase Hosting**

#### Exemplo com GitHub Pages:

1. Crie um repositório no GitHub
2. Faça upload dos arquivos:
   - `deriv-redirect-android.html`
   - `deriv-redirect-web.html`
3. Ative GitHub Pages nas configurações
4. Suas URLs serão:
   - `https://SEU-USERNAME.github.io/novasignal/deriv-redirect-android.html`
   - `https://SEU-USERNAME.github.io/novasignal/deriv-redirect-web.html`

### PASSO 2: Atualizar URLs nos Arquivos HTML

**No arquivo `deriv-redirect-android.html`:**

```javascript
// LINHA 125 - Substitua pelo seu deep link scheme (se alterou)
let deepLinkUrl = 'novasignal://deriv-callback';

// LINHA 142 - Substitua pelo link do seu APK
downloadLink.href = 'https://SEU-LINK-DE-DOWNLOAD.apk';
```

**No arquivo `deriv-redirect-web.html`:**

```javascript
// LINHA 84 - Substitua pela URL da sua aplicação web
const webAppUrl = 'https://SEU-DOMINIO.com';

// Exemplos:
// Firebase Hosting: 'https://novasignal.web.app'
// Seu domínio: 'https://novasignal.app'
// Localhost (dev): 'http://localhost:8080'
```

### PASSO 3: Configurar no Dashboard Deriv

1. **Acesse:** https://app.deriv.com/account/api-token
2. **Clique em "Manage" ao lado do App ID 71954**
3. **Configure os Redirect URLs:**

**Para Android:**
```
https://SEU-USERNAME.github.io/novasignal/deriv-redirect-android.html
```

**Para Web:**
```
https://SEU-USERNAME.github.io/novasignal/deriv-redirect-web.html
```

4. **Configure os Scopes necessários:**
   - ✅ Read
   - ✅ Trade
   - ✅ Payments
   - ✅ Trading information

### PASSO 4: Atualizar deriv_auth_service.dart

No arquivo `lib/services/deriv_auth_service.dart`, atualize as URLs:

```dart
// LINHA 24-25
static const String _androidRedirectUrl = 'https://SEU-USERNAME.github.io/novasignal/deriv-redirect-android.html';
static const String _webRedirectUrl = 'https://SEU-USERNAME.github.io/novasignal/deriv-redirect-web.html';
```

### PASSO 5: Configurar Firebase Android

1. **Baixe o arquivo `google-services.json`:**
   - Acesse: https://console.firebase.google.com
   - Selecione seu projeto: `cash-6138e`
   - Adicione um app Android
   - Package name: `com.nexa.novasignal`
   - Baixe `google-services.json`

2. **Cole o arquivo em:**
   ```
   android/app/google-services.json
   ```

### PASSO 6: Verificar Gradle

Os arquivos Gradle já estão configurados nos arquivos que você forneceu. Apenas certifique-se de que:

**`android/build.gradle` já tem:**
```gradle
id("com.google.gms.google-services") version "4.4.2" apply false
```

**`android/app/build.gradle` já tem:**
```gradle
id("com.google.gms.google-services")
implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
implementation("com.google.firebase:firebase-analytics")
implementation("com.google.firebase:firebase-auth")
implementation("com.google.firebase:firebase-firestore")
```

### PASSO 7: Instalar Dependências

Execute no terminal:

```bash
flutter pub get
flutter pub upgrade
```

### PASSO 8: Build e Test

**Para Android:**
```bash
flutter build apk --release
```

**Para Web:**
```bash
flutter build web --release
```

**Para testar localmente:**
```bash
# Web
flutter run -d chrome --web-port 8080

# Android
flutter run -d <device-id>
```

---

## 🔗 URLs Configuradas no Deriv Dashboard

Você precisa configurar estas URLs exatas no dashboard do Deriv para o App ID 71954:

### Redirect URLs:

| Plataforma | Redirect URL |
|------------|-------------|
| **Android** | `https://SEU-USERNAME.github.io/novasignal/deriv-redirect-android.html` |
| **Web** | `https://SEU-USERNAME.github.io/novasignal/deriv-redirect-web.html` |

### Verification URL:
Deixe em branco (não é necessário)

---

## 📱 Fluxo de Autenticação

### Android:
1. Usuário clica "Conectar com Deriv"
2. Abre navegador → Deriv OAuth
3. Usuário faz login
4. Deriv redireciona para: `deriv-redirect-android.html`
5. HTML processa e abre: `novasignal://deriv-callback?token1=xxx`
6. Deep link abre o app
7. App conecta ao WebSocket com o token

### Web:
1. Usuário clica "Conectar com Deriv"
2. Redireciona para Deriv OAuth
3. Usuário faz login
4. Deriv redireciona para: `deriv-redirect-web.html`
5. HTML processa e redireciona para: `https://SEU-DOMINIO.com/deriv-callback?token1=xxx`
6. App processa o token e conecta

---

## 🎯 Checklist Final

### Arquivos HTML:
- [ ] `deriv-redirect-android.html` hospedado
- [ ] `deriv-redirect-web.html` hospedado
- [ ] URLs atualizadas nos arquivos HTML

### Deriv Dashboard:
- [ ] Redirect URLs configurados
- [ ] Scopes configurados (Read, Trade, Payments)
- [ ] App ID verificado: 71954

### Firebase:
- [ ] `google-services.json` baixado e colocado em `android/app/`
- [ ] Firebase configurado no `index.html`
- [ ] `firebase_options.dart` criado

### Código:
- [ ] URLs atualizadas em `deriv_auth_service.dart`
- [ ] Deep link scheme correto: `novasignal://deriv-callback`
- [ ] Dependências instaladas: `flutter pub get`

### Build:
- [ ] App compila sem erros
- [ ] OAuth funciona no Android
- [ ] OAuth funciona na Web
- [ ] Login Firebase funciona

---

## 🐛 Troubleshooting

### OAuth não redireciona:
1. Verifique se as URLs no Deriv Dashboard estão corretas
2. Teste as URLs HTML no navegador
3. Verifique console do navegador para erros

### Deep Link não funciona (Android):
1. Verifique o `AndroidManifest.xml`
2. Reinstale o app: `flutter clean && flutter run`
3. Teste manualmente: `adb shell am start -W -a android.intent.action.VIEW -d "novasignal://deriv-callback?token1=test"`

### Firebase não conecta:
1. Verifique se `google-services.json` está no lugar correto
2. Verifique se o package name está correto: `com.nexa.novasignal`
3. Limpe e reconstrua: `flutter clean && flutter pub get`

### Token não salva:
1. Adicione permissões no `AndroidManifest.xml`
2. Verifique se SharedPreferences está funcionando
3. Teste em dispositivo real (não emulador)

---

## 📚 Links Úteis

- **Deriv API Docs:** https://api.deriv.com/
- **Firebase Console:** https://console.firebase.google.com
- **Deriv Dashboard:** https://app.deriv.com/account/api-token
- **GitHub Pages:** https://pages.github.com/

---

## 📝 Resumo das URLs que Você Precisa Substituir

1. **Em `deriv-redirect-android.html`:**
   - Linha 125: Deep link scheme (se alterou)
   - Linha 142: Link do APK para download

2. **Em `deriv-redirect-web.html`:**
   - Linha 84: URL da sua aplicação web

3. **Em `deriv_auth_service.dart`:**
   - Linha 24: URL do redirect Android
   - Linha 25: URL do redirect Web

4. **No Deriv Dashboard:**
   - Redirect URL Android
   - Redirect URL Web

---

**✅ Pronto! Seu app está configurado com Firebase e Deriv OAuth!**

Se tiver dúvidas, verifique os logs do console e do WebSocket.