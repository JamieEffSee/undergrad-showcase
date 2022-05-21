# My very first 'big' coding project, circa 2012.
# The code may be a bit hacky because this was written
# before I'd had any formal training in coding.

import os
import shutil
import string
#import zipfile

global listofFiles
global kk
global gg
global branch
#global ripper

ripofFiles = []
listofFiles = []
branch = ''

def call():                                           # works
      print(os.getcwd())                        

class Robot:                                                #whole class works.
      
      def proper ( self, filename ) :                    #propernator
            
            filename  = filename.title()
            return filename
            
      def artichoke (self, filename, newPath):
            q = str(input('About to move! Proceed? (Y/N)  _ '))
            if q == 'Y' or 'y':                        
                  shutil.copy(filename, newPath)
            else: print('quit...')

def stripper ( filename, characters ):           #works
            gg=''
            kk=''
            ll=''

            if branch == 'r':

                  mm = filename.split(".")[0]         #get filename

                  mp = filename.split(".")[-1]        #get filename extension          
                  
                  gg = str((os.getcwd() + '\\' + mm.rstrip(characters) + '.' + mp))

                  return gg
            
            else:
                  
                  kk = str(os.getcwd() + '\\' + filename.lstrip(characters))

                  return kk


def unzip(file):                                            #works

      ripper = zipfile.ZipFile(file)
      ripper.extractall(zipped)
            
def filesChecker():                                 #works FWIW

      path = call()
      print ("\n IS THE CURRENT WORKING DIRECTORY.")
      i = 0
      iMax = int(input('Depth? (Must be integer)  _ '))
      for (path, dirs, files) in os.walk(path):
          print (path)
          print (dirs)
          print (files)
          print ("----")
          i += 1
          if i >= iMax:
              break

def walkerGetter():                                               # execute in desired cwd
      path = call()
      ripofFiles = []
      
      i=0
      for (files) in os.walk(path):
            ripofFiles =  files
            i+=1
            if i == 1:
                  break

      listofFiles = ripofFiles[2]                                 # Now I have a list containing all the filenames in the cwd

#################################################

Robot = Robot()           

#################################################
#
# Here be dragons
cwd = 'F:\\'
bloom = 'bloom\\'
prop = 'propernate\\'
rex = 'regexpprac\\'

temp = []
      
## loops



##for i in range (len(someDirectoryList)):
##	os.chdir(cwd+someDirectoryList[i])
##	walkerGetter()
##	for j in range (lenlistofFiles):
##		shutil.copy(listofFiles[j], song)
##		call()



######Recursive walker/getters. includes support for stripping and propernating.

def stripPoker(dirList, stripChars):
      for i in range (len(dirList)):                  ##dirList should be a list of directory (folder) names of the format
            os.chdir(cwd+dirList[i])                        ##    ['abc\\', 'def\\', 'ghi\\', 'jkl\\']         within the same root directory.
            stripSearch(stripChars)

def stripSearch(stripChars):
            walkerGetter()
            temp=[]
            global rejects
            rejects = []
            for j in range (len(listofFiles)):
                  temp.append('')
                  call()
                  print ('    now propernating: ', listofFiles[j])
                  print ('           file ', j+1, ' of ', len(listofFiles))
                  try:
                        temp[j] = stripper(listofFiles[j], stripChars)   ## stripChars should obv. change b/w implementations
                        #temp[j] = Robot.proper(temp[j])          ## watch the referencing here if you dont strip
                        os.rename(listofFiles[j], temp[j])          ##and here
                        print ('.................................done!')
                  except FileExistsError:
                        print ('Cant rename, file exists')
                        rejects.append(listofFiles[j])
                        print ('BURP!', listofFiles[j], j, '-th file')
            print ('Number of rejected files: ', len(rejects))
            print ('Rejected files: \n\n')
            print (rejects)

####unzipper

##def multizip(ziplist):
##      for i in range (len(ziplist)):
##            os.chdir(cwd+ziplist[i])
##            ziploop()
##
##def ziploop():
##      zipped=call()
##      walkerGetter()
##      global rejects
##      rejects = []
##      for j in range (len(listofFiles)):
##            print('        file ', j+1, ' of ', len(listofFiles))
##            print('        filename: ', listofFiles[j])
##
##            try:
##                  unzip(listofFiles[j])
##                  call()
##            except NotImplementedError:
##                  rejects.append(listofFiles[j])
##                  print ('BURP!', listofFiles[j], j, '-th file')
##                  
##
##      print ('Number of rejected files: ', len(rejects))
##      print ('Rejected files: \n\n')
##      print (rejects)

#### regular expressions machine

##def rebot(swapout, swapin):
##      import re
##      walkerGetter()
##      newfiles = []
      
