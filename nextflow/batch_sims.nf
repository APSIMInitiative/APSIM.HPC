#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// ##################################################################
// Process
// ##################################################################

process moduleRunBatch {
  tag "batch: $batch"

  executor "slurm"
  cpus 1
  memory '1GB'
  time '1h'
  scratch true
  errorStrategy = 'terminate'
  
  module "${params.apsimx.module}/${params.apsimx.version}"
  
  publishDir "${params.output}", overwrite: true
  
  input:
  path outputDir
  path batch
  
  output:
  path '*.db'

  script:
  """
  for JOB in ${batch}
  do
      CMD="${params.apsimx.module}-${params.apsimx.version}.sif --cpu-count ${task.cpus} \$JOB"
      echo "Running: \$CMD"
      \$CMD
  done
  """
}

process imageRunBatch {
  tag "batch: $batch"

  executor "slurm"
  cpus 1
  memory '1GB'
  time '1h'
  scratch true
  errorStrategy = 'terminate'
  
  publishDir "${params.output}", overwrite: true
  
  input:
  path outputDir
  path batch
  
  output:
  path '*.db'

  script:
  """
  for JOB in ${batch}
  do
      CMD="${outputDir}/${params.apsimx.module}-${params.apsimx.version}.sif --cpu-count ${task.cpus} \$JOB"
      echo "Running: \$CMD"
      \$CMD
  done
  """
}

// ##################################################################
// Workflow
// ##################################################################

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

workflow.onComplete {
    log.info ( workflow.success ? "Pipeline successful." : "Pipeline failed." )
}
