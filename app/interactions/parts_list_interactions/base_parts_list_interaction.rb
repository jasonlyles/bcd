# frozen_string_literal: true

module PartsListInteractions
  class BasePartsListInteraction
    attr_accessor :error

    def initialize(options)
      @options = options
      @parts_list_id = @options[:parts_list_id]
    end

    def succeeded?
      error.blank?
    end

    def self.run(*args)
      interactor = new(*args)
      interactor.run
      interactor
    end

    private_class_method :new
  end
end
