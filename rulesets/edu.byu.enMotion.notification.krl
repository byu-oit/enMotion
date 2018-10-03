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
    channel = "#physical_facilities"
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
    if app:keys then // sanity check
    every {
      http:post(<<#{hook}/#{app:keys}>>,
        body = <<{ "channel": "#{channel}",>>
             + << "text": "testing #{vp:dname()}; please ignore"}>>)
        setting(postResult)
      send_directive("postResult",postResult)
    }
  }
}
