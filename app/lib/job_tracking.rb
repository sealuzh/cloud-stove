module JobTracking
  def add_job(job_id)
    # Notice that the `more_attributes` serialization mechanism converts the set into an array
    ma['jobs'].present? ? ma['jobs'] = Set.new(ma['jobs']).add(job_id) : ma['jobs'] = Set.new([job_id])
    self.save!
  end

  def remove_job(job_id)
    self.more_attributes['jobs'].delete(job_id)
    self.save!
  end

  def jobs_completed?
    self.more_attributes['jobs'].size == 0 rescue true
  end
end
