FROM quay.io/crunchtools/ubi10-httpd-php:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="UBI 10 PHP + PostgreSQL leaf image — requires RHSM for postgresql-server"

# postgresql-server requires RHSM — register, install, unregister in ONE layer
# with a trap so unregister+clean run even if the install fails (constitution II).
# The old `&& subscription-manager unregister` chain skipped unregister on any
# install failure, leaking an RHSM consumer as a ghost host in console inventory.
RUN --mount=type=secret,id=RHSM_ACTIVATION_KEY \
    --mount=type=secret,id=RHSM_ORG_ID <<'EOF'
set -euo pipefail
subscription-manager register \
    --activationkey="$(cat /run/secrets/RHSM_ACTIVATION_KEY)" \
    --org="$(cat /run/secrets/RHSM_ORG_ID)"
trap 'subscription-manager unregister || true; subscription-manager clean || true' EXIT
dnf install -y \
    postgresql-server \
    php-pgsql
dnf clean all
EOF

# Copy init scripts and systemd units
COPY rootfs/ /

# Enable postgresql and prep service, make scripts executable
RUN chmod +x /usr/local/bin/postgres-prep.sh && \
    systemctl enable postgresql postgres-prep
