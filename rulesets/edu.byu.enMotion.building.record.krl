ruleset edu.byu.enMotion.building.record {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "record", "type": "new_url", "attrs": [ "url" ] }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
  }
  rule set_up_url {
    select when record new_url url re#^(http.*)# setting(url)
    fired {
      ent:url := url;
      ent:urlInEffectSince := time:now()
    }
  }
  rule record_tag_scan_to_sheet {
    select when enMotion tag_scanned where ent:url
    pre {
      ts = time:strftime(event:attr("timestamp"), "%F %T");
      data = {
        "id": event:attr("id"),
        "timestamp": ts,
        "count": event:attr("count"),
        "status": event:attr("status")
      }
    }
    http:post(ent:url,qs=data) setting(response)
    fired {
      ent:lastData := data;
      ent:lastResponse := response;
      raise record event "tag_scan_recorded_to_sheet" attributes event:attrs
    }
  }
}
