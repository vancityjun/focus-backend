module Support
  module Helpers
    module RailsSpecHelpers
      extend ActiveSupport::Concern

      module ClassMethods
        def freeze_time!(testing_time = Time.current, &block)
          attr_reader :now

          around do |example|
            testing_time = instance_exec &block if block_given?

            instance_variable_set '@now', testing_time

            Timecop.freeze(testing_time) { example.call }
          end
        end
      end
    end
  end
end
