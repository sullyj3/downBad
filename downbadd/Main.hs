{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

-- Server Daemon

module Main (main) where

import Command qualified as Cmd
import Control.Monad
import Data.ByteString qualified as BS
import Data.ByteString.UTF8 qualified as UTF8
import Ki.Unlifted
import Network.Socket (Socket)
import Network.Socket qualified as Socket
import Network.Socket.ByteString (recv, sendAll)
import Streamly.Data.Fold qualified as Fold
import Streamly.Internal.Network.Inet.TCP (acceptOnPortLocal)
import Streamly.Prelude qualified as Stream
import System.IO (BufferMode (..), Handle, hGetLine, hPutStrLn, hSetBuffering, stderr)
import Prelude hiding (log)

port = 6777

log = hPutStrLn stderr

main :: IO ()
main = do
  hPutStrLn stderr $ "Server starting on localhost:" <> show port
  Stream.mapM_ handleClient $
    Stream.unfold acceptOnPortLocal port
  where
    handleClient sock = do
      log $ "Client connected on socket: " <> show sock
      loop sock

    loop :: Socket -> IO ()
    loop sock = do
      message <- recv sock 256
      if BS.null message
        then do
          Socket.close sock
          log "Client closed the connection"
        else do
          case Cmd.fromByteString message of
            Just cmd -> do
              log $ "Client: " <> show cmd
              case cmd of
                Cmd.CmdLs ->
                  sendAll sock "[]"
            Nothing -> do
              log $ "Client sent invalid command: " <> UTF8.toString message
              sendAll sock "error unknown command"
              Socket.close sock
          loop sock
