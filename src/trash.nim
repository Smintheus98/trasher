import std / [os, times, sequtils, parseopt]

type
  Path = string


proc exists(path: Path): bool =
  return path.fileExists() or path.dirExists()


proc allExist(paths: seq[Path]): bool =
  return paths.map(exists).allIt(it == true)


proc tryCreateTrashBin(trashbin: Path = getHomeDir()/".trashbin"): bool {.discardable.} =
  ## Tries to create `trashbin` if it doesn't already exist.
  ## The return value is false if the dircetory already exists but is discarded by default.
  if not trashbin.dirExists:
    trashbin.createDir()
    return true
  return false


proc trashFile(source, trashbin: Path) =
  ## Moves `source` (regular file) to `trashbin` and updates the
  ## last modification time by which the erase of the files are controlled.
  let
    filename = source.extractFilename
    dest = trashbin / filename
  moveFile(source, dest)
  setLastModificationTime(dest, getTime())


proc trashDir(source, trashbin: Path) =
  ## Moves `source` (dircetory) to `trashbin` and updates the 
  ## last modification time by which the erase of the files are controlled.
  let
    filename = source.extractFilename
    dest = trashbin / filename
  moveDir(source, dest)
  setLastModificationTime(dest, getTime())


proc trashDirOrFile(source, trashbin: Path) =
  ## Moves `source` to `trashbin` and updates the last modification time
  ## by which the erase of the files are controlled.
  let fileinfo = source.getFileInfo()
  if fileinfo.kind == pcDir:
    trashDir(source, trashbin)
  else:
    trashFile(source, trashbin)


proc parseOptions(): tuple[options: seq[string], paths: seq[Path]] =
  # TODO: parse options
  var parser = initOptParser()
  for argkind, argkey, argval in parser.getopt():
    case argkind:
      of cmdShortOption, cmdLongOption:
        result.options.add argkey
      of cmdArgument:
        result.paths.add argkey
      of cmdEnd:
        return



proc main() =
  let
    trashbin = getHomeDir() / ".trashbin"
    (options, paths) = parseOptions()

  for opt in options:
    case opt:
      of "-h", "--help":
        # TODO: print usage
        quit QuitSuccess

  if not paths.allExist:
    quit QuitFailure

  trashbin.tryCreateTrashBin()

  for path in paths:
    path.trashDirOrFile(trashbin)


when isMainModule:
  main()
