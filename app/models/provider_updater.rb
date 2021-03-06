require 'open-uri'

class ProviderUpdater < ActiveJob::Base
  queue_as :default

  class Error < StandardError; end

  def self.providers
    load_providers
    descendants
  end

  def self.update_providers
    providers.map(&:perform_later)
  end

  private

  def self.load_providers
    Dir[Rails.root + 'app/provider_updaters/*.rb'].each do |updater|
      require updater
    end
  end

  def logger
    Rails.logger
  end

  # Parse SLA information from an SLA document
  #
  # This method tries to get SLA information from the document at the
  # specified URI. Currently, it is _very_ simple and will only search for a
  # phrase like "at least <nn.nn>%" to get a basic availability SLA.
  def extract_sla(uri, pattern = %r{at least (\d+(?:\.\d+)?)%}im)
    result = { uri: uri.to_s }

    doc = Nokogiri::HTML(open(uri))
    pattern.match(doc.to_s) do |match|
      result['availability'] = (match[1].to_d / 100).to_s
    end
    result
  end
end
