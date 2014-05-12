convertToHighmapsObject = (result) ->
  {
    code: result.getValue 'custrecord_country'
    name: result.getValue 'name'
    value: result.getValue 'custrecord_population'
  }

window.get = (request, response) ->
  #args = JSON.parse datain
  filters = [
    new nlobjSearchFilter 'custrecord_reporteddate', null, 'within', '1/1/2010', '12/31/2010'
  ]
  columns = [
    new nlobjSearchColumn 'custrecord_country'
    new nlobjSearchColumn 'name'
    new nlobjSearchColumn 'custrecord_population'
  ]
  response.write JSON.stringify(convertToHighmapsObject(result) for result in nlapiSearchRecord('customrecord380', null, filters, columns))
