module Components
  module AppointmentSchedulers
    module Users
      class Show < RW
        expose

        def validate_props
          if !props.user_id
            p "#{self.class}#{self} props.user_id is required"
          end
          if props.user_id.is_a?(String) && props.user_id.to_i == 0
            p "#{self.class}#{self} props.user_id was provided but is not numeric"
          end
        end

        def get_initial_state
          {
            user: false
          }
        end

        def component_did_mount
          User.show(namespace: 'appointment_scheduler', wilds: {id: props.user_id}, component: self).then do |user|
            begin
            set_state user: user
            rescue Exception => e
              p e
            end
          end
        end

        def render
          t(:div, {className: 'user_show appointment_scheduler'},
            modal,
            progress_bar,
            if state.user
              t(:div, {},
                t(:h1, {},
                  state.user.profile.try(:name)
                ),
                if state.user.attributes[:registered]
                  t(:p, {}, 'registered user')
                else
                  t(:p, {}, 'unregistered user')
                end,
                t(:div, {className: 'contacts'},
                  t(:p, {},
                    "email: #{state.user.try(:email)}"
                  ),
                  t(:p, {},
                    "phone number: #{state.user.profile.try(:phone_number)}"
                  )
                ),
                t(:div, {className: 'roles'},
                  *splat_each(state.user.roles) do |role|
                    t(:p, {}, role.attributes[:name])
                  end
                ),
                t(:button, {onClick: ->{init_appointment_scheduling}}, 'schedule appointment for this user'),
                t(:button, {onClick: ->{init_edit(state.user)}}, 'edit this user'),
                t(:button, {onClick: ->{delete_selected_as_appointment_scheduler(state.user)}}, 'delete this user')
              )
            end
          )
        end

      #DELITING USER
        def delete_selected_as_appointment_scheduler(_user)
          _user.destroy(namespace: 'appointment_scheduler', component: self).then do |user|
            create_flash('user was deleted')
            set_state user: false
          end
        end
      #END DELETING USER

      #EDITING USER
        def init_edit(user)
          modal_open(
            'edit user',
            t(Components::AppointmentSchedulers::Users::Edit, {user: user, on_user_updated: event(->(_user){on_user_updated(_user)})})
          )
        end

        def on_user_updated(user)
          
        end
      #END EDITING USER
      #APPOINTMENTSCHEDULING
        def init_appointment_scheduling
          p 'init_appointment_scheduling'
          modal_open(
            'schedule appointment',
            t(Components::Appointments::AppointmentSchedulers::Index, {from_show: true, init_appointments_new: ProcEvent.new(->(date){init_appointments_new(date)})})
          )
        end

        def init_appointments_new(date)
          p 'initing init_appointments_new'
          modal_close
          modal_open(
            'schedule appointment',
            t(Components::Appointments::Doctors::New, {date: date, patient_id: props.user_id, on_appointment_created: ProcEvent.new(->(appointment){on_appointment_created(appointment)})})
          )
        end

        def on_appointment_created(appointment)
          create_flash 'appointment created'
          modal_close
        end
      #END APPOINTMENT SCHEDULING


      end
    end
  end
end