# Background

Kerberos based authentication dictates several areas be met in order for the successful exchange of credentials between running containers and the backing Key Distribution Center (KDC). The instructions on this page are intended for users with limited experience using containers.

The [Kerberos Sidecar](https://www.openshift.com/blog/kerberos-sidecar-container) is a more appropriate way to approach Kerberos. Unfortunately the average user may struggle if they are not familar with the topic. Follow the instructions on this page for a simplified solution.

- [Kerberos Sidecar - Blog](https://www.openshift.com/blog/kerberos-sidecar-container)
- [Kerberos Sidecar - GIT](Khttps://github.com/edseymour/kinit-sidecar)


**NOTE:** `These instructions do not address using a keytab for SPN setup. This is for service account based authentication.` 

For modern authentication, see [Reverse Proxy - OIDC]()

## Prereqsites

These instructions assume the following:
- [Access to OpenShift]() (inside the corporate network)
- Active Directory Service Account (instructions below)
- Access Granted to a Service (ex: Microsoft SQL Server) via Service Account (typically via AD group membership)
- [OpenShift Command Line Tool]()) (oc) - optional


### AD Service Account Creation
You will need to have an Active Directory (AD) account (NOT Azure AD) that has a username and password configured.



Select the following options for your New ID:

- ID Type: `Non-Personal`
- Domain: `NA`
- Orgnizational Unit: `Service Account`
- Password Settings:
  - [x] `Non-Expiring Password`: checked
  - [x] `User Cannot Change Password`: checked


### S2I-Kerberos - Patched Container

You will need to set the following Environment vars in your deployment config:
```
KRB5_SA_USERNAME=<AD account>
KRB5_SA_PASSWORD=<AD account password>
```

The settings to create a ticket granting ticket (TGT) inside a container have been configured for you. You will need to do a chained build of the following:

- [s2i-custom-certs]()
- [s2i-kerberos]()
- [s2i-ms-odbc-17]()(optional)

#### How to use in GIT Repo

An easy way to enable kerberos token renewal is to use s2i scripts. These scripts
will need to be created in your git repo with the following paths below.

See the following for more details:
- [Soure To Image (s2i)](https://github.com/openshift/source-to-image)
- [s2i Python](https://github.com/sclorg/s2i-python-container)

.s2i/bin/assemble
```
#!/bin/bash

# insert magic custom code here

/usr/libexec/s2i/assemble
```

.s2i/bin/run
```
#!/bin/bash

echo Starting custom s2i/run...

echo Staring background krb token process
/opt/app-root/src/krb5-setup.sh &


echo "
Starting regular s2i/run...
"
/usr/libexec/s2i/run
```

You can test with the following commands inside a patched container.

```
export KRB5_SA_USERNAME=<AD account>
export KRB5_SA_PASSWORD=<AD account password>

SKIP_REFRESH=true ./krb5-setup.sh

# test script
# pip needs to be configured to work (not covered here)
pip install requests requests-kerberos
python krb5-test.py

# curl has Kerberos features built-in also
curl -L --negotiate -u : 'https://goto/jupyter'

# see tokens
klist

```

`pyodbc` testing (optional)

```
pip install pyodbc

python odbc-test.py

```

## Custom Code Servers

The settings to create a ticket granting ticket (TGT) inside a [Custom Code Server]() have been pre configured.

You can test with the following commands inside a [Custom Code Server]().

```
export KRB5_SA_USERNAME=<AD account>
export KRB5_SA_PASSWORD=<AD account password>

/etc/skel/bin/krb5-setup.sh

# curl has Kerberos features built-in also
curl -L --negotiate -u : 'https://goto/jupyter'

# see tokens
klist

```

