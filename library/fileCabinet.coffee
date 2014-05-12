folderIdPathCache = {}

folderIdForFolderPath = (folderPath) ->
  nlapiLogExecution 'debug', 'folderPath', folderPath
  if !folderIdPathCache[folderPath]
    pathArray = folderPath.split '/'
    parentFolderId = '@NONE@'
    for pathArgument in pathArray
      continue if !pathArgument
      filters = [
        new nlobjSearchFilter 'name', null, 'is', pathArgument
        new nlobjSearchFilter 'parent', null, 'anyof', parentFolderId
      ]
      results = nlapiSearchRecord 'folder', null, filters
      if !results or results.length != 1
        parentFolderId = null
        break
      parentFolderId = results[0].getId()
    folderIdPathCache[folderPath] = parentFolderId
  folderIdPathCache[folderPath]

folderPathForFilePath = (filePath) ->
  components = filePath.split '/'
  components.splice components.length-1, 1
  components.join '/'

folderIdForFilePath = (filePath) ->
  folderIdForFolderPath(folderPathForFilePath(filePath))

fileNameForFilePath = (filePath) ->
  components = filePath.split '/'
  components[components.length-1]
  
getFileContents = (filePath) ->
  components = filePath.split('/')
  components = component for component in components when component?.length > 0
  file = nlapiLoadFile?(components.join('/'))
  if file
    file.getValue()
  else
    url = nlapiResolveURL 'SUITELET', 'customscript_getfilecontents_suitelet', 'customdeploy_invoked'
    response = nlapiRequestURL url, filePath, null, null, 'POST'
    response.getBody()

saveFileContents = (filePath, data, fileType) ->
  file = nlapiCreateFile fileNameForFilePath(filePath), fileType, data
  file.setFolder folderIdForFilePath(filePath)
  nlapiSubmitFile file

contentTypeHash =
  'application/x-autocad' : 'AUTOCAD'
  'image/x-xbitmap' : 'BMPIMAGE'
  'text/csv' : 'CSV'
  'application/comma-separated-values' : 'CSV'
  'application/vnd.ms-excel' : 'EXCEL'
  'application/x-shockwave-flash' : 'FLASH'
  'image/gif' : 'GIFIMAGE'
  'application/x-gzip-compressed' : 'GZIP'
  'text/html' : 'HTMLDOC'
  'image/ico' : 'ICON'
  'text/javascript' : 'JAVASCRIPT'
  'image/jpeg' : 'JPGIMAGE'
  'message/rfc822': 'MESSAGERFC'
  'audio/mpeg' : 'MP3'
  'video/mpeg' : 'MPEGMOVIE'
  'application/vnd.ms-project' : 'MSPROJECT'
  'application/pdf' : 'PDF'
  'image/pjpeg' : 'PJPGIMAGE'
  'text/plain' : 'PLAINTEXT'
  'image/x-png' : 'PNGIMAGE'
  'application/postscript' : 'POSTSCRIPT'
  'application/vnd.ms-powerpoint' : 'POWERPOINT'
  'video/quicktime' : 'QUICKTIME'
  'application/rtf' : 'RTF'
  'application/sms' : 'SMS'
  'text/css' : 'STYLESHEET'
  'image/tiff' : 'TIFFIMAGE'
  'application/vnd.visio' : 'VISIO'
  'application/msword' : 'WORD'
  'text/xml' : 'XMLDOC'
  'application/zip' : 'ZIP'
  
fileTypeFromContentType = (contentType) ->
  contentTypeHash[contentType] || ''

global.getFileContentsSuitelet = (request, response) ->
  response.write getFileContents(request.getBody())
  
module.exports = {
  getFileContents : getFileContents
  saveFileContents : saveFileContents
  fileTypeFromContentType : fileTypeFromContentType
  folderIdForFilePath: folderIdForFilePath
}
