# Pre-Processing Instructions

## Run Behavior

## Volume Mounts

## Run Command Templates
### Docker
```
docker run -it \
  -v "/PATH_TO_/fix_data:/UFS_UTILS/fix" \
  -v "/PATH_TO_/workdir:/workdir" \
  -v "/PATH_TO_/GFSvOPER:/GFSvOPER" \
  jzhang512/preprocessing_shield
```
### Apptainer 

Replace `/PATH_TO_/` with the actual path on your host machine. Ensure that the paths inside the container are as specified above. 
