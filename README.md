# Mostlymatter Docker

This project provides Docker containerization for [mostlymatter](https://framagit.org/framasoft/framateam/mostlymatter), a fork of [Mattermost](https://mattermost.com/) developed by [Framasoft](https://framasoft.org/) that removes user and message limits.

## About Mostlymatter

Mostlymatter is a fork of Mattermost that removes the user and message limits by multiplying them by 1,000. The user limits are increased to 5,000,000 and 11,000,000. The original project is maintained at [Framagit](https://framagit.org/framasoft/framateam/mostlymatter).

## Features

- Automated builds via GitHub Actions
- Automatic builds for each version released at https://packages.framasoft.org/projects/mostlymatter/
- Multi-architecture support (amd64 and arm64)
- Minimal Docker containers published to GitHub Packages
- Secure by default (runs as non-root user)
- Configurable via environment variables

## Usage

### Basic Usage

```bash
# Pull the latest image
docker pull ghcr.io/teda-tech/mostlymatter:latest

# Run the container
docker run -p 8065:8065 ghcr.io/teda-tech/mostlymatter:latest
```

### Persistent Storage

For production use, you should mount volumes for configuration, data, logs, and plugins:

```bash
docker run -d \
  --name mostlymatter \
  -p 8065:8065 \
  -v mostlymatter-config:/opt/mostlymatter/config \
  -v mostlymatter-data:/opt/mostlymatter/data \
  -v mostlymatter-logs:/opt/mostlymatter/logs \
  -v mostlymatter-plugins:/opt/mostlymatter/plugins \
  ghcr.io/teda-tech/mostlymatter:latest
```

### Docker Compose Example

Here's a basic example using Docker Compose with PostgreSQL:

```yaml
version: '3'

services:
  mostlymatter:
    image: ghcr.io/teda-tech/mostlymatter:latest
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      - MM_SQLSETTINGS_DRIVERNAME=postgres
      - MM_SQLSETTINGS_DATASOURCE=postgres://mmuser:mostest@postgres:5432/mattermost?sslmode=disable
    volumes:
      - mostlymatter-config:/opt/mostlymatter/config
      - mostlymatter-data:/opt/mostlymatter/data
      - mostlymatter-logs:/opt/mostlymatter/logs
      - mostlymatter-plugins:/opt/mostlymatter/plugins
    ports:
      - "8065:8065"
    
  postgres:
    image: postgres:13
    restart: unless-stopped
    environment:
      - POSTGRES_USER=mmuser
      - POSTGRES_PASSWORD=mostest
      - POSTGRES_DB=mattermost
    volumes:
      - postgres-data:/var/lib/postgresql/data
    
volumes:
  mostlymatter-config:
  mostlymatter-data:
  mostlymatter-logs:
  mostlymatter-plugins:
  postgres-data:
```

## Versions

The Docker images are tagged to match the upstream mostlymatter versions. You can use a specific version by specifying the tag:

```bash
docker pull ghcr.io/teda-tech/mostlymatter:v10.6.1
```

## Configuration

Mostlymatter can be configured using environment variables with the `MM_` prefix. Since Mostlymatter is a fork of Mattermost, it uses the same configuration options as the original Mattermost project. Here are some common configuration options:

### Database Configuration

```
MM_SQLSETTINGS_DRIVERNAME=postgres  # or mysql
MM_SQLSETTINGS_DATASOURCE=postgres://mmuser:mostest@postgres:5432/mattermost?sslmode=disable
```

### Server Configuration

```
MM_SERVICESETTINGS_SITEURL=https://mattermost.example.com
MM_SERVICESETTINGS_LISTENADDRESS=:8065
```

### Email Configuration

```
MM_EMAILSETTINGS_ENABLESMTPAUTH=true
MM_EMAILSETTINGS_SMTPUSERNAME=your-smtp-username
MM_EMAILSETTINGS_SMTPPASSWORD=your-smtp-password
MM_EMAILSETTINGS_SMTPSERVER=smtp.example.com
MM_EMAILSETTINGS_SMTPPORT=587
MM_EMAILSETTINGS_CONNECTIONSECURITY=TLS
MM_EMAILSETTINGS_FEEDBACKEMAIL=mattermost@example.com
MM_EMAILSETTINGS_REPLYTOADDRESS=mattermost@example.com
MM_EMAILSETTINGS_FEEDBACKNAME=Mattermost
```

### File Storage Configuration

```
# Local file storage
MM_FILESETTINGS_DIRECTORY=/opt/mostlymatter/data

# Or S3 compatible storage
MM_FILESETTINGS_DRIVERNAME=amazons3
MM_FILESETTINGS_AMAZONS3BUCKET=your-bucket-name
MM_FILESETTINGS_AMAZONS3ACCESSKEYID=your-access-key
MM_FILESETTINGS_AMAZONS3SECRETACCESSKEY=your-secret-key
MM_FILESETTINGS_AMAZONS3ENDPOINT=s3.amazonaws.com
```

For a complete list of environment variables and configuration options, refer to the [Mattermost Environment Variables Documentation](https://docs.mattermost.com/configure/environment-variables.html). All configuration options available in Mattermost are also available in Mostlymatter, with the same environment variable names and formats.

Note that while Mostlymatter removes the user and message limits from Mattermost, the configuration process and options remain identical to the original Mattermost project.

## Development

This project uses a memory bank approach for documentation. See the `memory-bank/` directory for comprehensive project documentation.

### Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/) to enable [Semantic Versioning](https://semver.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

This format allows us to automatically determine the next semantic version number (MAJOR.MINOR.PATCH) based on the types of commits:
- MAJOR version for incompatible API changes (`BREAKING CHANGE` in commit footer)
- MINOR version for new functionality in a backward compatible manner (`feat` type)
- PATCH version for backward compatible bug fixes (`fix` type)

Common types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests
- `chore`: Changes to the build process or auxiliary tools
- `ci`: Changes to CI configuration files and scripts

Examples:
```
feat: add automated version detection
fix: correct Docker image tag format
docs: update deployment instructions
chore: update GitHub Actions workflow
```

## License

This project is licensed under the same license as the upstream mostlymatter project.