module Crabgrass
  module Serializeable
    #ensures it only serializes attributes
    #the default implementation is def to_yaml_properties; instance_variables.sort; end
    #which was bombing if @data was initialized but set to nil, as might happen in after_saves
    def to_yaml_properties
      ['@attributes']
    end
  end
end
