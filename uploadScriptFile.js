//uploadScriptFile.js
/*extern externs/suitescriptApi.js */
/*source library/fileCabinetLib.js, library/json2.js */
/*compile*/
/*advanced*/

function doPost(datain) {
  var isOnline, message = "",
      path, content, pathArr, filename, parentFolderId, fileobj, oldFileObj;

  nlapiLogExecution("debug", "Restlet Starting", "Authentication Successful");
  if (datain.hasOwnProperty('cabpath')) {
    path = datain['cabpath'];
    content = datain['content'];
    pathArr = path.split("/");
    filename = pathArr[pathArr.length - 1];
    parentFolderId = folderIdForFilePath(path);

    if (filename !== 'uploadScriptFile.js') {
      content = content.replace(/use strict/gm, "use strict-disabled");
    }

    if (parentFolderId) {      
      //Create a new file, and preserve the isOnline status from any existing file.
      fileobj = nlapiCreateFile(filename, 'PLAINTEXT', content);
      fileobj.setFolder(parentFolderId);
      fileobj.setDescription("by Head in the Cloud Development, Inc.\ngurus@headintheclouddev.com");
      if (oldFileObj) {
        isOnline = oldFileObj.isOnline();
        nlapiLogExecution("debug", "Old File Object Found", "Setting online to " + isOnline)
          fileobj.setIsOnline(isOnline);
      }
      nlapiSubmitFile(fileobj);

      message += "Uploaded " + datain['cabpath'] + " ok!";
    }
    else {
      message += "No folder id found for " + datain['cabpath'];
    }
  }
  else {
    message += "cabpath was not specified";
  }

  return message;
}

/*exports*/
(function(global) {
    global['doPost'] = doPost;
}(this));
