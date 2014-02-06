#!/usr/bin/env python

import email, getpass, os, re, string
import imaplib2, time
from threading import *

user = 'fountainheadgame@gmail.com'
pwd = 'fountain2088'
# This is the threading object that does all the waiting on 
# the event
class Idler(object):
    def __init__(self, conn):
        self.thread = Thread(target=self.idle)
        self.M = conn
        self.event = Event()
 
    def start(self):
        self.thread.start()
 
    def stop(self):
        # This is a neat trick to make thread end. Took me a 
        # while to figure that one out!
        self.event.set()
 
    def join(self):
        self.thread.join()
 
    def idle(self):
        # Starting an unending loop here
        while True:
            # This is part of the trick to make the loop stop 
            # when the stop() command is given
            if self.event.isSet():
                return
            self.needsync = False
            # A callback method that gets called when a new 
            # email arrives. Very basic, but that's good.
            def callback(args):
                if not self.event.isSet():
                    self.needsync = True
                    self.event.set()
            # Do the actual idle call. This returns immediately, 
            # since it's asynchronous.
            self.M.idle(callback=callback)
            # This waits until the event is set. The event is 
            # set by the callback, when the server 'answers' 
            # the idle call and the callback function gets 
            # called.
            self.event.wait()
            # Because the function sets the needsync variable,
            # this helps escape the loop without doing 
            # anything if the stop() is called. Kinda neat 
            # solution.
            if self.needsync:
                self.event.clear()
                self.dosync()
 
    # The method that gets called when a new email arrives. 
    # Replace it with something better.
    def dosync(self):
       resp, items = M.search(None, 'UNSEEN') # you could filter using the IMAP rules here (check http://www.example-code.com/csharp/imap-search-critera.asp)
       items = items[0].split() # getting the mails id

       for emailid in items:
           resp, data = M.fetch(emailid, "(RFC822)") # fetching the mail, "`(RFC822)`" means "get the whole stuff", but you can ask for headers only, etc
           email_body = data[0][1] # getting the mail content
           mail = email.message_from_string(email_body) # parsing the mail content to get a mail object
       
           t = re.search("\([0-9]{3}\)\s[0-9]{3}-[0-9]{4}", mail["Subject"])
           if t is not None:
               txt = t.group(0)
               txtnum = re.sub("\D", "", txt)
               body_re = re.compile("^Content.*", re.DOTALL | re.MULTILINE)
               tail_re = re.compile("--.*", re.DOTALL | re.MULTILINE)
               rawmail = body_re.search(email_body)
               rawmail = re.sub("Content.*\n", "", rawmail.group(0))
               rawmail = tail_re.sub("", rawmail)
               rawmail = string.strip(rawmail)
               fd = open('texts', 'a')
               fd.write(rawmail + "|" + txtnum + '\n')
               fd.close()
 
# Had to do this stuff in a try-finally, since some testing 
# went a little wrong.....
try:
    # Set the following two lines to your creds and server
    M = imaplib2.IMAP4_SSL("imap.gmail.com")
    M.login(user,pwd)
    # We need to get out of the AUTH state, so we just select 
    # the INBOX.
    M.select("INBOX")
    # Start the Idler thread
    idler = Idler(M)
    idler.start()
    # Because this is just an example, exit after 1 minute.
    while True:
        time.sleep(5)
finally:
    # Clean up.
    idler.stop()
    idler.join()
    M.close()
    # This is important!
    M.logout()
