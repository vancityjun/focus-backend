class BaseService

  attr_accessor :params, :object, :user

  def initialize(params: {}, object: nil, object_id: nil, user: nil)
    @params = params.to_h.symbolize_keys
    @object = object || model.find_by(id: object_id)
    @user = user
  end

  def self.call(resource, method, options)
    service = "#{resource.to_s.pluralize.camelize}::Service"
    service.constantize.new(
      params: options[:params],
      user: options[:current_user],
      object_id: options[:params][:id]
    ).send(method)
  end

private
  
  def model
    singular_resource.camelize.constantize
  end

  def singular_resource
    resource_name.singularize
  end

  def resource_name
    self.class.to_s.split(':').first.underscore
  end
end
