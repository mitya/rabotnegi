$(function() {
  var edited_rows = {}
  $('#admin_vacancies').loaded(function() {
    $("#vacancies .pagination a").live('click', function() {
      $("#vacancies").load(this.href)
      return false
    })
    $("#vacancies tr td.actions .edit").live('click', function() {
      var row = $(this).closest('tr'), id = row.record_id()
      edited_rows[id] = row
      $.get("/admin/vacancies/" + id + '/edit', function(result) {
        row.replaceWith(result)
      })
    })
    $("#vacancies tr td.actions .cancel").live('click', function() {
      var row = $(this).closest('tr'), id = row.record_id()
      row.replaceWith(edited_rows[id])
      delete edited_rows[id]      
    })
    $("#vacancies tr td.actions .save").live('click', function() {
      var row = $(this).closest('tr'), id = row.record_id()
      console.debug(row.find(':input').serialize())
      $.ajax({
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

$(function() {
  $("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip()
  $("#edit-resume").find("#resume_fname, #resume_lname").requiredField()
  
  $("#vacancies-search-form form:first").submit(function() {
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
