module Services
  class PermissionsService < BaseService

    def create
      permission = Permission.new params
      permission.created_by_user = user
      if permission.save
        { status: 'Success to Add permission', errors: [] }
      else
        { status: nil, errors: permission.errors.full_messages }
      end
    end

    def delete
      permission = model.find(model_id)

      if permission.destroy
        { status: 'Success to Delete permission', errors: [] }
      else
        { status: nil, errors: permission.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound => error
      { status: nil, errors: [error.message] }
    end
  end
end
