$.extend(String.prototype, {
  evalJSON: function() {
    return eval("(" + this + ")")
  },
  unescapeHTML: function() {
    return this.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&')
  },
  modelId: function() {
    var digitsFound = this.match(/\d+/)
    return digitsFound && digitsFound[0]
  },
  blank: function() {
    return /^\s*$/.test(this)
  },
  present: function() {
    return !this.blank()
  },
  trim: function() {
    return $.trim(this)
  }
})

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
      $(fn)
    return this
  },
  record_id: function() {
    return this.attr('id').match(/\d+/)[0]
  },
  requiredField: function() {
    this.each(function() {
      var $input = $(this)
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
      var $input = $(this)
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
