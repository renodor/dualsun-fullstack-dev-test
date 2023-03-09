# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Panel, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:installation) }
  end

  context 'validations' do
    subject { panel }

    let(:panel) { create(:panel) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:flavor) }
    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_numericality_of(:code).only_integer }
  end

  it { is_expected.to define_enum_for(:flavor).with_values(%i[photovoltaic hybrid]) }
end
