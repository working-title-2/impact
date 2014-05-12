window.dafSuitelet = (request, response) ->
  # Set up the form (same for get/post)
  form = nlapiCreateForm "Donor Advised Fund Visualizer", false
  form.addSubmitButton "Reload"
  form.setScript "customscript_daf_client"
  mapField = form.addField "custpage_map", "inlinehtml", "map goes here"
  mapHtml = "<div id='mapcanvas'></div>"
  mapHtml += "<script src='https://code.highcharts.com/maps/highmaps.js'></script>"
  mapField.setDefaultValue mapHtml
  
  if request.getMethod == "GET"
    # Load form with defaults
  else # Load parameters for user-defined settings
    
  response.writePage form
  
window.pageInit = ->
  # initialize the map