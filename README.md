# Flutter Docker Development Environment for 42 School

A containerized Flutter and Android SDK development environment optimized for 42 School's infrastructure, specifically designed to work with NFS storage (goinfre) and avoid local storage quota limitations.

## 🎯 Purpose

This setup allows you to:
- ✅ Develop Flutter applications with full Android SDK support
- ✅ Store large SDKs and caches on NFS (goinfre) instead of local storage
- ✅ Use VSCode with Dev Containers extension for seamless development
- ✅ Maintain persistent development environment across container rebuilds
- ✅ Work without requiring sudo privileges on the host machine

## 📋 Architecture

```
Host System (42 School)
├── ~/goinfre/volumes/              # NFS Storage (large files)
│   ├── flutter-sdk/                # Flutter SDK (~1.5GB)
│   ├── android-sdk/                # Android SDK (~3GB)  
│   └── android-config/             # Android configurations
│
└── ~/project/                      # Your project (this repo)
    ├── .devcontainer/
    │   └── devcontainer.json       # VSCode Dev Container config
    ├── Dockerfile                  # Container image definition
    ├── docker-compose.yaml         # Service and volume configuration
    ├── setup-sdks.sh              # SDK installation script
    └── flutter.sh                 # Helper script for Flutter commands

Container Environment
├── /workspace/                     # Your project files (mounted)
├── /home/developer/flutter/        # Flutter SDK (from NFS)
├── /home/developer/android-sdk/    # Android SDK (from NFS)
└── /home/developer/.pub-cache/     # Package cache (from NFS)
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- VSCode with "Dev Containers" extension (`ms-vscode-remote.remote-containers`)
- Access to goinfre NFS mount (typically `/home/$USER/goinfre`)

### Option 1: Using VSCode Dev Containers (Recommended)

1. **Clone this repository:**
   ```bash
   cd ~/project
   git clone <repository-url>
   cd DockerEnviromentOn42
   ```

2. **Update paths in `docker-compose.yaml`:**
   Edit the volume mounts to match your username and project:
   ```yaml
   # Change the workspace path to your project:
   - /home/YOUR_USERNAME/your-project:/workspace:cached
   
   # Update NFS paths with your username:
   - /home/YOUR_USERNAME/goinfre/volumes/flutter-sdk:/home/developer/flutter
   - /home/YOUR_USERNAME/goinfre/volumes/android-sdk:/home/developer/android-sdk
   ```

3. **Open in VSCode:**
   ```bash
   code .
   ```

4. **Reopen in Container:**
   - VSCode will detect the Dev Container configuration
   - Click "Reopen in Container" when prompted, or
   - Press `F1` → "Dev Containers: Reopen in Container"

5. **Wait for setup:**
   - First run will download and install Flutter and Android SDKs (5-10 minutes)
   - The `setup-sdks.sh` script runs automatically
   - Check progress: Terminal → View logs

6. **Start developing:**
   ```bash
   flutter doctor
   flutter create my_app
   cd my_app
   flutter run
   ```

### Option 2: Using Docker Compose Directly

1. **Build and start the container:**
   ```bash
   docker-compose up -d --build
   ```

2. **Check installation progress:**
   ```bash
   docker logs -f flutter-dev-container
   ```
   Wait for "✅ Ambiente pronto!" message.

3. **Use the helper script:**
   ```bash
   chmod +x flutter.sh
   
   # Check Flutter installation
   ./flutter.sh doctor
   
   # Create a new project
   ./flutter.sh create my_app
   
   # Run Flutter commands
   cd pastaCompartilhada/my_app
   ../../flutter.sh run
   ```

4. **Or enter the container directly:**
   ```bash
   docker exec -it flutter-dev-container bash
   flutter doctor
   ```

## 💻 Daily Usage

### With VSCode Dev Containers
Simply open the project in VSCode and it will connect to the running container automatically. All terminal commands run inside the container.

### With Helper Script
```bash
# Check environment status
./flutter.sh doctor

# Create a new Flutter project
./flutter.sh create project_name

# Run Flutter commands
./flutter.sh pub get
./flutter.sh run

