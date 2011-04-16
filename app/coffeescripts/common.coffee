$.extend String.prototype,
  evalJSON: () -> 
    eval("(" + @ + ")")
  unescapeHTML: () ->
    @replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&')
  modelId: () ->
    digitsFound = @match(/\d+/)
    digitsFound && digitsFound[0]
  blank: () -> 
    /^\s*$/.test(@)
  present: () -> 
    !@blank() 
  trim: () -> 
    $.trim(@)
  query: () -> 
    $(@toString())

jQuery.extend
  initializers: {}

jQuery.fn.extend
  self: () ->
    @get(0)
  dump: () ->
    @
  loaded: (fn) ->
    $.initializers[@selector] ?= []
    $.initializers[@selector].push(fn)
    @
  record_id:  () ->
    @attr('id').match(/\d+/)[0]
  requiredField:  () ->
    @each () ->
      input = $(@)
      tip = input.attr('title')

      input.blur () ->
        if input.val().present() && input.val() != tip
          input.removeClass('required-field')
        else
          input.addClass('required-field')
  tooltip: () ->
    @each () ->
      input = $(@)
      tip = input.attr('title')

      input.addClass('inner-tooltip').val(tip) if input.val().blank()

      input.focus () ->
        input.removeClass('inner-tooltip').val('') if input.val() == tip
      input.blur () ->
        input.addClass('inner-tooltip').val(tip) if input.val().blank()
      input.closest('form').submit () -> 
        input.val('') if input.val() == tip

Spinner = () -> 
  $("<span>").addClass("spinner").text('загрузка...')

$ () -> 
  for selector, initializers of $.initializers
    fn() for fn in initializers
