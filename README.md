# Webchat application


# Description

This is a simple application that should allow users to connect to chatrooms
and start chatting.
Once a chatroom has no members anymore (abandoned),
then its history will be abandoned as well.

# How to use

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
