$("body.public").loaded ->
  $("#tabs").attr("data-selected").query().addClass("selected")
  $("#links").attr("data-selected").query().addClass("selected")

$("body#admin-vacancies").loaded ->
  edited_rows = {}
  $("#vacancies .pagination a").live 'click', ->
    $("#vacancies").load(@href)
    false
  
  $("#vacancies tr td.actions .edit").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    edited_rows[id] = row
    $.get "/admin/vacancies/#{id}/edit", (result) ->
      row.replaceWith(result)
  
  $("#vacancies tr td.actions .cancel").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    row.replaceWith(edited_rows[id])
    delete edited_rows[id]      
  
  $("#vacancies tr td.actions .save").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    $.ajax
      url: "/admin/vacancies/#{id}"
      type: 'POST'
      data: row.find(':input').serialize() + "&_method=PUT"
      success: ->
    delete edited_rows[id]

$("body#edit-resume").loaded ->
  $("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip()
  $("#edit-resume").find("#resume_fname, #resume_lname").requiredField()

$("body#vacancies").loaded ->
  $(".vacancies-list tr.header").live "click", ->
    vacancy_id = @id
    $row = $(this)

    if $row.next().is(".desc")
      $row.next().find(".content").slideToggle()
    else
      $row.addClass("loading")
      $.get "/vacancies/#{vacancy_id}.ajax", (html) ->
        $desc = $(html).insertAfter($row)
        $row.removeClass("loading").addClass('loaded')
        $desc.addClass('loaded')
        $desc.addClass('alt') if $row.hasClass('alt')
        $row.find(".spinner").remove()
        $desc.find(".content").slideDown()
        
    false

  $("#vacancies-search-form").submit ->
    form = this
    url = "/vacancies/#{form.city.value}"
    url += '/' + form.industry.value if form.industry.value.present()
    url += '?q=' + encodeURIComponent(form.q.value).replace(/(%20)+/g, '+') if form.q.value.present()
    window.location = url
    false
