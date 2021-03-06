require "vendor/model"

class User < Model

  attributes :id, :email, :password, :password_confirmation
  has_many :appointment_availabilities
  has_many :appointments

  route "sign_up", post: "users"

  route "Find", get: "users/:id"

  route "Show", get: "users/:id"

  route "test", post: "test"

  route "update", {put: "users/:id"}, {defaults: [:id]}

  route "create", post: "users"

  route "Index", get: "users"

  route "destroy", {delete: "users/:id"}, {defaults: [:id]} 

  route "Edit", {get: "users/:id/edit"}

  route 'destroy_unregistered_user_with_proposals', {delete: 'users/destroy_unregistered_user_with_proposals/:id'}, {defaults: [:id]}
 
  route 'Index_doctors_for_group_list', {get: 'users/index_doctors_for_group_list'}

  route 'transform_user_to_registered', {post: 'appointment_scheduler/users/transform_user_to_registered/:id'}, {defaults: [:id]}

  has_one :profile, :avatar
  has_many :roles
  has_many :chat_messages
  accepts_nested_attributes_for :profile, :avatar, :roles

  def self.responses_on_index_doctors_for_group_list(r)
    self.responses_on_index(r)
  end

  def responses_on_transform_user_to_registered(r)
    self.responses_on_update(r)
  end

  def responses_on_destroy_unregistered_user_with_proposals(r)
    self.responses_on_destroy(r)
  end

  def on_before_test(r)
    r.req_options = {payload: pure_attributes}
  end

  def validate_email(options={})
    unless email == nil
      unless (email.match /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i)
        add_error :email, "you should provide a valid email"
      end
    end
  end

  def has_role?(role)
    roles.each do |_role|
      return true if role.include? _role.name 
    end
    false
  end

  def validate_password
    if password.length < 6
      add_error :password, "password is too short"
    end
    if password != password_confirmation
      add_error :password_confirmation, "confirmation does not match"
    end
  end
end