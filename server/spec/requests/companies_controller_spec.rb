# frozen_string_literal:true

require 'rails_helper'

RSpec.describe 'CompaniesController', type: :request do
  describe 'POST /find_or_create' do
    context 'when params are valid' do
      let(:params) { { name: 'Cool Company', siren: 1234 } }

      context 'when company already exists' do
        let!(:company) { create(:company, name: 'Cool Company', siren: 1234) }

        it 'finds company and returns its id' do
          expect { post '/companies/find_or_create', params: params, as: :json }.not_to change(Company, :count)

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq(
            {
              'id' => company.id,
              'status' => 200
            }
          )
        end
      end

      context 'when company does not exists' do
        it 'creates company and returns its id' do
          expect do
            post '/companies/find_or_create', params: params, as: :json
          end.to change(Company, :count).by(1)

          company = Company.last
          expect(company.name).to eq('Cool Company')
          expect(company.siren).to eq(1234)

          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)).to eq(
            {
              'id' => company.id,
              'status' => 200
            }
          )
        end
      end
    end

    context 'when params are not valid' do
      it 'returns company errors' do
        post '/companies/find_or_create', params: { name: '', siren: 'abcd' }, as: :json

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq(
          {
            'errors' => {
              'name' => ['can\'t be blank'],
              'siren' => ['is not a number', 'is invalid']
            },
            'status' => 422
          }
        )
      end
    end
  end
end
