$("body.public").loaded ->
  $("#tabs").attr("data-selected").query().addClass("selected")

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
  $(".vacancies-list tr.entry-header a").live "click", -> $(this).closest('tr').click
  $(".vacancies-list tr.entry-header").live "click", ->
    row = $(this)
    link = row.find('a')

    if row.next().is(".entry-details")
      row.next().find(".entry-outer").slideToggle()
    else
      row.addClass("x-loading")
      $.get link.attr('href'), (html) ->
        details = $(html).insertAfter(row)
        row.removeClass("x-loading").addClass('x-loaded')
        details.addClass('x-loaded')
        details.addClass('alt') if row.hasClass('alt')
        row.find(".spinner").remove()
        details.find(".entry-outer").slideDown()
        
    false

  $("#search-vacancies").submit ->
    form = this
    url = "/vacancies/#{form.city.value}"
    url += '/' + form.industry.value if form.industry.value.present()
    url += '?q=' + encodeURIComponent(form.q.value).replace(/(%20)+/g, '+') if form.q.value.present()
    window.location = url
    false
