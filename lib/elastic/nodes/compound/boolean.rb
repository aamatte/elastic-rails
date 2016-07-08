module Elastic::Nodes
  class Boolean < BaseWithBoost
    attr_accessor :minimum_should_match, :disable_coord

    def initialize
      @musts = []
      @shoulds = []
    end

    def clone
      clone_with_conditions @musts.map(&:clone), @shoulds.map(&:clone)
    end

    def must(_node)
      @musts << _node
    end

    def should(_node)
      @shoulds << _node
    end

    def musts=(_nodes)
      @musts = _nodes.dup.to_a
    end

    def shoulds=(_nodes)
      @shoulds = _nodes.dup.to_a
    end

    def render
      {}.tap do |boolean|
        boolean['must'] = @musts.map(&:render) if @musts.length > 0
        boolean['should'] = @shoulds.map(&:render) if @shoulds.length > 0
        boolean['minimum_should_match'] = minimum_should_match unless minimum_should_match.nil?
        boolean['disable_coord'] = disable_coord unless disable_coord.nil?
        render_boost(boolean)
      end
    end

    def simplify
      new_must = @musts.map(&:simplify)
      new_should = @shoulds.map(&:simplify)

      return new_must.first if new_must.length == 1 && new_should.length == 0

      clone_with_conditions(new_must, new_should)
    end

    private

    def clone_with_conditions(_musts, _shoulds)
      base_clone.tap do |clone|
        clone.musts = _musts
        clone.shoulds = _shoulds
        clone.minimum_should_match = @minimum_should_match
        clone.disable_coord = @disable_coord
      end
    end
  end
end