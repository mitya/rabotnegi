function Spinner() { return $("<span>").addClass("spinner").text('загрузка...') }

$(function() {
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
})
