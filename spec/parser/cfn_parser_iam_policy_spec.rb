require 'spec_helper'
require 'cfn-model/parser/cfn_parser'
require 'cfn-model/parser/parser_error'

describe CfnParser do
  before :each do
    @cfn_parser = CfnParser.new
  end

  context 'an iam policy without required props' do
    it 'raises an error' do
      test_templates('iam_policy/policy_with_missing_properties').each do |test_template|
        begin
          _ = @cfn_parser.parse IO.read(test_template)
        rescue Exception => parse_error
          begin
            expect(parse_error.is_a?(ParserError)).to eq true
            expect(parse_error.errors.size).to eq(2)
            expect(parse_error.errors[0].to_s).to eq("[/Resources/policy/Properties] key 'PolicyDocument:' is required.")
            expect(parse_error.errors[1].to_s).to eq("[/Resources/policy/Properties] key 'PolicyName:' is required.")
          rescue RSpec::Expectations::ExpectationNotMetError
            $ERROR_INFO.message << "in file: #{test_template}"
            raise
          end
        end
      end
    end
  end

  context 'a valid iam policy' do
    it 'returns policy' do
      test_templates('iam_policy/valid_iam_policy').each do |test_template|
        cfn_model = @cfn_parser.parse IO.read(test_template)

        policies = cfn_model.resources_by_type('AWS::IAM::Policy')

        expect(policies.size).to eq 1
        policy = policies.first

        expect(policy).to eq valid_iam_policy
      end
    end
  end
end
