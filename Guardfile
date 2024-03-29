# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'compass' do
  watch(%r{^app/assets/stylesheets/.+\.scss})
end

guard 'livereload' do
  watch(%r{^app/assets/stylesheets/.+\.scss})
  watch(%r{^app/assets/javascripts/.+\.js})
  watch(%r{app/.+\.(erb|haml)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{config/locales/.+\.yml})
end

guard 'rspec', version: 2 do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }

  # Rails example
  watch('spec/spec_helper.rb')                       { 'spec' }
  watch('config/routes.rb')                          { 'spec/routing' }
  watch('app/controllers/application_controller.rb') { 'spec/controllers' }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^app/(.+)\.rb})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
end
