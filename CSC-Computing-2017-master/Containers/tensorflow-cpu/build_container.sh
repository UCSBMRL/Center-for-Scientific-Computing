sudo rm -f ubuntu_w_TFlowKeras.img
sudo singularity create ubuntu_w_TFlowKeras.img
sudo singularity expand --size 8192 ubuntu_w_TFlowKeras.img
sudo singularity bootstrap ubuntu_w_TFlowKeras.img ubuntu_w_TFlowKeras.def
