#!/bin/bash

set -e

echo "🚀 Configurando ambiente Flutter/Android..."

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Garantir que diretórios de cache existam e sejam graváveis
echo -e "${YELLOW}📂 Preparando diretórios de cache...${NC}"
mkdir -p "$PUB_CACHE" "$GRADLE_USER_HOME" 2>/dev/null || true
mkdir -p "$FLUTTER_HOME/bin/cache" 2>/dev/null || true
mkdir -p "$ANDROID_HOME" 2>/dev/null || true

# Dar permissões amplas
chmod -R 777 "$FLUTTER_HOME" 2>/dev/null || true
chmod -R 777 "$ANDROID_HOME" 2>/dev/null || true
chmod -R 777 "$PUB_CACHE" 2>/dev/null || true
chmod -R 777 "$GRADLE_USER_HOME" 2>/dev/null || true

# 1. Instalar Flutter SDK
if [ ! -f "$FLUTTER_HOME/bin/flutter" ]; then
    echo -e "${YELLOW}📦 Baixando Flutter SDK...${NC}"
    TMP_DIR="/home/developer/flutter-install"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
    git clone https://github.com/flutter/flutter.git flutter-sdk -b stable --depth 1
    echo -e "${YELLOW}📦 Copiando para $FLUTTER_HOME...${NC}"
    
    cp -r flutter-sdk/* "$FLUTTER_HOME"/ 2>/dev/null || true
    cp -r flutter-sdk/.??* "$FLUTTER_HOME"/ 2>/dev/null || true
    chmod -R +x "$FLUTTER_HOME/bin" 2>/dev/null || true
    
    cd ~
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}✓ Flutter SDK instalado${NC}"
else
    echo -e "${GREEN}✓ Flutter SDK já existe${NC}"
fi

# 2. Instalar Android cmdline-tools
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo -e "${YELLOW}📦 Baixando Android cmdline-tools...${NC}"
    TMP_DIR="/tmp/android-install"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip
    unzip -q commandlinetools-linux-8512546_latest.zip
    
    echo -e "${YELLOW}📦 Copiando para $ANDROID_HOME...${NC}"
    mkdir -p "$ANDROID_HOME/cmdline-tools/latest" 2>/dev/null || true
    cp -r cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
    cp -r cmdline-tools/.??* "$ANDROID_HOME/cmdline-tools/latest/" 2>/dev/null || true
    chmod -R +x "$ANDROID_HOME/cmdline-tools/latest/bin" 2>/dev/null || true
    
    cd ~
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}✓ Android cmdline-tools instalado${NC}"
else
    echo -e "${GREEN}✓ Android cmdline-tools já existe${NC}"
fi

# 3. Instalar componentes Android
if [ ! -d "$ANDROID_HOME/platform-tools" ]; then
    echo -e "${YELLOW}📦 Instalando componentes Android...${NC}"
    
    mkdir -p "$ANDROID_HOME"
    chmod -R 777 "$ANDROID_HOME" 2>/dev/null || true
    
    # Criar diretório temporário para cache do sdkmanager
    TEMP_HOME="/tmp/android-home"
    mkdir -p "$TEMP_HOME/.android/cache"
    chmod -R 777 "$TEMP_HOME/.android" 2>/dev/null || true
    
    # Criar ~/.android persistente
    mkdir -p "$HOME/.android" 2>/dev/null || true
    touch "$HOME/.android/repositories.cfg" 2>/dev/null || true
    chmod -R 777 "$HOME/.android" 2>/dev/null || true
    
    # Aceitar licenças e instalar componentes
    echo -e "${YELLOW}Aceitando licenças...${NC}"
    SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
    HOME="$TEMP_HOME" ANDROID_SDK_HOME="$TEMP_HOME" ANDROID_USER_HOME="$TEMP_HOME/.android" \
        yes | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --licenses 2>&1 || true
    
    echo -e "${YELLOW}Instalando platform-tools, build-tools e platform...${NC}"
    HOME="$TEMP_HOME" ANDROID_SDK_HOME="$TEMP_HOME" ANDROID_USER_HOME="$TEMP_HOME/.android" \
        "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --verbose \
        "platform-tools" "platforms;android-36" "build-tools;36.0.0"
    
    echo -e "${GREEN}✓ Componentes Android instalados${NC}"
else
    echo -e "${GREEN}✓ Componentes Android já existem${NC}"
fi

# 4. Configurar Flutter
echo -e "${YELLOW}⚙️  Configurando Flutter...${NC}"

# Se o Flutter SDK montado não for gravável, usar cópia em volume nomeado
if [ ! -w "$FLUTTER_HOME/bin/cache" ]; then
    echo -e "${YELLOW}⚠️  Flutter SDK not writable; creating writable runtime copy...${NC}"
    RUNTIME_FLUTTER="/home/developer/flutter-exec"
    
    mkdir -p "$RUNTIME_FLUTTER"
    cp -a "$FLUTTER_HOME/." "$RUNTIME_FLUTTER/" 2>/dev/null || true
    chmod -R 777 "$RUNTIME_FLUTTER" 2>/dev/null || true
    
    export FLUTTER_HOME="$RUNTIME_FLUTTER"
    export PATH="${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"
    echo -e "${GREEN}✓ Using writable Flutter at $FLUTTER_HOME${NC}"
else
    chmod -R 777 "$FLUTTER_HOME" 2>/dev/null || true
fi

# Configurar git safe directory
git config --global --add safe.directory "$FLUTTER_HOME" 2>/dev/null || true

export FLUTTER_DISABLE_ANALYTICS=true
flutter config --no-analytics
flutter config --android-sdk "$ANDROID_HOME"
flutter doctor

echo -e "${GREEN}✅ Ambiente pronto!${NC}"
echo ""
echo "📱 Use: flutter <command>"
echo "🔧 Workspace: /workspace"
echo ""
