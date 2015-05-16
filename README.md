## Whispering Gallery

An anonymous chat app that broadcasts all messages 60 minutes later, 
immediately before expiring their database entry. Also uses push notifications
to notify site visitors that someone has entered a new message. Created as an 
experiment in Redis and Websockets, but also in creating private yet intimate spaces
for communication.

###Technologies
- Sinatra
- Websockets
- Redis sorted sets, key expiration patterns, and pub/sub pattern
