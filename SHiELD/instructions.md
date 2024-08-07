# Model Execution Instructions

Image: [jzhang512/execution_shield](https://hub.docker.com/r/jzhang512/execution_shield)

## Volume Mounts
Make sure that you have two directories set up on the host machine: `rundir` and `GFS_fix`. They are critical for I/O operations.

### Directory Structure
Ensure that the structure and naming match exactly these:
```
rundir
├── INPUT
└── RESTART
```

```
GFS_fix
```
Refer to the last section on this page for an example of what files to include (example's resolution is C48). You can download the recent GFS analyses [here](https://www.nco.ncep.noaa.gov/pmb/products/gfs/).

## Run Behavior
### Configuration
Configure your run using the `input.nml` and `diag_table` files. They are provided in this same directory. 

### Runtime
The model script will run immediately upon running the image and will always exit the container. All outputs are in-place modifications of the files given in the `rundir` directory.


## Run Command Templates

### Docker
```
docker run -it --cap-add=SYS_PTRACE --ulimit='stack=-1:-1' \
 -v "/PATH_TO_/2022010100_C48/:/rundir" \
 -v "/PATH_TO_/GFS_fix/:/GFS_fix" \
 -it jzhang512/execution_shield mpirun -np 6 -oversubscribe SHiELD_nh.prod.32bit.x%   
```

### Apptainer
```
apptainer exec --bind
  /PATH_TO_/2022010100_C48/:/rundir,
  /PATH_TO_/GFS_fix/:/GFS_fix
  execution_shield_latest.sif cd /rundir && mpirun -np 6 -oversubscribe SHiELD_nh.prod.32bit.x
```
Replace `/PATH_TO_/` with the actual path on your host machine. Ensure that the paths inside the container are as specified above. 

Since Apptainer does not support the Docker `WORKDIR`, include the `cd` command in the run command to achieve the same behavior.

## Example Files for Mounted Directories

### /rundir
```
rundir
├── INPUT
│   ├── C48_grid.tile1.nc
│   ├── C48_grid.tile2.nc
│   ├── C48_grid.tile3.nc
│   ├── C48_grid.tile4.nc
│   ├── C48_grid.tile5.nc
│   ├── C48_grid.tile6.nc
│   ├── aerosol.dat
│   ├── co2historicaldata_2009.txt
│   ├── co2historicaldata_2010.txt
│   ├── co2historicaldata_2011.txt
│   ├── co2historicaldata_2012.txt
│   ├── co2historicaldata_2013.txt
│   ├── co2historicaldata_2014.txt
│   ├── co2historicaldata_2015.txt
│   ├── co2historicaldata_2016.txt
│   ├── co2historicaldata_2017.txt
│   ├── co2historicaldata_2018.txt
│   ├── co2historicaldata_2019.txt
│   ├── co2historicaldata_2020.txt
│   ├── co2historicaldata_glob.txt
│   ├── co2monthlycyc.txt
│   ├── gfs_ctrl.nc
│   ├── gfs_data.tile1.nc
│   ├── gfs_data.tile2.nc
│   ├── gfs_data.tile3.nc
│   ├── gfs_data.tile4.nc
│   ├── gfs_data.tile5.nc
│   ├── gfs_data.tile6.nc
│   ├── global_h2oprdlos.f77
│   ├── global_o3prdlos.f77
│   ├── grid_spec.nc
│   ├── oro_data.tile1.nc
│   ├── oro_data.tile2.nc
│   ├── oro_data.tile3.nc
│   ├── oro_data.tile4.nc
│   ├── oro_data.tile5.nc
│   ├── oro_data.tile6.nc
│   ├── sfc_data.tile1.nc
│   ├── sfc_data.tile2.nc
│   ├── sfc_data.tile3.nc
│   ├── sfc_data.tile4.nc
│   ├── sfc_data.tile5.nc
│   ├── sfc_data.tile6.nc
│   ├── sfc_emissivity_idx.txt
│   ├── solarconstant_noaa_an.txt
│   ├── volcanic_aerosols_1850-1859.txt
│   ├── volcanic_aerosols_1860-1869.txt
│   ├── volcanic_aerosols_1870-1879.txt
│   ├── volcanic_aerosols_1880-1889.txt
│   ├── volcanic_aerosols_1890-1899.txt
│   ├── volcanic_aerosols_1900-1909.txt
│   ├── volcanic_aerosols_1910-1919.txt
│   ├── volcanic_aerosols_1920-1929.txt
│   ├── volcanic_aerosols_1930-1939.txt
│   ├── volcanic_aerosols_1940-1949.txt
│   ├── volcanic_aerosols_1950-1959.txt
│   ├── volcanic_aerosols_1960-1969.txt
│   ├── volcanic_aerosols_1970-1979.txt
│   ├── volcanic_aerosols_1980-1989.txt
│   └── volcanic_aerosols_1990-1999.txt
├── RESTART
│   ├── coupler.res
│   ├── fv_core.res.nc
│   ├── fv_core.res.tile1.nc
│   ├── fv_core.res.tile2.nc
│   ├── fv_core.res.tile3.nc
│   ├── fv_core.res.tile4.nc
│   ├── fv_core.res.tile5.nc
│   ├── fv_core.res.tile6.nc
│   ├── fv_srf_wnd.res.tile1.nc
│   ├── fv_srf_wnd.res.tile2.nc
│   ├── fv_srf_wnd.res.tile3.nc
│   ├── fv_srf_wnd.res.tile4.nc
│   ├── fv_srf_wnd.res.tile5.nc
│   ├── fv_srf_wnd.res.tile6.nc
│   ├── fv_tracer.res.tile1.nc
│   ├── fv_tracer.res.tile2.nc
│   ├── fv_tracer.res.tile3.nc
│   ├── fv_tracer.res.tile4.nc
│   ├── fv_tracer.res.tile5.nc
│   ├── fv_tracer.res.tile6.nc
│   ├── phy_data.tile1.nc
│   ├── phy_data.tile2.nc
│   ├── phy_data.tile3.nc
│   ├── phy_data.tile4.nc
│   ├── phy_data.tile5.nc
│   ├── phy_data.tile6.nc
│   ├── sfc_data.tile1.nc
│   ├── sfc_data.tile2.nc
│   ├── sfc_data.tile3.nc
│   ├── sfc_data.tile4.nc
│   ├── sfc_data.tile5.nc
│   └── sfc_data.tile6.nc
├── atmos_sos.tile1.nc
├── atmos_sos.tile2.nc
├── atmos_sos.tile3.nc
├── atmos_sos.tile4.nc
├── atmos_sos.tile5.nc
├── atmos_sos.tile6.nc
├── atmos_sos_ave.tile1.nc
├── atmos_sos_ave.tile2.nc
├── atmos_sos_ave.tile3.nc
├── atmos_sos_ave.tile4.nc
├── atmos_sos_ave.tile5.nc
├── atmos_sos_ave.tile6.nc
├── atmos_static.tile1.nc
├── atmos_static.tile2.nc
├── atmos_static.tile3.nc
├── atmos_static.tile4.nc
├── atmos_static.tile5.nc
├── atmos_static.tile6.nc
├── data_table
├── diag_table
├── field_table
├── grid_spec.tile1.nc
├── grid_spec.tile2.nc
├── grid_spec.tile3.nc
├── grid_spec.tile4.nc
├── grid_spec.tile5.nc
├── grid_spec.tile6.nc
├── input.nml
├── logfile.000000.out
├── nggps2d.tile1.nc
├── nggps2d.tile2.nc
├── nggps2d.tile3.nc
├── nggps2d.tile4.nc
├── nggps2d.tile5.nc
├── nggps2d.tile6.nc
└── time_stamp.out
```
### GFS_fix
```
GFS_fix
├── CFSR.SEAICE.1982.2012.monthly.clim.grb
├── RTGSST.1982.2012.monthly.clim.grb
├── global_albedo4.1x1.grb
├── global_glacier.2x2.grb
├── global_maxice.2x2.grb
├── global_mxsnoalb.uariz.t1534.3072.1536.rg.grb
├── global_shdmax.0.144x0.144.grb
├── global_shdmin.0.144x0.144.grb
├── global_slope.1x1.grb
├── global_snoclim.1.875.grb
├── global_snowfree_albedo.bosu.t1534.3072.1536.rg.grb
├── global_soilmgldas.t1534.3072.1536.grb
├── global_soiltype.statsgo.t1534.3072.1536.rg.grb
├── global_tg3clim.2.6x1.5.grb
├── global_vegfrac.0.144.decpercent.grb
├── global_vegtype.igbp.t1534.3072.1536.rg.grb
├── mld_DR003_c1m_reg2.0.grb
└── seaice_newland.grb
```