# Open a shell in the container
./flutter.sh shell
```

### Direct Docker Commands
```bash
# Execute Flutter commands
docker exec -it flutter-dev-container flutter doctor

# Enter container shell
docker exec -it flutter-dev-container bash

# View container logs
docker logs -f flutter-dev-container

# Stop container
docker-compose down

# Restart container
docker-compose up -d
```

## 📱 Included Tools

- ✅ Flutter SDK (stable channel)
- ✅ Android SDK (API 34)
- ✅ Android Build Tools 34.0.0
- ✅ Android Platform Tools (adb)
- ✅ Java 17 (OpenJDK)
- ✅ Dart SDK (included with Flutter)
- ✅ Git, curl, wget, unzip
- ✅ Build essentials (clang, cmake, ninja)

## 🔧 Configuration

### Customizing NFS Path
Edit `docker-compose.yaml` to change the NFS storage location:

```yaml
volumes:
  - /your/custom/path/flutter-sdk:/home/developer/flutter:cached
  - /your/custom/path/android-sdk:/home/developer/android-sdk:cached
  # ... other volumes
```

### Customizing Project Path
By default, your code lives in `./pastaCompartilhada`. To change:

```yaml
volumes:
  - ./your-custom-folder:/workspace:cached
```

### Port Configuration
The following ports are exposed for web development:
- `8080`: Flutter web server
- `5000-5100`: Flutter debug servers

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs for errors
docker-compose logs

# Verify Docker is running
docker ps

# Rebuild from scratch
docker-compose down
docker-compose up -d --build
```

### Flutter SDK not found
```bash
# Enter container and check paths
docker exec -it flutter-dev-container bash
echo $PATH
which flutter
ls -la /home/developer/flutter/bin
```

### Permission errors on NFS
The container runs as root by default to handle NFS permission issues. If you encounter write errors:

```bash
# Verify NFS mount is writable
touch /home/$USER/goinfre/test.txt && rm /home/$USER/goinfre/test.txt
```

### SDKs not installing
```bash
# Manually run the setup script
docker exec -it flutter-dev-container bash /home/developer/setup-sdks.sh

# Check available disk space on NFS
df -h /home/$USER/goinfre
```

### VSCode can't connect to container
```bash
# Make sure container is running
docker ps | grep flutter-dev

# Restart the container
docker-compose restart

# Check VSCode Dev Containers extension is installed
code --list-extensions | grep ms-vscode-remote.remote-containers
```

## 🎯 Benefits of This Approach

1. **Local Storage Preserved**: SDKs and caches (~5GB+) stored on NFS, not local quota
2. **Persistent Environment**: Reinstalling container doesn't lose SDKs
3. **No Sudo Required**: Everything runs in container with proper permissions
4. **Reproducible**: Same environment across machines and team members
5. **VSCode Integration**: Full IDE features with Dev Containers
6. **Performance**: Cached volumes for faster I/O operations

## 📚 Additional Documentation

- **[DEVCONTAINER_SETUP.md](./DEVCONTAINER_SETUP.md)**: Detailed Dev Containers setup and troubleshooting
- **[Dockerfile](./Dockerfile)**: Container image specification
- **[docker-compose.yaml](./docker-compose.yaml)**: Service configuration
- **[setup-sdks.sh](./setup-sdks.sh)**: SDK installation script logic

## ⚠️ Important Notes

- **First run**: SDK installation takes 5-10 minutes and requires ~5GB on NFS
- **NFS permissions**: Container runs as root to handle NFS write restrictions
- **Network**: SDK downloads require internet access
- **Storage**: Ensure sufficient space on goinfre before starting

## 🤝 Contributing

Improvements and bug fixes are welcome! Please ensure changes work with:
- 42 School's infrastructure (NFS/goinfre)
- Docker rootless mode (if applicable)
- VSCode Dev Containers extension

## 📄 License

This project is provided as-is for educational purposes at 42 School.

## 🆘 Getting Help

If you encounter issues:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review logs: `docker logs flutter-dev-container`
3. Verify your setup matches the [Architecture](#-architecture) diagram
4. Check that paths in `docker-compose.yaml` match your system

---

**Happy coding! 🚀**
