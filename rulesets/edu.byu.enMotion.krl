ruleset edu.byu.enMotion {
// deprecated
  meta {
    name "enMotion dispensers in a building"
    description <<
      Hold information about the state of all enMotion* dispensers in a building.
      *"enMotion" is a trademark of Georgia-Pacific consumer products LP.
    >>
    author "Crazy Friday Pico Enthusiasts (CFPE)"
    shares __testing, status
  }
  global {
    __testing = { "queries": [ { "name": "__testing" }
                             , { "name": "status", "args": [ "id" ] }
                             ]
                , "events": [ { "domain": "tag", "type": "scanned", "attrs": [ "id" ] }
                            , { "domain": "admin", "type": "children_to_export" }
                            ]
                }
    status = function(id) {
      ent:tags{[id,"status"]}
    }
  }
  rule initialization {
    select when tag scanned
    if not ent:tags then noop();
    fired {
      ent:tags := {};
    }
  }
  rule report_problem {
    select when tag scanned
    pre {
      id = event:attr("id");
    }
    if status(id) == "ok" then send_directive("problem reported");
    always {
      ent:tags{[id,"status"]} := "problem";
    }
  }
  rule one_off {
    select when admin children_to_export
    foreach ent:tags setting(v,k)
    pre {
      child_specs = { "name": k };
    }
    fired {
      raise wrangler event "new_child_request" attributes child_specs;
    }
  }
}