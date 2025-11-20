# Shared Workspace Directory

This directory (`pastaCompartilhada`) is the workspace folder that gets mounted into the Docker container at `/workspace`.

## Purpose

- **Development files**: Place your Flutter projects here
- **Shared access**: Files are accessible from both host and container
- **Persistence**: Your code is stored on the host, not inside the container
- **Backup**: Since files are on the host, they're safer than container-only storage

## Usage

### Creating a new Flutter project

**From inside the container** (recommended):
```bash
# If using VSCode Dev Containers, just open a terminal (already inside container)
# Or connect to the container:
docker exec -it flutter-dev-container bash

# Then create your project:
cd /workspace
flutter create my_app
cd my_app
flutter run
```

**From the host using the helper script**:
```bash
./flutter.sh create my_app
```

### File structure

After creating a project, your directory will look like:
```
pastaCompartilhada/
├── README.md          # This file
└── my_app/           # Your Flutter project
    ├── lib/
    ├── test/
    ├── pubspec.yaml
    └── ...
```

## Editing Files

You can edit files in this directory using:

1. **VSCode Dev Containers**: Opens VSCode inside the container with full access
2. **Host editor**: Edit files on your host machine (they sync automatically)
3. **Container shell**: Use vim/nano inside the container

## Important Notes

- ✅ Safe to commit to git
- ✅ Files persist across container restarts
- ✅ Accessible from both host and container
- ⚠️ Don't delete this directory if you have projects here
- ⚠️ Keep project files here, not in other container directories

## Gitignore

This directory contains a `.gitignore` file to exclude Flutter build artifacts while keeping your source code.

## Need Help?

- Check the main [README.md](../README.md) for general setup
- See [DEVCONTAINER_SETUP.md](../DEVCONTAINER_SETUP.md) for Dev Container details
- Review your `docker-compose.yaml` to verify mount points
