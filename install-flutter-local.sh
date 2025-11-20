#!/bin/bash
set -euo pipefail

echo "🚀 Instalando Flutter e Android SDK localmente (sem sudo/docker)"
echo ""

# Montagem NFS (somente dados/caches)
SGOINFRE="/home/mamaral-/sgoinfre"
ANDROID_NFS="$SGOINFRE/android-sdk"   # Armazenará 'platforms' e artefatos pesados (somente leitura/grav.)
PUB_CACHE_NFS="$SGOINFRE/pub-cache"
GRADLE_CACHE_NFS="$SGOINFRE/gradle-cache"

# Diretórios locais (executáveis e ferramentas)
LOCAL_HOME="$HOME/.local"
JAVA_DIR="$LOCAL_HOME/openjdk-11"
FLUTTER_DIR="$LOCAL_HOME/flutter-sdk"   # Flutter totalmente local (executáveis + Dart SDK)
ANDROID_DIR="$LOCAL_HOME/android-sdk"   # cmdline-tools, platform-tools e build-tools locais

mkdir -p "$LOCAL_HOME"
mkdir -p "$ANDROID_DIR"
mkdir -p "$ANDROID_NFS"
mkdir -p "$PUB_CACHE_NFS" "$GRADLE_CACHE_NFS"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📂 Usando diretório: $SGOINFRE${NC}"
echo ""

# 1. Java local (executável precisa estar fora do NFS/noexec)
if [ ! -d "$JAVA_DIR" ]; then
    echo -e "${YELLOW}📦 Baixando OpenJDK 11 (local)...${NC}"
    cd "$LOCAL_HOME"
    wget -q https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
    tar -xzf openjdk-11.0.2_linux-x64_bin.tar.gz
    mv jdk-11.0.2 "$(basename "$JAVA_DIR")"
    rm openjdk-11.0.2_linux-x64_bin.tar.gz
    echo -e "${GREEN}✓ OpenJDK instalado em $JAVA_DIR${NC}"
else
    echo -e "${GREEN}✓ OpenJDK já existe em $JAVA_DIR${NC}"
fi

export JAVA_HOME="$JAVA_DIR"
export PATH="$JAVA_HOME/bin:$PATH"

# 2. Flutter local (para evitar lock/exec em NFS)
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
    echo -e "${YELLOW}📦 Clonando Flutter SDK (local)...${NC}"
    git clone https://github.com/flutter/flutter.git "$FLUTTER_DIR" -b stable --depth 1
    echo -e "${GREEN}✓ Flutter SDK instalado em $FLUTTER_DIR${NC}"
else
    echo -e "${GREEN}✓ Flutter SDK já existe em $FLUTTER_DIR${NC}"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# 3. Android SDK - cmdline-tools LOCAL, plataformas no NFS
