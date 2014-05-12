$ ->
  # Get some sample data
  $.getJSON('/app/site/hosting/scriptlet.nl?script=667&deploy=1', (data) ->
    # initialize the map
    $('#mapcanvas').highcharts {
      chart: {
        renderTo: "mapcanvas",
        type: 'Map'
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

      #colorAxis: {
      #  min: 1,
      #  max: 1000,
      #  type: 'logarithmic'
      #},

      series : [{
        type : 'map'
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
