module Main where

import Prelude
import Effect (Effect)
import Node.FS.Internal as FS
import Node.Path as Path
import Node.Path (FilePath)
import PursLS.App.Log as Log
import PursLS.Server as Server

main :: Effect Unit
main = do
    logfile <- getLogPath
    Server.start { logfile
                 , loglevel: Log.Debug
                 }

getLogPath :: Effect FilePath
getLogPath = do
    stateDir <- FS.getXdgDir "XDG_STATE_HOME" ".local/state"
    let logfile = Path.concat [stateDir, "purls/debug.log"]
    FS.mkdirp $ Path.dirname logfile
    pure logfile
