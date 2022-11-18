This file was used to build orthanc image to include S3 storage plugin. Since [osimis orthanc image](https://hub.docker.com/r/osimis/orthanc/) includes S3 plugin, this project moved to use the [Osimis orthanc image](https://osimis.atlassian.net/wiki/spaces/OKB/pages/26738689/How+to+use+osimis+orthanc+Docker+images) and no longer need the file in this directory.

According to [orthanc book](https://book.orthanc-server.com/users/docker-osimis.html) using the plugin in the Osimis image also requires environment variable AWS_S3_STORAGE_PLUGIN_ENABLED set to true. However, in my testing it doesn't seem to be required.


