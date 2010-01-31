$("body.public").loaded(function() {
  $("#tabs").attr("data-selected").query().addClass("selected")
  $("#links").attr("data-selected").query().addClass("selected")
})

$("body#admin-vacancies").loaded(function() {
  var edited_rows = {}
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
    $.ajax({
      url: "/admin/vacancies/" + id,
      type: 'POST',
      data: row.find(':input').serialize() + "&_method=PUT",
      success: function() { }
    })
    delete edited_rows[id]      
  })
})

$("body#edit-resume").loaded(function() {
  $("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip()
  $("#edit-resume").find("#resume_fname, #resume_lname").requiredField()
})

$("body#vacancies").loaded(function() {
  $(".vacancies-list tr.header").live("click", function() {
    var vacancy_id = this.id
  	var $row = $(this)

  	if ($row.next().is(".desc")) {
  	  $row.next().find(".content").slideToggle()
    } else {
      $row.addClass("loading")
      $.get('/vacancies/' + vacancy_id + '.ajax', function(html) {
        var $desc = $(html).insertAfter($row)
    		$row.removeClass("loading").addClass('loaded')
    		$desc.addClass('loaded')
      	if ($row.hasClass('alt')) {
      		$desc.addClass('alt')
      	}
        $row.find(".spinner").remove()
      	$desc.find(".content").slideDown()
      })
  	}
    return false
  })
  
  $("#vacancies-search-form").submit(function() {
    var form = this
     var url = '/vacancies/' + form.city.value
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
