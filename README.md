# APSIM.Singularity

## Introduction

This repository contains Singularity recipes for building and running APSIM within Singularity containers. The principal motivation for using these Singularity recipes is to execute APSIM within a high-performance computing (HPC) environment.

Please refer to the official Singularity documentation for more information: https://docs.sylabs.io/guides/latest/user-guide/

## Example

Run the following to build and execute a Singularity container for APSIM:

```
curl -o apsim.Singularity https://raw.githubusercontent.com/APSIMInitiative/APSIM.Singularity/main/Singularity.2022.12.7130.0
singularity build apsim.sif apsim.Singularity
./apsim.sif 
```
