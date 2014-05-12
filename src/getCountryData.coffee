window.get = (datain) ->
  args = JSON.parse datain
  filters = [
    new nlobjSearchFilter 'custrecord_reporteddate', null, 'within', 'thisyear'
  ]
  columns = [
    new nlobjSearchColumn 'custrecord_country'
    new nlobjSearchColumn
  ]
  JSON.stringify({
  } for result in nlapiSearchRecord('customrecord_country', null, null, ))