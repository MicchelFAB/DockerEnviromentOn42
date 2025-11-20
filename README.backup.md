# Flutter Docker Development Environment# Flutter Docker Environment



Ambiente containerizado para desenvolvimento Flutter com Android SDK, otimizado para uso com NFS (sgoinfre).Ambiente containerizado para desenvolvimento Flutter com Android SDK, otimizado para uso com NFS.



## 📋 Arquitetura## 📋 Estrutura



``````

Host (local):/home/mamaral-/sgoinfre/          # Volumes NFS (persistência)

├── pastaCompartilhada/     # Seus projetos Flutter├── flutter-sdk/                   # Flutter SDK

├── Dockerfile├── android-sdk/                   # Android SDK  

├── docker-compose.yaml├── pub-cache/                     # Packages Dart/Flutter

├── setup-sdks.sh├── gradle-cache/                  # Cache Gradle

└── flutter.sh              # Helper script└── android-config/                # Configurações Android



NFS (sgoinfre):/home/mamaral-/Documents/42Advanced/

├── flutter-sdk/            # Flutter SDK (~1.5GB)├── pastaCompartilhada/            # Seus projetos (local + container)

├── android-sdk/            # Android SDK (~3GB)├── Dockerfile

├── pub-cache/              # Packages Dart/Flutter├── docker-compose.yaml

├── gradle-cache/           # Cache Gradle├── init-sdk.sh                    # Script de inicialização

└── android-config/         # Configurações Android├── flutter-helper.sh              # Helper para comandos

└── README.md

Container:```

├── /workspace -> pastaCompartilhada/

├── /opt/flutter -> sgoinfre/flutter-sdk/## 🚀 Uso

└── /opt/android-sdk -> sgoinfre/android-sdk/

```### 1. Primeira execução (instala SDKs - APENAS UMA VEZ)

```bash

## 🚀 Setup Inicial# Primeiro build da imagem Docker

docker-compose build

### 1. Build e iniciar container

```bash# Instala Flutter e Android SDK nos volumes NFS (5-10 minutos)

cd /home/mamaral-/Documents/42Advanced./setup-volumes.sh

docker-compose up -d --build

```# Inicia o container

docker-compose up -d

Na primeira execução, o container irá:```

- Baixar Flutter SDK (~1.5GB)

- Baixar Android SDK + tools (~3GB)### 2. Verificar instalação

- Instalar platforms;android-34```bash

- Configurar ambientedocker logs flutter-dev-container

```

**Aguarde 5-10 minutos** na primeira vez.

### 3. Usar Flutter

### 2. Verificar instalação

```bash#### Opção A: Com o helper script (recomendado)

docker logs -f flutter-dev```bash

```chmod +x flutter-helper.sh



Quando aparecer "✅ Ambiente pronto!", o setup terminou.# Verificar ambiente

./flutter-helper.sh doctor

### 3. Validar ambiente

```bash# Criar novo projeto

chmod +x flutter.sh./flutter-helper.sh create meu_app

./flutter.sh doctor

```# Instalar dependências

cd pastaCompartilhada/meu_app

## 💻 Uso Diário../../flutter-helper.sh pub get



### Executar comandos Flutter# Rodar app

./flutter-helper.sh run

```bash

# Via helper script (recomendado)# Abrir shell no container

./flutter.sh doctor./flutter-helper.sh shell

./flutter.sh create meu_app```

./flutter.sh pub get

./flutter.sh run#### Opção B: Comandos diretos

```bash

# Direto no container# Executar comando Flutter

docker exec -it flutter-dev flutter doctordocker exec -it flutter-dev-container flutter doctor

```

# Entrar no container

### Entrar no containerdocker exec -it flutter-dev-container bash

```

```bash

./flutter.sh shell## 💡 VSCode Integration

# ou

docker exec -it flutter-dev /bin/bash1. Abra o VSCode **no seu host** (não no container)

```2. Instale a extensão "Flutter"

3. Configure o Flutter SDK path para usar o container:

### Trabalhar com projetos

   **Método 1: Via settings.json**

```bash   ```json

# Criar novo projeto   {

./flutter.sh create meu_app     "dart.flutterSdkPath": "/home/mamaral-/sgoinfre/flutter-sdk"

   }

# Os arquivos ficam em:   ```

# - Container: /workspace/meu_app

# - Host: ./pastaCompartilhada/meu_app   **Método 2: Remote - Containers**

   - Instale extensão "Dev Containers"

# Editar no VSCode (host)   - Use "Attach to Running Container"

code ./pastaCompartilhada/meu_app   - Selecione `flutter-dev-container`



# Compilar no container## 🔧 Comandos úteis

./flutter.sh run

``````bash

# Parar container

## 🔧 Integração VSCodedocker-compose down



### Opção 1: Remote - Containers (recomendado)# Rebuild (após mudanças no Dockerfile)

docker-compose up -d --build

1. Instale a extensão "Dev Containers"

2. `Ctrl+Shift+P` → "Attach to Running Container"# Ver logs

3. Selecione `flutter-dev`docker logs -f flutter-dev-container

