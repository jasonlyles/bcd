# frozen_string_literal: true

class NewsController < ApplicationController
  def index
    @updates = Update.live_updates.order(created_at: :desc).page(params[:page]).per(9)
  end
end
