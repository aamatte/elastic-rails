module Elastic::Types
  class BaseType < Elastic::Core::Serializer
    def self.target=(_name_or_class)
      definition.targets = [_name_or_class]
    end

    def self.targets=(_names_or_classes)
      definition.targets = _names_or_classes
    end

    def self.definition
      @definition ||= Elastic::Core::Definition.new.tap do |definition|
        definition.targets = [default_target] unless default_target.nil?
      end
    end

    def self.freeze_index_definition
      unless definition.frozen?
        definition.fields.each do |field|
          field.disable_mapping_inference if original_value_occluded? field.name
        end

        definition.freeze
      end
    end

    def initialize(_object)
      super(self.class.definition, _object)
    end

    private

    def self.default_target
      @default_target ||= begin
        target = self.to_s.match(/^(.*)Index$/)
        target[1].constantize rescue nil
      end
    end
  end
end