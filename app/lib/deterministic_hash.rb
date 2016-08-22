require 'xxhash'

module DeterministicHash
  def deterministic_hash(string)
    XXhash.xxh32(string)
  end
end
