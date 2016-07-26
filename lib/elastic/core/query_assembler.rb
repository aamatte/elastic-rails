module Elastic::Core
  class QueryAssembler
    def initialize(_index, _config)
      @index = _index
      @config = _config
    end

    def assemble
      query = build_base_query

      if !grouped?
        query.size = (@config.limit || Elastic::Configuration.page_size)
        query.offset = @config.offset
      else
        query.size = 0
        last = attach_groups query
        last.aggregate(Elastic::Nodes::TopHits.build('default'))

        query = grouped_query query
        query = reduced_query query
      end

      populated_query query
    end

    def assemble_ids
      raise NotImplementedError, 'ids retrieval not yet implemented'
    end

    def assemble_total
      raise NotImplementedError, 'total not yet implemented'
    end

    def assemble_pluck(_field)
      raise NotImplementedError, 'pluck not yet implemented'
    end

    def assemble_metric(_node)
      query = assemble_metrics([_node])
      reduced_query query
    end

    def assemble_metrics(_aggs)
      query = build_base_query
      query.size = 0

      last = attach_groups(query)
      last.aggs = _aggs

      query = grouped_query(query) if grouped?
      query
    end

    private

    def build_base_query
      @config.root.simplify
    end

    def grouped?
      !@config.groups.empty?
    end

    def attach_groups(_query)
      @config.groups.inject(_query) do |last, node|
        node = node.simplify
        last.aggregate node
        node
      end
    end

    def grouped_query(_query)
      Elastic::Shims::Grouping.new(_query)
    end

    def reduced_query(_query)
      Elastic::Shims::Reducing.new(_query)
    end

    def populated_query(_query)
      Elastic::Shims::Populating.new(@index, @config, _query)
    end
  end
end