#!/bin/bash
# Helper para executar comandos Flutter no container

CONTAINER="flutter-dev"

if ! docker ps -q -f name="$CONTAINER" | grep -q .; then
    echo "❌ Container não está rodando."
    echo "Execute: docker-compose up -d"
    exit 1
fi

if [ "$1" = "shell" ]; then
    docker exec -it "$CONTAINER" /bin/bash
elif [ $# -eq 0 ]; then
    echo "🎯 Flutter Helper"
    echo ""
    echo "Uso:"
    echo "  ./flutter.sh <comando>    - Executa comando Flutter"
    echo "  ./flutter.sh shell        - Abre shell no container"
    echo ""
    echo "Exemplos:"
    echo "  ./flutter.sh doctor"
    echo "  ./flutter.sh create meu_app"
    echo "  ./flutter.sh run"
else
    docker exec -it "$CONTAINER" flutter "$@"
fi
