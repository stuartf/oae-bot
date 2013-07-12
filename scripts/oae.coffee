# Description:
#   Various helpful oae things
#
# Commands:
#   nakamura - Tell people about nakamura

module.exports = (robot) ->
  robot.hear /nakamura/i, (msg) ->
    msg.send "nakamura is the deprecated oae backend, use hilary instead http://git.io/01eWyA"
