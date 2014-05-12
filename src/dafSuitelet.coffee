window.dafSuitelet = (request, response) ->
  # Set up the form (same for get/post)
  form = nlapiCreateForm "Donor Advised Fund Visualizer", false
  form.addSubmitButton "Reload"
  form.setScript "customscript_daf_client"
  mapField = form.addField "custpage_map", "inlinehtml", "map goes here"
  mapHtml = "<div id='mapcanvas'></div>"
  #mapHtml += "<script src='https://code.highcharts.com/maps/highmaps.js'></script>"
  mapField.setDefaultValue mapHtml
  
  if request.getMethod == "GET"
    # Load form with defaults
  else # Load parameters for user-defined settings
    
  response.writePage form
  
window.pageInit = ->
  # Get some sample data
  jQuery.getJSON('//www.highcharts.com/samples/data/jsonp.php?filename=world-population-density.json&callback=?', (data) ->
    Highcharts = require 'highmaps'
    # initialize the map
    map = new Highcharts.Chart {
      chart: {
        renderTo: "mapcanvas",
        type: "Map"
      },
      title : {
        text : 'Population density by country (/km²)'
      },

      mapNavigation: {
        enabled: true,
        buttonOptions: {
          verticalAlign: 'bottom'
        }
      },

      colorAxis: {
        min: 1,
        max: 1000,
        type: 'logarithmic'
      },

      series : [{
        data : data,
        mapData: Highcharts.maps.world,
        joinBy: 'code',
        name: 'Population density',
        states: {
          hover: {
            color: '#BADA55'
          }
        },
        tooltip: {
          valueSuffix: '/km²'
        }
      }]
    }
  )