# Docker, Dockge, and Postgres Setup Script

## Overview

This PowerShell script automates the process of setting up Docker, Dockge, and PostgreSQL on a Windows system. It provides a user-friendly interface to install and configure these tools, making it easier for developers to set up their development environment.

## Features

- Automatic installation of Docker Desktop (if not already installed)
- Installation and configuration of Dockge for Docker container management
- Installation of PostgreSQL as a Docker container
- Generation of Docker Compose configurations for PostgreSQL to be input into Dockge
- Interactive menu for easy navigation and selection of installation options

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later
- Windows Package Manager (`winget`)
- Internet connection for downloading Docker Desktop and container images

## Installation

1. Download the [`DB_Setup.ps1`](command:_github.copilot.openSymbolFromReferences?%5B%22DB_Setup.ps1%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22c%3A%5C%5CUsers%5C%5CJared%5C%5CDocuments%5C%5CGithub%5C%5CPersonals-Projects%5C%5CJs_tampermonkey%5C%5CPowerShell%20Scripts%5C%5Creadme.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fc%253A%2FUsers%2FJared%2FDocuments%2FGithub%2FPersonals-Projects%2FJs_tampermonkey%2FPowerShell%2520Scripts%2Freadme.md%22%2C%22path%22%3A%22%2FC%3A%2FUsers%2FJared%2FDocuments%2FGithub%2FPersonals-Projects%2FJs_tampermonkey%2FPowerShell%20Scripts%2Freadme.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A22%2C%22character%22%3A17%7D%7D%5D%5D "Go to definition") script to your local machine.
2. Open PowerShell as an administrator.
3. Navigate to the directory containing the script.
4. Run the following command to allow script execution:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
   ```

## Usage

1. In PowerShell (running as administrator), navigate to the script's directory.
2. Run the script using the following command:
   ```powershell
   .\DB_Setup.ps1
   ```
3. Follow the on-screen prompts to select your desired installation options.

## Menu Options

1. **Install Docker and Dockge, and display Postgres Compose**
   - Installs Docker Desktop (if not already installed)
   - Installs or starts Dockge
   - Prompts for PostgreSQL configuration details
   - Displays a Docker Compose configuration for PostgreSQL to be input into Dockge

2. **Install Docker and Postgres**
   - Installs Docker Desktop (if not already installed)
   - Prompts for PostgreSQL configuration details
   - Installs PostgreSQL as a Docker container

3. **Install Postgres with default port**
   - Installs PostgreSQL as a Docker container using the default port (5432)

4. **Install Postgres with specific port**
   - Prompts for a custom port number
   - Installs PostgreSQL as a Docker container using the specified port

5. **Exit**
   - Exits the script

## Configuration Options

When installing PostgreSQL, you'll be prompted for the following information:

- PostgreSQL username (default: postgres)
- PostgreSQL password
- Custom port (optional, default: 5432)

## Docker Compose Configuration

The script can generate a Docker Compose configuration for PostgreSQL. This configuration can be used to easily start and manage your PostgreSQL container using Docker Compose and input into Dockge.

## Troubleshooting

- If you encounter permission issues, ensure you're running PowerShell as an administrator.
- If Docker fails to start, try starting Docker Desktop manually and run the script again.
- For any installation errors, check your internet connection and firewall settings.

## Contributing

Contributions to improve the script are welcome. Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with a clear description.
4. Push your changes and create a pull request.

## License

This script is released under the [MIT License](https://choosealicense.com/licenses/mit/).

## Disclaimer

This script is provided as-is, without any warranties. Always review scripts before running them on your system, especially with elevated privileges.

