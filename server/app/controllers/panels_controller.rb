# frozen_string_literal:true

class PanelsController < ApplicationController
  def bulk_create
    errors = {}
    panels = []

    params[:panels].each do |panel_param|
      panel = Panel.new(code: panel_param[:code], flavor: panel_param[:flavor], installation_id: params[:installation_id])

      if panel.valid?
        panels << panel
      else
        errors[panel_param[:code]] = panel.errors.messages
      end
    end

    if errors.any?
      payload = {
        errors: errors,
        status: 422
      }
      render json: payload, status: :unprocessable_entity
    else
      panels.each(&:save)
      payload = { status: 200 }
      render json: payload, status: :ok
    end
  end
end
