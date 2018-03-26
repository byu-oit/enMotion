ruleset edu.byu.enMotion.dispenser {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }
  rule initialize {
    select when wrangler child_created
    pre {
      child_specs = event:attr("rs_attrs");
      tag_id = child_specs{"name"};
      room_name = child_specs{"room_name"};
    }
    fired {
      ent:tag_id := tag_id;
      ent:room_name := room_name;
      ent:status := "ok";
    }
  }
}
