# Singularity Container For Tensorflow with GPU Support

This repo is adapted from:

https://github.com/jdongca2003/Tensorflow-singularity-container-with-GPU-support/

https://github.com/clemsonciti/singularity-images

## Building the container

Download and setup [Singularity](http://singularity.lbl.gov/) and install either on your Linux machine, or a virtual machine that runs Linux.

Download nvidia driver `NVIDIA-Linux-x86_64-375.26.run`, cuda `cuda_8.0.61_375.26_linux.run` and cudnn `cudnn-8.0-linux-x64-v5.1.tgz`
(The same nvidia driver/cuda must be installed in your host machine)
and store the downloaded files and above scripts under the same folder.

From your local Linux machine (or instance), run 
```shell
sudo sh build_container.sh
```

This takes a while to complete and a `.img` file will be produced. This image contains Tensorflow, Keras 
and many other machine learning libraries. Copy this file to the host system (e.g. Knot) to use it via:

```shell
singuarity shell <path_to_img> 
```

for interactive use and

```shell 
singularity exec <path_to_img> python <your_python_program.py> 
```

for executing.
