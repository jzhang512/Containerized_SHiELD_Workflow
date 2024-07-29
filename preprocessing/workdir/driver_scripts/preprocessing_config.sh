#!/bin/bash

# Unified configurations for driver_grid.gaea.sh and chgres_cube.sh.

set -x

# Check which script is running.
caller_script=$1

# SET CONFIGURATIONS HERE.
if [ "$caller_script" = "driver_grid.gaea.sh" ]; then

    export gtype=uniform     # 'uniform', 'stretch', 'nest', 
                               # 'regional_gfdl', 'regional_esg'

    export make_gsl_orog=false    # When 'true' will output 'oro' files for 
                                  # the GSL orographic drag suite.

    export vegsoilt_frac='.false.'  # When true, outputs percent of each
                                   # soil and veg type category and a
                                   # dominant category. When false, only
                                   # outputs the dominant category. A
                                   # Fortran logical, so include the dots.

    export veg_type_src="modis.igbp.0.05" #  Vegetation type data.
                                    # For viirs-based vegetation type data, set to:
                                    # 1) "viirs.v3.igbp.30s" for global 30s data
                                    # For the modis-based data, set to:
                                    # 1) "modis.igbp.0.05" for global 0.05-deg data
                                    # 2) "modis.igbp.0.03" for global 0.03-deg data
                                    # 3) "modis.igbp.conus.30s" for CONUS 30s data
                                    # 4) "modis.igbp.nh.30s" for N Hemis 30s data
                                    # 5) "modis.igbp.30s" for global 30s data

    export soil_type_src="statsgo.0.05" #  Soil type data.
                                    # For Beijing Normal Univ. data, set to:
                                    # 1) "bnu.v3.30s" for global 30s data.
                                    # For STATSGO soil type data, set to:
                                    # 1) "statsgo.0.05" for global 0.05-deg data
                                    # 2) "statsgo.0.03" for global 0.03-deg data
                                    # 3) "statsgo.conus.30s" for CONUS 30s data
                                    # 4) "statsgo.nh.30s" for NH 30s data
                                    # 5) "statsgo.30s" for global 30s data

    #-----------------------------------------------------------------------
    # Check paths.
    #   home_dir - location of repository.
    #   TEMP_DIR - working directory.
    #   out_dir  - where files will be placed upon completion.
    #-----------------------------------------------------------------------

    export home_dir=/UFS_UTILS
    export TEMP_DIR=/workdir/outputs/fv3_grid.$gtype
    export out_dir=/workdir/outputs/my_grids

    #-----------------------------------------------------------------------

    # Uncomment if openmpi conflicts with slurm on MPC.
    #unset SLURM_JOBID
    #unset SLURM_NNODES
    #unset SLURM_TASKS_PER_NODE
    #unset SLURM_NTASKS
    #unset SLURM_NPROCS
    #unset SLURM_CPUS_ON_NODE
    #unset SLURM_NODEID
    #unset SLURM_LOCALID
    #unset SLURM_PROCID
    #unset SLURM_JOB_NODELIST
    #unset SLURM_JOB_NUM_NODES

    #-----------------------------------------------------------------------
    # Should not need to change anything below here.
    #-----------------------------------------------------------------------

    export APRUN=time
    export APRUN_SFC="mpirun -oversubscribe -np 48"
    export OMP_NUM_THREADS=48
    export OMP_STACKSIZE=2048m
    export machine=GAEA


else  # chgres_cube.sh

   # analysistyp: the format of GFS analysis. It can be gaussian_netcdf, gaussian_nemsio, gfs_gaussian_nemsio, and gfs_sigio, depending on the version of GFS.
   analysistype='gaussian_netcdf'
   # gridtype: model grid configuration. It can be global or nest. Multiple nesting is not supported yet.
   gridtype='global'
   # res: cubed-sphere resolution
   res=48
   # analysislevfile: vertical levels of the IC. Use the same as the GFS analysis is recommended.
   analysislevfile='global_hyblev.l65.txt'
   if [ -z "$CDATE" ]; then
     # Different test cases
     # 2020063000 for gaussian_nemsio
     # 2018051100 for gfs_gaussian_nemsio;
     # 2016080100 for gfs_sigio
     # 2022010100 for gaussian_netcdf
     CDATE=2022010100
   fi
   ICDIR=/workdir/outputs/SHiELD_IC/GLOBAL_C${res}
   UTILSDIR=/UFS_UTILS
   GRIDDIR=/workdir/outputs/my_grids/C${res}
   GFSANLDIR=/GFSvOPER
   WORKDIR=/workdir/outputs/wrk.chgres

   # probably don't have to change anything below here.

   export APRUN="mpirun -oversubscribe -np 6"

   # Threads useful when ingesting spectral gfs sigio files.
   # Otherwise set to 1.
   export OMP_NUM_THREADS=1
   export OMP_STACKSIZE=1024M


fi