FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Base deps + Firefox
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget gnupg \
    dbus-x11 xauth x11-xserver-utils \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
    
# ---- Install Firefox from Mozilla APT repo (real deb; avoids snap wrapper) ----
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget gnupg; \
    rm -rf /var/lib/apt/lists/*; \
    \
    # Import Mozilla signing key -> dearmor into a keyring apt can use
    wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/mozilla-archive-keyring.gpg; \
    \
    # (Optional sanity check) list key ids; helpful if it fails again
    gpg --show-keys --with-colons /usr/share/keyrings/mozilla-archive-keyring.gpg | head -n 20; \
    \
    echo "deb [signed-by=/usr/share/keyrings/mozilla-archive-keyring.gpg] https://packages.mozilla.org/apt mozilla main" \
      > /etc/apt/sources.list.d/mozilla.list; \
    \
    # Prefer Mozilla packages
    printf "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n" \
      > /etc/apt/preferences.d/mozilla; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends firefox; \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    xterm \
 && rm -rf /var/lib/apt/lists/*

# Install Xpra from official repo (Ubuntu Noble)
# (Xpra project recommends using official packages rather than Ubuntu's) 
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates apt-transport-https software-properties-common \
    && wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc \
    && wget -O "/etc/apt/sources.list.d/xpra.sources" \
       https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra.sources \
    && apt-get update && apt-get install -y --no-install-recommends \
       xpra xpra-html5 xpra-x11\
    && rm -rf /var/lib/apt/lists/*
# xpra-html5 is the packaged HTML5 client that xpra can serve. :contentReference[oaicite:2]{index=2}

# Create an unprivileged user (group may already exist because xpra packages create it)
RUN getent group xpra >/dev/null || groupadd -r xpra && \
    id -u xpra >/dev/null 2>&1 || useradd -m -s /bin/bash -g xpra xpra

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER xpra
WORKDIR /home/xpra

EXPOSE 14500
ENTRYPOINT ["/entrypoint.sh"]
