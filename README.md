# RCLPY From Zero to Hero Container Setup

This repository contains scripts and configuration files to work with the Docker containers for the book **RCLPY: From Zero to Hero**.

## Requirements

- [Docker](https://www.docker.com/) (or any other container runtime)
- [Visual Studio Code](https://code.visualstudio.com/) (optional, but recommended)

## Structure

```shell
.
├── .devcontainer
│   ├── README.md
│   └── devcontainer.json
├── ros2_src
│   └── .gitkeep
└── scripts
    ├── README.md
    ├── attach_terminal.ps1
    ├── attach_terminal.sh
    ├── run_docker.ps1
    └── run_docker.sh
```

- **.devcontainer**: Contains configuration files for the development container.
  - [devcontainer.json](.devcontainer/devcontainer.json): Configuration file for the development container.
- **ros2_src**: A folder to store your ROS 2 packages (mounted into the container).
- **scripts**: Contains scripts to run the container and attach a terminal to it.
  - [run_docker.sh](./scripts/run_docker.sh)/ [run_docker.ps1](./scripts/run_docker.ps1): Scripts to run the container without the VS Code Devcontainer extension.
  - [attach_terminal.sh](./scripts/attach_terminal.sh)/[attach_terminal.ps1](./scripts/attach_terminal.ps1): Scripts to attach a terminal to the running container.


> For more information see the corresponding README files in the subdirectories.

---

## Usage

1. **Clone the repository**:

   ```shell
   git clone https://github.com/Robotics-Content-Lab/rclpy-from-zero-to-hero-container.git
   ```

2. **Start the container**:

   - **Using VS Code Devcontainers (recommended)**:

     Open the repository folder in VS Code. When prompted, open it in a Dev Container.

   - **Using the script**:
    - **Linux/Mac**:

     ```bash
     ./scripts/run_docker.sh
     ```

     You can specify options like ROS distribution, base image, UI, and graphics platform. For example:

     ```bash
     ./scripts/run_docker.sh -d iron -p desktop -t vnc -g nvidia
     ```
    - **Windows**:

     ```pwsh
      ./scripts/run_docker.ps1 
    ```

3. **Attach a terminal to the running container**:

 - **Linux/Mac**:
   ```shell
   ./scripts/attach_terminal.sh
   ```
  - **Windows**:
    ```pwsh
    ./scripts/attach_terminal.ps1
    ```

   This will execute the entrypoint script inside the container and attach a terminal session.

## Optional Configuration

- **Specifying ROS Distribution**:

  Supported distributions are `iron` and `humble`. Use the `-d` option with the 

run_docker.sh

 script:

  ```shell
  ./scripts/run_docker.sh -d humble
  ```

- **Choosing Base Image**:

  Choose between `desktop` and `base` images using the `-p` option:

  ```shell
  ./scripts/run_docker.sh -p base
  ```

- **Selecting User Interface**:

  Select `terminal` or `vnc` using the `-t` option:

  ```shell
  ./scripts/run_docker.sh -t vnc
  ```

- **Setting Graphics Platform**:

  Specify `standard`, `nvidia`, or `amd` using the `-g` option:

  ```shell
  ./scripts/run_docker.sh -g nvidia
  ```
---

## Notes

- The [ros2_src](./ros2_src/) directory is mounted into the container at `/home/ros_user/ros2_ws/src`.
- If using the VNC UI, ports `6080` and `6900` are published for the noVNC web interface and VNC server respectively.

For more detailed usage, refer to the [devcontainer.json](./.devcontainer/devcontainer.json) file or the files in the [scripts](./scripts/) directory.

---

## License

This setup is licensed under [LICENSE_NAME]. See the [LICENSE](./LICENSE) file for more details.