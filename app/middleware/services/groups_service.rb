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
      if object.update params
        { group: object, errors: [] }
      else
        { group: nil, errors: object.errors.full_messages }
      end
    end

    def delete
      if object.archive
        { status: "Success to Delete Group", errors: [] }
      else
        { status: nil, errors: object.errors.full_messages }
      end
    end

    def join
      attendee = object.attenables.new attendee: user
      if attendee.save
        { status: "Success to Join the #{object.name}", errors: [] }
      else
        { status: nil, errors: attendee.errors.full_messages }
      end
    end

    def leave
      attendee = object.attenables.find_by(attendee: user)
      return { status: nil, errors: ['No record for attendee'] } if attendee.blank?

      if attendee.destroy
        { status: "Success to Leave the #{object.name}", errors: [] }
      else
        { status: nil, errors: attendee.errors.full_messages }
      end
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
