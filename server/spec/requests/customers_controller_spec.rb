# frozen_string_literal:true

require 'rails_helper'

RSpec.describe 'CustomersController', type: :request do
  describe 'POST /find_or_create' do
    context 'when params are valid' do
      let(:params) { { name: 'Cool Customer', email: 'cool-customer@email.com', phone: '0610101010' } }

      context 'when customer already exists' do
        let!(:customer) { create(:customer, name: 'Cool Customer', email: 'cool-customer@email.com', phone: '0610101010') }

        it 'finds customer and returns its id' do
          expect { post '/customers/find_or_create', params: params, as: :json }.not_to change(Customer, :count)

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq(
            {
              'id' => customer.id,
              'status' => 200
            }
          )
        end
      end

      context 'when customer does not exists' do
        it 'creates customer and returns its id' do
          expect { post '/customers/find_or_create', params: params, as: :json }.to change(Customer, :count).by(1)

          customer = Customer.last
          expect(customer.name).to eq('Cool Customer')
          expect(customer.email).to eq('cool-customer@email.com')
          expect(customer.phone).to eq('0610101010')

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq(
            {
              'id' => customer.id,
              'status' => 200
            }
          )
        end
      end
    end

    context 'when params are not valid' do
      it 'returns customer errors' do
        post '/customers/find_or_create', params: { name: '', email: 'wrong@email', phone: '' }, as: :json

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq(
          {
            'errors' => {
              'name' => ['can\'t be blank'],
              'email' => ['is invalid'],
              'phone' => ['can\'t be blank']
            },
            'status' => 422
          }
        )
      end
    end
  end
end