# 3.1 cmdline-tools (LOCAL)
if [ ! -f "$ANDROID_DIR/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo -e "${YELLOW}📦 Baixando Android cmdline-tools (local)...${NC}"
    mkdir -p "$ANDROID_DIR/cmdline-tools"
    cd "$ANDROID_DIR"
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip -d cmdline-tools
    mv cmdline-tools/cmdline-tools cmdline-tools/latest
    rm cmdline-tools.zip
    echo -e "${GREEN}✓ cmdline-tools instalado em $ANDROID_DIR${NC}"
else
    echo -e "${GREEN}✓ cmdline-tools já existe em $ANDROID_DIR${NC}"
fi

export ANDROID_HOME="$ANDROID_DIR"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# 3.2 Instalar executáveis (LOCAL): platform-tools e build-tools
if [ ! -d "$ANDROID_HOME/platform-tools" ] || [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    echo -e "${YELLOW}📦 Instalando executáveis Android locais...${NC}"
    yes | sdkmanager --licenses >/dev/null 2>&1 || true
    sdkmanager "platform-tools" "build-tools;34.0.0"
    echo -e "${GREEN}✓ platform-tools e build-tools instalados localmente${NC}"
else
    echo -e "${GREEN}✓ Executáveis Android já instalados localmente${NC}"
fi

# 3.3 Instalar plataformas (NFS) e ligar no local
if [ ! -d "$ANDROID_NFS/platforms/android-34" ]; then
    echo -e "${YELLOW}📦 Instalando plataformas Android no NFS...${NC}"
    ANDROID_SDK_ROOT="$ANDROID_NFS" ANDROID_HOME="$ANDROID_NFS" sdkmanager "platforms;android-34"
    # Aceitar licenças no NFS também
    ANDROID_SDK_ROOT="$ANDROID_NFS" ANDROID_HOME="$ANDROID_NFS" bash -lc 'yes | sdkmanager --licenses >/dev/null 2>&1 || true'
    echo -e "${GREEN}✓ platforms;android-34 instalado no NFS${NC}"
else
    echo -e "${GREEN}✓ platforms;android-34 já existe no NFS${NC}"
fi

# Linkar plataformas do NFS no SDK local
ln -sfn "$ANDROID_NFS/platforms" "$ANDROID_HOME/platforms"
echo -e "${GREEN}✓ Vinculado platforms -> $ANDROID_NFS/platforms${NC}"

# (Passo 4 consolidado acima)

# 4. Configurar caches (somente dados) no NFS com symlinks locais
echo -e "${YELLOW}🔗 Configurando caches...${NC}"
mkdir -p "$PUB_CACHE_NFS" "$GRADLE_CACHE_NFS" "$SGOINFRE/android-config"
rm -rf "$HOME/.pub-cache" "$HOME/.gradle" "$HOME/.android" 2>/dev/null || true
ln -sfn "$PUB_CACHE_NFS" "$HOME/.pub-cache"
ln -sfn "$GRADLE_CACHE_NFS" "$HOME/.gradle"
ln -sfn "$SGOINFRE/android-config" "$HOME/.android"
echo -e "${GREEN}✓ Caches configurados${NC}"

# 5. Configurar Flutter
echo -e "${YELLOW}⚙️  Configurando Flutter...${NC}"
# Evitar conflitos de lock de inicialização
pkill -f "${FLUTTER_DIR}/bin/flutter" 2>/dev/null || true
pkill -f "${FLUTTER_DIR}/bin/cache/dart-sdk/bin/dart" 2>/dev/null || true
LOCKFILE="${FLUTTER_DIR}/bin/cache/lockfile"
[ -f "$LOCKFILE" ] && rm -f "$LOCKFILE" || true

# Primeira inicialização controlada
export FLUTTER_DISABLE_ANALYTICS=true
flutter --version >/dev/null 2>&1 || true

# Aplicar configurações
flutter config --no-analytics
flutter config --android-sdk "$ANDROID_HOME"

# 7. Verificar instalação
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📝 Adicione ao seu ~/.zshrc:"
echo ""
echo -e "${YELLOW}export JAVA_HOME=\"$JAVA_DIR\"${NC}"
echo -e "${YELLOW}export FLUTTER_HOME=\"$FLUTTER_DIR\"${NC}"
echo -e "${YELLOW}export ANDROID_HOME=\"$ANDROID_DIR\"${NC}"
echo -e "${YELLOW}export ANDROID_SDK_ROOT=\"$ANDROID_DIR\"${NC}"
echo -e "${YELLOW}export PUB_CACHE=\"$PUB_CACHE_NFS\"${NC}"
echo -e "${YELLOW}export GRADLE_USER_HOME=\"$GRADLE_CACHE_NFS\"${NC}"
echo -e "${YELLOW}export PATH=\"\$JAVA_HOME/bin:\$FLUTTER_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\"${NC}"
echo ""
echo -e "${BLUE}Depois execute: source ~/.zshrc${NC}"
echo ""
echo "🧪 Teste com: flutter doctor"
echo ""
