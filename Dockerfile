FROM ubuntu:18.04

# original from https://github.com/cdrx/docker-pyinstaller

ENV DEBIAN_FRONTEND noninteractive

# wine settings
ENV WINEARCH win64
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy apt-transport-https software-properties-common wget gpg-agent rename zip \
    && wget -nv https://dl.winehq.org/wine-builds/winehq.key \
    # used to suppress apt-key warning message
    && APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && apt-key add winehq.key \
    && add-apt-repository 'https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy winehq-stable winbind cabextract \
    && apt-get clean \
    && wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin \
    # install python in wine, using the msi packages to install, extracting
    # the files directly, since installing isn't running correctly.
    && set -x \
    && winetricks win7 \
    && for msifile in `echo core dev exe lib path pip tcltk tools`; do \
        wget -nv "https://www.python.org/ftp/python/3.7.3/amd64/${msifile}.msi"; \
        wine msiexec /i "${msifile}.msi" /qb TARGETDIR=C:/Python37; \
        rm ${msifile}.msi; \
    done \
    && cd /wine/drive_c/Python37 \
    && echo 'wine '\''C:\Python37\python.exe'\'' "$@"' > /usr/bin/python \
    && echo 'wine '\''C:\Python37\Scripts\easy_install.exe'\'' "$@"' > /usr/bin/easy_install \
    && echo 'wine '\''C:\Python37\Scripts\pip.exe'\'' "$@"' > /usr/bin/pip \
    && echo 'wine '\''C:\Python37\Scripts\pyinstaller.exe'\'' "$@"' > /usr/bin/pyinstaller \
    && echo 'wine '\''C:\Python37\Scripts\pyupdater.exe'\'' "$@"' > /usr/bin/pyupdater \
    && echo 'assoc .py=PythonScript' | wine cmd \
    && echo 'ftype PythonScript=c:\Python37\python.exe "%1" %*' | wine cmd \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && chmod +x /usr/bin/python /usr/bin/easy_install /usr/bin/pip /usr/bin/pyinstaller /usr/bin/pyupdater \
    && wine python.exe Scripts/pip.exe install pywin32 \
    && rm -rf /tmp/.wine-* \
    # install Microsoft Visual C++ Redistributable for Visual Studio 2017 dll files
    && set -x \
    && W_TMP="/wine/drive_c/windows/temp/_$0" \
    && rm -f "$W_TMP"/* \
    && wget -P "$W_TMP" https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP"/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a10" \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a11" \
    && cd "$W_TMP" \
    && rename 's/_/\-/g' *.dll \
    && cp "$W_TMP"/*.dll "/wine/drive_c/windows/system32"/ \
    # link the src folder inside the wine folder
    && mkdir /src/ && ln -s /src /wine/drive_c/src \
    && mkdir -p /wine/drive_c/tmp \
    && pip install pyinstaller==3.5
