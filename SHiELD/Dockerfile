ARG BASE_IMAGE=debian:stable-20220125-slim
ARG MPI_IMAGE=shield-mpi
ARG MAKEJOBS=8
ARG OPENMPI_DIR=/opt/openmpi
ARG HDF5_DIR=/opt/hdf5
ARG NETCDF_DIR=/opt/netcdf
ARG OPENMPI_VERSION="4.1.0"
ARG HDF5_VERSION="hdf5-1_12_0"
ARG NETCDF_VERSION="4.7.4"
ARG NETCDFF_VERSION="4.5.3"
ARG GFDL_atmos_cubed_sphere_VERSION="main"
ARG SHiELD_physics_VERSION="main"

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
ARG HDF5_VERSION
ARG NETCDF_VERSION
ARG NETCDFF_VERSION
ARG GFDL_atmos_cubed_sphere_VERSION
ARG SHiELD_physics_VERSION

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
RUN apt-get install -y tcsh procps cmake
ENV CPATH ${NETCDF}/include:${CPATH}
ENV NETCDF_DIR ${NETCDF}

# Change the non-interactive shell from dash to bash
RUN cd /bin && rm sh && ln -s ./bash ./sh

# Download SHiELD_build
RUN cd / \
 && git clone https://github.com/NOAA-GFDL/SHiELD_build.git \
 && cd /SHiELD_build \
 && git submodule update --init --recursive

# Revise CHECKOUT_code
RUN cd /SHiELD_build \
 && sed -i '/${MODULESHOME}\/init\/sh/d' ./CHECKOUT_code \
 && sed -i '/module load git/d' ./CHECKOUT_code \
 && ./CHECKOUT_code

# Checkout code
RUN cd /SHiELD_SRC/SHiELD_physics \
 && git checkout ${SHiELD_physics_VERSION}

RUN cd /SHiELD_SRC/GFDL_atmos_cubed_sphere \
 && git checkout ${GFDL_atmos_cubed_sphere_VERSION}

# Revise environment.gnu.sh
RUN cd /SHiELD_build/site \
 &&  echo -e '\
  export FC=mpif90\n\
  export CC=mpicc\n\
  export CXX=mpicxx\n\
  export LD=mpif90\n\
  export TEMPLATE=site/gnu.mk\n\
  export LAUNCHER=mpirun\n\
  ' > ./environment.gnu.sh

# Revise gnu.mk for better performance
RUN cd /SHiELD_build/site \
 && sed -i 's/-fno-range-check -fbacktrace/-fno-range-check -fallow-argument-mismatch -fallow-invalid-boz -fbacktrace/g' ./gnu.mk \
 && sed -i 's/FFLAGS_OPT = -O2 -fno-range-check/FFLAGS_OPT = -O3 -funroll-all-loops -fno-protect-parens -fno-rounding-math -fno-trapping-math -fno-signaling-nans/g' ./gnu.mk \
 && sed -i 's/TRANSCENDENTALS :=/TRANSCENDENTALS := -ffinite-math-only/g' ./gnu.mk \
 && sed -i 's/CFLAGS_OPT = -O2/CFLAGS_OPT = -O3 -funroll-all-loops -fprefetch-loop-arrays -fno-protect-parens -fno-rounding-math -fno-trapping-math -fno-signaling-nans/g' ./gnu.mk

# Revise MAKE_libFMS
RUN cd /SHiELD_build/Build/mk_scripts \
 && sed -i 's/cppDefs="-Duse_libMPI/cppDefs="-DHAVE_GETTID -Duse_libMPI/g' ./MAKE_libFMS

# Compile SHiELD
RUN cd /SHiELD_build/Build \
 && ./COMPILE gnu 64bit \
 && ./COMPILE gnu 32bit

RUN rm -rf ${OPENMPI_DIR}/share \
 && rm -rf ${OPENMPI_DIR}/include

# Rename executables
RUN cd /SHiELD_build/Build/bin \
 && mv SHiELD_nh.prod.64bit.gnu.x SHiELD_nh.prod.64bit.x \
 && mv SHiELD_nh.prod.32bit.gnu.x SHiELD_nh.prod.32bit.x

# Create a clean image
FROM base-image as shield

ARG OPENMPI_DIR HDF5_DIR NETCDF_DIR

COPY --from=env-image ${OPENMPI_DIR} ${OPENMPI_DIR}
COPY --from=env-image ${HDF5_DIR}/lib ${HDF5_DIR}/lib
COPY --from=env-image ${NETCDF_DIR}/lib ${NETCDF_DIR}/lib
COPY --from=env-image /SHiELD_build/Build/bin /SHiELD_build/Build/bin

# Update environment variables
ENV PATH=/SHiELD_build/Build/bin:${OPENMPI_DIR}/bin:$PATH \ 
    LD_LIBRARY_PATH=${OPENMPI_DIR}/lib:${HDF5_DIR}/lib:${NETCDF_DIR}/lib:$LD_LIBRARY_PATH\
	USER=shield

RUN adduser shield

WORKDIR /rundir

RUN chown shield /rundir

USER shield