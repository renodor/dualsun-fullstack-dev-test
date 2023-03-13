# frozen_string_literal:true

class CustomersController < ApplicationController
  def find_or_create
    customer = Customer.find_or_initialize_by(customer_controller)
    if customer.save
      payload = {
        id: customer.id,
        status: 200
      }
      status = :ok
    else
      payload = {
        errors: customer.errors.messages,
        status: 422
      }
      status = :unprocessable_entity
    end

    render json: payload, status: status
  end

  private

  def customer_controller
    params.require(:customer).permit(:name, :email, :phone)
  end
end
