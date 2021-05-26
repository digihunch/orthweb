Use Github action to build library (artifact is so file)

To build in Docker on MacOS, create directory ~/Engineering/orthweb/plugin-builder/out
```sh
docker build -t "digihunch/s3-plugin-builder:0.1" .
docker run -d --mount src=~/Engineering/orthweb/plugin-builder/out,target=/out,type=bind digihunch/s3-plugin-builder:0.1
# To override the CMD section in image
docker run -d --mount src=~/Engineering/orthweb/plugin-builder/out,target=/out,type=bind digihunch/s3-plugin-builder:0.1 /bin/bash -c "ls && pwd"
