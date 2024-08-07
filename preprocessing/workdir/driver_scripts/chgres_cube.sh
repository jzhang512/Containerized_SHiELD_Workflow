#!/bin/bash

source /workdir/driver_scripts/preprocessing_config.sh "$(basename $0)"
set -x
set -e  # exit on error

#
# case configurations
# CONFIGURATIONS NOW SET IN preprocessing_config.sh.
#

# analysistyp: the format of GFS analysis. It can be gaussian_netcdf, gaussian_nemsio, gfs_gaussian_nemsio, and gfs_sigio, depending on the version of GFS.
# analysistype='gaussian_netcdf'
# gridtype: model grid configuration. It can be global or nest. Multiple nesting is not supported yet.
# gridtype='global'
# res: cubed-sphere resolution
# res=48
# analysislevfile: vertical levels of the IC. Use the same as the GFS analysis is recommended.
# analysislevfile='global_hyblev.l65.txt'
# if [ -z "$CDATE" ]; then
#   # Different test cases
#   # 2020063000 for gaussian_nemsio
#   # 2018051100 for gfs_gaussian_nemsio;
#   # 2016080100 for gfs_sigio
#   # 2022010100 for gaussian_netcdf
#   CDATE=2022010100
# fi
# ICDIR=/workdir/outputs/SHiELD_IC/GLOBAL_C${res}
# UTILSDIR=/UFS_UTILS
# GRIDDIR=/workdir/outputs/my_grids/C${res}
# GFSANLDIR=/GFSvOPER
# WORKDIR=/workdir/outputs/wrk.chgres

# probably don't have to change anything below here.

# Threads useful when ingesting spectral gfs sigio files.
# Otherwise set to 1.
# export OMP_NUM_THREADS=1
# export OMP_STACKSIZE=1024M

if [ "$analysistype" == 'gaussian_nemsio' ]; then
  atmext='atmanl.nemsio'
  sfcext='sfcanl.nemsio'
  tracerout='"sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"'
  tracerin='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
elif [ "$analysistype" == 'gaussian_netcdf' ]; then
  atmext='atmanl.nc'
  sfcext='sfcanl.nc'
  tracerout='"sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"'
  tracerin='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
elif [ "$analysistype" == 'gfs_gaussian_nemsio' ]; then
  export OMP_NUM_THREADS=6
  atmext='atmanl.nemsio'
  sfcext='sfcanl.nemsio'
  tracerout='"sphum","liq_wat","o3mr"'
  tracerin='"spfh","clwmr","o3mr"'
elif [ "$analysistype" == 'gfs_sigio' ]; then
  export OMP_NUM_THREADS=6
  atmext='sanl'
  sfcext='sfcanl'
  tracerout='"sphum","o3mr","liq_wat"'
  tracerin='"spfh","o3mr","clwmr"'
fi
# chop timestamp into pieces
ymd=$(echo $CDATE | cut -c 1-8)
mm=$(echo $CDATE | cut -c 5-6)
dd=$(echo $CDATE | cut -c 7-8)
hh=$(echo $CDATE | cut -c 9-10)

# random folder name to avoid I/O race condition
RANDEXT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
WORKDIR=$WORKDIR/chgres_cube_$RANDEXT

# clean up and create folders
CASEDIR=${ICDIR}/${ymd}.${hh}Z_IC
rm -fr $CASEDIR
mkdir -p $CASEDIR

rm -fr $WORKDIR
mkdir -p $WORKDIR
cd $WORKDIR

# Threads useful when ingesting spectral gfs sigio files.
# Otherwise set to 1.
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=1024M

# link executable
ln -s $UTILSDIR/exec/chgres_cube .

#
# process global domains
#
if [ "$gridtype" == 'global' ]; then
  ln -s $GRIDDIR/C${res}_mosaic.nc $WORKDIR/C${res}_mosaic.nc
elif [ "$gridtype" == 'nest' ]; then
  ln -s $GRIDDIR/C${res}_coarse_mosaic.nc $WORKDIR/C${res}_mosaic.nc
else
  echo "$gridtype is not supported yet. Stop"
  exit 1
fi

# set up namelist
cat <<EOF >$WORKDIR/fort.41
&config
 mosaic_file_target_grid="$WORKDIR/C${res}_mosaic.nc"
 fix_dir_target_grid="$GRIDDIR/fix_sfc"
 orog_dir_target_grid="$GRIDDIR"
 orog_files_target_grid="C${res}_oro_data.tile1.nc","C${res}_oro_data.tile2.nc","C${res}_oro_data.tile3.nc","C${res}_oro_data.tile4.nc","C${res}_oro_data.tile5.nc","C${res}_oro_data.tile6.nc",
 vcoord_file_target_grid="$UTILSDIR/fix/am/${analysislevfile}"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${GFSANLDIR}/${CDATE}"
 atm_files_input_grid="gfs.t${hh}z.${atmext}"
 sfc_files_input_grid="gfs.t${hh}z.${sfcext}"
 nst_files_input_grid="gfs.t${hh}z.nstanl.nemsio"
 cycle_mon=$mm
 cycle_day=$dd
 cycle_hour=$hh
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.false.
 input_type="$analysistype"
 tracers=$tracerout
 tracers_input=$tracerin
 regional=0
 halo_bndy=0
 halo_blend=0 
/
EOF

$APRUN ./chgres_cube

#
# move output files to save directory
#
mv gfs_ctrl.nc $CASEDIR/gfs_ctrl.nc
i=1
while [ $i -le 6 ]
do
  mv out.atm.tile${i}.nc $CASEDIR/gfs_data.tile${i}.nc
  mv out.sfc.tile${i}.nc $CASEDIR/sfc_data.tile${i}.nc
  i=$((i+1))
done


if [ "$gridtype" == 'nest' ]; then
  #
  # process the nest domain
  #
  rm $WORKDIR/C${res}_mosaic.nc
  ln -s $GRIDDIR/C${res}_nested_mosaic.nc $WORKDIR/C${res}_mosaic.nc
 
# set up namelist 
cat <<EOF >$WORKDIR/fort.41
&config
 mosaic_file_target_grid="$WORKDIR/C${res}_mosaic.nc"
 fix_dir_target_grid="$GRIDDIR/fix_sfc"
 orog_dir_target_grid="$GRIDDIR"
 orog_files_target_grid="C${res}_oro_data.tile7.nc",
 vcoord_file_target_grid="$UTILSDIR/fix/am/${analysislevfile}"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${GFSANLDIR}/${CDATE}"
 atm_files_input_grid="gfs.t${hh}z.${atmext}"
 sfc_files_input_grid="gfs.t${hh}z.${sfcext}"
 nst_files_input_grid="gfs.t${hh}z.nstanl.nemsio"
 cycle_mon=$mm
 cycle_day=$dd
 cycle_hour=$hh
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.false.
 input_type="$analysistype"
 tracers=$tracerout
 tracers_input=$tracerin
 regional=0
 halo_bndy=0
 halo_blend=0 
/
EOF


$APRUN ./chgres_cube

#
# move output files to save directory
#
mv out.atm.tile1.nc $CASEDIR/gfs_data.tile7.nc
mv out.sfc.tile1.nc $CASEDIR/sfc_data.tile7.nc

fi

export ICDIR
export GRIDDIR
/compile_exitpoint.sh

exit 0
