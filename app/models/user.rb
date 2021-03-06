class User < ActiveRecord::Base
  
  include Services::CustomErrorable

  include PgSearch

  pg_search_scope :user_search, :associated_against => {
    :profile => [:name],
  }, against: [:email]

  DEFAULT_PASSWORD = '123456'

  @arbitrary = {}

  class << self

    attr_accessor :arbitrary

  end

  def arbitrary
    @arbitrary ||= {}
  end

  rolify

  accepts_nested_attributes_for :roles,
                                allow_destroy: true, reject_if: :all_blank


# => ################AUTHENTICATION
  ACTIVATABLE = false
  
  attr_accessor :activation_token #ACTIVATION

  attr_accessor :reset_token
  
  attr_accessor :remember_token

############### => VALIDATIONS

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i


  with_options unless: ->{ User.arbitrary[:register_as_guest] } do |user|
    user.validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    unless: -> {arbitrary[:skip_email_validation]}
  end
  
  validates :password, presence: true, 
                      length: { minimum: 6 },
                      confirmation: true, unless: ->{arbitrary[:no_password_update] || password == nil}


  ########### VALIDATION METHODS



  ############
                        
######################################################

############################ CALLBACKS ##################3
  
  before_validation :handle_unregistered_user


    ####################### CALLBACK METHODS

  def handle_unregistered_user
    if User.arbitrary[:register_as_guest] == true
      self.password = self.class::DEFAULT_PASSWORD
      self.password_confirmation = self.class::DEFAULT_PASSWORD
      #self.registered = false
      return true
    else
      return true
    end
  end

    ##################################

########################################################

  before_save :downcase_email, unless: ->{ User.arbitrary[:register_as_guest] || arbitrary[:skip_email_validation] }

  before_create :create_activation_digest #ACTIVATION

  has_secure_password

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                 BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def downcase_email
    self.email = email.downcase 
  end

  def create_activation_digest
    self.activation_token = self.class.new_token
    self.activation_digest =  self.class.digest(activation_token)
  end

  def activate
    update_attribute :activated, true
    update_attribute :activated_at, Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest # RESET PASSWORD
    self.reset_token = self.class.new_token
    self.update_attribute(:reset_digest, self.class.digest(reset_token))
    self.update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end
  #//////         END AUTHENTICATION

  EXPOSABLE_ATTRIBUTES = [:id, :email, :created_at, :updated_at]

  has_one :profile, dependent: :destroy
  has_one :avatar, dependent: :destroy
  has_many :appointments_as_doctor, class_name: 'Appointment', foreign_key: 'doctor_id', dependent: :destroy
  has_many :appointments_as_doctor_for_patient, ->{where(scheduled: true).select(User.arbitrary[:patient_id])}, class_name: 'Appointment', foreign_key: 'doctor_id', dependent: :destroy
  has_many :appointments_as_patient, class_name: 'Appointment', foreign_key: 'patient_id', dependent: :destroy
  has_many :unscheduled_appointments_as_patient, ->{where(scheduled: false)}, class_name: 'Appointment', foreign_key: 'patient_id'

  has_one :profile_id_name, ->{ select(:id, :user_id, :name) }, class_name: :Profile
  has_one :si_profile1id_name, ->{select(:id, :name, :user_id)}, class_name: "Profile"
  has_one :si_profile1name_phone_number, ->{select(:id, :name, :user_id, :phone_number)}, class_name: 'Profile'
  has_one :si_profile1id_name_bio, ->{select(:id, :name, :user_id, :bio)}, class_name: 'Profile'

  has_many :blogs
  has_many :pages

  def general_roles_as_json
    self.roles.where(resource_type: nil).select(:id, :name).as_json(only: [:id, :name])   
  end

  has_many :appointment_availabilities
  #need to set self.class.artbitrary to {from: Date.iso8601, to: Date.iso8601}
  has_many :si_appointment_availabilities1apsindex, ->{select(:id, :user_id, :for_date, :map).
    where("for_date >= ? AND for_date <= ?", User.arbitrary[:from], User.arbitrary[:to])}, class_name: "AppointmentAvailability"

  has_many :si_appointments1as_doctor_all, ->{ where("start_date >= ? AND end_date <= ?", User.arbitrary[:from], User.arbitrary[:to]) },
    class_name: 'Appointment', foreign_key: 'doctor_id'
  
  has_many :si_appointments1as_patient_all, ->{ where("appointments.start_date >= ? AND appointments.end_date <= ?", User.arbitrary[:from], User.arbitrary[:to]).select(:id, :start_date, :end_date, :doctor_id) },
    class_name: 'Appointment', foreign_key: 'doctor_id'

  has_many :si_appointments1for_patient_id, ->{ where("appointments.start_date >= ? AND appointments.end_date <= ?", User.arbitrary[:from], User.arbitrary[:to]).where("appointments.patient_id = ?", User.arbitrary[:patient_id]).select(:id, :start_date, :end_date, :doctor_id) },
    class_name: 'Appointment', foreign_key: 'doctor_id'

  

  has_many :si_appointments_as_patient1id, ->{select(:id)},class_name: 'Appointment',foreign_key: 'patient_id'

  has_many :chats, dependent: :destroy

  has_many :chat_messages, dependent: :destroy

  has_many :chat_messages_as_recepient, class_name: 'ChatMessage', foreign_key: 'to_user'


  accepts_nested_attributes_for :avatar, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :profile, allow_destroy: true

#ROLIFY
  rolify :before_add => :before_role_add

  def before_role_add(role)
    if role.resource_type == "Page"
      raise "assigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_page_roles.include? role.name
    elsif role.resource_type == "Blog"
      raise "ssigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_blog_roles.include? role.name
    else 
      raise "assigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_global_roles.include? role.name
    end
  end
###############


end
