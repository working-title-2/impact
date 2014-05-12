global.dafSuitelet = (request, response) ->
  # Set up the form (same for get/post)
  form = nlapiCreateForm "Donor Advised Fund Visualizer", false
  form.addSubmitButton "Reload"
  form.setScript "customscript_daf_client"
  mapField = form.addField "custpage_map", "inlinehtml", "map goes here"
  mapHtml = """
    <script type='text/javascript'>Highcharts = null;</script>
    <script src="/core/media/media.nl?id=6855&c=TSTDRV1203574&h=ed7bfd10c0646c4eaf33&mv=hv4aeu0o&_xt=.js&whence=">//highmaps.js</script>
    <script src="/core/media/media.nl?id=6856&c=TSTDRV1203574&h=3243b01c63a1fa41e392&mv=hv4ajhgg&_xt=.js&whence=">//world.js</script>
    <div id='mapcanvas'></div>
  """
  mapField.setDefaultValue mapHtml
  response.writePage form

global.pageInit = ->
  # Get some sample data
  jQuery.getJSON('/app/site/hosting/scriptlet.nl?script=667&deploy=1', (data) ->
    # initialize the map
    jQuery('#mapcanvas').highcharts {
      chart: {
        renderTo: "mapcanvas",
        type: 'Map',
        width: 800,
        height: 400
      },
      title : {
        text : 'Population by country'
      },

      mapNavigation: {
        enabled: true,
        buttonOptions: {
          verticalAlign: 'bottom'
        }
      },

      colorAxis: {
        min: 1
      },

      series : [{
        type : 'map'
        data : data,
        mapData: Highcharts.maps.world,
        joinBy: 'code',
        name: 'Population',
        states: {
          hover: {
            color: '#BADA55'
          }
        },
        # tooltip: {
        #   valueSuffix: '/km²'
        # }
      }]
    }
  )
  