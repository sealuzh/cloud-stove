class JobWrapper

  def initialize(delayed_job)
    @uuid = extract_uuid_from_handler_string(delayed_job.handler)
    @job_type = extract_job_type_from_handler_string(delayed_job.handler)
    @delayed_job = delayed_job
  end

  def self.all
    list = []
    Delayed::Web::Job.all.each do |delayed_job|
      list << JobWrapper.new(delayed_job)
    end
    list
  end

  def self.find(id)
    JobWrapper.new(Delayed::Web::Job.find(id))
  end

  def self.find_by_uuid(uuid)
    self.all.each do |job|
      if job.uuid == uuid
        return job
      end
    end
    return NIL
  end

  def uuid
    @uuid
  end

  def job_type
    @job_type
  end


  private

    def extract_uuid_from_handler_string(handlerstring)
      startindex = handlerstring.index('job_id:')
      handlerstring[startindex + 8,36]
    end

    def extract_job_type_from_handler_string(handlerstring)
      startindex = handlerstring.index('job_class:') + 10
      endindex = handlerstring.index('job_id:') - 4
      handlerstring.at(startindex..endindex)
    end

end
