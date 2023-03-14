# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Installation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:panels) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
  end
end
