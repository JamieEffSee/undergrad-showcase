# My very first 'big' coding project, circa 2012.
# The code may be a bit hacky because this was written
# before I'd had any formal training in coding.


import os
import shutil
import string
import zipfile

global ripofFiles
global listofFiles
global lenlistofFiles
global kk
global gg
global branch


ripofFiles = []
listofFiles = []
lenlistofFiles = 0
kk = ''
gg = ''
branch = ''

def call():                                           # works
      print(os.getcwd())                        
      
class Chdir:                                          ##change directories, works
      def __init__( self, newPath ):                  ##stays in savedPath      
        self.savedPath = os.getcwd()
        os.chdir(newPath)

      def __del__( self ):
        os.chdir( self.savedPath )

class Movedir:                                        ##move directories      , works
      def __init__( self, newPath):                   ##stays in savedPath      
        self.savedPath = os.getcwd()
        q = str(input('About to move ' + self.savedPath + ' to ' + newPath + ' ! Proceed? (Y/N)  _ '))
        if q == 'Y' or 'y':
                  w = str(input('Sure? ' + self.savedPath + ' to ' + newPath + '  .  Proceed? (Y/N)  _ '))
                  if w == 'Y' or 'y':
                        shutil.copytree(self.savedPath, newPath)          ##should be last operation.
                        
                        
                                                ##ignore resulting Permission Error
      def __del__( self ) :                     ## New path CANNOT already exist!
        os.chdir( self.savedPath )

class Robot:                                                #whole class works.
      
      def proper ( self, filename ) :                    #propernator
            
            filename  = filename.title()
            return filename
            
      def artichoke (self, filename, newPath):
            q = str(input('About to move! Proceed? (Y/N)  _ '))
            if q == 'Y' or 'y':                        
                  shutil.copy(filename, newPath)
            else: print('quit...')




def stripper ( filename, characters ):           #works - make this return the string or map to global instead of renaming
            branch = str(input("Leading characters stripping Commencing. Press 'r' for trailing-characters"))
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
            
def stringToFilesChecker():                                 #works FWIW

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
      global ripofFiles
      global listofFiles
      global lenlistofFiles
      ripofFiles = []
      listofFiles = []
      lenlistofFiles = 0
      
      i=0
      for (files) in os.walk(path):
            ripofFiles =  files
            
            
            
            i+=1
            if i == 1:
                  break



      listofFiles = ripofFiles[2]                                 # Now I have a list containing all the filenames in the cwd
      lenlistofFiles = len(listofFiles)

#################################################

Robot = Robot()           

#################################################
#
# Here be dragons
C8=[]
C1=[]
cwd = 'F:\\'
artist = 'F:\\By Artist\\'
song = 'F:\\By Song'


SC1X = ['SC1019 H of F 70s & 80s 6Pk - COMPLET - RAR', 'SC1020 H of F 70s & 80s 6Pk - COMPLET - RAR', 'SC1021 H of F 70s & 80s 6Pk - COMPLET - RAR', 'SC1022 H of F 70s & 80s 6Pk - COMPLET - RAR', 'SC1023 H of F 70s & 80s 6Pk - COMPLET - RAR', 'SC1024 H of F 70s & 80s 6Pk - COMPLET - RAR']
SC8X = ['SC8948 - COMPLET - RAR', 'SC8949 - COMPLET - RAR', 'SC8950 - COMPLET - RAR', 'SC8952 - COMPLET - RAR', 'SC8953 - COMPLET - RAR', 'SC8954 - COMPLET - RAR', 'SC8956 - COMPLET - RAR', 'SC8957 - COMPLET - RAR', 'SC8958 - COMPLET - RAR', 'SC8959 - COMPLET - RAR', 'SC8965 - COMPLET - RAR', 'SC8967 - COMPLET - RAR']


for i in range(6):
      C1.append(cwd + SC1X[i] + '\\')

for i in range(12):
      C8.append(cwd + SC8X[i] + '\\')






##Chdir(cwd+SC1X[0])
##walkerGetter()
##for j in range(lenlistofFiles):
##      listofFiles[j],'SC1234567890HofF&Pk')
