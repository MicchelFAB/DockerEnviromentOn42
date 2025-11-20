# Flutter Android Development Environment - Docker Setup

## 🚀 Quick Start com VS Code Remote Containers

### Pré-requisitos
- VS Code instalado
- Docker e Docker Compose instalados
- Extensão "Dev Containers" instalada no VS Code (`ms-vscode-remote.remote-containers`)

### Passos

1. **Abra a pasta do projeto no VS Code:**
   ```bash
   code /home/mamaral-/Documents/42Advanced/Github/42Porto-MobilePiscine/Docker
   ```

2. **VS Code detectará a configuração de dev container:**
   - Uma notificação aparecerá: "Folder contains a Dev Container configuration file"
   - Clique em "Reopen in Container"
   - OU use o comando: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

3. **Aguarde a build e setup:**
   - Docker construirá a imagem
   - O script `setup-sdks.sh` será executado automaticamente
   - VS Code instalará as extensões Flutter/Dart

4. **Comece a desenvolver:**
   - Abra o terminal no VS Code (você estará dentro do container)
   - Use `flutter run` normalmente
   - Todas as dependências estão disponíveis

### Estrutura de Pastas

```
Docker/
├── .devcontainer/
│   └── devcontainer.json      # Configuração VS Code Remote Containers
├── docker-compose.yaml         # Configuração Docker Compose
├── Dockerfile                  # Imagem Docker
├── setup-sdks.sh              # Script de setup dos SDKs
├── pastaCompartilhada/        # Seu código de desenvolvimento
└── README.md
```

### Volumes Montados

- **Código**: `./pastaCompartilhada/` → `/workspace` (seu código de trabalho)
- **Flutter SDK**: `/home/mamaral-/goinfre/flutter-sdk` → `/home/developer/flutter`
- **Android SDK**: `/home/mamaral-/goinfre/android-sdk` → `/home/developer/android-sdk`
- **Pub Cache**: `/home/mamaral-/goinfre/pub-cache` → `/home/developer/pub-cache`
- **Gradle Cache**: `/home/mamaral-/goinfre/gradle-cache` → `/home/developer/gradle-cache`

### Portas Expostas

- **8080**: Flutter Dev Server
- **5000-5100**: Debug Server Flutter

## 📱 Usando Flutter

Dentro do VS Code (container):

```bash
# Verificar instalação
flutter doctor

# Criar novo projeto
flutter create --platforms android myapp

# Rodar em debug (precisa de dispositivo/emulador Android)
flutter run

# Rodar web (debug no browser)
flutter run -d chrome

# Build APK
flutter build apk
```

## 🛠️ Troubleshooting

### "Folder contains a Dev Container configuration file" não aparece
- Pressione `Ctrl+Shift+P` e procure "Dev Containers: Reopen in Container"

### Erro de permissão nos SDKs
- Os SDKs têm permissões 777, está OK para desenvolvimento
- Se precisar resetar: `sudo chmod -R 777 /home/mamaral-/goinfre/`

### Flutter não encontra Android SDK
- Execute dentro do container: `flutter doctor`
- Deve mostrar `[✓] Android toolchain`

### Acessar código de fora do container
- Seu código está em `./pastaCompartilhada/` no host
- Está montado em `/workspace` no container
- Editar em qualquer lugar sincroniza automaticamente

## 💡 Dicas

- Primeira build é lenta (download de dependências)
- Builds subsequentes são rápidas (cache)
- Hot reload funciona normalmente com `flutter run`
- Debugging funciona no VS Code (breakpoints, etc)
- Use `docker-compose down` quando terminar
- Use `docker-compose up` para retomar (rápido, sem rebuild)

## 🔄 Alternativa: Sem Docker Compose (se necessário)

Se preferir usar diretamente o Dockerfile sem docker-compose:

```bash
docker build -t flutter-android .
docker run -it \
  -v ./pastaCompartilhada:/workspace \
  -v /home/mamaral-/goinfre/flutter-sdk:/home/developer/flutter \
  -v /home/mamaral-/goinfre/android-sdk:/home/developer/android-sdk \
  -v /home/mamaral-/goinfre/pub-cache:/home/developer/pub-cache \
  -v /home/mamaral-/goinfre/gradle-cache:/home/developer/gradle-cache \
  flutter-android
```

Mas a forma com Dev Containers é muito mais confortável! 🎯

## ⚠️ Nota: execução do Dev Container como `root`

Por compatibilidade com ambientes Docker "rootless" e com remapeamento de UIDs no host, o devcontainer foi configurado para se conectar como `root` dentro do container (`.devcontainer/devcontainer.json` usa `"remoteUser": "root"`).

- Por que isso foi feito: alguns hosts (como o seu) usam user namespace remapping. UIDs altos do host (por exemplo `101034`) não estão mapeados dentro da namespace do container, o que impede o container de iniciar quando o VS Code tenta usar esse UID. Rodar como `root` contorna esse problema imediatamente.

- O que muda para você: o container inicia corretamente e o VS Code consegue editar o `workspace`. Processos dentro do container correm como root dentro do container, o que é comum em dev containers.

Como reverter para um usuário não-root mais tarde

1. Ajustar permissões do workspace no host (recomendado se quiser que os ficheiros no host pertençam ao seu usuário):

```bash
sudo chown -R $(id -u):$(id -g) /caminho/para/mobileModule00
```

2. Tentar reconstruir com o `developer` user ativo:

```bash
# (opcional) exporte seu UID/GID e reconstrua
export LOCAL_USER_ID=$(id -u)
export LOCAL_GID=$(id -g)
DOCKER_BUILDKIT=0 LOCAL_USER_ID=${LOCAL_USER_ID} LOCAL_GID=${LOCAL_GID} docker-compose build --no-cache
docker-compose up
```

3. Se quiser voltar a usar `developer` no VS Code, edite `.devcontainer/devcontainer.json` e altere `"remoteUser": "root"` para `"remoteUser": "developer"`, então reabra no container.

Se preferir, eu posso executar esses passos por si (ajustar permissões e testar a reconstrução). Diga qual abordagem prefere.
