FROM quay.io/crunchtools/ubi10-httpd-php:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="UBI 10 PHP + PostgreSQL leaf image — requires RHSM for postgresql-server"

# postgresql-server requires RHSM — register, install, unregister in single layer
RUN --mount=type=secret,id=RHSM_ACTIVATION_KEY \
    --mount=type=secret,id=RHSM_ORG_ID \
    subscription-manager register \
      --activationkey="$(cat /run/secrets/RHSM_ACTIVATION_KEY)" \
      --org="$(cat /run/secrets/RHSM_ORG_ID)" \
    && dnf install -y \
      postgresql-server \
      php-pgsql \
    && dnf clean all \
    && subscription-manager unregister

# Copy init scripts and systemd units
COPY rootfs/ /

# Enable postgresql and prep service, make scripts executable
RUN chmod +x /usr/local/bin/postgres-prep.sh && \
    systemctl enable postgresql postgres-prep
