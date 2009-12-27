var q = jQuery.noConflict()

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

q.fn.extend({
  tooltip: function() {
    this.each(function() {
      var $input = q(this)
      var tip = $input.attr('title')

      if ($input.val().blank())
        $input.addClass('inner-tooltip').val(tip)
      
      $input.focus(function() {
        if ($input.val() == tip)
          $input.removeClass('inner-tooltip').val('')
      }).blur(function() {
        if ($input.val().blank())
          $input.addClass('inner-tooltip').val(tip)
      })
      
      $input.closest('form').submit(function() {
        if ($input.val() == tip)
          $input.val('')
      })
    })
  }
})

q(function() {
  q("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip()
})
