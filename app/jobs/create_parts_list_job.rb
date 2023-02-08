# frozen_string_literal: true

class CreatePartsListJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform(parts_list_id)
    # Pass the jid to the interactor so it can track the jobs progress in Redis so
    # that the poller on the parts list page can see if the job is still active or not.
    PartsListInteractions::CreatePartsList.run(parts_list_id:, jid:)
  end
end
