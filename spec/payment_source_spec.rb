require 'spec_helper'

RSpec.describe PaymentSource do
  let(:rider_id) { 1 }
  let(:token) { ENV['TOKEN_CARD'] }

  it 'creates a new payment source successfully' do
    payment_source = PaymentSource.create(rider_id: rider_id, token: token)
    expect(payment_source.rider_id).to eq(rider_id)
    expect(payment_source.token).to eq(token)
  end

  it 'validates presence of required fields' do
    payment_source = PaymentSource.new
    expect(payment_source.valid?).to be false
    expect(payment_source.errors[:rider_id]).to include('is not present')
    expect(payment_source.errors[:token]).to include('is not present')
  end

end