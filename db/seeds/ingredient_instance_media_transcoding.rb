begin
batch_template = Ingredient.find_by_name!('Batch Processing')
media_instance = Ingredient.create(
    template_id: batch_template,
    name: 'Media Transcoding',
    body: <<HERE
A batch processing application that transcodes videos to different formats
  and resolutions.
HERE
)

mgr = media_instance.children.create(
    name: 'Job Manager',
    body: <<HERE
Specific things about the job manager.
HERE
)
mgr.constraints << RamConstraint.create(
    min_ram: 4096
)
mgr.constraints << CpuConstraint.create(
    min_cpus: 1
)

ds = media_instance.children.create(
    name: 'Job Data Store',
    body: <<HERE
Specific things about this object store. Maybe S3. Or Riak.
HERE
)
ds.constraints << RamConstraint.create(
    min_ram: 1024
)
ds.constraints << CpuConstraint.create(
    min_cpus: 1
)

queue = media_instance.children.create(
    name: 'Message Queue',
    body: <<HERE
Specific things about the message queue. Probably RabbitMQ.
HERE
)
queue.constraints << RamConstraint.create(
    min_ram: 6144
)
queue.constraints << CpuConstraint.create(
    min_cpus: 1
)

worker = media_instance.children.create(
    name: 'Transcoder',
    body: <<HERE
Specific things about the transcoding worker.
HERE
)
worker.constraints << RamConstraint.create(
    min_ram: 2048
)
worker.constraints << CpuConstraint.create(
    min_cpus: 1
)
end
