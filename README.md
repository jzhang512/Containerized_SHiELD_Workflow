<img width="813" alt="Screenshot 2024-07-29 at 3 43 59 PM" src="https://github.com/user-attachments/assets/425090e3-0406-4a21-b06f-024b9258b2c7">

We render the workflow of using Geophysical Fluid Dynamics Laboratory (GFDL)'s System for High-resolution modeling for Earth-to-Local Domains (SHiELD) into three stages: pre-processing, model execution, post-processing. Although we primarily use Docker, the images are also compatible with Apptainer.

## Usage
Each stage has its own image, which can be pulled directly from DockerHub (see below). If you would like to make further your own modifications, we also provide the Dockerfiles and the corresponding scripts used in the image build process. 

Starting from scratch, setting up and running a single stage consists of three simple steps:

1. Downloading the corresponding image from DockerHub, or building it with its Dockerfile
2. Mounting user-specified files and directories
3. Running the stage in a container

To run the whole workflow, you must run each image (we are currently working on a fully end-to-end solution).

All default user-specified files and detailed information about running an image container for a specific stage can be found in a Markdown file in their respective directory.


## Published Images
All three images were built using Docker's multi-arch functionality and publicly availiable on DockerHub. They each currently support ARM64 and AMD64.

```
docker pull jzhang512/preprocessing_shield
```

```
docker pull jzhang512/execution_shield
```

```
docker pull jzhang512/visualization_shield
```

For security, we use Docker Content Trust (DCT). Verify that the `SIGNER` is `gfdl_shield` and `KEY` is `b774a2813968`.

For systems using Apptainer, pull the image like:

```
apptainer pull docker://jzhang512/preprocessing_shield
```
