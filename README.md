<img width="787" alt="Screenshot 2024-08-07 at 11 55 16 AM" src="https://github.com/user-attachments/assets/6f72fd40-dbfb-4a4a-8360-06056678c9fb">

We render the workflow of using Geophysical Fluid Dynamics Laboratory (GFDL)'s System for High-resolution modeling for Earth-to-Local Domains (SHiELD) into three stages: pre-processing, model execution, post-processing. Although we primarily use Docker, the images are also compatible with Apptainer (formerly Singularity).

## Usage
Each stage has its own image and repository, which can be pulled directly from DockerHub (see below). If you would like to make your own modifications, we also provide the Dockerfiles and the corresponding scripts used in the image build process. 

Starting from scratch, setting up and running a single stage consists of three simple steps:

1. Downloading the corresponding image from DockerHub, or building it with its Dockerfile
2. Mounting user-specified files and directories
3. Running the stage in a container

To run the whole workflow, you must run each image stage by stage.

All default user-specified files and detailed information about running a specific stage's image can be found in a Markdown file in their respective directory.


## Published Images
All three images were built using Docker's multi-arch functionality and publicly availiable on DockerHub. They each currently support ARM64 and AMD64.

```
docker pull gfdlfv3/preprocessing
```

```
docker pull gfdlfv3/shield
```

```
docker pull gfdlfv3/visualization
```

For security, we use Docker Content Trust (DCT). Verify that the `SIGNER` is `gfdl_shield` and `KEY` is `b774a2813968`.

For systems using Apptainer, pull the image like:

```
apptainer pull docker://gfdlfv3/preprocessing
```
