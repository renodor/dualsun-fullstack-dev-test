# frozen_string_literal:true

require 'rails_helper'

RSpec.describe 'InstallationsController', type: :request do
  describe 'POST /create' do
    let!(:company) { create(:company) }
    let!(:customer) { create(:customer) }

    context 'when params are valid' do
      let(:params) do
        {
          date: Date.today,
          address: '10 Rue Cool',
          city: 'Cool City',
          company_id: company.id,
          customer_id: customer.id
        }
      end

      it 'creates installation and returns its id' do
        expect { post '/installations', params: params, as: :json }.to change(Installation, :count).by(1)

        installation = Installation.last
        expect(installation.date).to eq(Date.today)
        expect(installation.address).to eq('10 Rue Cool')
        expect(installation.city).to eq('Cool City')
        expect(installation.company).to eq(company)
        expect(installation.customer).to eq(customer)

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(
          {
            'id' => Installation.last.id,
            'status' => 200
          }
        )
      end
    end

    context 'when params are not valid' do
      it 'returns installation errors' do
        expect { post '/installations', params: { data: '', address: '', city: '' }, as: :json }.not_to change(Installation, :count)

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq(
          {
            'errors' => {
              'date' => ['can\'t be blank'],
              'address' => ['can\'t be blank'],
              'city' => ['can\'t be blank'],
              'company' => ['must exist'],
              'customer' => ['must exist']
            },
            'status' => 422
          }
        )
      end
    end
  end
end
