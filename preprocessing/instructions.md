# Pre-Processing Instructions

## Volume Mounts
Make sure that you have three directories set up on the host machine **with the exact naming**: `fix`, `workdir`, `GFSvOPER`. They are critical for I/O operations.

### Directory Structure
```
fix
├── am
├── orog_raw
└── sfc_climo
```
```
workdir
├── driver_scripts
└── outputs
```
```
GFSvOPER
└── 2016080100
```
Refer to the last section on this page for an example of what files to include.

## Run Behavior
Upon running the image, you will be prompted with four options: 
```
Enter:
'a' to generate grid (driver_grid.gaea.sh)
'b' to create initial conditions (chgres_cube.sh)
'c' to run both (driver_grid.gaea.sh then chgres_cube.sh)
'd' for manual access
Press Ctrl-Z or Ctrl-C to quit.
```
When an option is completed successfully, the container will be exited. If any error occurs, a bash shell will be opened inside the running container. All outputs are saved in `/workdir/outputs`.

To simplify setting up for running the SHiELD model, we compile all expected SHiELD inputs in `/workdir/outputs/model_inputs/run_date%year%month%dday%Hour%Minute%Second` whenever executing `chgres_cube.sh` successfully finishes. The files compiled together are outputs from both `driver_grid.gaea.sh` and `chgres_cube.sh`.

## Run Command Templates
### Docker
```
docker run -it \
  -v "/PATH_TO_/fix:/UFS_UTILS/fix" \
  -v "/PATH_TO_/workdir:/workdir" \
  -v "/PATH_TO_/GFSvOPER:/GFSvOPER" \
  jzhang512/preprocessing_shield
```
### Apptainer 
```
apptainer exec --bind
  /PATH_TO_/fix:/UFS_UTILS/fix,
  /PATH_TO_/workdir:/workdir,
  /PATH_TO_/GFSvOPER:/GFSvOPER
  preprocessing_shield_latest.sif /PATH_TO_/preprocessing_entrypoint.sh
```

Replace `/PATH_TO_/` with the actual path on your host machine. Ensure that the paths inside the container are as specified above. 

Since Apptainer does not support the Docker `ENTRYPOINT` command, include the entrypoint script in the run command to achieve the same behavior.

## Example File Structure for Mounted Directories

### /fix
```
fix
├── am
│   └── global_hyblev.l65.txt
├── orog_raw
│   ├── gmted2010.30sec.int
│   ├── landcover30.fixed
│   └── thirty.second.antarctic.new.bin
└── sfc_climo
    ├── facsf.1.0.nc
    ├── maximum_snow_albedo.0.05.nc
    ├── slope_type.1.0.nc
    ├── snowfree_albedo.4comp.0.05.nc
    ├── soil_color.clm.0.05.nc
    ├── soil_type.bnu.v3.30s.nc
    ├── soil_type.statsgo.0.05.nc
    ├── substrate_temperature.gfs.0.5.nc
    ├── vegetation_greenness.0.144.nc
    ├── vegetation_type.modis.igbp.0.05.nc
    └── vegetation_type.viirs.v3.igbp.30s.nc
```

### workdir
```
workdir
├── driver_scripts
│   ├── chgres_cube.sh
│   ├── driver_grid.gaea.sh
│   └── preprocessing_config.sh
└── outputs
```

### GFSvOPER
```
GFSvOPER
└── 2016080100
    ├── gfs.t00z.sanl
    └── gfs.t00z.sfcanl
```

