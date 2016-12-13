# Based on https://github.com/troessner/reek/blob/master/docs/yard_plugin.rb
require 'yard'

# Template helper to modify processing of links in HTML generated from our
# markdown files.
module LocalLinkHelper
  # Rewrites links to local markdown files so they're processed as
  # {file: } directives.
  def resolve_links(text)
    text = text.gsub(%r{<a href="(./[^"]*.md)">([^<]*)</a>}, '{file:\1 \2}')
    super text
  end
end

# Template helper to modify image links in top-level .md files
module ImagesHelper
  # Rewrites links to images in the doc folder to the included assets folder
  def resolve_links(text)
    text = text.gsub(%r{docs/images/}, 'images/')
    super text
  end
end

YARD::Templates::Template.extra_includes << LocalLinkHelper
YARD::Templates::Template.extra_includes << ImagesHelper
# YARD::Tags::Library.define_tag('Guaranteed public API', :public)
# YARD::Templates::Engine.register_template_path File.join(File.dirname(__FILE__), 'templates')

# Monkey-patch `yard server` to support serving SVG files
# from `lib/yard/server/commands/display_file_command.rb`
module YARD
  module Server
    module Commands
      # Displays a README or extra file.
      #
      # @todo Implement better support for detecting binary (image) filetypes
      class DisplayFileCommand < LibraryCommand
        attr_accessor :index

        def run
          ppath = library.source_path
          filename = File.cleanpath(File.join(library.source_path, path))
          raise NotFoundError if !File.file?(filename)
          if filename =~ /\.(jpe?g|gif|png|bmp|svg)$/i
            headers['Content-Type'] = StaticFileCommand::DefaultMimeTypes[$1.downcase] || 'text/html'
            render File.read_binary(filename)
          else
            file = CodeObjects::ExtraFileObject.new(filename)
            options.update :object => Registry.root,
                           :type => :layout,
                           :file => file,
                           :index => index ? true : false
            render
          end
        end
      end
    end
  end
end
