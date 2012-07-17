# Description:
#   Mail the channel logs from couch at midnight
#
# Dependencies:
#   nodemailer
#
# Configuration:
#   None
#
# Commands:
#
# Authors:
#   stuartf

midnight = new Date()
midnight.setHours 24, 0, 0, 0
midnight = midnight.getTime() - new Date().getTime()
msPerDay = 86400000
nodemailer = require 'nodemailer'
http = require 'http'
transport = nodemailer.createTransport "SMTP", {
  service: "SendGrid",
  auth: {
    user: process.env.SENDGRID_USERNAME,
    pass: process.env.SENDGRID_PASSWORD
  }
}

getDays = =>
  now = new Date()
  yesterday = new Date(now.getTime() - msPerDay)
  [yesterday, now]

formatKey = (d) ->
  "%5B#{d.getFullYear()}%2C#{d.getMonth()}%2C#{d.getDate()}%5D"

sendlogs = =>
  days = getDays()
  startKey = formatKey days[0]
  endKey = formatKey days[1]
  data = ''

  http.get {
    host: "sakai.iriscouch.com",
    path: "/irc/_design/viewer/_view/messages?include_docs=true
&reduce=false&startkey=#{startKey}&endkey=#{endKey}"
  }, (res) =>
    res.on 'data', (chunk) =>
      data += chunk.toString()
    res.on 'end', () =>
      json = JSON.parse data
      sendEmail days[0], json

formatTimecode = (key) ->
  hours = "#{key[3]}"
  mins = "#{key[4]}"
  if hours.length == 1
    hours = "0" + hours
  if mins.length == 1
    mins = "0" + mins
  return "#{hours}:#{mins}"

formatLine = (row) =>
  "#{formatTimecode(row.key)} <#{row.doc.user.name}> #{row.doc.text}\n"

formatLogs = (json) =>
  text = ''
  text += formatLine(row) for row in json.rows
  return text

sendEmail = (day, json) =>
  mailOptions = {
    from: "Sakai-Bot <noreply@sakai-bot.herokuapp.com>",
    to: "oae-dev@collab.sakaiproject.org",
    replyTo: "oae-dev@collab.sakaiproject.org",
    subject: "IRC Logs from #{day.toDateString()}",
    text: "The IRC channel is #sakai on the freenode network,
 you can join using a web client at
 http://webchat.freenode.net/?channels=sakai and you can view the
 complete logs at http://sakai.iriscouch.com/irc/_design/viewer/index.html
\n\n#{formatLogs(json)}"
  }
  transport.sendMail mailOptions, (err, res) ->
    if err
      console.log err
    else
      console.log "IRC Logs emailed: #{res}"

setupInterval = =>
  setInterval sendlogs, msPerDay

setTimeout sendlogs, midnight
setTimeout setInterval, midnight

module.exports = (robot) ->
  console.log "IRC Log mailer loaded"
