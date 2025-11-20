# Complete Setup Guide

This guide walks you through setting up the Flutter Docker development environment step-by-step.

## Prerequisites

Before starting, ensure you have:

1. **Docker installed** and running
   ```bash
   docker --version
   # Should show Docker version 20.10 or later
   ```

2. **Docker Compose installed**
   ```bash
   docker-compose --version
   # Should show docker-compose version 1.29 or later
   ```

3. **VSCode installed** (for Dev Containers method)
   ```bash
   code --version
   ```

4. **Access to goinfre/NFS mount**
   ```bash
   ls ~/goinfre
   # Should list directory contents
   ```

5. **Sufficient disk space on NFS**
   ```bash
   df -h ~/goinfre
   # Need at least 5GB free
   ```

## Step-by-Step Setup

### Step 1: Clone the Repository

```bash
cd ~
git clone https://github.com/MicchelFAB/DockerEnviromentOn42.git
cd DockerEnviromentOn42
```

### Step 2: Configure Paths

The default configuration uses `/home/YOUR_USERNAME/goinfre/volumes/` for NFS storage. You MUST update the paths:

1. **Edit `docker-compose.yaml`:**
   ```bash
   nano docker-compose.yaml
   ```

2. **Update the volume paths** with your username and project path:
   ```yaml
   volumes:
     # Change to your Flutter project directory:
     - /home/YOUR_USERNAME/your-project:/workspace:cached
     
     # Update with your username:
     - /home/YOUR_USERNAME/goinfre/volumes/flutter-sdk:/home/developer/flutter:cached
     - /home/YOUR_USERNAME/goinfre/volumes/android-sdk:/home/developer/android-sdk:cached
     - /home/YOUR_USERNAME/goinfre/volumes/android-config:/home/developer/.android:cached
   ```

3. **Important notes:**
   - Replace `YOUR_USERNAME` with your actual 42 username
   - The `goinfre/volumes/` structure is required for proper NFS permissions
   - Do NOT use `~/` notation - use full absolute paths

### Step 3: Prepare NFS Directories

Create the required directories on your NFS mount:

```bash
mkdir -p /home/$USER/goinfre/volumes/flutter-sdk
mkdir -p /home/$USER/goinfre/volumes/android-sdk
mkdir -p /home/$USER/goinfre/volumes/android-config
```

### Step 4: Choose Your Setup Method

You have two options:

#### Option A: VSCode Dev Containers (Recommended)

**Advantages:**
- ✅ Fully integrated IDE experience
- ✅ Automatic container management
- ✅ Extensions auto-install
- ✅ Best for daily development

**Steps:**

1. **Install Dev Containers extension:**
   ```bash
   code --install-extension ms-vscode-remote.remote-containers
   ```

2. **Open project in VSCode:**
   ```bash
   code .
   ```

3. **Reopen in container:**
   - Click "Reopen in Container" when prompted, OR
   - Press `F1` → Type "Dev Containers: Reopen in Container" → Enter

4. **Wait for setup:**
   - First run takes 5-10 minutes
   - Downloads Flutter SDK (~1.5GB)
   - Downloads Android SDK (~3GB)
   - Watch progress in terminal output

5. **Verify installation:**
   - Open terminal in VSCode (Ctrl+`)
   - Run:
     ```bash
     flutter doctor
     ```
   - Should show Flutter and Android SDK installed

#### Option B: Docker Compose Direct

**Advantages:**
- ✅ No VSCode required
- ✅ Use any editor
- ✅ More control over container

**Steps:**

1. **Build and start container:**
   ```bash
   docker-compose up -d --build
   ```

2. **Monitor installation progress:**
   ```bash
   docker logs -f flutter-dev-container
   ```
   - Wait for "✅ Ambiente pronto!" message
   - Press Ctrl+C to exit log view

3. **Verify installation:**
   ```bash
   docker exec -it flutter-dev-container flutter doctor
   ```

### Step 5: Create Your First Project

**Using VSCode Dev Containers:**

1. Open terminal in VSCode (Ctrl+`)
2. Create project:
   ```bash
   cd /workspace
   flutter create hello_flutter
   cd hello_flutter
   flutter run -d web-server --web-port 8080
   ```
3. Open browser to http://localhost:8080

**Using Docker directly:**

1. Create project:
   ```bash
   ./flutter.sh create hello_flutter
   ```

2. Files will be in `./pastaCompartilhada/hello_flutter`

3. Run the app:
   ```bash
   cd pastaCompartilhada/hello_flutter
   ../../flutter.sh run -d web-server --web-port 8080
   ```

4. Open browser to http://localhost:8080

### Step 6: Daily Development Workflow

**With VSCode Dev Containers:**

```bash
# 1. Open project
code ~/DockerEnviromentOn42

# 2. VSCode connects to container automatically

# 3. Work normally:
flutter create my_app
flutter pub get
flutter run
```

**With Docker Compose:**

```bash
# 1. Ensure container is running
docker-compose ps

# 2. Use helper script
./flutter.sh doctor
./flutter.sh create my_app

# 3. Or enter container
docker exec -it flutter-dev-container bash
flutter doctor
```

## Troubleshooting

### Issue: Container won't start

**Check Docker is running:**
```bash
docker ps
```

**Check logs for errors:**
```bash
docker-compose logs
```

**Rebuild container:**
```bash
docker-compose down
docker-compose up -d --build
```

### Issue: SDKs not installing

**Check disk space:**
```bash
df -h ~/goinfre
```

**Check permissions:**
```bash
touch ~/goinfre/test && rm ~/goinfre/test
```

**Manually run setup:**
```bash
docker exec -it flutter-dev-container bash
/home/developer/setup-sdks.sh
```

### Issue: VSCode can't connect

**Check extension is installed:**
```bash
code --list-extensions | grep ms-vscode-remote.remote-containers
```

**Check container is running:**
```bash
docker ps | grep flutter-dev
```

**Rebuild Dev Container:**
- Press `F1` in VSCode
- Type "Dev Containers: Rebuild Container"
- Press Enter

### Issue: Flutter commands not found

**Check PATH in container:**
```bash
docker exec -it flutter-dev-container bash -c 'echo $PATH'
```

**Check Flutter SDK location:**
```bash
docker exec -it flutter-dev-container bash -c 'ls -la /home/developer/flutter/bin/'
```

**Re-run setup:**
```bash
docker exec -it flutter-dev-container bash /home/developer/setup-sdks.sh
```

## Next Steps

Once setup is complete:

1. **Learn Flutter**: https://flutter.dev/docs/get-started/codelab
2. **Explore examples**: https://flutter.dev/docs/cookbook
3. **Add dependencies**: Edit `pubspec.yaml` in your project
4. **Use hot reload**: Press `r` in Flutter run console

## Additional Resources

- [README.md](./README.md) - Overview and quick start
- [DEVCONTAINER_SETUP.md](./DEVCONTAINER_SETUP.md) - Dev Containers details
- [.devcontainer/README.md](./.devcontainer/README.md) - Configuration reference
- [pastaCompartilhada/README.md](./pastaCompartilhada/README.md) - Workspace info

## Getting Help

If you're still having issues:

1. Check all paths in `docker-compose.yaml` are correct
2. Verify NFS mount is accessible and writable
3. Ensure Docker has enough resources (CPU/Memory)
4. Check Docker logs: `docker logs flutter-dev-container`
5. Try rebuilding from scratch:
   ```bash
   docker-compose down -v
   docker-compose up -d --build
   ```

---

**Happy Flutter development! 🚀**
