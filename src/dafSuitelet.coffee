window.dafSuitelet = (request, response) ->
  if request.getParameter('custparam_iframe') == 'T'
    fs = require 'fs'
    html = fs.readFileSync("#{__dirname}/../templates/dafSuitelet.iframe.html")
    response.write html
  else
    # Set up the form (same for get/post)
    form = nlapiCreateForm "Donor Advised Fund Visualizer", false
    form.addSubmitButton "Reload"
    mapField = form.addField "custpage_map", "inlinehtml", "map goes here"
    mapHtml = "<iframe src='https://system.na1.netsuite.com/app/site/hosting/scriptlet.nl?script=664&deploy=1&custparam_iframe=T' height=700 width=1200 seamless></iframe>"
    mapField.setDefaultValue mapHtml
    response.writePage form
