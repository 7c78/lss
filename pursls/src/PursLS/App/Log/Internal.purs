module PursLS.App.Log.Internal where

import Prelude
import Effect (Effect)
import Node.Path (FilePath)
import Node.FS.Async as FS
import Node.Encoding as Encoding

data LogLevel
    = Debug
    | Info
    | Warn
    | Error

derive instance Eq LogLevel
derive instance Ord LogLevel

instance Show LogLevel where
    show = case _ of
        Debug -> "DEBUG"
        Info  -> "INFO"
        Warn  -> "WARN"
        Error -> "ERROR"

type Log = LogLevel -> String -> Effect Unit

makeFileLog :: FilePath -> Effect Log
makeFileLog logfile =
    pure \severity msg -> do
        let contents = "[" <> show severity <> "] " <> msg <> "\n"
        FS.appendTextFile Encoding.UTF8 logfile contents (const $ pure unit)
