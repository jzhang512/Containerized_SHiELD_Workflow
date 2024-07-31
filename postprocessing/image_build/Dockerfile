ARG BASE_IMAGE=continuumio/miniconda3

# Create a base image
FROM $BASE_IMAGE

USER root

RUN apt update && \
    apt-get clean && rm -rf /var/lib/apt

RUN conda install jupyter cartopy xarray netCDF4 h5netcdf cftime -y && \
    jupyter server --generate-config 

ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT


CMD ["start-notebook.sh"]
COPY start-notebook.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start-notebook.sh

RUN adduser visualizer
USER visualizer
WORKDIR /home/
