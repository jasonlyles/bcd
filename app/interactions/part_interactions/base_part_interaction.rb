module PartInteractions
  class BasePartInteraction

    attr_accessor :error

    def initialize(options)
      @part = options[:part]
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

    private

  end
end
