# frozen_string_literal: true

class ObsoletePartsCheckJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    PartInteractions::ObsoletePartsCheck.run({})
  end
end
