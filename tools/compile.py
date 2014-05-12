#!/usr/bin/python

import sys
import os
import argparse
import subprocess
import re
import tempfile

scriptPath = os.path.realpath(__file__)
toolsPath = os.path.dirname(scriptPath)
basePath = os.path.dirname(toolsPath)

advancedDisable = False
allIncludedFiles = []

TYPE_EXTERN = '--externs'
TYPE_SOURCE = '--js'

def upsertIncludedFile(path, type):
    for incFile in allIncludedFiles:
        if incFile.path == path:
            return incFile

    newfile = IncludedFile(path, type)
    allIncludedFiles.append(newfile)
    return newfile

class IncludedFile:
    def __init__(self, path, type):
        self.path = path
        self.type = type
        self.dependencies = set()
        self.visited = False
        self.added = False

    def addDependency(self, incfile):
        self.dependencies.add(incfile)

    def addDependencies(self, deps):
        self.dependencies.update(deps)

def parsePaths(line, type):
    return [upsertIncludedFile(os.path.join(basePath, path.strip()), type) for path in line.split(',') if len(path.strip()) > 0]

def visitFile(thisFile):
    global advancedDisable
    
    if thisFile.visited:
        return

    thisFile.visted = True

    with open(thisFile.path, 'r') as file:
        for line in file:
            if line.startswith("/*extern"):
                thisFile.addDependencies(parsePaths(line.replace("/*extern", "").replace("*/", ""), TYPE_EXTERN))
            if line.startswith("/*source"):
                thisFile.addDependencies(parsePaths(line.replace("/*source", "").replace("*/", ""), TYPE_SOURCE))
            if line.startswith("/*advanced-disable"):
                advancedDisable = True
    
    for incfile in thisFile.dependencies:
        visitFile(incfile)

def getCommandLineFileArgs(thisFile, argsList):
    for incfile in thisFile.dependencies:
        getCommandLineFileArgs(incfile, argsList)

    if thisFile.added:
        return

    thisFile.added = True
    argsList.extend([thisFile.type, thisFile.path])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compile one or many scripts using Google Closure Compiler to be uploaded to NetSuite')
    parser.add_argument('--debug', type=str, nargs='?')
    parser.add_argument('infile', type=argparse.FileType('rU'))
    parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
    args = parser.parse_args()
    
    inFilePath = os.path.realpath(args.infile.name)
    rootFile = upsertIncludedFile(inFilePath, TYPE_SOURCE)
    
    try:
        visitFile(rootFile)
    except Exception as e:
        args.outfile.write(str(e))
        sys.exit(-1)
    
    doAdvanced = False
    doAdvancedDebug = False

    if not advancedDisable:
        args.infile.seek(0)
        for line in args.infile:
            if line.strip() == '/*advanced*/':
                doAdvanced = True
                break
        
        args.infile.seek(0)
        for line in args.infile:
            if line.strip() == '/*advanced-debug*/':
                doAdvancedDebug = True
                break
    
    compilerPath = os.path.join(toolsPath, "compiler.jar")
    command = ["java", "-jar", compilerPath]
    fileArgs = []
    getCommandLineFileArgs(rootFile, fileArgs)
    command.extend(fileArgs)
    for errName in ['accessControls', 'ambiguousFunctionDecl', 'checkRegExp', 'checkVars', 'constantProperty', 'deprecated', 'duplicateMessage', 'es5Strict', 'externsValidation', 'fileoverviewTags', 'globalThis', 'internetExplorerChecks', 'invalidCasts', 'missingProperties', 'nonStandardJsDocs', 'strictModuleDepCheck', 'typeInvalidation', 'undefinedNames', 'undefinedVars', 'unknownDefines', 'uselessCode', 'visibility', 'checkTypes']:
        command.extend(["--jscomp_error", errName])
    if args.debug == 'true':
        command.extend(["--compilation_level", "WHITESPACE_ONLY", "--formatting", "pretty_print"])
    elif doAdvancedDebug == True:
        command.extend(["--compilation_level", "ADVANCED_OPTIMIZATIONS", "--formatting", "pretty_print"])
    elif doAdvanced == True:
        command.extend(["--compilation_level", "ADVANCED_OPTIMIZATIONS"])
    else:
        command.extend(["--compilation_level", "SIMPLE_OPTIMIZATIONS"])
    
    commandline = ' '.join(command)
    
    tempoutput = tempfile.TemporaryFile()
    
    try:
        output = subprocess.check_output(command, stderr=tempoutput)
    except subprocess.CalledProcessError:
        tempoutput.seek(0)
        for outline in tempoutput:
            args.outfile.write(outline)
        args.outfile.write('\n\nCommand:\n' + commandline)
        raise
    
    tempoutput.seek(0)
    for line in tempoutput:
        if re.search("\d+ error\(s\), \d+ warning\(s\)", line):
            tempoutput.seek(0)
            for outline in tempoutput:
                args.outfile.write(outline)
            args.outfile.write('\n\nCommand:\n' + commandline + '\n\n')
            args.outfile.flush()
            raise Exception("Compiling failed")
    
    args.outfile.write(output)
    
    args.infile.close()
    args.outfile.close()