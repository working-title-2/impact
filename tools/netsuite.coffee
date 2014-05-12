execSync = require 'exec-sync'
crypto = require 'crypto'
fs = require 'fs'
os = require 'os'
path = require 'path'

cachedURLRegexes = []
addRequestURLRegexCache = (regex) ->
	cachedURLRegexes.push(regex)
	
urlCacheFilename = null
getURLCacheFilename = ->
	unless urlCacheFilename
		dir = process.env.TM_DIRECTORY
		urlCacheFilename = path.join(dir, "nlapiRequestURL.cache")
	return urlCacheFilename

urlCache = null
loadURLCache = ->
	unless urlCache
		filename = getURLCacheFilename()
		if fs.existsSync(filename)
			cacheString = fs.readFileSync(filename).toString('utf8')
			urlCache = JSON.parse(cacheString)
		else
			urlCache = {}
	
	return urlCache

urlCacheHash = (url, postdata) ->
	md5 = crypto.createHash('md5')
	md5.update(url + JSON.stringify(postdata))
	return md5.digest('hex')

checkURLCache = (url, postdata) ->
	hash = urlCacheHash(url, postdata)
	cache = loadURLCache()
	if hash of cache
		response = cache[hash]
		res = new nlobjResponse()
		res.write(response.body)
		return res
	else
		return null

addToURLCache = (url, postdata, response) ->
	hash = urlCacheHash(url, postdata)
	cache = loadURLCache()
	cache[hash] = response
	fs.writeFileSync(getURLCacheFilename(), JSON.stringify(cache))

doNlapiRequestURL = (url, postdata, headers, httpMethod) ->
	response = new nlobjResponse()
	headers = {} if !headers
	
	if httpMethod
		method = httpMethod
	else if postdata
		method = 'POST'
	else
		method = 'GET'
	
	if !headers['X-Suite-Operation'] || global.TEST_ENV == 'live'
		
		postdatafile = null
		
		command = []
		command.push('/usr/bin/curl')
		command.push('-s') # silent mode (to prevent progress meter)
		command.push('-X '+method)
		for key, val of headers
			command.push("-H '"+[key, val].join(': ')+"'")
		if postdata
			md5 = crypto.createHash('md5')
			md5.update(JSON.stringify(postdata))
			postdatafile = path.resolve(os.tmpdir(), md5.digest('hex'))
			fs.writeFileSync(postdatafile, postdata)
			command.push("-d @"+postdatafile)
		command.push('"'+url+'"')
		
		#nlapiLogExecution('DEBUG', 'nlapiRequestURL', 'Running command '+command.join(' '))
		result = execSync(command.join(' '))
		fs.unlink(postdatafile) if postdatafile
		response.write(result)
		#nlapiLogExecution('DEBUG', 'nlapiRequestURL-response', result)
		
	else
		request = new nlobjRequest(postdata, headers)
		request.setMethod(method)
		webservicesplus.api(request, response)
	return response
	
	
global.nlapiRequestURL = (url, postdata, headers, httpMethod) ->
	for regex in cachedURLRegexes
		if url.match(regex)
			response = checkURLCache(url, postdata)
			if response
				return response
			else
				response = doNlapiRequestURL(url, postdata, headers, httpMethod)
				addToURLCache(url, postdata, response)
				
				return response
	
	#Didn't return above, url doesn't match any regexes
	console.log("Didn't match a URL regex")
	return doNlapiRequestURL(url, postdata, headers, httpMethod)

class nlobjRequest
  constructor: (@body, @headers)->
	  @parameters = {}
  getParameter: (key, value) ->
    @parameters[key]
  setParameter: (key, value) ->
    @parameters[key] = value
  getAllParameters: -> @parameters
  getAllHeaders: -> @headers
  #getAllParameters()
    #var params = request.getAllParameters()
    #for ( param in params ){
    #    nlapiLogExecution('DEBUG', 'parameter: '+ param)
    #    nlapiLogExecution('DEBUG', 'value: '+params[param])
    #}
  getBody: -> @body
  #getFile(id)
  getHeader: (name) ->
    @headers[name]
  #getLineItemCount(group)
  #getLineItemValue(group, name, line)
  getMethod: -> @method
  setMethod: (@method) ->
  #getParameter(name)
  #getParameterValues(name)
  #getURL()
global.nlobjRequest = nlobjRequest

class nlobjResponse
  constructor: ->
    @body = ''
    @code = 0
  write: (output) ->
    @body += output
  #addHeader(name, value)
  getAllHeaders: -> @headers
  getBody: () -> @body
  getCode: () -> @code
  setCode: (@code) ->
  getError: -> ''
  #getHeader(name)
  #getHeaders(name)
  setContentType: (type, name, disposition) ->
    
  #setHeader(name, value)
  #sendRedirect(type, identifier, id, editmode, parameters)
  #write(output)
  #writeLine(output)
  #writePage(pageobject)
global.nlobjResponse = nlobjResponse

nlapiLogExecution = (type, title, details) ->
  # valid types:DEBUG AUDIT ERROR EMERGENCY
  # title (optional) : (max length: 99 characters) .. will show "Untitled" if null
  # details (optional): (max length: 3000 characters)
    console.log(type, title, details)
global.nlapiLogExecution = nlapiLogExecution

nlapiResolveURL = (type, id, id2, editMode) ->
  ""
global.nlapiResolveURL = nlapiResolveURL