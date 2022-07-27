{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

-- client

module Main (main) where

import Command (Command)
import Command qualified as Cmd
import Control.Exception
import Data.ByteString qualified as BS
import Data.ByteString.UTF8 qualified as UTF8
import Network.Run.TCP (runTCPClient)
import Network.Socket (Socket)
import Network.Socket qualified as Socket
import Network.Socket.ByteString (recv, sendAll)
import Options.Applicative
import System.IO (BufferMode (..), Handle, hFlush, hGetLine, hPutStrLn, hSetBuffering, stderr, hPrint)
import System.IO.Error

lsMod :: Mod CommandFields Command
lsMod = command "ls" (info (pure Cmd.CmdLs) (progDesc "get a list of active downloads"))

parserInfo' :: ParserInfo Command
parserInfo' =
  info
    (helper <*> parser')
    (fullDesc <> progDesc "downbad download daemon client")

parser' :: Parser Command
parser' = subparser lsMod

port = "6777"

main :: IO ()
main = do
  cmd <- execParser parserInfo'
  runTCPClient "127.0.0.1" port (go cmd) `catch` handleConnectionError
  where
    go cmd sock = do
      sendAll sock (Cmd.toByteString cmd)
      recv sock 256 >>= hPrint stderr

    handleConnectionError :: IOException -> IO ()
    handleConnectionError exc
      | isDoesNotExistError exc = do
          hPutStrLn stderr "Couldn't connect to the downbad server. Make sure it's running!"
      | otherwise = ioError exc
