# frozen_string_literal: true

class ErrorsController < ApplicationController
  # I don't think we actually want to skip these.
  # skip_before_action :find_cart
  # skip_before_action :verify_authenticity_token

  def not_found
    render status: 404
  end

  def internal_server
    render status: 500
  end

  def unprocessable
    render status: 422
  end
end
