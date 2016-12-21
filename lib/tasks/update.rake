namespace :update do
  DEFAULT_ICON = 'server'

  desc 'Substring matching heuristic to guess an appropriate icon for all leaf ingredients'
  task icon: :environment do
    Ingredient.leafs.each do |leaf|
      leaf.icon = guess_icon(leaf.name) || DEFAULT_ICON
      leaf.save!
    end
  end

  def guess_icon(name)
    name_to_icon_mappings.each do |subname, icon|
      return icon if name.downcase.include?(subname.downcase)
    end
    nil
  end

  def name_to_icon_mappings
    {
        'PostgreSQL' => 'database',
        'MongoDB' => 'database',
        'Worker' => 'cog',
        'RabbitMQ' => 'ellipsis-h',
        'Rails' => 'server',
        'Django' => 'server',
        'Server' => 'server',
        'Load Balancer' => 'sitemap',
    }
  end
end
