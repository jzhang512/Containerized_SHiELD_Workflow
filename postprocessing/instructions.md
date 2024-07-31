# Post-processing Instructions

Image: [jzhang512/visualization_shield](https://hub.docker.com/r/jzhang512/visualization_shield)

## Volume Mounts
Make sure you have a directory set up on the host machine with your desired files. It will be known as `home` in the container and the directory that the Jupyter Server has access to.

## Run Behavior
Upon running the image, you will be provided a link for the Jupyter Server. 

## Run Command Templates
### Docker
```
docker run -v .\:/home -p 8888:8888 jzhang512/visualization_shield
```
If you use this command, make sure you are in the directory you want Jupyter to access before running it.
