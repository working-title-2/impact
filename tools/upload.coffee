#!/usr/bin/env coffee

require './netsuite.coffee'

class Uploader
  constructor: (@username, @password, @account, @role, @environment) ->
    @uploadURL = null
  getRESTServiceAuthString: ->
    return "NLAuth nlauth_email="+@username+", nlauth_signature="+@password
  getRESTServiceURL: ->
    if @environment == 'SANDBOX'
      "https://rest.sandbox.netsuite.com/rest/roles"
    else if @environment == 'BETA'
      "https://rest.beta.netsuite.com/rest/roles"
    else
      "https://rest.netsuite.com/rest/roles"
  getUploadURL: ->
    if !@uploadURL
      url = @getRESTServiceURL()
      headers = {"Authorization":@getRESTServiceAuthString()}
      response = nlapiRequestURL(url, null, headers)
      #console.log(response.getBody())
      roles = JSON.parse(response.getBody())
      for role in roles
        if parseInt(@role, 10) == role['role']['internalId'] && @account == role['account']['internalId']
          baseURL = role['dataCenterURLs']['restDomain']
          @uploadURL = baseURL + "/app/site/hosting/restlet.nl?script=customscript_uploadscriptfile&deploy=customdeploy1"
          break
    return @uploadURL
  getAuthString: ->
    return "NLAuth nlauth_account="+@account+", nlauth_email="+@username+", nlauth_signature="+@password+", nlauth_role="+@role
  upload: (contents, path) ->
    url = @getUploadURL()
    headers = {
      "Authorization":@getAuthString(),
      "Content-Type":"application/json"
    }
    postdata = JSON.stringify({
      cabpath:path,
      content:contents
    })
    console.log("Uploading file #{path} to URL #{url}")
    response = nlapiRequestURL(url, postdata, headers)
    console.log(response.getBody())

main = ->
  filePath = process.argv[2]
  uploader = new Uploader(process.env.NS_EMAIL, process.env.NS_PASSWORD, process.env.NS_ACCOUNT, process.env.NS_ROLE, process.env.NS_ENVIRONMENT)
  console.log "Compiling file #{filePath}"
  compile = require './compile.coffee'
  compile filePath, (error, contents) ->
    if error
      console.log "An error occurred during compilation:\n#{error}\n#{contents}"
    else
      path = require 'path'
      relPath = path.relative "#{__dirname}/..", filePath
      relPath = relPath.replace /.coffee$/, '.js'
      cabParentPath = process.env.NS_CAB_PARENTPATH or '/SuiteScripts'
      cabpath = path.join cabParentPath, relPath
      uploader.upload(contents, cabpath)

main() if require.main == module