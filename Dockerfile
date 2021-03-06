FROM resin/armv7hf-node:0.10.38

RUN apt-get update \
  && apt-get install -y \
    bison \
    flex \
    freebsd-glue \
    libconfig++-dev \
  && rm -rf /var/lib/apt/lists/*

# Install epiphany SDK
ENV EPIPHANY_HOME /opt/adapteva/esdk
ENV ESDK_VERSION 2015.1_linux_armv7l-20150523

RUN mkdir -p $EPIPHANY_HOME \
    && curl -sL http://ftp.parallella.org/esdk/beta/esdk.$ESDK_VERSION.tar.gz | tar xz -C $EPIPHANY_HOME --strip-components=1

# Build libelf
ENV LIBELF_VERSION 0.8.13

RUN mkdir -p /usr/src/libelf \
    && curl -sL http://www.mr511.de/software/libelf-$LIBELF_VERSION.tar.gz | tar xz -C /usr/src/libelf --strip-components=1 \
    && cd /usr/src/libelf \
    && ./configure \
    && make -j $(nproc) \
    && make install \
    && rm -rf /usr/src/libelf

# Build libcoprthr
ENV LIBCOPRTHR_VERSION parallellocalypse

RUN . /opt/adapteva/esdk/setup.sh \
    && mkdir -p /usr/src/libcoprthr \
    && curl -sL https://github.com/olajep/coprthr/archive/$LIBCOPRTHR_VERSION.tar.gz | tar xz -C /usr/src/libcoprthr --strip-components=1 \
    && cd /usr/src/libcoprthr \
    && ./configure --enable-epiphany \
    && make \
    && make install \
    && rm -rf /usr/src/libcoprthr

# Install libcoprthr_mpi
ENV LIBCOPTHR_MPI_VERSION preview

RUN . /opt/adapteva/esdk/setup.sh \
    && mkdir -p /usr/src/libcoprthr-mpi \
    && curl -sL http://www.browndeertechnology.com/code/bdt-libcoprthr_mpi-$LIBCOPTHR_MPI_VERSION.tgz | tar xz -C /usr/src/libcoprthr-mpi --strip-components=1 \
    && cd /usr/src/libcoprthr-mpi \
    && ./install.sh \
    && rm -rf /usr/src/libcoprthr_mpi

# Install parallella thermald
ENV PARALLELLA_UTILS_VERSION 4acba56ddd6c002d64b0f856572b227664fe904e

RUN mkdir -p /usr/src/parallella-utils \
    && curl -sL https://github.com/parallella/parallella-utils/archive/$PARALLELLA_UTILS_VERSION.tar.gz | tar xz -C /usr/src/parallella-utils --strip-components=1 \
    && cd /usr/src/parallella-utils/thermald \
    && make \
    && make install \
    && rm -rf /usr/src/parallella-utils

# Clone the FFT correlation repo
ENV PARALLELLA_FFT_XCORR_VERSION c2bee839535bcff868cdeb7c1c5f735a60d02f44

RUN mkdir -p /usr/src/app/parallella-fft-xcorr \
    && curl -sL https://github.com/olajep/parallella-fft-xcorr/archive/$PARALLELLA_FFT_XCORR_VERSION.tar.gz | tar xz -C /usr/src/app/parallella-fft-xcorr --strip-components=1

RUN mkdir -p /usr/src/app

COPY . /usr/src/app

# Run this on startup.
CMD [ "/usr/src/app/run.sh" ]
