ARG BASE_IMAGE=debian:stable-20220125-slim
ARG MPI_IMAGE=ufs_utils
ARG MAKEJOBS=8
ARG OPENMPI_DIR=/opt/openmpi
ARG OPENMPI_VERSION="4.1.0"
ARG UFS_UTILS_EXEC_DIR=/UFS_UTILS/exec
ARG UFS_UTILS_USH_DIR=/UFS_UTILS/ush

FROM $BASE_IMAGE AS base-image

RUN apt update && \
    apt-get install -y \
    time \
    gfortran \
    openssh-client \
    libcurl4-gnutls-dev && \
    rm -rf /var/lib/apt

# Create an intermediate image for model compilation  
FROM base-image AS env-image
ARG OPENMPI_DIR
ARG OPENMPI_VERSION

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

# Install ufs_utils_libs
RUN apt-get install -y cmake m4
RUN cd /
RUN git clone https://github.com/kaiyuan-cheng/ufs_utils_libs.git \
 && cd ufs_utils_libs \
 && sed -i 's/--as-needed,-lmpifort_intel,//' ./CMakeLists.txt \
 && sed -i 's/--as-needed,-lmpi_intel,//' ./CMakeLists.txt \
 && sed -i 's/--as-needed,-limf,//' ./CMakeLists.txt \
 && ./build_all.sh

# Install UFS_UTILS
RUN cd /
RUN git clone -b gaea https://github.com/kaiyuan-cheng/UFS_UTILS.git \
 && cd UFS_UTILS \
 && sed -i 's/. ${MODULESHOME}\/init\/sh/export CMAKE_PREFIX_PATH="\/ufs_utils_libs\/install"/' ./build_all.sh \
 && sed -i 's/module use .\/modulefiles/export LD_LIBRARY_PATH="\/ufs_utils_libs\/install\/lib"/' ./build_all.sh \
 && sed -i 's/module load build.$target.$compiler/export ESMFMKFILE="\/ufs_utils_libs\/install\/lib\/esmf.mk"/' ./build_all.sh \
 && ./build_all.sh

# # Create clean (final) image
FROM base-image AS final-preprocessing

RUN cd / && mkdir UFS_UTILS \
 && cd UFS_UTILS && mkdir fix

ARG OPENMPI_DIR UFS_UTILS_EXEC_DIR UFS_UTILS_USH_DIR

COPY --from=env-image ${OPENMPI_DIR} ${OPENMPI_DIR}
COPY --from=env-image ${UFS_UTILS_EXEC_DIR} ${UFS_UTILS_EXEC_DIR}
COPY --from=env-image ${UFS_UTILS_USH_DIR} ${UFS_UTILS_USH_DIR}
COPY --from=env-image /ufs_utils_libs/install/bin/ncdump /ufs_utils_libs/install/bin/ncdump

# Redeclare (does not carry over from env-image, previous build stage)
ENV PATH ${OPENMPI_DIR}/bin:/ufs_utils_libs/install/bin:$PATH

# Non-root user for parallel computing
RUN adduser preprocesser \
 && mkdir /workdir \
 && chown preprocesser /workdir

USER preprocesser
WORKDIR /workdir

COPY preprocessing_entrypoint.sh /preprocessing_entrypoint.sh
COPY compile_exitpoint.sh /compile_exitpoint.sh

ENTRYPOINT ["/preprocessing_entrypoint.sh"]
