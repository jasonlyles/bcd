# frozen_string_literal: true

class InteractorGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_interactor_files
    # First create the base interactor
    base_interactor_file = "app/interactions/#{file_name}_interactions/base_#{file_name}_interaction.rb"
    template 'base_interactor.erb', base_interactor_file unless File.exist?(base_interactor_file)

    methods = ARGV.drop(1)

    # Now create files for each method passed in
    methods.each do |method|
      @method = method
      template 'method_interactor.erb', "app/interactions/#{file_name}_interactions/#{method.underscore}.rb"
      template 'method_interactor_spec.erb', "spec/interactions/#{file_name}_interactions/#{method.underscore}_spec.rb"
    end
  end
end
