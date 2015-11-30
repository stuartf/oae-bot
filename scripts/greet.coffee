# Description:
#   Greet individuals when they enter
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot greet <user name>: <message>
#   hubot ungreet <user name>
#
# Author:
#   stuartf

setGreet = (data, toUser, message) ->
  data[toUser.name] = message

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.greets ||= {}

  robot.respond /greet (.*): (.*)/i, (msg) ->
    users = robot.usersForFuzzyName(msg.match[1])
    if users.length is 1
      user = users[0]
      setGreet(robot.brain.data.greets, user, msg.match[2])
      msg.send("Greeting prepared")
    else if users.length > 1
      msg.send "Too many users like that"
    else
      msg.send "#{msg.match[1]}? Never heard of 'em"

  robot.respond /ungreet (.*)/i, (msg) ->
    users = robot.usersForFuzzyName(msg.match[1])
    if users.length is 1
      user = users[0]
      delete robot.brain.data.greets[msg.message.user.name]
      msg.send "Greeting removed"
    else if users.length > 1
      msg.send "Too many users like that"
    else
      msg.send "#{msg.match[1]}? Never heard of 'em"

  robot.enter (msg) ->
    if (greet = robot.brain.data.greets[msg.message.user.name])
      msg.reply greet
