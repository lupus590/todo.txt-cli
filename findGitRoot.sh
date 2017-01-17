#! /bin/bash
echo "$0 running"

errorNoGit="bash: git: command not found"
errorNotAGitRepo="fatal: Not a git repository (or any of the parent directories): .git"


#workDir="/tmp/findGitRoot"
workDir="findGitRoot"
mkdir -p "$workDir" #/tmp should exist but just in case

function cleanUp
{
  echo "$0 cleaned"
  rm -r -f "$workDir"
}

function readFile
{
  echo "$0 reading file"
  read LINE <$1
  echo $LINE
  return $LINE
}

function convertPath
{
  realpath <$1 >"$workDir/realpath.out"
  return readfile "$workDir/realpath.out"
}

echo "$0 checking for git"
git > "$workDir"/git.out 2> "$workDir"/git.err
gitErr=readFile "$workDir/git.err"
gitOut=readFile "$workDir/git.out"
if ($gitErr=$errorNoGit)
  then #no git so assume no git repos
  echo "$0 no git"
  cleanUp
  exit 1 
fi
echo "$0 found git"

# check if in git repo
git rev-parse --show-cdup > "$workDir/git.out" 2> "$workDir/git.err"
gitErr=readFile "$workDir/git.err"
gitOut=readFile "$workDir/git.out"

if($gitErr=$errorNotAGitRepo)
  then #not a git repo
  echo "$0 no repo"
  cleanUp
  exit 1 
fi

if($gitOut="")
  then #in a git repo and at root
  cleanUp
  echo "$0 already at root"
  echo convertPath .
  realpath "$(pwd)/" | dirname "$(pwd)/"
  exit 0
fi

cleanUp
echo "$0 found root at $(pwd)/$gitOut/"
dirname convertPath "/$gitOut/"
exit 0