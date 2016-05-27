batch_template = Ingredient.create(
  name: 'Batch Processing',
  is_template: true,
  body: <<HERE
A batch processing architecture is suitable for processing large numbers of
similar tasks that are reasonably large themselves.

Common examples are:

- image transformation
- media tanscoding
- various data processing tasks

> Batch processing architectures are often synonymous with highly variable
> usage patterns that have significant usage peaks (e.g., month-end
> processing) followed by significant periods of underutilization.
>
> There are numerous approaches to building a batch processing architecture.
> This document outlines a basic batch processing architecture that supports
> job scheduling, job status inspection, uploading raw data, outputting job
> results, grid management, and reporting job performance data.
> <br>
> — [AWS Batch Processing Reference Architecture][awsbatch]

*(This blueprint is based on the [AWS Batch Processing Reference
Architecture][awsbatch].)*

[awsbatch]: http://media.amazonwebservices.com/architecturecenter/AWS_ac_ra_batch_03.pdf
HERE
)

mgr = batch_template.children.create(
  name: 'Job Manager',
  is_template: true,
  body: <<HERE
Users interact with the Job Manager application which is deployed on a
compute instance. This component controls the process of accepting,
scheduling, starting, managing, and completing batch jobs. It also provides
access to the final results, job and worker statistics, and job progress
information.

# Performance Considerations

* add some
HERE
)
mgr.constraints << RamConstraint.create(
    min_ram: 4096
)

ds = batch_template.children.create(
  name: 'Job Data Store',
  is_template: true,
  body: <<HERE
Raw job data is uploaded to a persitent object store.

Also, job results can be uploaded to the object store.

# Performance Considerations

* add some
HERE
)
ds.constraints << RamConstraint.create(
    min_ram: 1024
)

queue = batch_template.children.create(
  name: 'Input Queue',
  is_template: true,
  body: <<HERE
Individual job tasks are inserted by the Job Manager in a MQM input queue
on the user’s behalf.

Also, completed tasks can be inserted in another queue for chaining to a
second processing stage.

# Performance Considerations

* add some
HERE
)
queue.constraints << RamConstraint.create(
    min_ram: 6144
)

worker = batch_template.children.create(
  name: 'Worker',
  is_template: true,
  body: <<HERE
Worker nodes are compute instances deployed on an auto scaling group.
This group is a container that ensures health and scalability of worker
nodes. Worker nodes pick up job parts from the input queue automatically
and perform single tasks that are part of the list of batch processing
steps.

# Performance Considerations

* add some
HERE
)
worker.constraints << RamConstraint.create(
    min_ram: 2048
)
