FROM jodogne/orthanc-plugins:latest
COPY libOrthancAwsS3Storage.so /usr/local/share/orthanc/plugins/
RUN chmod 644 /usr/local/share/orthanc/plugins/libOrthancAwsS3Storage.so && apt-get update && \
    apt-get install -y curl libssl1.1 libcrypto++* libcurl4-openssl-dev libjsoncpp-dev libboost-all-dev libcurl4 libssl-dev libcurl-dev
