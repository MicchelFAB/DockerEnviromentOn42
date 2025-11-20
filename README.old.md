# Flutter Docker Environment

Ambiente containerizado para desenvolvimento Flutter com Android SDK, otimizado para uso com NFS.

## 📋 Estrutura

```
/home/mamaral-/sgoinfre/          # Volumes NFS (persistência)
├── flutter-sdk/                   # Flutter SDK
├── android-sdk/                   # Android SDK  
├── pub-cache/                     # Packages Dart/Flutter
├── gradle-cache/                  # Cache Gradle
└── android-config/                # Configurações Android

/home/mamaral-/Documents/42Advanced/
├── pastaCompartilhada/            # Seus projetos (local + container)
├── Dockerfile
├── docker-compose.yaml
├── init-sdk.sh                    # Script de inicialização
├── flutter-helper.sh              # Helper para comandos
└── README.md
```

## 🚀 Uso

### 1. Primeira execução (instala SDKs - APENAS UMA VEZ)
```bash
# Primeiro build da imagem Docker
docker-compose build

# Instala Flutter e Android SDK nos volumes NFS (5-10 minutos)
./setup-volumes.sh

# Inicia o container
docker-compose up -d
```

### 2. Verificar instalação
```bash
docker logs flutter-dev-container
```

### 3. Usar Flutter

#### Opção A: Com o helper script (recomendado)
```bash
chmod +x flutter-helper.sh

# Verificar ambiente
./flutter-helper.sh doctor

# Criar novo projeto
./flutter-helper.sh create meu_app

# Instalar dependências
cd pastaCompartilhada/meu_app
../../flutter-helper.sh pub get

# Rodar app
./flutter-helper.sh run

# Abrir shell no container
./flutter-helper.sh shell
```

#### Opção B: Comandos diretos
```bash
# Executar comando Flutter
docker exec -it flutter-dev-container flutter doctor

# Entrar no container
docker exec -it flutter-dev-container bash
```

## 💡 VSCode Integration

1. Abra o VSCode **no seu host** (não no container)
2. Instale a extensão "Flutter"
3. Configure o Flutter SDK path para usar o container:

   **Método 1: Via settings.json**
   ```json
   {
     "dart.flutterSdkPath": "/home/mamaral-/sgoinfre/flutter-sdk"
   }
   ```

   **Método 2: Remote - Containers**
   - Instale extensão "Dev Containers"
   - Use "Attach to Running Container"
   - Selecione `flutter-dev-container`

## 🔧 Comandos úteis

```bash
# Parar container
docker-compose down

# Rebuild (após mudanças no Dockerfile)
docker-compose up -d --build

# Ver logs
docker logs -f flutter-dev-container

# Limpar tudo (CUIDADO: apaga volumes NFS)
docker-compose down -v
rm -rf /home/mamaral-/sgoinfre/flutter-sdk
rm -rf /home/mamaral-/sgoinfre/android-sdk
```

## 📦 O que está incluído

- ✅ Flutter SDK (stable channel)
- ✅ Android SDK (API 34)
- ✅ Build tools 34.0.0
- ✅ Platform tools
- ✅ Emulator
- ✅ Java 11 (OpenJDK)
- ✅ Dart SDK (incluído no Flutter)

## 🎯 Vantagens desta abordagem

1. **Espaço local preservado**: SDKs grandes ficam no NFS
2. **Persistência**: Reinstalar container não perde SDKs
3. **Performance**: Cache compartilhado entre rebuilds
4. **Flexibilidade**: VSCode no host com todas funcionalidades
5. **Sem sudo**: Tudo roda no container

## 🐛 Troubleshooting

### Container não inicia
```bash
docker-compose logs
```

### Flutter não encontrado
```bash
docker exec -it flutter-dev-container bash
echo $PATH
which flutter
```

### Limpar cache
```bash
docker exec -it flutter-dev-container flutter clean
docker exec -it flutter-dev-container flutter pub cache repair
```

### Permissões NFS
Certifique-se que `/home/mamaral-/sgoinfre` é gravável:
```bash
touch /home/mamaral-/sgoinfre/test.txt && rm /home/mamaral-/sgoinfre/test.txt
```
