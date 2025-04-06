# Project Brief: Mostlymatter Docker

## Overview
This project aims to provide the latest version of [mostlymatter](https://framagit.org/framasoft/framateam/mostlymatter), a theme for [Mattermost](https://mattermost.com/) developed by Framasoft, in a containerized format. Our goal is to make it easily deployable via Docker.

## Core Requirements

1. **Automated Builds**
   - Implement GitHub Actions workflows to build Docker images automatically
   - Ensure builds trigger on new releases from the upstream repository

2. **Version Tracking**
   - Automatically build for each version released at https://packages.framasoft.org/projects/mostlymatter/
   - Maintain version consistency between the upstream project and our Docker images

3. **Docker Optimization**
   - Build and publish minimal Docker containers to GitHub Packages
   - Optimize for size, security, and performance

## Project Scope
- Focus on containerization only, not modifying the core mostlymatter application
- Provide clear documentation for deployment and usage
- Ensure reliable and consistent builds across all upstream versions

## Success Criteria
- Automated build pipeline successfully creates Docker images for all new mostlymatter releases
- Docker images are minimal in size while maintaining full functionality
- Images are published to GitHub Packages with appropriate versioning
- Documentation provides clear instructions for deployment and usage