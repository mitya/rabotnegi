$("body.public").loaded(function() {
  $("#tab-bar").attr("data-selected-tab").query().addClass("selected-tab")
  $("#nav-bar").attr("data-selected-link").query().addClass("selected")
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
      $row.find("td:first").append(new Spinner())
      $.get('/vacancies/' + vacancy_id + '.ajax', function(html) {
        var $desc = $(html).insertAfter($row)
      	if ($row.hasClass('alt')) {
      		$row.addClass('alt-active')
      		$desc.addClass('alt-active').addClass('alt-desc-active')
      	} else {
      		$row.addClass('active')
      		$desc.addClass('active').addClass('desc-active')
      	}
        $row.find(".spinner").remove()
      	$desc.find(".content").slideDown()
      })
  	}
    return false
  })
  
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
