require "controllers/users_controller"
module Components
  module Users

    class SignUp < RW

      include Plugins::Formable
   
      def init
        @controller = UsersController.new(self)
      end


      def get_initial_state
        user = User.new
        user.profile = Profile.new
        {
          form_model: user,
          submitted: false
        }
      end

      def render
        t(:div, {className: "create_user_form row"},
          t(:div, {className: 'thumbnail container'},
            progress_bar,
            if state.submitted
              t(:h3, {}, "Confirmation letter was sent to #{self.state.form_model.email} (NO LETTER WAS SEND USER::ACTIVATABLE == false")
            end,
            input(Forms::Input, state.form_model, :email, {type: "email", show_name: 'email*'}),
            input(Forms::Input, state.form_model.profile, :phone_number, {show_name: 'phone number'}),
            t(:p, {className: 'g-sm-disclaimer'}, 
              'phone number is not reuired for registration, but if you want to book appointment via site you have to provide it. 
               We do not disclose you information to any third parties.'),
            input(Forms::Input, state.form_model, :password, {type: "password", show_name: 'password*'}),
            input(Forms::Input, state.form_model, :password_confirmation, {type: 'password', show_name: 'confirm password*'}),
            t(:br, {} ),
            t(:button, {className: 'btn btn-primary', onClick: ->{controller.handle_signup_submit}}, "create new user")
          )
        )
      end

    end
  end
end