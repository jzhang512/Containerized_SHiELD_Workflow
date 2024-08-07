#!/bin/bash

#-----------------------------------------------------------------------
# Driver script to create a cubic-sphere based model grid on Orion.
#
# Produces the following files (netcdf, each tile in separate file):
#   1) 'mosaic' and 'grid' files containing lat/lon and other
#      records that describe the model grid.
#   2) 'oro' files containing land mask, terrain and gravity
#      wave drag fields.
#   3) Surface climo fields, such as soil type, vegetation
#      greenness and albedo.
#
# Note: The sfc_climo_gen program only runs with an
#       mpi task count that is a multiple of six.  This is
#       an ESMF library requirement.  Large grids may require
#       tasks spread across multiple nodes. The orography code
#       benefits from threads.
#
# To run, do the following:
#
#   1) Set "C" resolution, "res" - Example: res=96.
#   2) Set grid type ("gtype").  Valid choices are
#         "uniform"  - global uniform grid
#         "stretch"  - global stretched grid
#         "nest"     - global stretched grid with nest
#         "regional_gfdl" - stand-alone gfdl regional grid
#         "regional_esg"  - stand-alone extended Schmidt gnomonic
#                           (esg) regional grid
#   3) For "uniform" and "regional_gfdl" grids - to include lake
#      fraction and depth, set "add_lake" to true, and the
#      "lake_cutoff" value.
#   4) For "stretch" and "nest" grids, set the stretching factor -
#       "stretch_fac", and center lat/lon of highest resolution
#      tile - "target_lat" and "target_lon".
#   5) For "nest" grids, set the refinement ratio - "refine_ratio",
#      the starting/ending i/j index location within the parent
#      tile - "istart_nest", "jstart_nest", "iend_nest", "jend_nest"
#   6) For "regional_gfdl" grids, set the "halo".  Default is three
#      rows/columns.
#   7) For "regional_esg" grids, set center lat/lon of grid,
#      - "target_lat/lon" - the i/j dimensions - "i/jdim", the
#      x/y grid spacing - "delx/y", and halo.
#   8) Set working directory - TEMP_DIR - and path to the repository
#      clone - home_dir.
#   9) To use the GSL orographic drag suite, set 'make_gsl_orog' to true.
#  10) Set 'soil_veg_src' and 'veg_type_src' to choose the
#      soil type and vegetation type data.
#  11) Submit script: "sbatch $script".
#  12) All files will be placed in "out_dir".
#
#-----------------------------------------------------------------------

source /workdir/driver_scripts//preprocessing_config.sh "$(basename $0)"
set -x
set -e  # exit on error


#-----------------------------------------------------------------------
# Set grid specs here.
#-----------------------------------------------------------------------

# CONFIGURATIONS NOW SET IN preprocessing_config.sh.

# export gtype=uniform     # 'uniform', 'stretch', 'nest', 
#                                # 'regional_gfdl', 'regional_esg'

# export make_gsl_orog=false    # When 'true' will output 'oro' files for 
#                               # the GSL orographic drag suite.

# export vegsoilt_frac='.false.'  # When true, outputs percent of each
#                                # soil and veg type category and a
#                                # dominant category. When false, only
#                                # outputs the dominant category. A
#                                # Fortran logical, so include the dots.

# export veg_type_src="viirs.v3.igbp.30s" #  Vegetation type data.
#                                 # For viirs-based vegetation type data, set to:
#                                 # 1) "viirs.v3.igbp.30s" for global 30s data
#                                 # For the modis-based data, set to:
#                                 # 1) "modis.igbp.0.05" for global 0.05-deg data
#                                 # 2) "modis.igbp.0.03" for global 0.03-deg data
#                                 # 3) "modis.igbp.conus.30s" for CONUS 30s data
#                                 # 4) "modis.igbp.nh.30s" for N Hemis 30s data
#                                 # 5) "modis.igbp.30s" for global 30s data

# export soil_type_src="bnu.v3.30s" #  Soil type data.
#                                 # For Beijing Normal Univ. data, set to:
#                                 # 1) "bnu.v3.30s" for global 30s data.
#                                 # For STATSGO soil type data, set to:
#                                 # 1) "statsgo.0.05" for global 0.05-deg data
#                                 # 2) "statsgo.0.03" for global 0.03-deg data
#                                 # 3) "statsgo.conus.30s" for CONUS 30s data
#                                 # 4) "statsgo.nh.30s" for NH 30s data
#                                 # 5) "statsgo.30s" for global 30s data

if [ $gtype = uniform ]; then
  export res=48
  export add_lake=false        # Add lake frac and depth to orography data.
  export lake_cutoff=0.20      # lake frac < lake_cutoff ignored when add_lake=T
