ruleset edu.byu.enMotion.site {
  meta {
    shares __testing, buildings, buildingECI
  }
  global {
    __testing =
      { "queries": [ { "name": "__testing" }
                   , { "name": "buildings" }
                   , { "name": "buildingECI", "args": [ "bldg" ] }
                   ]
      , "events": [ { "domain": "enMotion", "type": "building_added", "attrs": [ "bldg" ] }
                  ]
      }
    buildings = function() {
      ent:buildings
    }
    buildingECI = function(bldg) {
      ent:buildings{[bldg,"eci"]}
    }
  }
  rule initialize {
    select when wrangler ruleset_added where rids >< meta:rid
    if not ent:buildings then noop();
    fired {
      ent:buildings := {};
    }
  }
  rule new_building {
    select when enMotion building_added
    pre {
      bldg = event:attr("bldg");
      name = "enMotion "+bldg;
      rids = "edu.byu.enMotion";
      child_specs = { "name": name, "rids": rids, "bldg": bldg, "color": "#002e5d" };
    }
    if not (ent:buildings >< bldg) then noop();
    fired {
      raise wrangler event "new_child_request" attributes child_specs;
    }
  }
  rule pico_new_child_created {
    select when pico new_child_created
    pre {
      child_id = event:attr("id");
      child_eci = event:attr("eci");
      child_specs = event:attr("rs_attrs");
      bldg = child_specs{"bldg"};
    }
    engine:newChannel(child_id, bldg, "building") setting (new_channel);
    fired {
      ent:buildings{bldg} := { "bldg": bldg, "eci": new_channel{"id"}};
    }
  }
}
