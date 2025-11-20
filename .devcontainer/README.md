# Dev Container Configuration

This directory contains the configuration for Visual Studio Code's Dev Containers extension.

## What is a Dev Container?

A Dev Container allows you to use a Docker container as a full-featured development environment. VSCode will run inside (or connected to) the container, giving you access to all the tools, SDKs, and configurations defined in the container.

## Files

- **devcontainer.json**: Main configuration file that tells VSCode how to connect to the container

## Configuration Details

### Service Integration
The `devcontainer.json` references the `flutter-dev` service defined in `../docker-compose.yaml`. This means:
- The container is built using the `Dockerfile` in the parent directory
- All volume mounts and environment variables from `docker-compose.yaml` are applied
- The workspace folder is set to `/workspace` inside the container

### Extensions
The following VSCode extensions are automatically installed when you open the Dev Container:
- **Dart**: Official Dart language support
- **Flutter**: Official Flutter framework support
- **Docker**: Docker file support and management

### Settings
Pre-configured settings include:
- Flutter SDK path: `/home/developer/flutter`
- Dart SDK path: `/home/developer/flutter/bin/cache/dart-sdk`
- File watcher exclusions for build directories to improve performance

### Port Forwarding
The following ports are automatically forwarded:
- `8080`: Flutter web server
- `5000-5002`: Flutter debug servers

### User Configuration
The container runs as `root` user. This is necessary because:
1. NFS volumes mounted from the host may have permission restrictions
2. The 42 School environment uses user namespace remapping
3. Running as root in the container doesn't affect host security in rootless Docker

For more details, see `../DEVCONTAINER_SETUP.md`.

## Usage

1. Install the "Dev Containers" extension in VSCode: `ms-vscode-remote.remote-containers`
2. Open this project in VSCode
3. Click "Reopen in Container" when prompted, or use `F1` → "Dev Containers: Reopen in Container"
4. VSCode will build (if needed) and connect to the container
5. All terminal commands will run inside the container automatically

## Troubleshooting

### "Cannot connect to container"
- Make sure Docker is running: `docker ps`
- Try rebuilding: `F1` → "Dev Containers: Rebuild Container"
- Check Docker Compose: `docker-compose ps`

### "Extensions not installing"
- Wait for the container to fully start
- Check the Dev Container logs: `F1` → "Dev Containers: Show Container Log"
- Manually install extensions from the Extensions panel

### "Flutter SDK not found"
- The SDKs are installed on first run by `setup-sdks.sh`
- Check installation: Open terminal and run `flutter doctor`
- View logs: `docker logs flutter-dev-container`

## Customization

To customize the Dev Container configuration:

1. Edit `devcontainer.json` to add/remove extensions
2. Modify VSCode settings in the `settings` section
3. Add additional port forwards in the `forwardPorts` array
4. Change the remote user if needed (not recommended for this setup)

After making changes, rebuild the container:
- `F1` → "Dev Containers: Rebuild Container"

## Learn More

- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
- [Docker Compose Integration](https://code.visualstudio.com/docs/devcontainers/docker-compose)
