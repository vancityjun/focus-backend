module Services
  class GroupsService < BaseService

    def fetch
      if params[:id].present?
        collection.where(id: params[:id])
      else
        collection
      end
    end

    def create
      group = user.groups.new params
      if group.save
        { group: group, errors: [] }
      else
        { group: nil, errors: group.errors.full_messages }
      end
    end

    def update
      group = model.find(model_id)
      if group.update params
        { group: group, errors: [] }
      else
        { group: nil, errors: group.errors.full_messages }
      end

    rescue ActiveRecord::RecordNotFound => error
      { group: nil, errors: [error.message] }
    end

    def delete
      group = model.find(model_id)
      if group.archive
        { status: "Success to Delete Group", errors: [] }
      else
        { status: nil, errors: group.errors.full_messages }
      end

    rescue ActiveRecord::RecordNotFound => error
      { status: nil, errors: [error.message] }
    end

    def join
      group = model.find(model_id)
      attendee = group.attenables.new attendee: user
      if attendee.save
        { status: "Success to Join the #{group.name}", errors: [] }
      else
        { status: nil, errors: attendee.errors.full_messages }
      end

    rescue ActiveRecord::RecordNotFound => error
      { status: nil, errors: [error.message] }
    end

    def leave
      group = model.find(model_id)
      attendee = group.attenables.find_by attendee: user
      return { status: nil, errors: ['No record for attendee'] } if attendee.blank?

      if attendee.destroy
        { status: "Success to Leave the #{group.name}", errors: [] }
      else
        { status: nil, errors: attendee.errors.full_messages }
      end

    rescue ActiveRecord::RecordNotFound => error
      { status: nil, errors: [error.message] }
    end

  private
    def collection
      if params[:range] == 'attended'
        user.attended_groups.active
      else
        Group.active.find_public
      end
    end
  end
end
