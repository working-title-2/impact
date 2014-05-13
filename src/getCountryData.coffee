parseFloatOrZero = (value) ->
  value = parseFloat(value)
  value = 0 if isNaN value
  value

convertToHighmapsObject = (result, valueColumn, max) ->
  {
    code: result.getValue 'custrecord_countrycode_2', 'custrecord_countrycode', 'group'
    name: result.getValue 'custrecord_countrycode_name', 'custrecord_countrycode', 'group'
    #value: parseFloatOrZero(result.getValue(valueColumn)) / max * 100
    value: parseFloatOrZero(result.getValue(valueColumn))
  }

buildHighmapsObject = (results, valueColumn) ->
  max = 0
  for result in results
    value = parseFloatOrZero result.getValue(valueColumn)
    max = Math.max(value, max)
  {
    max: max
    data: convertToHighmapsObject(result, valueColumn, max) for result in results
  }

window.get = (datain) ->
  filters = [
    new nlobjSearchFilter 'custrecord_reporteddate', null, 'within', '1/1/2004', '12/31/2014'
  ]
  valueColumn = new nlobjSearchColumn 'custrecord_povertylevel', null, 'avg'
  columns = [
    new nlobjSearchColumn 'custrecord_countrycode_name', 'custrecord_countrycode', 'group'
    new nlobjSearchColumn 'custrecord_countrycode_2', 'custrecord_countrycode', 'group'
    valueColumn
  ]
  JSON.stringify(buildHighmapsObject(nlapiSearchRecord('customrecord380', null, filters, columns), valueColumn))
