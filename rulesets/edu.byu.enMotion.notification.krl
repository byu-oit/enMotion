ruleset edu.byu.enMotion.notification {
  meta {
    use module io.picolabs.visual_params alias vp
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "notification", "type": "test" }
      , { "domain": "notification", "type": "new_keys", "attrs": [ "keys" ] }
      ]
    }
    channel = "#slack-bot-testing" //"#physical_facilities"
    hook = "https://hooks.slack.com/services"
  }
  rule stash_keys {
    select when notification new_keys
      keys re#^(T[^/]*/B[^/]*/[^/]*)$# setting(keys)
    if keys then send_directive("keys_stashed")
    fired {
      app:keys := keys
    }
  }
  rule test_notification {
    select when notification test
    pre {
      body = { "channel": channel,
               "text": "testing; please ignore",
               "username": vp:dname() }
    }
    if app:keys then // sanity check
    every {
      http:post(<<#{hook}/#{app:keys}>>,body=body.encode())
        setting(postResult)
      send_directive("postResult",postResult)
    }
    fired {
      ent:lastMessage := body;
      ent:lastResponse := postResult;
    }
  }
  rule notify_on_first_problem {
    select when enMotion problem_reported
    pre {
      body = { "channel": channel,
               "text": "problem reported for dispenser "+event:attr("id"),
               "username": vp:dname() }
    }
    if app:keys then // sanity check
      http:post(<<#{hook}/#{app:keys}>>,body=body.encode())
        setting(postResult)
    fired {
      ent:lastEvent := event:attrs;
      ent:lastMessage := body;
      ent:lastResponse := postResult;
    }
  }
}
