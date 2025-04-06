# Mostlymatter Docker

This project provides Docker containerization for [mostlymatter](https://framagit.org/framasoft/framateam/mostlymatter), a theme for [Mattermost](https://mattermost.com/) developed by [Framasoft](https://framasoft.org/).

## About Mostlymatter

Mostlymatter is a custom theme for Mattermost that provides a clean, modern interface aligned with Framasoft's design principles. The original project is maintained at [Framagit](https://framagit.org/framasoft/framateam/mostlymatter).

## Features

- Automated builds via GitHub Actions
- Automatic builds for each version released at https://packages.framasoft.org/projects/mostlymatter/
- Minimal Docker containers published to GitHub Packages

## Usage

```bash
# Pull the latest image
docker pull ghcr.io/teda-tech/mostlymatter:latest

# Run the container
docker run -p 8080:8080 ghcr.io/teda-tech/mostlymatter:latest
```

## Versions

The Docker images are tagged to match the upstream mostlymatter versions. You can use a specific version by specifying the tag:

```bash
docker pull ghcr.io/teda-tech/mostlymatter:x.y.z
```

## Configuration

Configuration details and environment variables will be documented here as they are implemented.

## Development

This project uses a memory bank approach for documentation. See the `memory-bank/` directory for comprehensive project documentation.

### Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/) for semantic versioning:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

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