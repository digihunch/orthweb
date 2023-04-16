## Overview
We first perform a basic level of validation as an end user. Then we'll dive into technical validation with certain components.

## DICOM ping

To Validate DICOM capability, we can test with C-ECHO and C-STORE. We can use any DICOM compliant application. For example, [Horos](https://horosproject.org/) on MacOS is a UI-based application. In Preference->Locations, configure a new DICOM nodes with:
* Address: the site address as given above
* AE title: ORTHANC
* Port: 11112 (or otherwise configured)

Remember to enable TLS. Then you will be able to verify the node (i.e. C-ECHO) and send existing studies from Horos to Orthanc (C-STORE).

## Web Browser
To Validate the the web service, simply visit the site address (with `https://` scheme) and put in the [default credential](https://github.com/digihunch/orthweb/blob/main/app/orthanc.json#L6) at the prompt. Note that your web browser may flag the site as insecure because the server certificate's CA is self-signed and not trusted. 

Alternatively, you may use `curl` command to fetch the web content:

```sh
curl -HHost:web.orthweb.com -k -X GET https://ec2-35-183-66-248.ca-central-1.compute.amazonaws.com/app/explorer.html -u admin:orthanc --cacert ca.crt
```
The curl command should print out the web content.