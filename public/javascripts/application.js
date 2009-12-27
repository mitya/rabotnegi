var q = jQuery.noConflict()

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
  requiredField: function() {
    this.each(function() {
      var $input = q(this)
      var tip = $input.attr('title')      

      $input.blur(function() {
        console.debug($input.val())
        if ($input.val().present() && $input.val() != tip) {
          $input.removeClass('required-field')
        } else {
          $input.addClass('required-field')
        }
      })      
    })    
  },
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
  q("#edit-resume").find("#resume_fname, #resume_lname").requiredField()
  
  q("#vacancies-search-form form:first").submit(function() {
    var form = this
     var url = form.action + '/' + form.city.value
     if (form.industry.value.present()) {
       url += '/' + form.industry.value
     }   
     if (form.q.value.present()) {
       url += '?q=' + encodeURIComponent(form.q.value).replace(/(%20)+/g, '+')
     }
     window.location = url
     return false
  })
})
