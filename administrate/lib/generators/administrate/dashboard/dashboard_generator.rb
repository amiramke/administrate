require "rails/generators/named_base"

module Administrate
  module Generators
    class DashboardGenerator < Rails::Generators::NamedBase
      TABLE_ATTRIBUTE_LIMIT = 4

      source_root File.expand_path("../templates", __FILE__)

      def create_dashboard_definition
        template "dashboard.rb.erb", "app/dashboards/#{file_name}_dashboard.rb"
      end

      def create_resource_controller
        template(
          "controller.rb.erb",
          "app/controllers/admin/#{file_name.pluralize}_controller.rb"
        )
      end

      private

      def attributes
        klass.attribute_names + klass.reflections.keys
      end

      def field_type(attribute)
        if klass.type_for_attribute(attribute).type
          default_field_type
        else
          association_type(attribute)
        end
      end

      def default_field_type
        "Field::String"
      end

      def association_type(attribute)
        reflection = klass.reflections[attribute.to_s]
        if reflection.has_one?
          "Field::HasOne"
        elsif reflection.collection?
          "Field::HasMany" + has_many_options_string(reflection)
        else
          "Field::BelongsTo"
        end
      end

      def klass
        @klass ||= Object.const_get(class_name)
      end

      def has_many_options_string(reflection)
        if reflection.class_name != reflection.name.to_s.classify
          options_string(class_name: reflection.class_name)
        else
          ""
        end
      end

      def options_string(options)
        ".with_options(#{inspect_hash_as_ruby(options)})"
      end

      def inspect_hash_as_ruby(hash)
        hash.map { |key, value| "#{key}: #{value.inspect}" }.join(", ")
      end
    end
  end
end