4. Instale extensões Flutter/Dart no container

# Limpar tudo (CUIDADO: apaga volumes NFS)

### Opção 2: Edição localdocker-compose down -v

rm -rf /home/mamaral-/sgoinfre/flutter-sdk

1. Edite arquivos em `./pastaCompartilhada/` no hostrm -rf /home/mamaral-/sgoinfre/android-sdk

2. Execute comandos via `./flutter.sh` ou dentro do container```

3. Flutter SDK do container será usado automaticamente

## 📦 O que está incluído

## 📦 Estrutura de Arquivos

- ✅ Flutter SDK (stable channel)

```- ✅ Android SDK (API 34)

42Advanced/- ✅ Build tools 34.0.0

├── Dockerfile                  # Imagem base- ✅ Platform tools

├── docker-compose.yaml         # Configuração de volumes- ✅ Emulator

├── setup-sdks.sh              # Setup automático dos SDKs- ✅ Java 11 (OpenJDK)

├── flutter.sh                 # Helper para comandos Flutter- ✅ Dart SDK (incluído no Flutter)

├── README.md                  # Este arquivo

└── pastaCompartilhada/        # Seus projetos## 🎯 Vantagens desta abordagem

    └── meu_app/

```1. **Espaço local preservado**: SDKs grandes ficam no NFS

2. **Persistência**: Reinstalar container não perde SDKs

## 🛠️ Comandos Úteis3. **Performance**: Cache compartilhado entre rebuilds

4. **Flexibilidade**: VSCode no host com todas funcionalidades

```bash5. **Sem sudo**: Tudo roda no container

# Parar container

docker-compose down## 🐛 Troubleshooting



# Rebuild (após mudanças no Dockerfile)### Container não inicia

docker-compose up -d --build```bash

docker-compose logs

# Ver logs```

docker logs -f flutter-dev

### Flutter não encontrado

# Limpar tudo (CUIDADO: apaga volumes NFS)```bash

docker-compose downdocker exec -it flutter-dev-container bash

rm -rf /home/mamaral-/sgoinfre/flutter-sdkecho $PATH

rm -rf /home/mamaral-/sgoinfre/android-sdkwhich flutter

```

# Restart container

docker-compose restart### Limpar cache

```bash

# Statusdocker exec -it flutter-dev-container flutter clean

docker-compose psdocker exec -it flutter-dev-container flutter pub cache repair

``````



## 📱 O que está incluído### Permissões NFS

Certifique-se que `/home/mamaral-/sgoinfre` é gravável:

- ✅ Flutter SDK (stable)```bash

- ✅ Android SDK (API 34)touch /home/mamaral-/sgoinfre/test.txt && rm /home/mamaral-/sgoinfre/test.txt

- ✅ Build tools 34.0.0```

- ✅ Platform tools (adb)
- ✅ Java 11 (OpenJDK)
- ✅ Dart SDK (incluído no Flutter)
- ✅ Clang, CMake, Ninja (para builds nativos)

## 🎯 Vantagens

1. **Sem restrição noexec**: Executáveis rodam no container
2. **Espaço local preservado**: SDKs grandes no NFS
3. **Persistência**: Rebuilds mantêm SDKs
4. **Performance**: Caches compartilhados
5. **Isolamento**: Ambiente reproduzível
6. **Sem sudo**: Tudo via Docker (se seu user está no grupo docker)

## 🐛 Troubleshooting

### Container não inicia
```bash
docker-compose logs
docker ps -a
```

### Flutter não encontrado
```bash
docker exec -it flutter-dev bash
echo $PATH
which flutter
flutter doctor -v
```

### Reinstalar SDKs
```bash
docker-compose down
rm -rf /home/mamaral-/sgoinfre/flutter-sdk/*
rm -rf /home/mamaral-/sgoinfre/android-sdk/*
docker-compose up -d
```

### Permissões NFS
```bash
touch /home/mamaral-/sgoinfre/test.txt && rm /home/mamaral-/sgoinfre/test.txt
```

## 📚 Workflow Exemplo

```bash
# 1. Iniciar ambiente
docker-compose up -d

# 2. Criar projeto
./flutter.sh create hello_flutter

# 3. Editar no VSCode
code ./pastaCompartilhada/hello_flutter

# 4. Instalar dependências
cd pastaCompartilhada/hello_flutter
../../flutter.sh pub get

# 5. Rodar (web)
../../flutter.sh run -d web-server --web-port 8080

# 6. Acessar no browser
# http://localhost:8080
```

## 🔐 Nota de Segurança

- **pastaCompartilhada**: Volume local (redundância, segurança)
- **sgoinfre**: Apenas SDKs e caches (dados não-críticos)
- Faça backup regular de seus projetos em `pastaCompartilhada`

## 💡 Dicas

- Use `./flutter.sh shell` para desenvolvimento interativo
- Hot reload funciona normalmente
- Para Android device real, configure USB forwarding (adb)
- Para web dev, acesse `localhost:8080`
- Logs em tempo real: `docker logs -f flutter-dev`
