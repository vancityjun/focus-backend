module Resolvers
  class LocationData < Resolvers::Base
    description 'Fetch the word countries, regions, cities list'
    type [Types::PickerSelect::PickerSelectType], null: false
    argument :country, String, required: false, default_value: nil
    argument :region, String, required: false, default_value: nil

    def resolve(country:, region:)
      if country.present? && region.present?
        return CS.get(country, region).map do |record|
          {label: record, value: record}
        end
      end

      CS.get(country).map do |record|
        {label: record[1], value: record[0]}
      end
    end
  end
end
