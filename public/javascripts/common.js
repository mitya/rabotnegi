Element.addMethods('A', {
  disable:  function(link) {
    link.addClassName('disabled');
    link.disabled = true;
  },
  enable: function(link) {
    link.removeClassName('disabled');
    link.disabled = false;
  },
  observeWhenEnabled: function(link, event, handler) {
    link.observe(event, handler.wrap(function(f, e) { if (!link.disabled) f(e) }))
  }
})

Event.observeWhenEnabled = function(link, event, handler) {
  link = $(link)
  if (link.tagName != 'A')
    throw 'Only links can be observed'
  link.observeWhenEnabled(event, handler)
}

// Returns first Array in argument list.
// If no array found returns last argument extended as array.
function selectArray() {
  return $A(arguments).find(function(a) { return a instanceof Array; }) || $A($A(arguments).last());
}


function newErrorsDiv(id, errors) {
  return Builder.node('div',  {id: id, className: 'error-message'}, [
    Builder.node('h2', 'There was an error'),
      Builder.node('ul', errors.map(function(e) { return Builder.node('li', e) }) )])
}

function showErrors(prevElement, errorsDivId, errors) {
  if ($(errorsDivId)) $(errorsDivId).remove()
  var errorsDiv = newErrorsDiv(errorsDivId, errors)
  $(prevElement).insert({after: errorsDiv})
}
var showLightboxErrors = showErrors.curry('lb-head', 'lb-errors')
var showPageErrors = showErrors.curry('heading', 'errors')

function ajaxRequest(url, method, parameters, activeElements, options) {
    if (options.disable instanceof Array)
      activeElements = options.disable
    var defaults = $H({
      method: method,
      parameters: parameters,
      onCreate: function() { activeElements.invoke('disable'); if($(options.errors)) $(options.errors).remove(); },
      onComplete: function() { activeElements.invoke('enable'); }
    })
    var mergedOptions = defaults.merge($H(options))
    new Ajax.Request(url, mergedOptions.toObject())
}

function parseActionUrl(url) {
   var methodTest = /(get|post|put|delete):(.*)/i.exec(url)
   if (methodTest)
      return {method: methodTest[1], url: methodTest[2]}
    else
      return {method: 'GET', url: url}
}

function AjaxForm(form, options) {
  Event.observe(form, 'submit', function(e) {
    ajaxRequest(this.action, this.method, this.serialize(), [this], options)
    e.stop()
  })
}


function AjaxLink(link, options) {
  Event.observeWhenEnabled(link, 'click', function(e) {
    var action = parseActionUrl(this.href)
    ajaxRequest(action.url, action.method, null, [this], options)
    e.stop()
  })
}

// Link which invokes server-side action
function ActionLink(link) {
  Event.observeWhenEnabled(link, 'click', function(e) {
    e.stop()
    var action = parseActionUrl(this.href)
    var form = new Element('form', {action: action.url, method: action.method})
    document.body.insert(form)
    form.submit()
  })
}

// Link which executes client-side code
function CommandLink(link, command) {
  Event.observeWhenEnabled(link, 'click', function(e) {
    command()
    e.stop()
  })
}

jQuery.fn.extend({
  self: function() {
    return this.get(0)
  },
  dump: function() {
    console.debug(this.get())
    return this
  },
  loaded: function(fn) {
    if (this.length > 0)
      q(fn)
    return this
  },
  record_id: function() {
    return this.attr('id').match(/\d+/)[0]
  }
})
