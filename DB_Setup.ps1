# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-ExecutionPolicy Bypass $CommandLine"
        Exit
    }
}

# Set the execution policy for the current user
try {
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
} catch {
    Write-Host "Failed to set the execution policy. Error: $_"
}

# Function to install Docker Desktop
function Install-Docker {
    $dockerDesktop = "Docker Desktop"
    $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

    # Check if Docker Desktop is installed
    $installedApps = winget list --name $dockerDesktop

    if ($installedApps -like "*$dockerDesktop*") {
        Write-Host "Docker Desktop is installed."
    } else {
        Write-Host "Docker Desktop is not installed. Installing now..."
        # Install Docker Desktop using winget
        $process = Start-Process -FilePath "winget" -ArgumentList "install Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
        if ($process.ExitCode -ne 0) {
            Write-Host "Docker Desktop installation failed with exit code $($process.ExitCode)."
            return $false
        }
        Write-Host "Docker Desktop installation completed successfully."
    }

    # Start Docker Desktop
    Start-Process $dockerPath

    # Wait for Docker Desktop to start
    Write-Host "Waiting for Docker Desktop to start..."
    $timeout = 120
    $timer = [Diagnostics.Stopwatch]::StartNew()
    while (-not (docker info 2>$null)) {
        if ($timer.Elapsed.TotalSeconds -gt $timeout) {
            Write-Host "Timeout waiting for Docker to start. Please start Docker manually and try again."
            return $false
        }
        Start-Sleep -Seconds 5
    }
    $timer.Stop()
    Write-Host "Docker Desktop is ready."
    return $true
}

# Function to install Dockge
function Install-Dockge {
    # Create necessary folders in the user's Documents path
    $documentsPath = "$env:USERPROFILE\Documents\Docker Stuff\Dockge"
    $dataPath = "$documentsPath\data"
    $stacksPath = "$documentsPath\stacks"

    New-Item -ItemType Directory -Path $dataPath, $stacksPath -Force

    # Check if Dockge container already exists
    $existingContainer = docker ps -a --filter "name=dockge" --format "{{.Names}}"
    if ($existingContainer -eq "dockge") {
        Write-Host "Dockge container already exists. Starting it if not running..."
        docker start dockge
    } else {
        # Run the specified Docker container
        docker run -d --name dockge --restart unless-stopped `
            -p 5001:5001 `
            -v /var/run/docker.sock:/var/run/docker.sock `
            -v "${dataPath}:/app/data" `
            -v "${stacksPath}:/opt/stacks" `
            -e DOCKGE_STACKS_DIR=/opt/stacks `
            louislam/dockge:1
    }

    Write-Host "Dockge is now running at http://localhost:5001"
}

# Function to get Postgres details from user
function Get-PostgresDetails {
    $username = Read-Host "Enter PostgreSQL username (default: postgres)"
    if ([string]::IsNullOrWhiteSpace($username)) {
        $username = "postgres"
    }
    
    $password = Read-Host "Enter PostgreSQL password" -AsSecureString
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    $port = Read-Host "Enter the port for Postgres (default: 5432)"
    if ([string]::IsNullOrWhiteSpace($port)) {
        $port = 5432
    } else {
        $port = [int]$port
    }

    return @{
        Username = $username
        Password = $password
        Port = $port
    }
}

# Function to print Docker Compose configuration for Postgres
function Print-DockerCompose {
    param (
        [string]$username,
        [string]$password,
        [int]$port
    )

    $instanceName = "postgres_" + (Get-Date).ToString("yyyyMMddHHmmss")

    $composeContent = @"
version: '3.3'
services:
  postgres:
    container_name: $instanceName
    ports:
      - $($port):5432
    environment:
      - POSTGRES_USER=$username
      - POSTGRES_PASSWORD=$password
    image: postgres:latest
    volumes:
      - ${instanceName}_data:/var/lib/postgresql/data
volumes:
  ${instanceName}_data:
"@

    Write-Host "Docker Compose configuration for Postgres:" -ForegroundColor Green
    Write-Host $composeContent -ForegroundColor Green
}

# Function to install Postgres using Docker
function Install-Postgres {
    param (
        [int]$port = 5432,
        [string]$username = "postgres",
        [string]$password
    )

    try {
        # Generate a unique name for the new Postgres instance
        $instanceName = "postgres_" + (Get-Date).ToString("yyyyMMddHHmmss")
        $volumeName = "${instanceName}_data"
        # Construct the docker run command
        $dockerCommand = "docker run -d --name $instanceName --restart unless-stopped " +
                         "-e POSTGRES_USER=$username " +
                         "-e POSTGRES_PASSWORD=$password " +
                         "-p ${port}:5432 " +
                         "-v ${volumeName}:/var/lib/postgresql/data " +
                         "postgres:latest"

        # Execute the docker run command
        $containerId = Invoke-Expression $dockerCommand

        if ($containerId) {
            Write-Host "New Postgres instance '$instanceName' is now running on port $port with username $username."
            return $true
        } else {
            Write-Host "Failed to start new Postgres instance."
            return $false
        }
    }
    catch {
        Write-Host "Error occurred while installing Postgres: $_"
        Write-Host "Docker command attempted: $dockerCommand"
        return $false
    }
}

# Main script
function Show-Menu {
    Write-Host "`nDocker and Postgres Installation Menu:"
    Write-Host "1. Install Docker and Dockge, and display Postgres Compose"
    Write-Host "2. Install Docker and Postgres"
    Write-Host "3. Install Postgres"
    Write-Host "4. Exit"
    Write-Host
}

do {
    Show-Menu
    $choice = Read-Host "Select an option (1-4)"

    switch ($choice) {
        1 {
            if (Install-Docker) {
                Install-Dockge
                $postgresDetails = Get-PostgresDetails
                Print-DockerCompose -username $postgresDetails.Username -password $postgresDetails.Password -port $postgresDetails.Port
            }
        }
        2 {
            if (Install-Docker) {
                $postgresDetails = Get-PostgresDetails
                $result = Install-Postgres -port $postgresDetails.Port -username $postgresDetails.Username -password $postgresDetails.Password
                if (-not $result) {
                    Write-Host "Failed to install Postgres. Please check your Docker installation and try again."
                }
            }
        }
        3 {
            if (Get-Command docker -ErrorAction SilentlyContinue) {
                $postgresDetails = Get-PostgresDetails
                $result = Install-Postgres -port $postgresDetails.Port -username $postgresDetails.Username -password $postgresDetails.Password
                if (-not $result) {
                    Write-Host "Failed to install Postgres. Please check your Docker installation and try again."
                }
            } else {
                Write-Host "Docker CLI is not installed or not found in PATH."
            }
        }
        4 {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid option selected. Please try again."
        }
    }

    if ($choice -ne 4) {
        Read-Host "Press Enter to continue..."
    }
} while ($choice -ne 4)