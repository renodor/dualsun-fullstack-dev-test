# frozen_string_literal:true

require 'rails_helper'

RSpec.describe 'PanelsController', type: :request do
  describe 'POST /create' do
    let!(:installation) { create(:installation) }

    context 'when params of all panels are valid' do
      let(:params) do
        {
          panels: [
            { code: '123456', flavor: 'photovoltaic' },
            { code: '111111', flavor: 'hybrid' }
          ],
          installation_id: installation.id
        }
      end

      it 'creates all panels' do
        expect { post '/panels/bulk_create', params: params, as: :json }.to change(Panel, :count).by(2)

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq({ 'status' => 200 })
      end
    end

    context 'when params of at least one panel is not valid' do
      let(:params) do
        {
          panels: [
            { code: '123456', flavor: 'photovoltaic' },
            { code: '1111', flavor: 'hybrid' }
          ],
          installation_id: installation.id
        }
      end

      it 'does not create any panel and add errors to invalid panel' do
        expect { post '/panels/bulk_create', params: params, as: :json }.not_to change(Panel, :count)

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq(
          {
            'errors' => { '1111' => { 'code' => ['is invalid'] } },
            'status' => 422
          }
        )
      end
    end
  end
end
