# Webchat application

This is a simple application that should allow users to connect to chatrooms
and start chatting.
Once a chatroom has no members anymore (abandoned),
then its history will be abandoned as well.

# How to use

What's below is from a dev point of view. Once the server is up and running it should be pretty straight forward to use. At least I hope so...

## Prerequisites

 * [nodejs](http://nodejs.org/download/)

## Starting up the server

```shell
npm install
grunt
```
## Testing

**Unit tests**

`npm test`

**E2E tests**

In seperate terminals, run the commands
`NODE_ENV=test npm start` and
`npm run protractor`
