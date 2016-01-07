# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'page:change', ->
  Array::numericSort = () -> this.sort (a, b) -> a - b
  
  ppcs = $.map($('[data-ppc]'), (v) ->
    parseFloat($(v).data('ppc'))
  ).numericSort()
  
  ppgbs = $.map($('[data-ppgb]'), (v) ->
    parseFloat($(v).data('ppgb'))
  ).numericSort()
  
  ppms = $.map($('[data-ppm]'), (v) ->
    parseFloat($(v).data('ppm'))
  ).numericSort()
  
  class_for = (value, array) ->
    position = array.indexOf value
    size = array.length
    modifier = switch
      when position < size * 1 / 5 then 'success'
      when position < size * 2 / 5 then 'info'
      when position < size * 3 / 5 then 'default'
      when position < size * 4 / 5 then 'warning'
      else 'danger'
    [ 'bg', 'text' ].map((x) -> x + "-#{modifier}").join(' ')
  
  $('[data-ppc]').each (idx, element) ->
    e = $(element)
    value = parseFloat e.data('ppc')
    e.addClass class_for(value, ppcs)

  $('[data-ppgb]').each (idx, element) ->
    e = $(element)
    value = parseFloat e.data('ppgb')
    e.addClass class_for(value, ppgbs)

  $('[data-ppm]').each (idx, element) ->
    e = $(element)
    value = parseFloat e.data('ppm')
    e.addClass class_for(value, ppms)

