sudo rm -f ubuntu.img
sudo singularity create ubuntu.img
sudo singularity expand --size 8192 ubuntu.img
sudo singularity bootstrap ubuntu.img ubuntu.def
sudo singularity exec -B `pwd`:/mnt -w ubuntu.img mkdir /local_scratch
