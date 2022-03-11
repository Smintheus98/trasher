import std / [os, times, parseopt]

type Path = string


proc tryCreateTrashBin(trashbin: Path = getHomeDir()/".trashbin"): bool {.inline, discardable.} =
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
  discard


proc main() =
  let
    trashbin = getHomeDir() / ".trashbin"
    (options, paths) = parseOptions()

  for opt in options:
    case opt:
      of "-h", "--help":
        # TODO: print usage
        quit QuitSuccess

  trashbin.tryCreateTrashBin()

  for path in paths:
    path.trashDirOrFile(trashbin)


when isMainModule:
  main()
