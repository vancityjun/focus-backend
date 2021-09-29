module Types::PickerSelect
  class PickerSelectType < Types::BaseObject
    field :label, String, null: false
    field :value, String, null: false
  end
end
