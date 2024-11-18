[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("iron", "humble")]
    [string]$ROS_DISTRO = "iron",

    [Parameter()]
    [ValidateSet("desktop", "base")]
    [string]$BASE = "desktop",

    [Parameter()]
    [ValidateSet("terminal", "vnc")]
    [string]$UI = "terminal",

    [Parameter()]
    [ValidateSet("standard", "nvidia", "amd")]
    [string]$GRAPHICS_PLATFORM
)


function Show-Usage {
    Write-Host @"
Usage: .\run_docker.ps1 [OPTIONS]

Options:
    -ROS_DISTRO <string>         ROS distribution (iron, humble)
    -BASE <string>               Base profile (desktop, base)
    -UI <string>                 UI type (terminal, vnc) 
    -GRAPHICS_PLATFORM <string>  Graphics platform (standard, nvidia, amd)
    -Help                        Show this help message

Examples:
    .\run_docker.ps1 -ROS_DISTRO iron -BASE desktop -UI terminal
    .\run_docker.ps1 -ROS_DISTRO humble -BASE base -UI vnc -GRAPHICS_PLATFORM nvidia
"@
    exit 1
}


try {
    $BASE_DIR = git rev-parse --show-toplevel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Could not find base directory of repository."
        exit 1
    }
    Push-Location $BASE_DIR

    if ($null -eq $GRAPHICS_PLATFORM -or $GRAPHICS_PLATFORM -eq "") {
        $GPU = ((Get-WmiObject Win32_VideoController) | Select-Object -ExpandProperty Name) -join " "
        $GPU = $GPU.ToLower()
        if ($GPU -like "*nvidia*") {
            $GRAPHICS_PLATFORM = "nvidia"
        } elseif ($GPU -like "*amd*") {
            $GRAPHICS_PLATFORM = "amd"
        } else {
            $GRAPHICS_PLATFORM = "standard"
        }
    }

    $SHARED_DIR = "/home/ros_user/ros2_ws/src"
    # Find path to ros_src folder in $BASE_DIR
    $HOST_DIR = Get-ChildItem -Path $BASE_DIR -Recurse -Directory -Filter "ros2_src" | Select-Object -ExpandProperty FullName
    if ($null -eq $HOST_DIR -or (Test-Path -Path $HOST_DIR) -eq $false) {
        Write-Host "Error: Could not find ROS 2 workspace: $HOST_DIR"
        exit 1
    }
    Write-Host "Mounting folder:`n    $HOST_DIR    to`n    $SHARED_DIR"

    $RUN_ARGS = "--rm", "--volume=`"$HOST_DIR`:$SHARED_DIR`:rw`"", "--env=`"QT_X11_NO_MITSHM=1`""

    if ($UI -eq "vnc") {
        $RUN_ARGS += "--publish 0.0.0.0:6080:80", "--publish 0.0.0.0:6900:5901"
    }

    $IMAGE = "ghcr.io/robotics-content-lab/rclpy-from-zero-to-hero:$ROS_DISTRO-$BASE-$UI-$GRAPHICS_PLATFORM"
    # Update the docker run section:
    if ($GRAPHICS_PLATFORM -eq "nvidia") {
        function ConvertTo-WslPath {
            param([string]$WindowsPath)
            $path = $WindowsPath.Replace('\', '/')
            if ($path -match '^([A-Za-z]):(.*)$') {
                return "/mnt/" + $matches[1].ToLower() + $matches[2]
            }
            return $path
        }
        # Convert Windows path to WSL path
        $wslHostDir = ConvertTo-WslPath -WindowsPath $HOST_DIR
        $volumeArg = "--volume=`"$wslHostDir`:$SHARED_DIR`""
        
        # Reconstruct run args with new volume path
        $finalRunArgs = @(
            "--rm"
            $volumeArg
            "--env=`"QT_X11_NO_MITSHM=1`""
            "--volume=`"/mnt/wslg/.X11-unix:/tmp/.X11-unix:rw`""
            "--volume=`"/mnt/wslg:/mnt/wslg`""
            "--env=`"DISPLAY=:0`" "
            "--env=`"VGL_DISPLAY=:0`" "
            "--env=`"XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir`""
        )
        
        if ($UI -eq "vnc") {
            $finalRunArgs += "--publish 0.0.0.0:6080:80"
            $finalRunArgs += "--publish 0.0.0.0:6900:5901"
        }
        
        Write-Host "Running: wsl docker run -it $($finalRunArgs -join ' ') --gpus all --name `"rclpy-from-zero-to-hero-$ROS_DISTRO`" $IMAGE"
        $command = "docker run -it " + ($finalRunArgs -join ' ') + " --gpus all --name `"rclpy-from-zero-to-hero-$ROS_DISTRO`" $IMAGE"
        wsl bash -c "$command"
    } else {
        docker run -it $RUN_ARGS --name "ghcr.io/robotics-content-lab/rclpy-from-zero-to-hero-$ROS_DISTRO" $IMAGE
    }
    Pop-Location
} catch {
    Write-Host "Error: $_"
    Show-Usage
}