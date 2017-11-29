# Instructions
First [download](http://singularity.lbl.gov/install-linux) Singularity and set it up on your system.

Singularity runs on Linux. Therefore, whether use a Linux machine or have a Linux instance running on your PC/Mac.
You can use [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for creating virtual machines that run Linux.
For installing Linux (e.g. Ubuntu) on a virtual machine, see for example the following [tutorial](https://linus.nci.nih.gov/bdge/installUbuntu.html)


## On a remote host (like Knot)
Copy your `.img` file to the remote host. Then you can simply wrap a `singularity exec` command in a job submission 
script to submit your job to the queue. For example, on Knot, you can use the following job submission script:

```shell
#!/bin/bash

#PBS -l nodes=1:ppn=12
#PBS -l walltime=1:00:00
#PBS -N TFlinear
#PBS -V

# Make sure that you are in the job submission directory
cd $PBS_O_WORKDIR

singularity exec /sw/csc/SingularityImg/ubuntu_w_TFlow.img python linear.py > out.log
```

will run `python` within the container. `linear.py` is a Python code in your working directory on the host. The output
`out.log` will also be written on your working directory in the host.
