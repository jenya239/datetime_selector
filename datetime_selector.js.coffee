window.j = {} unless window.j
j = window.j
j.view = {} unless j.view
j.view.Datetime_Selector = Class.create()
Object.extend j.view.Datetime_Selector,
	_instance: null #?
j.view.Datetime_Selector.addMethods
	_container: null
	_close: null
	_years: null
	_months: null
	_days: null
	_hours: null
	_colon: null
	_mins: null
	_selected_year: null
	_selected_month: null
	_selected_day: null
	_selected_hour: null
	_selected_min: null
	_input: null
	_mode: null
	_format: null
	initialize: () ->
		throw 'singleton' if j.view.Datetime_Selector._instance
		j.view.Datetime_Selector._instance = this
		@_close = null
		@_selected_year = 2009
		@_selected_month = 4 #0 - январь
		@_selected_day = 19
		@_selected_hour = 13
		@_selected_min = 10
		@_years = null
		@_months = null
		@_days = null
		@_hours = null
		@_colon = null
		@_mins = null
		@_input = null
		@_mode = 'datetime'
		@_format = 
			datetime: 'yyyy.MM.dd HH:mm'
			date: 'yyyy.MM.dd'
			time: 'HH:mm'
		@_build()
		@_container.hide();
		$( document.body ).insert @_container
	_build: () ->
		@_container = new Element 'div', { id: 'datetime_selector' }
		@_container.insert @_close = new Element( 'div', { 'class': 'close_button' } ).update 'закрыть'
		@_close.on 'click', ( e ) => @_container.fade( { duration: 0.4 } )
		@_container.insert @_years = new Element 'div', { class: 'years', style: 'width: 220px; left: 10px; top: 12px;' }
		today = Date.today()
		for year in [2006..2019]
			@_years.insert ye = (new Element 'span', { 'class': 'year_button' }).update year
			ye.addClassName 'year_button_selected' if year == @_selected_year
			ye.addClassName 'today' if year == today.getFullYear()
			ye.on 'click', (( year, event ) =>
				@_selected_year = year
				el.removeClassName 'year_button_selected' for el in @_years.select '.year_button'
				event.target.addClassName 'year_button_selected'
				@_render_days @_selected_year, @_selected_month
				@_send_value()
			).curry year
			@_years.insert '<br/>' if year == 2012
		@_container.insert @_months = new Element 'div', { class: 'months', style: 'width: 220px; left: 10px; top: 50px;' }
		for month, i in 'янв фев мар апр май июнь июль авг сен окт ноя дек'.split ' '
			@_months.insert me = (new Element 'span', { 'class': 'year_button' }).update month
			me.addClassName 'year_button_selected' if i == @_selected_month
			me.addClassName 'today' if i == today.getMonth()
			me.on 'click', (( month, event ) =>
				@_selected_month = month
				el.removeClassName 'year_button_selected' for el in @_months.select '.year_button'
				event.target.addClassName 'year_button_selected'
				@_render_days @_selected_year, @_selected_month
				@_send_value()
			).curry i
			@_months.insert '<br/>' if i == 5
		@_container.insert @_days = new Element 'div',
			class: 'days'
			style: 'width: 220px; left: 10px; top: 85px;'
		@_render_days @_selected_year, @_selected_month
		@_days.on 'click', 'div.date', ( event ) =>
			return if event.target.hasClassName 'other_month'
			@_selected_day = parseInt event.target.innerHTML
			el.removeClassName 'selected' for el in @_days.select 'div.date'
			event.target.addClassName 'selected'
			@_send_value()
		now = new Date()
		@_container.insert @_hours = new Element 'div', { class: 'hours', style: 'width: 50px; right: 40px; top: 33px;' }
		for hour in [0..23]
			@_hours.insert hd = new Element 'div',
				style: "width: 16px; height: 15px; left: #{ Math.floor( hour / 12 ) * 25 }px; top: #{ ( hour % 12 ) * 15 }px;"
			hd.update hour
			hd.addClassName 'selected' if hour == @_selected_hour
			hd.addClassName 'now' if hour == now.getHours()
			hd.on 'click', (( hour, event ) =>
				@_selected_hour = hour
				el.removeClassName 'selected' for el in @_hours.select 'div'
				event.target.addClassName 'selected'
				@_send_value()
			).curry hour
		@_container.insert @_colon = new Element( 'div', { class: 'colon', style: 'right: 28px; top: 100px;' } ).update ':'
		@_container.insert @_mins = new Element 'div', { class: 'mins', style: 'width: 20px; right: 10px; top: 33px;' }
		for min in [0..11]
			@_mins.insert md = new Element 'div', { style: "width: 20px; height: 15px; left: 0px; top: #{ min * 15 }px;" }
			md.update ( if min < 2 then '0' else '' )+min*5
			md.addClassName 'selected' if min == Math.round( @_selected_min / 5 )
			md.addClassName 'now' if min == Math.round( now.getMinutes() / 5 )
			md.on 'click', (( min, event ) =>
				@_selected_min = min
				el.removeClassName 'selected' for el in @_mins.select 'div'
				event.target.addClassName 'selected'
				@_send_value()
			).curry min*5
	input_handler: ( event ) ->
		@_input = $ event.target
		offset = @_input.cumulativeOffset()
		@_container.setStyle
			left: ( offset.left ) + 'px'
			top: ( offset.top + @_input.getHeight() - 4 ) + 'px'
		if @_input.hasClassName 'mode_date'
			@set_mode 'date'
		else if @_input.hasClassName 'mode_time'
			@set_mode 'time'
		else
			@set_mode 'datetime'
		@_receive_value()
		@_container.appear( { duration: 0.4 } )
	_render_days: ( year, month ) ->
		@_days.update ''
		width = 20; height = 18
		horizontal_gap = 10; vertical_gap = 2
		row = 0
		for wday, i in 'пн вт ср чт пт сб вс'.split ' '
			left = ( width + horizontal_gap ) * i
			top = 0
			@_days.insert hd = new Element 'div',
				class: 'header'
				style: "width: #{ width }px; height: #{ height-6 }px; left: #{ left }px; top: #{ top }px;"
			hd.update wday
		today = Date.today()
		day = ( new Date( year, month, 1, 1 ) ).last().monday()
		while j.Calendar.date_before_or_in day, year, month
			row += 1
			for wday, i in 'пн вт ср чт пт сб вс'.split ' '
				left = ( width + horizontal_gap ) * i
				top = ( height + vertical_gap ) * row
				classes = 'date '
				classes += 'today ' if j.Utils.dates_equal day, today
				classes += 'other_month ' unless day.getMonth() == month
				classes += 'selected ' if day.getFullYear() == year && day.getMonth() == month && day.getDate() == @_selected_day
				classes += 'dayoff ' if wday == 5 || wday == 6
				@_days.insert dd = new Element 'div',
					class: classes
					style: "width: #{ width }px; height: #{ height }px; left: #{ left }px; top: #{ top }px;"
				dd.update day.getDate()
				day.addDays 1
	_set_date: ( date ) ->
		@_selected_year = date.getFullYear()
		@_selected_month = date.getMonth()
		@_selected_day = date.getDate()
		@_selected_hour = date.getHours()
		@_selected_min = date.getMinutes()
		(if parseInt( el.innerHTML ) == @_selected_year then el.addClassName 'year_button_selected' else el.removeClassName 'year_button_selected') for el in @_years.select '.year_button'
		(if el.innerHTML.trim() == 'янв фев мар апр май июнь июль авг сен окт ноя дек'.split( ' ' )[ @_selected_month ] then el.addClassName 'year_button_selected' else el.removeClassName 'year_button_selected')for el in @_months.select '.year_button'
		(if parseInt( el.childNodes[0].innerHTML ) == @_selected_day  && not el.hasClassName( 'other_month' ) then el.addClassName 'selected' else el.removeClassName 'selected') for el in @_days.select 'td'
		(if parseInt( el.innerHTML ) == @_selected_hour then el.addClassName 'selected' else el.removeClassName 'selected') for el in @_hours.select 'div'
		(if parseInt( el.innerHTML ) == Math.round( @_selected_min / 5 ) * 5 then el.addClassName 'selected' else el.removeClassName 'selected') for el in @_mins.select 'div'
	set_format: ( datetime, date, time ) ->
		@_format =
			datetime: datetime
			date: date
			time: time
		@_send_value()
	_format_string: () ->
		switch @_mode 
			when 'datetime' then @_format.datetime
			when 'date' then @_format.date
			when 'time' then @_format.time
	_receive_value: () ->
		return unless @_input
		date = Date.parseExact @_input.getValue(), @_format_string()
		if date
			@_set_date date
		else
			@_set_date new Date()
	_send_value: () ->
		return unless @_input
		@_input.setValue ( new Date @_selected_year, @_selected_month, @_selected_day, @_selected_hour, @_selected_min ).toString @_format_string()
	set_mode: ( mode ) ->
		switch mode
			when @_mode then return
			when 'datetime'
				@_mode = mode
				@_container.setStyle "width: 310px;"
				@_years.show()
				@_months.show()
				@_days.show()
				@_hours.show()
				@_colon.show()
				@_mins.show()
			when 'date'
				@_mode = mode
				@_container.setStyle "width: 310px;"
				@_years.show()
				@_months.show()
				@_days.show()
				@_hours.hide()
				@_colon.hide()
				@_mins.hide()
			when 'time'
				@_mode = mode
				@_container.setStyle "width: 84px;"
				@_years.hide()
				@_months.hide()
				@_days.hide()
				@_hours.show()
				@_colon.show()
				@_mins.show()
			else throw 'incorrect mode'


