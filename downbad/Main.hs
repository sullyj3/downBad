{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

-- client

module Main (main) where

import Data.ByteString qualified as BS
import Data.ByteString.UTF8 qualified as UTF8
import Network.Run.TCP (runTCPClient)
import Network.Socket (Socket)
import Network.Socket qualified as Socket
import Network.Socket.ByteString (recv, sendAll)
import System.IO (BufferMode (..), Handle, hGetLine, hPutStrLn, hSetBuffering, stderr, hFlush)
import System.IO.Error
import Options.Applicative
import Command (Command)
import Command qualified as Cmd
import Control.Exception


lsMod :: Mod CommandFields Command
lsMod = command "ls" (info (pure Cmd.CmdLs) (progDesc "get a list of active downloads")) 

parserInfo' :: ParserInfo Command
parserInfo' = info
  (helper <*> parser')
  (fullDesc <> progDesc "downbad download daemon client")

parser' :: Parser Command
parser' = subparser lsMod

port = "6777"

main :: IO ()
main = do
  cmd <- execParser parserInfo'
  (runTCPClient "127.0.0.1" port (go cmd)) `catch` handleConnectionError

  where go cmd sock = do
          "Hello, client!" <- recv sock 256
          sendAll sock (UTF8.fromString "Hello, server!")
          "Ok" <- recv sock 256
          sendAll sock (Cmd.toByteString cmd)

        handleConnectionError :: IOException -> IO ()
        handleConnectionError exc
          | isDoesNotExistError exc = do
            hPutStrLn stderr $ "Couldn't connect to the downbad server. Make sure it's running!"
          | otherwise = ioError exc
