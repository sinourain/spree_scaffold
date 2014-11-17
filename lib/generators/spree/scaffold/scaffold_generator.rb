require 'rails/generators'
require 'rails/generators/generated_attribute'

module Spree
  module Generators
    class ScaffoldGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
  
      attr_accessor :scaffold_name, :model_attributes, :controller_actions
      
      argument :scaffold_name, :type => :string, :required => true, :banner => 'ModelName'
      argument :model_attribute_args, :type => :array, :default => [], :banner => 'model:attributes'
  
      def initialize(*args, &block)
        super
        print_usage unless scaffold_name.underscore =~ /^[a-z][a-z0-9_\/]+$/
    
        @model_attributes = []
        model_attribute_args.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          end
        end
      end
      
      def create_model
        template 'model.rb', "app/models/spree/#{model_path}.rb"
      end
  
      def create_controller
        template 'controller.rb', "app/controllers/spree/admin/#{model_path.pluralize}_controller.rb"
      end
  
      def create_views
        ['index','new','edit'].each do |view|
          template "views/#{view}.html.erb", "app/views/spree/admin/#{model_path.pluralize}/#{view}.html.erb"
        end
        template "views/_form.html.erb", "app/views/spree/admin/#{model_path.pluralize}/_form.html.erb"
        template "views/show.html.erb", "app/views/spree/#{model_path.pluralize}/show.html.erb"
      end
  
      def create_migration
        stamp =  Time.now.utc.strftime("%Y%m%d%H%M%S")
        template 'migration.rb', "db/migrate/#{stamp}_create_spree#{model_path.pluralize}.rb"
      end
  
      def create_locale
        template 'en.yml', "config/locales/en_#{model_path.pluralize}.yml"
      end

      # Added back since using deface
      def create_hooks
        template 'hooks.rb', "app/overrides/spree_scaffold_#{model_path.pluralize}_hooks.rb"
      end

      private
  
      def model_path
        scaffold_name.underscore.downcase
      end
  
      def class_name
        scaffold_name.camelize
      end
  
      def table_name
         .downcase.underscore.pluralize
      end
  
      def display_name
        scaffold_name.underscore.titleize
      end
  
      def display_name_plural
        scaffold_name.underscore.titleize.pluralize
      end
  
    end
  end
end