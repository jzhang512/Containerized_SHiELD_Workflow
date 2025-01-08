# Post-processing Instructions

Image: [gfdlfv3/visualization](https://hub.docker.com/r/gfdlfv3/visualization)

If building your own image, ensure that the script `start-notebook.sh` is **in the same directory** as the Dockerfile.

## Bind Mounts
Make sure you have a directory set up on the host machine with your desired files. It will be known as `workdir` in the container and the directory that the Jupyter Server has access to.

## Run Behavior
Upon running the image, you will be provided a link for the Jupyter Server. 

## Run Command Templates
### Docker
```
docker run -v .\:/workdir -p 8888:8888 gfdlfv3/visualization
```
If you use this command, make sure you are in the directory you want Jupyter to access before running it.
