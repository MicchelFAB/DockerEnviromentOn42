#!/bin/bash

# Script para fazer build da imagem Docker com suporte a GitHub token seguro

set -e

# Carregar variáveis do .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Erro: Arquivo .env não encontrado"
    exit 1
fi

# Verificar se GH_TOKEN está definido
if [ -z "$GH_TOKEN" ]; then
    echo "Erro: GH_TOKEN não está definido no .env"
    exit 1
fi

echo "🔨 Building Docker image com GitHub token seguro..."

# Ativar BuildKit e fazer build com secret
export DOCKER_BUILDKIT=1

# Criar arquivo temporário com o token
TEMP_TOKEN=$(mktemp)
echo "$GH_TOKEN" > "$TEMP_TOKEN"

# Build da imagem
docker build \
    --secret id=gh_token,src="$TEMP_TOKEN" \
    -t flutter-dev:latest \
    -f Dockerfile \
    .

# Limpar arquivo temporário
rm "$TEMP_TOKEN"

echo "✅ Build concluído com sucesso!"
echo ""
echo "Para iniciar o container, execute:"
echo "  docker-compose up flutter-dev"
