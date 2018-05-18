FROM ubuntu:xenial
RUN apt-get update && \
    apt-get install -y locales

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y software-properties-common python-software-properties python-pip
RUN pip install --upgrade cython==0.25
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y build-essential ccache git libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python python-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386 pkg-config libtool autoconf automake libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev curl

RUN pip install --upgrade pip

# Install CrystaX NDK (only needed for python3)
#RUN CHECKSUM=7305b59a3cee178a58eeee86fe78ad7bef7060c6d22cdb027e8d68157356c4c0 && \
#    FILE=crystax-ndk-10.3.2-linux-x86_64.tar.xz && \
#    curl -sLo $FILE https://www.crystax.net/download/$FILE && \
#    openssl sha256 ${FILE} > $$.file && \
#    echo "SHA256(${FILE})= ${CHECKSUM}" > $$.expected && \
#    diff $$.file $$.expected && \
#    echo 'OK' || echo '*** CORRUPTED!!!'
#
#RUN tar xvf crystax-ndk-10.3.2-linux-x86_64.tar.xz -C /opt
#ENV ANDROID_NDK_HOME /opt/crystax-ndk-10.3.2

RUN git clone https://github.com/sofwerx/buildozer /buildozer
WORKDIR /buildozer
RUN python setup.py build
RUN pip install -e .

ADD requirements.txt /app/
WORKDIR /app
RUN pip install -r requirements.txt

WORKDIR /app

ADD buildozer.spec /app/
RUN git clone http://github.com/sofwerx/python-for-android /python-for-android
RUN buildozer android update

ADD . /app
RUN mkdir -p /app/.buildozer/android/platform/build/dists/provost/build/outputs/apk
RUN buildozer android debug || true
RUN find / -name '*.apk' -exec ls -la {} \;

VOLUME /outputs

CMD find / -name '*.apk' -exec cp {} /outputs \;

