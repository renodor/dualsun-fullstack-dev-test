# frozen_string_literal:true

class InstallationsController < ApplicationController
  def create
    installation = Installation.new(installation_params)
    if installation.save
      payload = {
        id: installation.id,
        status: 200
      }
      status = :ok
    else
      payload = {
        errors: installation.errors.messages,
        status: 422
      }
      status = :unprocessable_entity
    end

    render json: payload, status: status
  end

  private

  def installation_params
    params.require(:installation).permit(:date, :address, :city, :company_id, :customer_id)
  end
end
