# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:installations) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }

    it 'validates email format' do
      expect { create(:customer, email: 'wrong@email') }
        .to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Email is invalid')
    end
  end
end
