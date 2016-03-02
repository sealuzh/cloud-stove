# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'page:change', ->
  $select_options = {}
  showOnlyRelevantComponents = ->
    selected_blueprint_id = $('#cloud_application_blueprint_id').val()
    $('select.component').each () ->
      # Store initial state of select options
      $select_options[this.id] ?= $(this).html()
      $(this).html($select_options[this.id])
    $("select.component > option[data-blueprint-id!=\"#{selected_blueprint_id}\"]").remove()

  $('#cloud_application_blueprint_id').change showOnlyRelevantComponents
  showOnlyRelevantComponents()
