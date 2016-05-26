batch_template = Ingredient.find_by_name!('Batch Processing')
media_instance = Ingredient.create(
    template_id: batch_template,
    name: 'Media Transcoding',
    body: <<HERE
A batch processing application that transcodes videos to different formats
  and resolutions.
HERE
)

media_instance.children.create(
    name: 'Job Manager',
    body: <<HERE
Specific things about the job manager.
HERE
)

media_instance.children.create(
    name: 'Job Data Store',
    body: <<HERE
Specific things about this object store. Maybe S3. Or Riak.
HERE
)

media_instance.children.create(
    name: 'Message Queue',
    body: <<HERE
Specific things about the message queue. Probably RabbitMQ.
HERE
)

media_instance.children.create(
    name: 'Transcoder',
    body: <<HERE
Specific things about the transcoding worker.
HERE
)
