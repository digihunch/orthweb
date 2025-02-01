When an EC2 instance is launched, the cloud-init process executes a script as defined in user-data on the first boot. This initializes the configuration management.

## Automation Pattern

The main steps of the user data script is illustrated below. 

<div style="text-align: center;">
```mermaid
graph LR
  subgraph OuterRectangle["EC2 Instance"]
    subgraph MiddleRectangle["Cloud Init"]
      InnerRectangle1["1 git clone"]
      InnerRectangle2["2 update parameter"]
      InnerRectangle3["3 execute command"]
    end
  end
  InnerRectangle1 --> |deployment_options<br>ConfigRepo| Repo["orthanc-config repository"]
  InnerRectangle3 --> |deployment_options<br>InitCommand| Command["cd orthanc-config<br> && make aws"]
```
</div>

First, the script pulls the configuration repo as specified to a local directory. Then it updates parameter file in the repo. Last, the scripts executes the command given in the variable, from the directory. They are configured in the Terraform variable `deployment_options`.


## Configuration Process

The configuration management repo is [orthanc-config](https://github.com/digihunchinc/orthanc-config). The repo suits multiple environments. It uses `makefile` to orchestrate the configuration steps. On AWS EC2, the initial command can be set to `make aws`. Review the `README.md` file in the repo for how it works. 

To watch for the log and errors, check the cloud init file (/var/log/cloud-init-output.log). The output from the command prints the next steps to finish the configuration.