defined?(Footnotes) && Footnotes.setup do |f|
  # Whether or not to enable footnotes
  f.enabled = Rails.env.development?
  # You can also use a lambda / proc to conditionally toggle footnotes
  # Example :
  # f.enabled = -> { User.current.admin? }
  # Beware of thread-safety though, Footnotes.enabled is NOT thread safe
  # and should not be modified anywhere else.

  # Only toggle some notes :
  # f.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log]

  # Change the prefix :
  # f.prefix = 'mvim://open?url=file://%s&line=%d&column=%d'

  # Disable style :
  # f.no_style = true

  # Lock notes to top right :
  # f.lock_top_right = true

  # Change font size :
  # f.font_size = '11px'

  # Allow to open multiple notes :
  # f.multiple_notes = true
  Footnotes::Notes::PartialsNote.class_eval do
    def self.start!(controller)
      self.partials = []
      @subscriber ||= ActiveSupport::Notifications.subscribe(/^render.*action_view$/) do |*args|
        event = ActiveSupport::Notifications::Event.new *args
        self.partials << {:file => event.payload[:identifier], :duration => event.duration}
      end
    end
  end
  
  Footnotes::Notes::FilesNote.class_eval do
    protected
    def parse_files!
      @files.each do |f| 
        f.gsub!(/\.self[^.]*/, '')
        @files << f.gsub('.css', '.scss') if f.end_with?('.css')
        @files << f.gsub('.js', '.coffee') if f.end_with?('.js')
      end

      asset_paths = Rails.application.config.assets.paths
      linked_files = []
      @files.collect do |file|
        base_name = File.basename(file)
        asset_paths.each do |asset_path|
          results = Dir[File.expand_path(base_name, asset_path) + '*']
          results.each do |r|
            linked_files << %[<a href="#{Footnotes::Filter.prefix(r, 1, 1)}">#{File.basename(r)}</a>]
          end
          break if results.present?
        end
      end
      @files = linked_files
    end
  end
end
