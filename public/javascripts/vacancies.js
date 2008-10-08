function toggleVacancy(id) {
	id = id.toString()
	if (!rowLoaded(id)) {
		showSpinner(id);
		new Ajax.Updater(id, '/vacancies/' + id + '.ajax', {
			asynchronous:true, evalScripts:true,
			insertion:Insertion.After,
			method:'get',
			onComplete:function(request) {hideSpinner(id); processResult(request, id)}
		});
	}
	return false			
}

function rowLoaded(rid) {
  row = $(rid)
  descRow = $(descriptionRowId(rid))
  if (descRow != null) {
    Effect.toggle($(descriptionDivId(rid)), 'blind')
    return true
  }
  return false
}

function processResult(xhr, rid) {
	if ($(rid).hasClassName('alt')) {
		$(rid).addClassName('alt-active')
		$(descriptionRowId(rid)).addClassName('alt-active')
		$(descriptionRowId(rid)).addClassName('alt-desc-active')				
	} else {
		$(rid).addClassName('active')
		$(descriptionRowId(rid)).addClassName('active')
		$(descriptionRowId(rid)).addClassName('desc-active')
	}
	new Effect.BlindDown($(descriptionDivId(rid)), {duration: 0.5})
}

function showSpinner(rid) {
  baseCell = $(rid).cells[0]
  spinner = document.createElement('span')
  spinner.id = spinnerId(rid)
  spinner.className = 'spinner'
  spinner.innerText = 'загрузка...'
  baseCell.appendChild(spinner)
}

function hideSpinner(rid) {
  baseCell = $(rid).cells[0]
  baseCell.removeChild($(spinnerId(rid)))
}

function spinnerId(rid) { return rid + '-spinner' }
function descriptionRowId(rid) { return rid + '-description' }
function descriptionDivId(rid) { return rid + '-description-content' }