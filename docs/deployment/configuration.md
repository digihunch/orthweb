## Overview

The Terraform template no longer initiates the application configuration for Orthanc. Instead, it initiates a git clone of the [orthanc-config](https://github.com/digihunchinc/orthanc-config) repository to the servers home directory.

Users are expected to use the assets in the `orthanc-config` repository. The repository creates a prescriptive configuration with an automation wrapper so that it only takes a few commands to finish installation.

## Application Configuration

Review the instruction in the orthanc-config repository.
