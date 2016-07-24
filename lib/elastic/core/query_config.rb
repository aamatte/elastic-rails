module Elastic::Core
  class QueryConfig
    attr_accessor :root, :groups, :limit, :offset, :middleware_options

    def self.initial_config
      new.tap do |config|
        config.root = Elastic::Nodes::Search.new
        config.root.query = Elastic::Nodes::Boolean.new
        config.root.query.disable_coord = true unless Elastic::Configuration.coord_similarity
        config.groups = []
        config.middleware_options = HashWithIndifferentAccess.new
      end
    end

    def clone
      self.class.new.tap do |clone|
        clone.root = @root.clone
        clone.groups = @groups.dup
        clone.limit = @limit
        clone.offset = @offset
        clone.middleware_options = @middleware_options.dup
      end
    end
  end
end