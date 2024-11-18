# Docker Scripts

This directory contains scripts to manage Docker containers for ROS 2 development, including running containers and attaching terminals to them.

---

## run_docker Scripts

The `run_docker` scripts ([run_docker.sh](./run_docker.sh) for Unix-based systems and [run_docker.ps1](./run_docker.ps1) for Windows) provide a flexible setup for ROS 2 environments. You can specify ROS distribution, base profile, UI type, and graphics platform, allowing tailored configurations.

## Features

- **Automatic GPU Detection**: Determines GPU type (`NVIDIA` or `AMD`) for graphics platform settings.
- **WSL Support**: Adapts configurations for Windows Subsystem for Linux (WSL), ensuring seamless Docker integration.
- **Workspace Mounting**: Mounts your local ROS 2 workspace ([ros2_src](../ros2_src/)) to `/home/ros_user/ros2_ws/src` inside the container.
- **UI Selection**: Choose between terminal interaction or VNC for GUI-based applications.
- **Error Handling**: Provides detailed help messages and error diagnostics for troubleshooting.


### Unix-based Systems (`run_docker.sh`)

```bash
./run_docker.sh -d <distribution> -p <profile> -t <type> [-g <graphics_platform>] [-h]
```

### Windows Systems (`run_docker.ps1`)

```powershell
.\run_docker.ps1 [-ROS_DISTRO <string>] [-BASE <string>] [-UI <string>] [-GRAPHICS_PLATFORM <string>] [-Help]
```

## Options (Both Scripts)

| Option (Unix / PowerShell) | Description                                                                                   | Default   | Valid Values          |
|-------------------------|--------------------------------------------------------------------------------------------------|-----------|-----------------------|
| `-d` / `-ROS_DISTRO`    | Specify the ROS distribution.                                                                    | `iron`    | `jazzy`, `iron`, `humble` |
| `-p` / `-BASE`          | Specify the base profile.                                                                        | `desktop` | `desktop`, `base`     |
| `-t` / `-UI`            | Specify the UI type.                                                                             | `terminal`| `terminal`, `vnc`     |
| `-g` / `-GRAPHICS_PLATFORM` | (Optional) Specify the graphics platform. Automatically detected if not provided.            | Auto-detect | `standard`, `nvidia`, `amd` |
| `-h` / `-Help`          | Display the help message.                                                                        |           |                       |


### Examples

#### Unix-based Systems

```bash
./run_docker.sh -d iron -p desktop -t terminal -g nvidia
./run_docker.sh -d humble -p base -t vnc
```

#### Windows Systems

* Using powershell:

```powershell
.\run_docker.ps1 -ROS_DISTRO iron -BASE desktop -UI terminal
.\run_docker.ps1 -ROS_DISTRO humble -BASE base -UI vnc -GRAPHICS_PLATFORM nvidia
```

* Using WSL2:
    
```powershell
./run_docker.sh -d iron -p desktop -t terminal -g nvidia
```

---

## attach_docker Scripts

The `attach_docker` scripts (`attach_docker.sh` for Unix-based systems and `attach_docker.ps1` for Windows) provide a convenient way to attach a terminal to a running Docker container.

### Usage (Both Scripts)

The script searches for a container with the name `rclpy` and attaches a terminal to it.

```bash
./attach_docker.sh
```

```powershell
.\attach_docker.ps1
```


---

## Notes

- Ensure Docker is installed and running on your system.
- Scripts are compatible with the specified ROS distributions and require appropriate permissions to execute.

