module Components
  module Appointments
    class Index < RW
      expose

      def self.wdays
        ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
      end

      def get_initial_state
        {
          date: Moment.new.startOf('day'),
          current_controll_component: Native(:div, {}).to_n,
          current_view: "week"
        }
      end

      def component_did_mount
        Services::MetaTagsController.new('chedule an appointment')
        init_week_view
      end  

      def render
        t(:div, {className: 'appointments_calendar row'},
          modal,
          #t(MonthBox, {date: state.date, ref: 'month_box', index: self}),
          t(:h2, {className: 'view_title_date'}, "#{state.date.month() + 1}.#{state.date.year()}"),
          t(:div, {className: 'view_controlls'},
            #t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_month_view}}, "month"),
            t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_week_view(state.date.clone())}}, "week"),
            t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_day_view(state.date.clone())}}, "day"),
            t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{set_state date: Moment.new}}, "go to today"),
          ),
          t(:div, {},
            state.current_controll_component.to_n
          )
        )
      end

      def init_week_view
        state.current_view = "week"
        set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}))}
      end

      # def init_month_view
      #   state.current_view = "month"
      #   set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}))}
      # end

      def init_day_view(day)
        state.current_view = "day"
        state.date = day
        set_state date: state.date,current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}))}, current_view: "day"
      end

      def current_view
        self.ref(state.current_view).rb
      end

      def build_availabilities(appointments, date)
        appointments.unshift Appointment.new(start_date: Moment.new(date).set(hour: 9).format('YYYY-MM-DD:HH:mm'), end_date: Moment.new(date).set(hour: 9).format('YYYY-MM-DD:HH:mm'))
        appointments.push Appointment.new(start_date: Moment.new(date).set(hour: 19).format('YYYY-MM-DD:HH:mm'), end_date: Moment.new(date).set(hour: 19).format('YYYY-MM-DD:HH:mm'))
        appointments.sort! do |a,b|
          Moment.new(a.start_date).format('YYYY-MM-DD:HH:mm') <=> Moment.new(b.start_date).format('YYYY-MM-DD:HH:mm')
        end
        i = 0
        a_l = appointments.length
        aps = appointments
        av_map = []  
        while i < (a_l - 1)
          last_end = Moment.new(aps[i].end_date)
          next_start = Moment.new(aps[i+1].start_date)
          x = next_start.diff(last_end, 'minutes')
          if next_start.diff(last_end, 'minutes') > 10
            av_map << [last_end, next_start] 
          end 
          i += 1
        end
        AppointmentAvailability.new(map: av_map)
      end

      #method is used and coupled to Week Month WeekDay
      #called from there by accessing through props.index, so self should be passed as index prop
      def fetch_appointments(obj, t_d)
        (z = obj.state.appointments_for_dates[t_d]) ? z : {}
      end

      def prepare_availability_tree(obj, users_with_appointments)
        tree_block = lambda{|h,k| 
          if k[4] == "-"
            h[k] = Hash.new(&tree_block)
          else
            h[k] = []
          end 
        }
        opts = Hash.new(&tree_block)
        user_accessor = {}
        users_with_appointments.each do |user|
          user_accessor[user.id] = user
          user.appointments.each do |appointment|
            opts[Moment.new(appointment.start_date).format('YYYY-MM-DD')][user.id] << appointment 
          end
        end
        opts.each do |date, user_and_apps|
          user_and_apps.each do |user_id, appointments_array|
            user_and_apps[user_id] = self.build_availabilities(appointments_array, date)
          end
        end
        obj.set_state appointments_for_dates: opts, user_accessor: user_accessor

      end

    end

    class MonthBox < RW

      expose

      def prepare_dates
        @cur_month = props.date.clone().startOf("month")
        @first_wday = @cur_month.day()
        @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
        @current_week_num = `Math.ceil(#{props.date.diff(@track_day, 'days')} / 7)`
      end
      
      def render
        prepare_dates
        today = props.date.format('YYYY-MM-DD')     
        t(:div, {},
          t(:div, {className: "month_box"},
            t(:div, {className: "row week_row"},
              *splat_each(Services::Calendar.wdays) do |wday_name| 
                  t(:div, {className: "day"}, wday_name)
              end,
            ),
            *splat_each(0..5) do |week_num|
              if week_num + 1 == @current_week_num
                is_current = 'current_week'
              else
                is_current = ''
              end
              t_d = (@track_day).clone
              t(:div, {className: "row week_row #{is_current}"},
                *splat_each(0..6) do |d|
                  t_d_a = (@track_day.add(1, 'days')).clone()
                  is_today = (t_d_a.format('YYYY-MM-DD') == today) ? 'today' : ''
                  t(:div, {className: "day #{is_today}", onClick: ->{set_date(t_d_a)}}, 
                    t(:div, {},
                      t(:span, {}, @track_day.date())
                    )
                  )
                end
              )
            end   
          )
        )
      end

      def set_date(date)
        props.index.set_state date: date
      end

      def prev_month 
        props.index.set_state date: (@date = props.index.state.date.subtract(1, "month"))
        component_did_mount
      end

      def next_month
        props.index.set_state date: (@date = props.index.state.date.add(1, "month"))
        component_did_mount
      end

    end

    # class  Month < RW
    #   expose

    #   def prepare_dates
    #     @cur_month = props.date.clone().startOf("month")
    #     @first_wday = @cur_month.day()
    #     @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
    #   end

    #   def queries(date)
    #     date = date.clone()
    #     date.startOf("month")
    #     date = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : date 
    #     wd = date.day() + 1
    #     x = {}
    #     z = date.subtract((wd), "days")
    #     x[:to] = z.clone().add(weeks: 6, days: 1).format('YYYY-MM-DD')
    #     x[:from] = z.format('YYYY-MM-DD')
    #     x
    #   end

    #   def get_initial_state
    #     @date = props.date
    #     {
    #       appointment_availabilities: {}
    #     }
    #   end

    #   def component_did_mount
    #     AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
    #       props.index.prepare_availability_tree(self, users)
    #     end
    #   end
      
    #   def render
    #     prepare_dates     
    #     t(:div, {},
    #       spinner,
    #       t(:button, {onClick: ->{prev_month}}, "<"),
    #       t(:button, {onClick: ->{next_month}}, ">"),
    #       t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
    #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
    #           *splat_each(Services::Calendar.wdays) do |wday_name| 
    #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n}, wday_name)
    #           end,
    #         ),
    #         *splat_each(0..5) do |week_num|
    #           t_d = (@track_day).clone
    #           t(:div, {className: "row", style: {display: "table-row"}.to_n},
    #             t(:div, {},
    #               *splat_each(0..6) do |d|
    #                 t_d_a = (@track_day.add(1, 'days')).clone()
    #                 t(:div, {className: "col-lg-1", style: {"height" => "12em", display: "table-cell", width: "12%", overflow: "scroll"}.to_n}, 
    #                   t(:div, {},
    #                     t(:span, {}, @track_day.date())
    #                   ),
    #                   t(:div, {},
    #                     *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |k, v|
    #                       t(:span, {},
    #                         "#{k}",
    #                         t(:br, {}),
    #                         *splat_each(v[0].map) do |av|
    #                           t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
    #                         end,
    #                         "------------",
    #                         t(:br, {})

    #                       )
    #                     end
    #                   )             
    #                 )
    #               end
    #             )
    #           )
    #         end   
    #       )
    #     )
    #   end

    #   def prev_month 
    #     props.index.set_state date: (@date = props.index.state.date.subtract(1, "month"))
    #     component_did_mount
    #   end

    #   def next_month
    #     props.index.set_state date: (@date = props.index.state.date.add(1, "month"))
    #     component_did_mount
    #   end
    # end

    class Week < RW
      expose

      def queries(date)
        z = date.clone().startOf("week")
        z = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : z 
        x = {}
        x[:from] = z.format('YYYY-MM-DD')
        x[:to] = z.clone().endOf('week').format('YYYY-MM-DD')
        x
      end

      def get_initial_state
        {
          #appointment_availabilities: {}
          appointments_for_dates: {}
        }
      end

      def component_did_mount

        Appointment.availabilities_index(component: self, payload: queries(props.date)).then do |users_with_appointments|
          begin
          props.index.prepare_availability_tree(self, users_with_appointments)
          rescue Exception => e
            p e
          end
        end
        # return
        # AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
        #   props.index.prepare_availability_tree(self, users)
        # end
      end

      def component_did_update(prev_props, prev_state)
        if props.date.format != prev_props.date.format
          component_did_mount
        end     
      end

      def render
        passed_day = ''
        current_day = Moment.new
        t_d = @track_day = props.date.clone().startOf('week').subtract(1, 'days')
        t(:div, {},
          progress_bar,
          t(:div, {className: 'row'},
            t(:div, {className: 'col-lg-4'},
              t(MonthBox, {date: props.date, index: props.index})
            ),
            t(:div, {className: 'prev_next_controlls col-lg-8'}, 
              t(:button, {onClick: ->{prev_week}}, "<"),
              t(:button, {onClick: ->{next_week}}, ">"),
            ),
          ),
          t(:div, {className: 'row'},
            modal, 
            *splat_each(0..6) do |d|

              t_d_a = (@track_day.add(1, 'days')).clone()

              if @track_day.format('YYYY-MM-DD') < current_day.format('YYYY-MM-DD')
                passed_day = 'passed'
              elsif @track_day.format('YYYY-MM-DD') == current_day.format('YYYY-MM-DD')
                passed_day = 'today'
              else
                passed_day = 'not_passed'
              end

              if @track_day.isoWeekday == 7
                week_end = true  
              end
              
              if passed_day != 'passed'
                go_to_day_event = {onClick: ->{props.index.init_day_view(t_d_a)}}
              else
                go_to_day_event = {}
              end

              t(:div, {className: "col-lg-1 week_day_panel #{$DISPLAY_SIZE}"},
                t(:div, {className: "day_heading #{passed_day}"}.merge(go_to_day_event), 
                  t(:h4, {className: 'wday_name'}, 
                    Services::Calendar.wdays[d]
                  ),
                  t(:p, {}, @track_day.date())
                ),
                if passed_day == 'passed' || week_end
                  t(:div, {})
                else

                  fetched_appointments = props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))

                  t(:div, {className: "day_body"},
                    t(:button, {className: 'init_appointment_btn btn btn-success center-block', onClick: ->{init_appointments_proposals_new(t_d_a)}},
                      'book appointment for this day'
                    ),
                    *if fetched_appointments.empty?
                      t(:p, {className: 'any_time_appointment'}, 'there are appointments available any time with any doctor for this day')
                    else
                      splat_each(fetched_appointments) do |user_id, appointment_availability|

                        t(:div, {className: 'appointments_for_doctor'},
                          t(:img, {src: "#{state.user_accessor[user_id].avatar.url}", className: 'doctor_avatar'}),
                          t(:span, {className: 'doctor_name'}, 
                            "#{state.user_accessor[user_id].profile.name}"
                          ),
                          t(:br, {}),
                          *splat_each(appointment_availability.map) do |av|
                            t(:p, {className: 'doctor_appointment'}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                          end,
                          t(:br, {})
                        )
                      end                     
                    end
                  )
                end
              )
            end
          )
        )
      end

      def init_appointments_proposals_new(date)
        modal_open(
          "book an appointment",
          t(Components::Appointments::Proposals::New, {date: date, appointment_availabilities: props.index.fetch_appointments(self, date.clone.format("YYYY-MM-DD")), user_accessor: state.user_accessor, on_appointment_proposal_created: event(->{modal_close})})
        )
      end

      def prev_week 
        props.index.set_state date: (props.index.state.date.subtract(7, 'days')) 
        component_did_mount
      end

      def next_week
        props.index.set_state date: (props.index.state.date.add(7, 'days'))
        component_did_mount
      end
      
    end

    class WeekDay < RW
      expose
      #date: the moment the state is on

      def get_initial_state
        {
          appointments_for_dates: {}
        }
      end

      def component_did_mount
        Appointment.availabilities_index(component: self, payload: {from: props.date.format('YYYY-MM-DD'), to: props.date.clone.add(1, 'days').format('YYYY-MM-DD')}).then do |users_with_appointments|
          begin
          props.index.prepare_availability_tree(self, users_with_appointments)
          rescue Exception => e
            p e
          end
        end
      end

      def component_did_update(prev_props, prev_state)
        if props.date.format != prev_props.date.format
          component_did_mount
        end     
      end

      def render
        fetched_appointments = props.index.fetch_appointments(self, props.date.format("YYYY-MM-DD"))
        t(:div, {className: "row "},
          spinner,
          modal,
          t(:div, {className: "col-lg-3"},
            t(MonthBox, {date: props.date, index: props.index})
          ),
          t(:div, {className: "col-lg-6 day_panel"},
            t(:div, {className: 'prev_next_controlls'},
              t(:button, {onClick: ->{prev_day}}, "<"),
              t(:button, {onClick: ->{next_day}}, ">"),
            ),
            t(:div, {className: "day_heading"}, 
              t(:h4, {className: 'wday_name'}, 
                Services::Calendar.wdays[props.date.day()]
              ),
              t(:p, {}, props.date.format('DD'))
            ),
            t(:div, {className: "day_body"},
              t(:button, {className: 'init_appointment_btn btn btn-success center-block', onClick: ->{init_appointments_proposals_new(props.date)}},
                'book appointment for this day'
              ),
              *if fetched_appointments.empty?
                t(:p, {className: 'any_time_appointment'}, 'there are appointments available for any doctor at any time for this day')
              else
                
                splat_each(fetched_appointments) do |k, v|
                  t(:div, {className: 'appointments_for_doctor'},
                    t(:img, {src: "#{state.user_accessor[k].avatar.url}", className: 'doctor_avatar'}),
                    t(:span, {className: 'doctor_name'}, 
                      "#{state.user_accessor[k].profile.name}"
                    ),
                    t(:p, {}, "appointments for this doctor available in these time windows"),
                    t(:br, {}),
                    *splat_each(v.map) do |av|
                      t(:p, {className: 'doctor_appointment'}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                    end,
                    t(:br, {})
                  )
                end
                
              end
            )
          ),
          t(:div, {className: 'col-lg-3'})
        )
      end  

      def init_appointments_proposals_new(date)
        modal_open(
          "book an appointment",
          t(Components::Appointments::Proposals::New, {date: date, appointment_availabilities: props.index.fetch_appointments(self, date.clone.format("YYYY-MM-DD")), user_accessor: state.user_accessor, on_appointment_proposal_created: event(->{modal_close})})
        )
      end

      def prev_day
        props.index.set_state date: (props.index.state.date.subtract(1, 'day'))
        component_did_mount
      end

      def next_day
        props.index.set_state date: (props.index.state.date.add(1, 'day'))
        component_did_mount
      end

    end
  end
end

