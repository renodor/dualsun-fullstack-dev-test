# frozen_string_literal:true

class CompaniesController < ApplicationController
  def find_or_create
    company = Company.find_or_initialize_by(company_params)
    if company.save
      payload = {
        id: company.id,
        status: 200
      }
      status = :ok
    else
      payload = {
        errors: company.errors.messages,
        status: 422
      }
      status = :unprocessable_entity
    end

    render json: payload, status: status
  end

  private

  def company_params
    params.require(:company).permit(:name, :siren)
  end
end
