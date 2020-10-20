FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-12

COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
	&& bash /tmp/library-scripts/desktop-lite-debian.sh \
	&& apt-get -y install firefox-esr \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Core environment variables for X11, VNC, and fluxbox
ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
	MAX_VNC_RESOLUTION="1920x1080x16" \
	VNC_RESOLUTION="1440x768" \
	VNC_DPI="96" \
	VNC_PORT="5901" \
	NOVNC_PORT="6080" \
	DISPLAY=":1" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8"

ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
CMD ["sleep", "infinity"]

