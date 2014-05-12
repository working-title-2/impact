convertToHighmapsObject = (result) ->
  {
    code: result.getValue 'custrecord_country'
    name: result.getValue 'name'
    value: result.getValue 'custrecord_population'
  }

window.get = (datain) ->
  args = JSON.parse datain
  filters = [
    new nlobjSearchFilter 'custrecord_reporteddate', null, 'within', '1/1/2010', '12/31/2010'
  ]
  columns = [
    new nlobjSearchColumn 'custrecord_country'
    new nlobjSearchColumn 'name'
    new nlobjSearchColumn 'custrecord_population'
  ]
  JSON.stringify(convertToHighmapsObject(result) for result in nlapiSearchRecord('customrecord_country', null, filters, columns))
