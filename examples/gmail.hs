{-# LANGUAGE OverloadedStrings #-}

import Network.HaskellNet.IMAP
import Network.HaskellNet.IMAP.SSL

import Network.HaskellNet.SMTP
import Network.HaskellNet.SMTP.SSL

import Network.HaskellNet.SSL

import Network.HaskellNet.Auth (AuthType(LOGIN))

import qualified Data.ByteString.Char8 as B

username = "username@gmail.com"
password = "password"
recipient = "someone@somewhere.com"

imapTest = do
    c <- connectIMAPSSLWithSettings "imap.gmail.com" cfg
    login c username password
    mboxes <- list c
    mapM_ print mboxes
    select c "INBOX"
    msgs <- search c [ALLs]
    let firstMsg = head msgs
    msgContent <- fetch c firstMsg
    B.putStrLn msgContent
    logout c
  where cfg = defaultSettingsIMAPSSL { sslMaxLineLength = 100000 }

smtpTest = doSMTPSTARTTLS "smtp.gmail.com" $ \c -> do
    r@(rsp, _) <- sendCommand c $ AUTH LOGIN username password
    if rsp /= 235
      then print r
      else sendMail username [recipient] mailContent c
  where mailContent = subject `B.append` body
        subject = "Subject: Test message\r\n\r\n"
        body = "This is a test message"

main :: IO ()
main = smtpTest >> imapTest >> return ()
