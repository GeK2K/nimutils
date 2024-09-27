import  std/[os, sequtils, strformat, strutils]


# script parameters
# =================
const
  srcDir = "./src"
  binDir = "./bin"
  tstDir = "./tst"
  docDir = "./docs"
  mainfile = srcDir.joinPath("nimutils.nim")
  runTestsTask = "runTests"
  gitUrl = "https://github.com/GeK2K/nimutils.git"


# disabling some warnings
# =======================
# A dot-like operator is an operator starting with '.' but not with '..'.
# Since Nim v2.0, dot-like operator have the same precedence as '.',
# and we get a warning every time we use a dot-like operator (e.g. '.?' 
# of the 'questionable' module).
# https://nim-lang.org/docs/manual.html#syntax-dotminuslike-operators
# https://nim-lang.org/blog/2021/10/19/version-160-released.html  
# (section "Dot-like operators")
# We have decided to disable this warning.
if (NimMajor, NimMinor) >= (1, 6):
  switch("warning", "DotLikeOps:off")


# procs
# =====
proc  cleanDir() =
  echo "\n\n"
  echo "======================================================="
  echo "Start of task:  cleaning 'bin' and 'docs' directories.."
  echo "======================================================="
  for aDir in [binDir, docDir]:
    for kind, path in walkDir(aDir):
      if kind == pcFile:  rmFile(path.string)  
      elif kind == pcDir:  rmDir(path.string)    
      else:  discard
  echo "==========="
  echo "End of task"
  echo "==========="


proc  nimCompilation(options = "", comment = "") =
  let taskStartBegin = "Start of task:  "
  let length = taskStartBegin.len + comment.len
  let line = '='.repeat(length)
  echo "\n", line, "\n", taskStartBegin, comment, "\n", line
  exec fmt"""nim  c  {options}  --mm:orc  """ &
       fmt"""--path:{srcDir}  --outdir:{binDir}  {mainfile}"""
  echo "==========="
  echo "End of task"
  echo "==========="


proc  runNimDoc(exportDocToGit = false) =
  let gitUrlOption = if exportDocToGit: fmt"--git.url:{gitUrl}"  else: ""
  echo "\n\n"
  echo "====================================="
  echo "Start of task:  document generation.."
  echo "====================================="
  exec "nim  doc  --project  --index:on  " &
       fmt"""--outdir:{docDir}  {gitUrlOption}  {mainfile}""""
  exec fmt"""nim  buildindex  -o:{docDir}/index.html  {docDir}""""
  echo "==========="
  echo "End of task"
  echo "==========="


task  buildApp, "":
  # user menu
  let usrMenu = """
What task(s) do you want to accomplish?

-1 = exit
 0 = cleaning directories ('bin' and 'docs')
 1 = compilation in danger mode
 2 = compilation in default mode
 3 = compilation in release mode
 4 = run nimdoc
 5 = run tests
"""
  # valid choices
  let validUsrChoices = (-1..5).mapIt($it)
  let validUsrChoicesStr = join(validUsrChoices, " ")
  while true:  # we stop only at the user's request
    # reading and validating user choices
    echo "\n", usrMenu
    let usrChoices = block:
      var usrChoices: seq[string]
      while true:
        echo "\n\nWaiting for your keyboard input..\n"
        let line = readLineFromStdin()
        if line.strip == "":
          echo "\nNothing has been entered. Please try again.\n\n"
          continue
        usrChoices = line.splitWhitespace()  
        let invalidUsrChoices = usrChoices.filterIt(it notin validUsrChoices).deduplicate
        let invalidUsrChoicesLen = invalidUsrChoices.len  
        if invalidUsrChoicesLen > 0:
          let invalidUsrChoicesStr = join(invalidUsrChoices, " ")
          echo fmt("\n\n{invalidUsrChoicesLen} invalid choice(s):  {invalidUsrChoicesStr}"),
               fmt("    (valid choices are:  {validUsrChoicesStr})\n\nPlease try again.")
          continue 
        break
      usrChoices
    # processing of user choices
    for c in usrChoices:
      if c == "-1":  quit(QuitSuccess)
      elif c == "0":  cleanDir()
      elif c == "1":
        nimCompilation(options = "-d:danger", comment = "Nim compilation in danger mode..")
      elif c == "2":
        nimCompilation(options = "", comment = "Nim compilation in default mode..")
      elif c == "3":
        nimCompilation(options = "-d:release", comment = "Nim compilation in release mode..")
      elif c == "4":
        runNimDoc()
      elif c == "5": 
        # execution of the 'runTests' task defined in the './tst/config.nims' file
        withDir tstDir:
          selfExec runTestsTask
      else:
        raise newException(ValueError, fmt("\nThe value {c} is not supported by the system !"))


# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
