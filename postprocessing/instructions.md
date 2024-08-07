# Postprocessing Instructions
Containerization of GFDL [FRE-NCtools](https://github.com/NOAA-GFDL/FRE-NCtools/tree/main/tools)

Docker image: [gfdlfv3/fre-nctools](https://hub.docker.com/r/gfdlfv3/fre-nctools)

# Example
Remap C96 data onto 1- by 1-degree latitude-longitude grid. Use SHiELD C96 global-nest simulation of Hurricane Ida as an example
```
docker run -v ./global_nest_Ida/:/workdir gfdlfv3/fre-nctools fregrid --input_mosaic ./INPUT/C96_coarse_mosaic.nc --nlon 360 --nlat 180 --interp_method conserve_order1 --input_file atmos_sos --output_file atmos_sos_ltd.nc --scalar_field PRMSL,TMP2m,DPT2m,PRATEsfc,ULWRFtoa
```
