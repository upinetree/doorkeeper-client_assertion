# frozen_string_literal: true

require 'rails_helper'

describe Doorkeeper::ClientAssertion, 'configuration' do
  subject { Doorkeeper::ClientAssertion.configuration }

  describe 'client_assertion_algorithms' do
    it 'defaults to RS256 and ES256' do
      Doorkeeper::ClientAssertion.configure {}
      expect(subject.client_assertion_algorithms).to eq(%w[RS256 ES256])
    end

    it 'can be customized' do
      custom_algorithms = %w[RS256 RS384 RS512 ES256 ES384 ES512]
      Doorkeeper::ClientAssertion.configure do
        client_assertion_algorithms custom_algorithms
      end
      expect(subject.client_assertion_algorithms).to eq(custom_algorithms)
    end
  end

  describe 'jwt_assertion_exp_tolerance' do
    it 'defaults to 300 seconds' do
      Doorkeeper::ClientAssertion.configure {}
      expect(subject.jwt_assertion_exp_tolerance).to eq(300)
    end

    it 'can be customized' do
      custom_tolerance = 600
      Doorkeeper::ClientAssertion.configure do
        jwt_assertion_exp_tolerance custom_tolerance
      end
      expect(subject.jwt_assertion_exp_tolerance).to eq(custom_tolerance)
    end
  end

  describe 'on_jwt_verification_failure' do
    it 'defaults to a no-op' do
      Doorkeeper::ClientAssertion.configure {}
      expect(subject.on_jwt_verification_failure.call(nil, {})).to be_nil
    end

    it 'can be set with a lambda' do
      Doorkeeper::ClientAssertion.configure do
        on_jwt_verification_failure ->(error, context) { [error, context] }
      end
      error = StandardError.new
      result = subject.on_jwt_verification_failure.call(error, { application_id: 1 })
      expect(result).to eq([error, { application_id: 1 }])
    end

    it 'can be set with a block' do
      Doorkeeper::ClientAssertion.configure do
        on_jwt_verification_failure { |error, context| [error, context] }
      end
      error = StandardError.new
      result = subject.on_jwt_verification_failure.call(error, { application_id: 1 })
      expect(result).to eq([error, { application_id: 1 }])
    end
  end
end
