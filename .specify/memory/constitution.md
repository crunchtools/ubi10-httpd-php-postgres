# ubi10-httpd-php-postgres Constitution

> **Version:** 1.1.0
> **Ratified:** 2026-03-10
> **Amended:** 2026-10-02
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.22.0
> **Profile:** Container Image

This file holds what is specific to ubi10-httpd-php-postgres. The fleet rules and the Container
Image profile (license, versioning, LABELs, the RHSM secret-mount pattern,
systemd conventions, registry, testing and quality gates) apply at the
inherited version and are checked against this repo's files by
`constitution.yml`. They are not restated here.

## Purpose

UBI 10 PHP + PostgreSQL leaf image. Published as
`quay.io/crunchtools/ubi10-httpd-php-postgres`.

## Parent Image

`quay.io/crunchtools/ubi10-httpd-php:latest`. It inherits httpd, PHP 8.3 with
its extensions, php-fpm with the bounded pool, and everything ubi10-core
provides.

## RHSM Use

`postgresql-server` is not in the UBI repos, so this image registers with
RHSM at build time. Register, install and unregister run in one `RUN` layer,
with the secrets mounted as `RHSM_ACTIVATION_KEY` and `RHSM_ORG_ID`.

## Packages and Services

- **Packages:** postgresql-server, php-pgsql.
- **Enabled:** postgresql and `postgres-prep`.
- **postgres-prep.service** (from `rootfs/`): a oneshot ordered before
  postgresql that runs `/usr/local/bin/postgres-prep.sh`, which runs initdb
  when PGDATA is empty, so a fresh data volume initializes on first boot.

## Smoke Test Coverage

`tests/smoke-test.sh` asserts httpd, postgresql and php-fpm are active, PGDATA
is initialized, runs a PostgreSQL CRUD cycle (createdb, CREATE TABLE, INSERT,
SELECT, dropdb), and checks the inherited packages.

## Downstream Consumers

Leaf image: no downstream container images and no dispatch. Its original
consumer, Zabbix, was replaced by Nagios (RT #1459).

## History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-10 | Initial constitution, tier 3b leaf |
| 1.0.1 | 2026-09-25 | Gatehouse review, triage and pre-commit gates |
| 1.1.0 | 2026-10-02 | Manifest under constitution v1.18.0: profile restatement removed, image specifics kept |
