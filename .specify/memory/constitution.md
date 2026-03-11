# ubi10-httpd-php-postgres Constitution

> **Version:** 1.0.0
> **Ratified:** 2026-03-10
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.0.0
> **Profile:** Container Image

UBI 10 PHP + PostgreSQL leaf image. Inherits Apache httpd, PHP 8.3, php-fpm, and all PHP extensions from ubi10-httpd-php. Adds PostgreSQL server and php-pgsql for Zabbix hosting. Requires RHSM for postgresql-server package.

---

## License

AGPL-3.0-or-later

## Versioning

Follow Semantic Versioning 2.0.0. MAJOR/MINOR/PATCH.

## Base Image

`quay.io/crunchtools/ubi10-httpd-php:latest` — inherits httpd, PHP 8.3 with extensions, php-fpm, troubleshooting tools, and systemd hardening.

## Registry

Published to `quay.io/crunchtools/ubi10-httpd-php-postgres`.

## RHSM Registration

Required. `postgresql-server` is not available in UBI repos. Uses `--mount=type=secret` for subscription-manager registration. Register, install, and unregister happen in a single `RUN` layer so secrets are never cached in intermediate layers.

## Containerfile Conventions

- Uses `Containerfile` (not Dockerfile)
- Required LABELs: `maintainer`, `description`
- `dnf install -y` followed by `dnf clean all`
- `subscription-manager unregister` after package installation
- systemd services enabled: postgresql, postgres-prep
- postgres-prep.service: oneshot, Before=postgresql, runs initdb if PGDATA empty
- Inherits from parent chain: httpd, php-fpm (enabled), systemd-remount-fs/systemd-update-done/systemd-udev-trigger (masked)
- Inherits `STOPSIGNAL SIGRTMIN+3` and `ENTRYPOINT ["/sbin/init"]` from ubi10-core

## Packages Installed

postgresql-server, php-pgsql

Inherited from ubi10-httpd-php: php, php-mysqlnd, php-xml, php-mbstring, php-intl, php-gd, php-opcache, php-pecl-apcu
Inherited from ubi10-httpd: httpd
Inherited from ubi10-core: iputils, bind-utils, net-tools, less, cronie, procps-ng, diffutils

## Testing

- **Build test**: CI builds the image on every push to main/master
- **Smoke tests**: Service health (httpd, postgresql, php-fpm), PostgreSQL functional (PGDATA initialized, createdb, CREATE TABLE, INSERT, SELECT, dropdb), package integrity, inherited package verification
- **Security scan**: Recommended (not yet implemented)

## Quality Gates

1. Build — CI builds the Containerfile successfully
2. Test — smoke tests pass (services up, PostgreSQL CRUD cycle works, packages verified)
3. Push — image published only after tests pass
4. Weekly rebuild — cron job picks up base image updates every Monday 4:45 AM UTC

## Downstream Consumers

Zabbix (crunchtools/zabbix). Dispatches repository_dispatch to zabbix on push.
