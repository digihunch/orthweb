Use Github action to build library (artifact is so file)

To build in Docker on MacOS, create directory ~/Engineering/orthweb/plugin-builder/out
```sh
docker build -t "digihunch/s3-plugin-builder:0.1" .
```

To build, map a host directory (e.g. /tmp/out) to container's /out directory, and launch the container. build command is included as a CMD instruction in Dockerfile
```sh
docker run -d --mount src=/tmp/out,target=/out,type=bind digihunch/s3-plugin-builder:0.1
```

To use customized build command (e.g. for troubleshooting), override CMD instruction with imperative command with docker run
```sh
docker run --mount src=/tmp/out,target=/out,type=bind digihunch/s3-plugin-builder:0.1 /bin/bash -c " \
cmake -DUSE_VCPKG_PACKAGES=FALSE -DSTATIC_AWS_CLIENT=TRUE /sources/orthanc-object-storage/Aws && \
cmake --build . --config Release && \
./UnitTests && \
cp /build/*.so /out/"
```
