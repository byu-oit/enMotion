ruleset edu.byu.enMotion.building {
  meta {
    name "enMotion dispensers in a building"
    description <<
      Hold information about all enMotion* dispensers in a building.
      Manage the life cycle of dispenser picos.
      *"enMotion" is a trademark of Georgia-Pacific consumer products LP.
    >>
    author "Crazy Friday Pico Enthusiasts (CFPE)"
    provides dispenser_rooms
    shares __testing, eci
  }
  global {
    __testing = { "queries": [ { "name": "__testing" }
                             , { "name": "eci", "args": [ "tag_id" ] }
                             ]
                , "events": [ { "domain": "tag", "type": "affixed", "attrs": [ "tag_id", "room_name" ] }
                            , { "domain": "tag", "type": "new_dispensers_ready", "attrs": [ "content" ] }
                            ]
                }
    eci = function(tag_id) {
      ent:tags{[tag_id,"eci"]}
    }
    import_re = re#^([A-Z]+[0-9]+[^ ]*) (.*)$#;
    dispenser_map = function(line) {
      parts = line.extract(import_re);
      { "tag_id": parts[0], "room_name": parts[1]}
    }
    import = function(content) {
      newline = (13.chr() + "?" + 10.chr()).as("RegExp");
      content.split(newline)
             .filter(function(line){line.match(import_re)})
             .map(dispenser_map)
    }
    dispenser_rooms = function() {
      ent:tags.map(function(v){v{"room_name"}})
    }
  }
  rule initialization {
    select when wrangler ruleset_added where rids >< meta:rid
    if ent:tags.isnull() then noop();
    fired {
      ent:tags := {};
    }
  }
  rule start_tracking_dispenser {
    select when tag affixed
    pre {
      tag_id = event:attr("tag_id");
      room_name = event:attr("room_name");
      rids = "edu.byu.enMotion.dispenser";
      child_specs = { "name": tag_id, "room_name": room_name, "rids": rids, "color": "#002e5d" };
    }
    if not (ent:tags >< tag_id) then noop();
    fired {
      raise wrangler event "new_child_request" attributes child_specs;
    }
  }
  rule pico_new_child_created {
    select when wrangler new_child_created
    pre {
      child_id = event:attr("id");
      child_specs = event:attr("rs_attrs");
      tag_id = child_specs{"name"};
      room_name = child_specs{"room_name"};
    }
    engine:newChannel(child_id, tag_id, "dispenser") setting (new_channel);
    fired {
      ent:tags{tag_id} := { "tag_id": tag_id, "room_name": room_name, "eci": new_channel{"id"}};
    }
  }
  rule import_dispensers {
    select when tag new_dispensers_ready
    foreach import(event:attr("content")) setting(map)
    fired {
      raise tag event "affixed" attributes map;
    }
  }
}
