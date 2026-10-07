FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '%s\n' \
    'deb http://archive.debian.org/debian bullseye main' \
    'deb http://snapshot.debian.org/archive/debian-security/20260903T220410Z bullseye-security main' \
    > /etc/apt/sources.list \
    && printf '%s\n' \
    'Acquire::Check-Valid-Until "false";' \
    'Acquire::Retries "3";' \
    > /etc/apt/apt.conf.d/99bullseye

RUN apt-get update && apt-get install -y \
    gosa \
    python3 \
    python3-pip \
    python3-venv \
    samba-client \
    smbclient \
    ldap-utils \
    apache2 \
    && rm -rf /var/lib/apt/lists/*

# Python environment for GOsa postexec hooks
RUN python3 -m venv /opt/gosa-venv

# Install whatever your hooks require
RUN /opt/gosa-venv/bin/pip install --no-cache-dir \
    ldap3

# Put hooks somewhere predictable
RUN mkdir -p /opt/gosa-hooks

COPY hooks/ /opt/gosa-hooks/
RUN chmod 755 /opt/gosa-hooks/*.py

# Make sure the Apache/GOsa user can execute the hooks
RUN chown -R root:root /opt/gosa-hooks && \
    chmod -R 755 /opt/gosa-hooks

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]