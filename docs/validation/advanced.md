## Overview
In this section, we go through a few checkpoints through a system administrator's lens, to ensure the system is functional and correctly configured.

## Server Validation

Now we SSH to the server as `ec2-user`, as instructed above. Once connected, we can check cloud init log:
```sh
sudo tail -F /var/log/cloud-init-output.log
```
In the log, each container should say `Orthanc has started`. To confirm Envoy proxy started properly, look for the line that says:
```
all dependencies initialized. starting workers
```
The configuration files related to Orthanc deployment are in directory `/home/ec2-user/orthweb/app`, including:

* `orthanc.json`: the Orthanc configuration file. Some values are specified as [environment variables](https://book.orthanc-server.com/users/configuration.html#environment-variables). Their value can be found in file `~/.orthanc.env`. For example, you can change `VERBOSE_ENABLED` to true and restart Docker compose for Orthanc verbose logging.
* `envoy.yaml`: the configuration file for Envoy proxy. Changes to this file should take effect rightaway. However, it is helpful to restart Docker container and watch for Envoy logs in case of configuration error.
* `compute-1.amazonaws.com.pem`: the file that contains the self-signed certificate and key that were generated during server bootstrapping. 
* `docker-compose.yml`: the file that tells `Docker-compose` how to orchestrate Docker containers. Changes to this file requires Docker-compose to restart to take effect.
* `.env`: the file that stores the environment variables being referenced in the `docker-compose.yml` file. Changes to this file requires Docker compose to restart to take effect.

Based on envoy proxy configuration, some additional logging files are located in `/home/envoy/` for troubleshooting Envoy proxy.

## DICOM communication

To emulate DICOM activity,  we use [dcmtk](https://dicom.offis.de/dcmtk.php.en), with TLS options. We use the `echoscu` executable to issue `C-ECHO` DIMSE command, and the `storescu` executable to issue `C-STORE` commands. For example:

```sh
echoscu -aet TESTER -aec ORTHANC -d +tls client.key client.crt -rc +cf ca.crt ec2-35-183-66-248.ca-central-1.compute.amazonaws.com 11112
```
The files `client.key`, `client.crt` and `ca.crt` can all be obtained from the /tmp/ directory on the server. 


The output should read Status code 0 in `C-ECHO-RSP`, followed by `C-ECHO-RQ`. Here is an example of the output from `storescu`:

```
I: Association Accepted (Max Send PDV: 16372)
I: Sending Echo Request (MsgID 1)
D: DcmDataset::read() TransferSyntax="Little Endian Implicit"
I: Received Echo Response (Success)
I: Releasing Association
```

Further, we can store some DICOM part 10 file (usually .dcm extension containing images) to Orthanc server, using `storescu` executable:

```sh
storescu -aet TESTER -aec ORTHANC -d +tls client.key client.crt -rc +cf ca.crt ec2-35-183-66-248.ca-central-1.compute.amazonaws.com 11112 DICOM_Images/COVID/56364823.dcm
```

Below is an example of what the output from `storescu` should look like:

```
D: ===================== OUTGOING DIMSE MESSAGE ====================
D: Message Type                  : C-STORE RQ
D: Message ID                    : 427
D: Affected SOP Class UID        : CTImageStorage
D: Affected SOP Instance UID     : 1.3.6.1.4.1.9590.100.1.2.227776817313443872620744441692571990763
D: Data Set                      : present
D: Priority                      : medium
D: ======================= END DIMSE MESSAGE =======================
D: DcmDataset::read() TransferSyntax="Little Endian Implicit"
I: Received Store Response
D: ===================== INCOMING DIMSE MESSAGE ====================
D: Message Type                  : C-STORE RSP
D: Presentation Context ID       : 41
D: Message ID Being Responded To : 427
D: Affected SOP Class UID        : CTImageStorage
D: Affected SOP Instance UID     : 1.3.6.1.4.1.9590.100.1.2.227776817313443872620744441692571990763
D: Data Set                      : none
D: DIMSE Status                  : 0x0000: Success
D: ======================= END DIMSE MESSAGE =======================
I: Releasing Association
```

C-STORE-RSP status 0 indicates successful image transfer, and the image should viewable from the Orthanc site address. 