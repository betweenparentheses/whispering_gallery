## Whispering Gallery

An anonymous chat app that broadcasts all messages 60 minutes later, 
immediately before expiring their database entry. Additionally, push notifications
subtly let site visitors know that someone has entered a new message. Created as an 
experiment in Redis and Websockets, but also in creating private yet intimate spaces
for communication.

[Live Heroku Link](https://whispering-gallery.herokuapp.com)

###Technologies
- Sinatra
- Websockets
- Redis sorted sets, expiring keys, and pub/sub pattern