elif [ $gtype = stretch ]; then
  export res=96
  export stretch_fac=1.5       # Stretching factor for the grid
  export target_lon=-97.5      # Center longitude of the highest resolution tile
  export target_lat=35.5       # Center latitude of the highest resolution tile
elif [ $gtype = nest ] || [ $gtype = regional_gfdl ]; then
  export add_lake=false        # Add lake frac and depth to orography data.
  export lake_cutoff=0.20      # lake frac < lake_cutoff ignored when add_lake=T
  export res=96
  export stretch_fac=1.000001       # Stretching factor for the grid
  export target_lon=-85.0      # Center longitude of the highest resolution tile
  export target_lat=30.0       # Center latitude of the highest resolution tile
  export refine_ratio=3        # The refinement ratio
  export istart_nest=61        # Starting i-direction index of nest grid in parent tile supergrid
  export jstart_nest=61        # Starting j-direction index of nest grid in parent tile supergrid
  export iend_nest=132         # Ending i-direction index of nest grid in parent tile supergrid
  export jend_nest=132         # Ending j-direction index of nest grid in parent tile supergrid
  export halo=3                # Lateral boundary halo
elif [ $gtype = regional_esg ] ; then
  export res=-999              # equivalent resolution is computed
  export target_lon=-97.5      # Center longitude of grid
  export target_lat=35.5       # Center latitude of grid
  export idim=301              # Dimension of grid in 'i' direction
  export jdim=200              # Dimension of grid in 'j' direction
  export delx=0.0585           # Grid spacing (in degrees) in the 'i' direction
                               # on the SUPERGRID (which has twice the resolution of
                               # the model grid).  The physical grid spacing in the 'i'
                               # direction is related to delx as follows:
                               #    distance = 2*delx*(circumf_Earth/360 deg)
  export dely=0.0585           # Grid spacing (in degrees) in the 'j' direction.
  export halo=3                # number of row/cols for halo
fi

#-----------------------------------------------------------------------
# CONFIGURATIONS NOW SET IN preprocessing_config.sh.
# Check paths.
#   home_dir - location of repository.
#   TEMP_DIR - working directory.
#   out_dir  - where files will be placed upon completion.
#-----------------------------------------------------------------------

# export home_dir=/UFS_UTILS
# export TEMP_DIR=/workdir/outputs/fv3_grid.$gtype
# export out_dir=/workdir/outputs/my_grids

#-----------------------------------------------------------------------
# CONFIGURATIONS NOW SET IN preprocessing_config.sh.
# Should not need to change anything below here.
#-----------------------------------------------------------------------

# export APRUN=time
# export APRUN_SFC="mpirun -oversubscribe -np 48"
# export OMP_NUM_THREADS=48
# export OMP_STACKSIZE=2048m
# export machine=GAEA

ulimit -a
ulimit -s unlimited

#-----------------------------------------------------------------------
# Start script.
#-----------------------------------------------------------------------

$home_dir/ush/fv3gfs_driver_grid.sh

 
if [ $gtype = regional_gfdl ] || [ $gtype = regional_esg ]; then
  exit
else
  # link orog files and grid_spec
  cd $out_dir/C${res}

  for i in 1 2 3 4 5 6
  do
    ln -s C${res}_oro_data.tile${i}.nc oro_data.tile${i}.nc
  done

  ln -s C${res}_mosaic.nc grid_spec.nc
fi

if [ $gtype = nest ] ; then
  out_dir_nest=$out_dir
  export out_dir=${TEMP_DIR}/regional_grid_tmp

  # create a regional grid that is exactly the same as the nested domain and filter it 
  export gtype=regional_gfdl
  $home_dir/ush/fv3gfs_driver_grid.sh
  
  # replace the nested orog file with a filtered one (presuming that we only create global-nested grid one at a time so as to avoid I/O race condition)  
  orog_filt=$(find $out_dir  -iname "*oro_data.tile7.halo0.nc" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
  mv $orog_filt $out_dir_nest/C${res}/C${res}_oro_data.tile7.nc
  
  # replace fix files 
  fix_files=("facsf" "maximum_snow_albedo" "slope_type" "snowfree_albedo" "soil_type" "soil_color" "substrate_temperature" "vegetation_greenness" "vegetation_type")

  for val in ${fix_files[*]}; do
    fix_file=$(find $out_dir  -iname "*$val.tile7.halo0.nc" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
    cp $fix_file $out_dir_nest/C${res}/fix_sfc/C${res}.$val.tile7.nc
  done
  rm -rf $out_dir
 
  # link orog file
  cd $out_dir_nest/C${res}
  ln -s C${res}_oro_data.tile7.nc oro_data.tile7.nc

fi

exit
