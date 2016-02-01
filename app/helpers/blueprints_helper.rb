module BlueprintsHelper
  def body_excerpt(blueprint)
    truncate(blueprint.body, length: 300, separator: ' ')
  end
end
