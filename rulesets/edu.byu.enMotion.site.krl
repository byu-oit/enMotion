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
      , "events": [ { "domain": "enMotion", "type": "building_added", "attrs": [ "bldg", "eci" ] }
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
      eci = event:attr("eci");
    }
    if not (ent:buildings >< bldg) then noop();
    fired {
      ent:buildings{bldg} := { "bldg": bldg, "eci": eci };
    }
  }
}
