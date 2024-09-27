import  std/[os, strformat, strutils]


# source directory of the project for which the tests are written 
switch("path", "../src/nimutils")


task  runTests, "run all tests":
  echo "======================="
  echo "Start of task:  tests.."
  echo "======================="
  for file in walkDirRec(dir = ".", checkDir = true):
    let (dir, name, ext) = splitFile(file)
    if ext == ".nim"  and  (name.toLowerAscii.startsWith("test") or 
                            name.toLowerAscii.endsWith("test") or 
                            name.toLowerAscii.endsWith("tests")):
      withDir(dir):
        exec fmt"""nim  c  -d:release  -r  {name.addFileExt(ext)}"""
  echo "==========="
  echo "End of task"
  echo "==========="
