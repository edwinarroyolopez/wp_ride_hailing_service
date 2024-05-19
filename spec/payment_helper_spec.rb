# spec/helpers/payment_helper_spec.rb
require 'spec_helper'
require 'webmock/rspec'
require_relative '../app/api/helpers/payment_helper'

RSpec.describe PaymentHelper do
  include PaymentHelper

  describe '#generate_acceptance_token' do
    let(:pub_gateway_key) { 'test_pub_key' }
    let(:url) { "#{ENV['EXTERNAL_API_URL']}/merchants/#{pub_gateway_key}" }

    before do
      stub_request(:get, url)
        .to_return(
          status: 200,
          body: {
            data: {
              presigned_acceptance: {
                acceptance_token: 'test_acceptance_token'
              }
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'generates an acceptance token successfully' do
      token = generate_acceptance_token(pub_gateway_key)
      expect(token).to eq('test_acceptance_token')
    end

    it 'raises an error if the API call fails' do
      stub_request(:get, url)
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        generate_acceptance_token(pub_gateway_key)
      }.to raise_error(StandardError, /Error getting aceptation token/)
    end
  end

  describe '#generate_external_transaction' do
    let(:url) { "#{ENV['EXTERNAL_API_URL']}/transactions" }
    let(:body) do
      {
        acceptance_token: "test_acceptance_token",
        amount_in_cents: 1000,
        currency: "COP",
        customer_email: "test@example.com",
        reference: "test_reference",
        payment_method: {
          type: "NEQUI",
          phone_number: "3107654321"
        }
      }
    end
    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer test_pub_key'
      }
    end

    before do
      stub_request(:post, url)
        .with(body: body.to_json, headers: headers)
        .to_return(
          status: 200,
          body: { status: 'success', transaction_id: '12345' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'generates an external transaction successfully' do
      response = generate_external_transaction(body, headers)
      expect(response['status']).to eq('success')
      expect(response['transaction_id']).to eq('12345')
    end

    it 'raises an error if the API call fails' do
      stub_request(:post, url)
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        generate_external_transaction(body, headers)
      }.to raise_error(StandardError, /Error while was generating the transaction/)
    end
  end
end
