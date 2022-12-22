# frozen_string_literal: true

namespace :obsolete_parts do
  task :check => :environment do
    PartInteractions::ObsoletePartsCheck.run({})
  end
end
