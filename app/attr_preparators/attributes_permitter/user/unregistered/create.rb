class AttributesPermitter::User::Unregistered::Create

  def initialize(params)
    @params = params.require(:user)  
  end

  def get_permitted
    @permitted_attributes = @params.permit(profile_attributes: [:phone_number, :name])
    @permitted_attributes
  end

end