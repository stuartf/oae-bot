# Just mention a jira issue to get it's summary and link
module.exports = (robot) ->

  robot.hear /(KERN-|SAKIII-)(\d+)/i, (msg) ->
    issue = msg.match[1].toUpperCase() + msg.match[2]
    msg.http("https://jira.sakaiproject.org/rest/api/2.0.alpha1/issue/" + issue)
      .get() (err, res, body) ->
        try
          msg.send "[" + issue + "] " + JSON.parse(body).fields.summary.value
          msg.send "https://jira.sakaiproject.org/browse/" + issue
        catch error
          try
            msg.send "[" + issue + " *ERROR*] " + JSON.parse(body).errorMessages[0]
          catch reallyError
            msg.send "[" + issue + " *ERROR*] Couldn't parse message from JIRA"
