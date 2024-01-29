FROM ubuntu:20.04

LABEL Maintainer="Apoorv Vyavahare <apoorvvyavahare@pm.me>"

ARG DEBIAN_FRONTEND=noninteractive

# VNC Server Password
ENV VNC_PASS="samplepass" \
    VNC_TITLE="Vubuntu_Desktop" \
    VNC_RESOLUTION="1280x720" \
    VNC_SHARED=0 \
    DISPLAY=:0 \
    NOVNC_PORT=$PORT \
    NGROK_AUTH_TOKEN="placeholder" \
    BRAVE_USE_SHM=1 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ="Asia/Kolkata"

COPY . /app/.vubuntu

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get --no-install-recommends install -y \
        tzdata software-properties-common apt-transport-https wget zip unzip htop git curl vim nano zip sudo net-tools x11-utils eterm iputils-ping build-essential xvfb x11vnc supervisor \
        gnome-terminal gnome-calculator gnome-system-monitor pcmanfm terminator firefox \
        python3 python3-pip python-is-python3 \
        default-jre default-jdk \
        vim-gtk3 mousepad pluma \
        nodejs npm \
        golang \
        libreoffice \
        gnupg \
        dirmngr \
        gdebi-core \
        nginx \
        ffmpeg && \
    apt-get install --no-install-recommends -y /app/.vubuntu/assets/packages/fluxbox.deb /app/.vubuntu/assets/packages/novnc.deb && \
    cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/ST=Maharastra/L=Private/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key  -out /etc/ssl/novnc.cert && \
    npm i -g websockify && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg && \
    install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"| tee /etc/apt/sources.list.d/brave-browser-release.list && \
    wget https://github.com/peazip/PeaZip/releases/download/8.2.0/peazip_8.2.0.LINUX.GTK2-1_amd64.deb -P /tmp && \
    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - && \
    add-apt-repository "deb https://download.sublimetext.com/ apt/stable/" && \
    wget https://updates.tdesktop.com/tlinux/tsetup.3.2.2.tar.xz -P /tmp && \
    tar -xvf /tmp/tsetup.3.2.2.tar.xz -C /tmp && \
    mv /tmp/Telegram/Telegram /usr/bin/telegram && \
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -P /tmp && \
    apt-get update && \
    apt-get install --no-install-recommends -y code brave-browser /tmp/peazip_8.2.0.LINUX.GTK2-1_amd64.deb sublime-text /tmp/packages-microsoft-prod.deb powershell && \
    wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -P /tmp && \
    unzip /tmp/ngrok-stable-linux-amd64.zip -d /usr/bin && \
    ngrok authtoken $NGROK_AUTH_TOKEN && \
    code --user-data-dir /root --no-sandbox --install-extension philnash.ngrok-for-vscode && \
    code --user-data-dir /root --no-sandbox --install-extension ritwickdey.LiveServer && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["supervisord", "-l", "/app/.vubuntu/assets/logs/supervisord.log", "-c"]

CMD ["/app/.vubuntu/assets/configs/supervisordconf"]
