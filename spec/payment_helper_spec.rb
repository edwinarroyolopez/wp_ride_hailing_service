# spec/helpers/payment_helper_spec.rb
require 'spec_helper'
require 'webmock/rspec'
require_relative '../app/api/helpers/payment_helper'

RSpec.describe PaymentHelper do
  include PaymentHelper

  describe '#generate_acceptance_token' do
    let(:pub_gateway_key) { ENV['PUB_GATEWAY_KEY'] }
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
      token = generate_acceptance_token()
      expect(token).to eq('test_acceptance_token')
    end

    it 'raises an error if the API call fails' do
      stub_request(:get, url)
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        generate_acceptance_token()
      }.to raise_error(StandardError, /Error getting aceptation token/)
    end
  end

  describe '#generate_external_transaction' do
    let(:url) { "#{ENV['EXTERNAL_API_URL']}/transactions" }
    let(:body) do
      {
        acceptance_token: "test_acceptance_token",
        amount_in_cents: 20000*100,
        currency: "COP",
        customer_email: "test@example.com",
        reference: "#{20000*100}-test@example.com",
        payment_method: {
          type: "CARD",
          token: "#{ENV['TOKEN_CARD']}",
          installments: 2
        }
      }
    end
    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['PUB_GATEWAY_KEY']}"
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
      response = generate_external_transaction('test_acceptance_token', ENV['TOKEN_CARD'], 'test@example.com', 20000)
      expect(response['status']).to eq('success')
      expect(response['transaction_id']).to eq('12345')
    end

    it 'raises an error if the API call fails' do
      stub_request(:post, url)
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        generate_external_transaction('test_acceptance_token', ENV['TOKEN_CARD'], 'test@example.com', 250000)
      }.to raise_error(StandardError, /Error while was generating the transaction/)
    end
  end
end
