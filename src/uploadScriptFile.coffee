global.doPost = (datain) ->
  message = ""
  
  {folderIdForFilePath} = require('../lib/fileCabinet.coffee')
  if (datain.hasOwnProperty('cabpath'))
    path = datain['cabpath']
    content = datain['content']
    pathArr = path.split("/")
    filename = pathArr[pathArr.length - 1]
    parentFolderId = folderIdForFilePath(path)

    if (parentFolderId)
      try
        oldFileObj = nlapiLoadFile(filename)
      catch
        #To catch any errors when loading an existing file
      
      #Create a new file, and preserve the isOnline status from any existing file.
      fileobj = nlapiCreateFile(filename, 'PLAINTEXT', content)
      fileobj.setFolder(parentFolderId)
      fileobj.setIsOnline(oldFileObj.isOnline?()) if oldFileObj
      nlapiSubmitFile(fileobj)

      message += "Uploaded #{datain['cabpath']} ok!"
    else
      message += "No folder id found for #{datain['cabpath']}"
  else
    message += "cabpath was not specified"

  return message