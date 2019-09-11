FROM ubuntu:18.04
MAINTAINER Gabriel Ionescu <gabi.ionescu+dockerthings@protonmail.com>

# ARGS
ARG DOCKER_USERID
ARG DOCKER_GROUPID
ARG DOCKER_USERNAME
ARG TZ

# SET USER VARS IN ENV
ENV DOCKER_USERID $DOCKER_USERID
ENV DOCKER_GROUPID $DOCKER_GROUPID
ENV DOCKER_USERNAME $DOCKER_USERNAME

# SET NONINTERACTIVE
ENV DEBIAN_FRONTEND "noninteractive"

# SET LOCALES
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL en_US.UTF-8

# SET TZ
ENV TZ=$TZ

# QT GUI
ENV QT_X11_NO_MITSHM=1

# ADD FILES
COPY install/elementary /usr/share/themes/elementary
COPY install/config/gtk-3.0 /home/$DOCKER_USERNAME/.config/gtk-3.0
COPY install/gtkrc-2.0 /home/$DOCKER_USERNAME/.gtkrc-2.0

RUN echo "\n > CREATE USER\n" \
 && mkdir -p /home/$DOCKER_USERNAME \
 && echo "$DOCKER_USERNAME:x:$DOCKER_USERID:$DOCKER_GROUPID:$DOCKER_USERNAME,,,:/home/$DOCKER_USERNAME:/bin/bash" >> /etc/passwd \
 && echo "$DOCKER_USERNAME:x:$DOCKER_USERID:" >> /etc/group \
 && mkdir -p /etc/sudoers.d \
 && echo "$DOCKER_USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$DOCKER_USERNAME \
 && chmod 0440 /etc/sudoers.d/$DOCKER_USERNAME \
 && chown $DOCKER_USERID:$DOCKER_GROUPID -R /home/$DOCKER_USERNAME \
 && chmod 777 -R /home/$DOCKER_USERNAME \
 \
 && echo "\n > UPDATE REPOS\n" \
 && apt-get update \
 \
 && echo "\n > LOCALES\n" \
 && apt-get install -y --no-install-recommends \
        locales \
 && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 \
 && echo "\n > TIMEZONE: $TZ\n" \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 \
 && echo "\n > GTK3\n" \
 && apt-get install -y --no-install-recommends \
        libgtk-3-0 \
 \
 && echo "\n > THEME\n" \
 && apt-get install -y --no-install-recommends \
        gtk2-engines-murrine \
        gtk2-engines-pixbuf \
        ubuntu-mate-themes \
 \
 && echo "\n > ELEMENTARY ICONS\n" \
 && apt-get install -y --no-install-recommends \
        software-properties-common \
        libnotify-bin \
 && add-apt-repository ppa:elementary-add-team/icons \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        elementary-add-icon-theme \
 \
 && echo "\n > DBUS\n" \
 && apt-get install -y --no-install-recommends \
        dbus-x11 \
 \
 && echo "\n > FILE MANAGER\n" \
 && apt-get install -y --no-install-recommends \
        pcmanfm \
 \
 && echo "\n > CLEANUP\n" \
 && apt-get remove -y \
        software-properties-common \
 && apt-get clean -y \
 && apt-get autoclean -y \
 && apt-get autoremove -y \
 && rm -f /var/cache/apt/archives/*.deb \
 \
 && echo "\n > MAKE SURE BUS IS \n" \
 && chown $DOCKER_USERID:$DOCKER_GROUPID -R /home/$DOCKER_USERNAME \
 \
 && echo "\n > FIX DBUS\n" \
 && mkdir -p /var/run/dbus

# ADD FIFO
COPY install/fifo/xdg-open /usr/bin/xdg-open
COPY install/fifo/notify-send /usr/bin/notify-send
RUN chmod +x \
        /usr/bin/xdg-open \
        /usr/bin/notify-send

# UNSET NONINTERACTIVE
ENV DEBIAN_FRONTEND ""
