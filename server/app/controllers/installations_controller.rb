# frozen_string_literal:true

class InstallationsController < ApplicationController
  def create
    errors = {}

    company = Company.find_by(company_params)
    errors[:company] = "Couldn't find Company, please review Name and SIREN" unless company

    customer = Customer.find_or_initialize_by(customer_params)
    errors[:customer] = customer.errors.messages if customer.new_record? && !customer.save

    installation = Installation.new(installation_params)
    installation.company = company
    installation.customer = customer
    errors[:installation] = installation.errors.messages.except(:company, :customer) unless installation.save

    if errors.any?
      payload = {
        errors: errors,
        status: 422
      }
      render json: payload, status: :unprocessable_entity
    else
      payload = { status: 200 }
      render json: payload, status: :ok
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :siren)
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone)
  end

  def installation_params
    params.require(:installation).permit(:address1, :date)
  end
end
