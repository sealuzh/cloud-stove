Base.class_eval do
  class << self; attr_accessor :base_stack_depth; end
  before_save do
    Base.base_stack_depth ||= caller.size
    stack_depth = [ caller.size - Base.base_stack_depth, 0 ].max
    record_properties = self.try(:name)
    record_properties ||= self.more_attributes.to_json
    puts [
             ' ' * stack_depth, '- ', 'Saving ', self.class.to_s, ': ', record_properties
         ].join
  end
end

# Update provider resources if we don't have any
if Provider.count.zero?
  # Reset log indent
  Base.base_stack_depth = nil
  # Execute the update job inline. We need the resources to create
  # deployment recommendations in the next step.
  Rails.application.config.active_job.queue_adapter = :inline
  UpdateProvidersJob.perform_later rescue nil
end
