ARG BASE_IMAGE=debian:stable-20220125-slim
ARG MAKEJOBS=8
ARG OPENMPI_DIR=/opt/openmpi
ARG HDF5_DIR=/opt/hdf5
ARG NETCDF_DIR=/opt/netcdf
ARG FRENCTOOLS_DIR=/opt/frenctools
ARG OPENMPI_VERSION="4.1.0"
ARG HDF5_VERSION="hdf5-1_12_0"
ARG NETCDF_VERSION="4.7.4"
ARG NETCDFF_VERSION="4.5.3"
ARG FRENCTOOLS_VERSION="2024.03"

# Create a base image
FROM $BASE_IMAGE AS base-image

RUN apt update && \
    apt-get install -y \
    gfortran \
    openssh-client \
    libcurl4-gnutls-dev && \
    rm -rf /var/lib/apt

# Create an intermediate image for model compilation  
FROM base-image as env-image
ARG OPENMPI_DIR
ARG HDF5_DIR
ARG NETCDF_DIR
ARG OPENMPI_VERSION
ARG FRENCTOOLS_DIR
ARG HDF5_VERSION
ARG NETCDF_VERSION
ARG NETCDFF_VERSION
ARG FRENCTOOLS_VERSION

RUN apt update && \
    apt-get install -y \
    build-essential \
    wget \
    git

# Install OPENMPI
RUN cd /tmp
RUN wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.gz \
 && tar xvf openmpi-4.1.0.tar.gz \
 && cd openmpi-4.1.0 \
 && ./configure --prefix=${OPENMPI_DIR} \
 && make -j${MAKEJOBS} && make install

ENV OPENMPI_DIR ${OPENMPI_DIR}
ENV PATH ${OPENMPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH ${OPENMPI_DIR}/lib:${LD_LIBRARY_PATH}

# Build HDF5 libraries
RUN apt-get install -y zlib1g-dev

RUN cd /tmp
RUN git clone https://github.com/HDFGroup/hdf5.git \
 && cd hdf5 \
 && git checkout $HDF5_VERSION \
 && ./configure --enable-fortran --enable-cxx --prefix=${HDF5_DIR} \
 && make -j${MAKEJOBS} && make install
ENV LD_LIBRARY_PATH ${HDF5_DIR}/lib:${LD_LIBRARY_PATH}

# Build netCDF C and Fortran libraries
ENV CPPFLAGS=-I${HDF5_DIR}/include
RUN apt-get install -y m4

RUN cd /tmp \
 && wget -q https://github.com/Unidata/netcdf-c/archive/v${NETCDF_VERSION}.tar.gz \
 && tar -xf v${NETCDF_VERSION}.tar.gz \
 && cd netcdf-c-${NETCDF_VERSION} \
 && ./configure --prefix=${NETCDF_DIR} LDFLAGS=-L${HDF5_DIR}/lib\
 && make -j${MAKEJOBS} && make install

RUN cd /tmp \
 && wget -q https://github.com/Unidata/netcdf-fortran/archive/v${NETCDFF_VERSION}.tar.gz \
 && tar -xf v${NETCDFF_VERSION}.tar.gz \
 && cd netcdf-fortran-${NETCDFF_VERSION}/ \
 && export LD_LIBRARY_PATH=${NETCDF_DIR}/lib:${LD_LIBRARY_PATH} \
 && CPPFLAGS=-I${NETCDF_DIR}/include LDFLAGS=-L${NETCDF_DIR}/lib ./configure --prefix=${NETCDF_DIR} \
 && make -j${MAKEJOBS} && make install

ENV HDF5_DIR ${HDF5_DIR}
ENV NETCDF ${NETCDF_DIR}
ENV LD_LIBRARY_PATH ${NETCDF}/lib:${LD_LIBRARY_PATH}
ENV PATH ${NETCDF}/bin:$PATH

# Preconfiguration for SHiELD
RUN apt-get install -y autoconf
ENV CPATH ${NETCDF}/include:${CPATH}
ENV NETCDF_DIR ${NETCDF}

RUN cd /tmp
RUN git clone https://github.com/NOAA-GFDL/FRE-NCtools.git \
 && cd FRE-NCtools \
 && git checkout ${FRENCTOOLS_VERSION} \
 && autoreconf -i \
 && ./configure --prefix=${FRENCTOOLS_DIR} \
 && make -j${MAKEJOBS} && make install


# Create a clean image
FROM base-image as frenctools

ARG OPENMPI_DIR HDF5_DIR NETCDF_DIR FRENCTOOLS_DIR

COPY --from=env-image ${OPENMPI_DIR} ${OPENMPI_DIR}
COPY --from=env-image ${HDF5_DIR}/lib ${HDF5_DIR}/lib
COPY --from=env-image ${NETCDF_DIR}/lib ${NETCDF_DIR}/lib
COPY --from=env-image ${FRENCTOOLS_DIR} ${FRENCTOOLS_DIR}

ENV PATH=${OPENMPI_DIR}/bin:${FRENCTOOLS_DIR}/bin:$PATH \ 
    LD_LIBRARY_PATH=${OPENMPI_DIR}/lib:${HDF5_DIR}/lib:${NETCDF_DIR}/lib:$LD_LIBRARY_PATH \
	  USER=shield

RUN adduser shield

WORKDIR /workdir
