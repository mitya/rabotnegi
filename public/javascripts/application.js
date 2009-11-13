Vacancies = {
	prepare: function(form) {
		var city = form.city.value
		var industry = form.industry.value
		var url = form.action + '/' + city + '/' + industry
		if (form.q.value != '') {
			q = form.q.value
			q = q.replace(' ', '+')
			url += '?q=' + encodeURI(q)
		}
		window.location = url
		return false
	}
}

// Изначально подсказка хранится в аттрибуте title.
TooltipControlExtender = Class.create()
TooltipControlExtender.cssClassName = 'inner-tooltip'
TooltipControlExtender.prototype = {
	// control: HtmlInputElement | HtmlTextAreaElement
	initialize: function(control) {
		this.control = control
		this.control.observe('focus', this.onFocus.bindAsEventListener(this))
		this.control.observe('blur', this.onBlur.bindAsEventListener(this))
		$(this.control.form).observe('submit', this.onSubmit.bindAsEventListener(this))
		this.onInit()
	},
	onInit: function() {
		if (this.controlHasContent())
			this.resetStyle()
		else {
			this.showTooltip()
			this.setStyle() 
		}
	},
	onFocus: function() {
		if (this.tooltipIsShown()) {
			this.resetStyle()
			this.hideTooltip()
		}
	},
	onBlur: function() {
		if (this.controlHasContent())
			this.resetStyle()
		else {
			this.showTooltip()
			this.setStyle()
		}
	},
	onSubmit: function() {
		if (this.tooltipIsShown())
			this.hideTooltip()
	},
	controlHasContent: function() { return !this.control.value.match(/^\s*$/) },
	hideTooltip: function() { this.control.value = '' },
	showTooltip: function() { this.control.value = this.control.title },
	tooltipIsShown: function() { return this.control.value == this.control.title },
	resetStyle: function() { this.control.removeClassName(TooltipControlExtender.cssClassName) },
	setStyle: function() { this.control.addClassName(TooltipControlExtender.cssClassName) }
}


RequiredFieldExtender = Class.create()
RequiredFieldExtender.cssClassName = 'required-field'
RequiredFieldExtender.prototype = {
	initialize: function(control) {
		this.control = control
		this.control.observe('blur', this.onBlur.bindAsEventListener(this))
		this.onInit()
	},
	onInit: function() {
		if (this.hasContent())
			this.resetStyle()
	},
	onBlur: function() {
		if (this.hasContent())
			this.resetStyle()
		else
			this.setStyle()
	},
	hasContent: function() { return !this.control.value.match(/^\s*$/) && this.control.value != this.control.title },
	resetStyle: function() { this.control.removeClassName(this.klass.cssClassName) },
	setStyle: function() { this.control.addClassName(this.klass.cssClassName) },
	klass: RequiredFieldExtender
}

Element.addMethods(['INPUT', 'TEXTAREA'], {
	makeTooltip: function(self) { new TooltipControlExtender(self) }
})

q(function() {
  var edited_rows = {}
  q('#admin_vacancies').loaded(function() {
    q("#vacancies .pagination a").live('click', function() {
      q("#vacancies").load(this.href)
      return false
    })
    q("#vacancies tr td.actions .edit").live('click', function() {
      var row = q(this).closest('tr'), id = row.record_id()
      edited_rows[id] = row
      q.get("/admin/vacancies/" + id + '/edit', function(result) {
        row.replaceWith(result)
      })
    })
    q("#vacancies tr td.actions .cancel").live('click', function() {
      var row = q(this).closest('tr'), id = row.record_id()
      row.replaceWith(edited_rows[id])
      delete edited_rows[id]      
    })
    q("#vacancies tr td.actions .save").live('click', function() {
      var row = q(this).closest('tr'), id = row.record_id()
      console.debug(row.find(':input').serialize())
      q.ajax({
        url: "/admin/vacancies/" + id,
        type: 'POST',
        data: row.find(':input').serialize() + "&_method=PUT",
        success: function() {
          console.debug(1)
        }
      })
      delete edited_rows[id]      
    })
  })
})
