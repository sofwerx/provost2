FROM ubuntu:xenial
RUN apt-get update && \
    apt-get install -y locales

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

RUN apt-get install -y software-properties-common python-software-properties python3-pip
RUN pip3 install --upgrade cython==0.21
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y build-essential ccache git libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python3.5 python3.5-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386 pkg-config libtool autoconf automake libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

RUN pip3 install --upgrade pip

ADD requirements.txt /app/
WORKDIR /app
RUN pip3 install -r requirements.txt

ADD buildozer.spec /app/
RUN buildozer android update

RUN apt-get install -y build-essential ccache git libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python3.5 python3.5-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386 automake autoconf libtool pkg-config

ADD . /app
RUN mkdir -p /app/.buildozer/android/platform/build/dists/provost/build/outputs/apk
RUN buildozer android debug || true
RUN find / -name '*.apk' -exec ls -la {} \;

VOLUME /outputs

CMD find / -name '*.apk' -exec cp {} /outputs \;

