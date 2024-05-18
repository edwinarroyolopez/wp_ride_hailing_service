require 'spec_helper'

RSpec.describe PaymentSource do
  let(:rider_id) { 1 }
  let(:pub_gateway_key) { 'test_pub_gateway_key' }

  it 'creates a new payment source successfully' do
    payment_source = PaymentSource.create(rider_id: rider_id, pub_gateway_key: pub_gateway_key)
    expect(payment_source.rider_id).to eq(rider_id)
    expect(payment_source.pub_gateway_key).to eq(pub_gateway_key)
  end

  it 'validates presence of required fields' do
    payment_source = PaymentSource.new
    expect(payment_source.valid?).to be false
    expect(payment_source.errors[:rider_id]).to include('is not present')
    expect(payment_source.errors[:pub_gateway_key]).to include('is not present')
  end

end