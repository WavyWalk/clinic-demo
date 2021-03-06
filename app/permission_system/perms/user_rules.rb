module Perms
  class UserRules < Perms::Base

    def create
      @permitted_attributes = @controller.params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:name, :phone_number], avatar_attributes: [:id ,:file])      
    end

    def appointment_scheduler_create
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success = 
        {
          only: [:id, :email],
          include: 
          [
            profile: 
            {
              root: true,
              only: [:id, :user_id, :name, :phone_number]
            }
          ]
        }
        @serialize_on_error =
        {
          methods: [:errors],
          include:
          {
            profile:
            {
              root: true,
              methods: [:errors]
            }
          }
        }
        return true
      end
    end
  #********************

    def admin_create
      if @controller.current_user && @controller.current_user.has_any_role?(:admin, :root)
        
        @permitted_attributes = @controller.params.require(:user).
              permit(:email, :password, :password_confirmation, avatar_attributes: [:file], 
                      profile_attributes: [:name, :bio], roles_attributes: [:name] )
        
      end
    end
  

  #***********************
    def index
      per_page = params[:per_page] || 25

      
        @model = ::User.includes(:profile_id_name, :avatar).all.paginate(page: params[:page], per_page: per_page)

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id], methods: [:url] },
            profile: { root: true, only: [:id,  :name]}
          }
        ) << @controller.extract_pagination_hash(@model)
      
    end    

    def appointment_scheduler_index
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        @serialize_on_success = 
        {
          only: [:id, :email, :registered],
          include:
          [
            si_profile1name_phone_number: {root: true, only: [:id, :name, :user_id, :email, :phone_number]}
          ]
        }
        true
      end
    end
  #********************

    def admin_index

      if @current_user && @current_user.has_any_role?(:admin)

       @serialize_on_success = {
          only:    [:id, :email],
          include: {
            avatar:  { root: true, only: [:id], methods: [:url]},
            si_profile1name_phone_number: {root: true, only: [:id, :name, :user_id, :email, :phone_number]},
            roles: { root: true, only: [:name, :id] }
          }
        }
      end
      
    end

  #***********

    def destroy
      @current_user.has_any_role?(:admin, :root)
    end

  #*********************

    def update
      if ::User.find(params[:id]).id == @current_user.try(:id)
        @permitted_attributes = params.require(:user).permit(:email, :password, :password_confirmation, avatar_attributes: [:file, :id, :user_id], profile_attributes: [:name, :id, :user_id, :phone_number])
      end
    end

  #********************

    def admin_update
      if @current_user.has_any_role? :admin, :root
        @permitted_attributes = params.require(:user).permit(:email, :password, :password_confirmation, 
                                                              avatar_attributes: [:file, :id, :user_id], 
                                                              profile_attributes: [:name, :bio, :id, :user_id, :phone_number],
                                                              roles_attributes: [:name, :id, :user_id, :_destroy])        
      end
    end


  #**************
    
    def show

      @model = ::User.includes(:profile, :avatar).find(@controller.params[:id])

      @model = @model.as_json(
        only:  ::User::EXPOSABLE_ATTRIBUTES,
        include: {
          avatar:  { root: true, only: [:id, :user_id], methods: [:url] },
          profile: { root: true, only: [:id,  :name, :bio, :user_id]}
        }
      )

      @model    

    end

    def admin_show
      if @current_user && @current_user.has_role?(:admin)

        @model = ::User.includes(:profile, :avatar, :roles).find(@controller.params[:id])

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url]},
            profile: { root: true, only: [:id,  :name, :bio, :user_id]},
            roles: { root: true, only: [:name] }
          }
        )

        @model
      end
    end

  #********************

    def edit
      if @current_user.id.to_s == params[:id]
        @model = ::User.includes(:profile, :avatar).find(@controller.params[:id])

        @model = @model.as_json(
          only:  ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url] },
            profile: { root: true, only: [:id,  :name, :user_id, :phone_number]}
          }
        )

        @model    
      end
    end

    def admin_edit
      
      if @current_user && @current_user.has_role?(:admin)

        @model = ::User.includes(:profile, :avatar, :roles).find(@controller.params[:id])

        @model = @model.as_json(
          only:    ::User::EXPOSABLE_ATTRIBUTES,
          include: {
            avatar:  { root: true, only: [:id, :user_id], methods: [:url]},
            profile: { root: true, only: [:id,  :name, :bio, :user_id, :phone_number]},
            roles: { root: true, only: [:name, :id] }
          }
        )

        @model
      end
    end


    def appointment_scheduler_edit
      
      if @current_user && @current_user.has_role?(:appointment_scheduler)

        unless @model.has_role?(:patient)
          return false
        end

        if @model.has_any_role?(:admin, :blogger, :appointment_scheduler)
          return false
        end

        @serialize_on_success = 
        {
          only: [:id, :email, :registered],
          include:
          {
            profile: {root: true, only: [:id, :name, :bio, :user_id, :phone_number]}
          }
        }
      end

    end

    def appointment_scheduler_show
      
      if @current_user && @current_user.has_role?(:appointment_scheduler)

        unless @model.has_role?(:patient)
          return false
        end

        if @model.has_any_role?(:admin, :blogger, :appointment_scheduler)
          return false
        end

        true
        
      end

    end

    def appointment_scheduler_update
      if @current_user && @current_user.has_role?(:appointment_scheduler)
        unless @model.has_role?(:patient)
          return false
        end

        if @model.has_any_role?(:admin, :blogger, :appointment_scheduler)
          return false
        end

        @serialize_on_success = 
        {
          only: [:id, :email],
          include: 
          {
            profile: {root: true, only: [:id, :name, :bio, :user_id, :phone_number]}
          }
        }
      end
    end

    def appointment_scheduler_destroy
      if @current_user && @current_user.has_role?(:appointment_scheduler)

        unless @model.has_role?(:patient)
          return false
        end

        if @model.has_any_role?(:admin, :blogger, :appointment_scheduler)
          return false
        end

        true

      end
    end

    def doctors_feed

      if @current_user && @current_user.has_role?(:appointment_scheduler)

        @serialize_on_succes = {only: [:user_id, :name]}
        return true

      end        

    end

    def destroy_unregistered_user_with_proposals
      if @current_user && @current_user.has_any_role?(:admin, :appointment_scheduler)
        return true
      end
    end

    def appointment_scheduler_transform_user_to_registered
      if @current_user && @current_user.has_any_role?(:admin, :appointment_scheduler)
        if @model.has_role?(:patient) && !@model.registered
          true
        end
      end
    end

  end
end