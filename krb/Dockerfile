FROM ubi7/python-36

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="patch-kerberos" \
      maintainer="sample@business.com" \
      summary="Patch with kerberos" \
      description="Base image patched with kerberos"

USER root

# https://access.redhat.com/articles/4238681
#RUN yum-config-manager --disable '*ubi*' > /dev/null

RUN yum install -y krb5-workstation && \
    yum clean all && \
    rm -rf /var/cache/yum

ENV KRB5CCNAME=FILE:/tmp/krb5.cache
ENV REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt

COPY krb5.conf /etc/krb5.conf.d
COPY krb5-setup.sh .
COPY krb5-test.py .

RUN chmod -Rv g+rw /opt/app-root/. /etc/passwd && \
    chown -Rv default.root /opt/app-root/.

USER 1001
