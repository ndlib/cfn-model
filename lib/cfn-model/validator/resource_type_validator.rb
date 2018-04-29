require 'cfn-model/parser/parser_error'

class ResourceTypeValidator
  def self.validate(cloudformation_yml)
    hash = YAML.safe_load cloudformation_yml
    raise ParserError, 'yml empty' if hash == false || hash.nil?

    if hash.is_a?(Array) || hash['Resources'].nil? || hash['Resources'].empty?
      raise ParserError, 'Illegal cfn - no Resources'
    end

    resources = hash['Resources']

    resources.each do |resource_id, resource|
      raise ParserError, "Illegal cfn - missing Type: id: #{resource_id}" if resource['Type'].nil?
    end

    parameters = hash['Parameters']
    unless parameters.nil?
      parameters.each do |parameter_id, parameter|
        if parameter['Type'].nil?
          raise ParserError, "Illegal cfn - missing Parameter Type: id: #{parameter_id}"
        end
      end
    end

    hash
  end
end
