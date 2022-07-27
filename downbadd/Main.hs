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
      sendAll sock (UTF8.fromString "Hello, client!")
      resp <- recv sock 256
      if resp == "Hello, server!"
        then do
          sendAll sock (UTF8.fromString "Ok")
          loop sock
        else do
          log "client got the handshake wrong. Closing the connection"
          Socket.close sock

    loop :: Socket -> IO ()
    loop sock = do
      resp <- recv sock 256
      if BS.null resp
        then do
          Socket.close sock
          log "Client closed the connection"
        else do
          case Cmd.fromByteString resp of
            Just cmd -> do
              log $ "Client: " <> show cmd
            Nothing -> do
              log $ "Client sent invalid command: " <> UTF8.toString resp
          loop sock
