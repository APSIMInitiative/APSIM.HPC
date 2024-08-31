# Nextflow

## Introduction

This directory contains a Nextflow script to run APSIM simulations within a high-performance computing (HPC) environment.

You can test that Nextflow is working using the following shell script:

```
bash scripts/nextflow_batch_test.sh
```

This should result in the following output, assuming everything is working:

```
Pipeline successful.

Nextflow batch simulations completed
Output results
1_SWIM.apsimx  2_SWIM.apsimx  3_SWIM.apsim  1_SWIM.db      2_SWIM.db  3_SWIM.db      
```

## Quickstart

### Nextflow command

The following steps will allow you to dispatch APSIM simulations over Nextflow.

First, copy the SWIM.apsimx configuration file into the output directory:

```
cp data/SWIM.apsimx output/
```

Next, execute the following Nextflow command to run the batch_sims.nf Nextflow script:

```
nextflow run nextflow/batch_sims.nf -config nextflow/nextflow.config -profile reports
```

We can specify the Nextflow configuration file using the `-config` flag. Nextflow configuration profiles can be specified using the `-profile` flag; multiple profiles can be specified using a comma-delimited list.

### Nextflow script

Let's work our way through the batch_sims.nf file:

```
process moduleRunBatch {
  tag "batch: $batch"

  executor "slurm"
  cpus 1
  memory '1GB'
  time '1h'
  scratch true
  errorStrategy = 'terminate'
```

The default HPC executor is SLURM, although Nextflow supports many others. We can specify the per-job CPU usage, memory allocation, max wall time, and error handling.

```
module "${params.apsimx.module}/${params.apsimx.version}"
```

This specifies the Linux module name.

```
publishDir "${params.output}", overwrite: true
```

This is the published output directory for the APSIM simulation results.

```
input:
path outputDir
path batch

output:
path '*.db'
```

The `outputDir` and `batch` inputs define the location of the simulation output directory and batched .apsimx configuration file names. The `*.db` output specifies the file pattern for the SQLite databases that are produced by the batched simulations.

```
script:
"""
for JOB in ${batch}
do
    CMD="${params.apsimx.module}-${params.apsimx.version}.sif --cpu-count ${task.cpus} \$JOB"
    echo "Running: \$CMD"
    \$CMD
done
"""
```

This Nextflow script section will loop through the batched .apsimx configuration files and run the batched APSIM simulations using the specified APSIMX Linux module.

We have a slightly different Nextflow process called `imageRunBatch`. This is very similar to the `moduleRunBatch` process, with a few differences. Firstly, there is no reference to a `module "${params.apsimx.module}/${params.apsimx.version}"` Linux module.

```
script:
"""
for JOB in ${batch}
do
    CMD="${outputDir}/${params.apsimx.module}-${params.apsimx.version}.sif --cpu-count ${task.cpus} \$JOB"
    echo "Running: \$CMD"
    \$CMD
done
"""
```

The Nextflow script section will loop through the batched .apsimx configuration files and run the batched APSIM simulations using the `${outputDir}/${params.apsimx.module}-${params.apsimx.version}.sif` APSIMX Singularity image file.

Finally, let's look through the Nextflow workflow section:

```
workflow {
  outputDir = file(params.output)
  batchJobs = Channel
    .fromPath("${params.output}/*.apsimx")
    .collate(params.batch_size)
  
  if (params.use_module) {
    moduleRunBatch(outputDir, batchJobs)
  } else {
    imageRunBatch(outputDir, batchJobs)
  }
}
```

This will batch all the .apsimx files located in `params.output`. Finally, it will execute the batches using either the Linux module or a Singularity image.

### Nextflow configuration

Let's look through the `nextflow/nextflow.config` Nextflow configuration file. The parameters section defines overridable Nextflow job parameters. You can override each parameter by supplying a parameter name and value to the `nextflow run` command:

```
nextflow run nextflow/batch_sims.nf -config nextflow/nextflow.config -profile reports --project_name nextflow_project_name
```

In the example above, the `project_name` parameter has been overridden to become `nextflow_project_name`.

We can group together different configuration specifications into Nextflow profiles. We can see a definition for the `reports` profile, which writes Nextflow job reports to file. In the `nextflow run` command, we have activated the `reports` profile using `-profile reports`. We could exclude `-profile reports` to disable Nextflow job reports from being created.


