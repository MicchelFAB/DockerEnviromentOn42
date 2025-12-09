# syntax=docker/dockerfile:1.4

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Dependências do sistema para Flutter/Android
RUN apt-get update && apt-get install -y \
    curl git unzip wget xz-utils file \
    openjdk-17-jdk \
    libglu1-mesa mesa-utils \
    clang cmake ninja-build pkg-config libgtk-3-dev \
    ca-certificates \
    sudo \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Ensure tar extractions do not fail trying to set owners/timestamps from archives
RUN mv /usr/bin/tar /usr/bin/tar-original && \
    printf '#!/bin/sh\nexec /usr/bin/tar-original --no-same-owner --no-same-permissions "$@"\n' > /usr/bin/tar && \
    chmod +x /usr/bin/tar

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for GitHub Agentic Workflows)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório home para developer (mas rodar como root)
RUN mkdir -p /home/developer && \
    chmod 777 /home/developer

# Variáveis de ambiente (SDKs nos volumes montados)
ENV FLUTTER_HOME=/home/developer/flutter
ENV ANDROID_HOME=/home/developer/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PUB_CACHE=/home/developer/pub-cache
ENV GRADLE_USER_HOME=/home/developer/gradle-cache
ENV PATH="${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# Script de setup dos SDKs
COPY setup-sdks.sh /home/developer/setup-sdks.sh
RUN chmod +x /home/developer/setup-sdks.sh

# Rodar como root (seguro no Docker Rootless - mapeia para seu user no host)
WORKDIR /home/developer

# Configure git
RUN git config --global --add safe.directory /workspace

# Authenticate GitHub CLI using secret (only available at build time, not in final image)
RUN --mount=type=secret,id=gh_token \
    GH_TOKEN=$(cat /run/secrets/gh_token 2>/dev/null || echo "") && \
    if [ -n "$GH_TOKEN" ]; then \
        echo "$GH_TOKEN" | gh auth login --with-token && \
        gh extension install githubnext/gh-aw || true; \
    fi


# Comando padrão: setup e shell interativo
CMD ["/bin/bash", "-c", "/home/developer/setup-sdks.sh && exec /bin/bash"]
