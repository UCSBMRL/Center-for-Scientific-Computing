# CSC-Computing-2017
Materials for the CSC computing series (2017)

## Instructions

For downlaoding the materials, clone this repository either by 

```
git clone https://github.com/bhimmetoglu/CSC-Computing-2017
```
or using your browser.

## Contents

* R for Scientific and Data Intensive Computing
* Python for Scientific Computing
* Software Containers with Singularity

### 1. R for Scientific and Data Intensive Computing
Make sure to install the `tidyverse`, `doMC` and `glmnet` packages:

```R
install.packages("tidyverse")
install.packages("doMC")
install.packages("glmnet")
```

The data for the Titanic Survival Prediction is obtained from [Kaggle](https://www.kaggle.com/c/titanic).

### 2. Python for Scientific Computing
The code is compatible with Python > 3. Make sure that you have `numpy`, `scipy`, `sklearn` and `matplotlib` installed. 

For the molecular charge density construction, the pseudopotentials are downloaded from [Quantum Espresso](http://www.quantum-espresso.org/)


### 3. Software Containers with Singularity
Singularity runs on Linux. Therefore, whether use a Linux machine or have a Linux instance running on your PC/Mac. 
You can use [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for creating virtual machines that run Linux. 
For installing Linux (e.g. Ubuntu) on a virtual machine, see for example the following [tutorial](https://linus.nci.nih.gov/bdge/installUbuntu.html)
