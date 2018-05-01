ruleset edu.byu.enMotion.building.grouper {
  meta {
    use module edu.byu.enMotion.building alias building
    shares __testing, by_prefix
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "by_prefix", "args": [ "name_prefix" ] } ],
                  "events": [ {"domain":"grouper","type":"creation","attrs":["name_prefix"]}] }
    //-----------------------------------
    //compute array of dispenser picos whose names have a given prefix
    //
    by_prefix = function(name_prefix) {
      prefix_re = ("^"+name_prefix).as("RegExp");
      building:dispenser_rooms().filter(function(v){v like prefix_re})
    }
    //-----------------------------------
    //obtain subscription request ECI for a dispenser pico, or null
    //
    get_wellKnown_eci = function(eci) {
      url = meta:host+"/sky/cloud/"+eci+"/io.picolabs.subscription/wellKnown_Rx";
      http:get(url.klog("url")){"content"}.decode(){"id"}
    }
  }
  //-----------------------------------
  //start process to create a group-of-dispensers pico
  //asking for a new child pico
  //
  rule collection_needed {
    select when grouper creation
    pre {
      name_prefix = event:attr("name_prefix");
      group_name = name_prefix + " Rooms";
      rids = "edu.byu.enMotion.collection;io.picolabs.subscription";
      child_specs = { "name": group_name, "name_prefix": name_prefix,
        "rids": rids, "color": "#002e5d" };
    }
    fired {
      raise wrangler event "new_child_request" attributes child_specs;
    }
  }
  //-----------------------------------
  //start process to create a group-of-dispensers pico
  //verify that all dispenser picos can do subscriptions
  //
  rule collection_creation {
    select when grouper creation
    fired {
      raise grouper event "need_subscribability" attributes event:attrs;
    }
  }
  //-----------------------------------
  //verify that all dispenser picos can do subscriptions
  //for any that don't, install the io.picolabs.subscription ruleset
  //
  rule collection_subscription_check {
    select when grouper need_subscribability
    foreach by_prefix(event:attr("name_prefix")) setting(v,k)
    pre {
      tag_id = k.klog("tag_id");
      room_name = v.klog("room_name");
      eci = building:eci(tag_id);
      wellKnown_Tx = get_wellKnown_eci(eci).klog("wellKnown_Tx");
    }
    if wellKnown_Tx.isnull() then every {
      send_directive(tag_id,{"eci":eci,"room_name":room_name});
      event:send({"eci":eci,"domain":"wrangler","type":"install_rulesets_requested",
        "attrs": { "rid": "io.picolabs.subscription" }
      })
    }
  }
  //-----------------------------------
  //when the new group-of-dispensers pico is ready for use
  //obtain its subscription request ECI
  //
  rule collection_subscriptions {
    select when wrangler child_initialized
    pre {
      eci = event:attr("eci").klog("child_eci");
      collection_eci = get_wellKnown_eci(eci).klog("collection_eci")
    }
    if collection_eci then noop();
    fired {
      raise grouper event "need_subscriptions"
        attributes event:attr("rs_attrs").put("collection_eci",collection_eci)
    }
  }
  //-----------------------------------
  //have each dispenser pico propose a subscription to the collection pico
  //
  rule collection_subscription_requests {
    select when grouper need_subscriptions
    foreach by_prefix(event:attr("name_prefix")) setting(v,k)
    pre {
      tag_id = k.klog("tag_id");
      room_name = v.klog("room_name");
      eci = building:eci(tag_id);
      wellKnown_Tx = get_wellKnown_eci(eci).klog("wellKnown_Tx");
    }
    if wellKnown_Tx then every {
      event:send({"eci":eci,"domain":"wrangler","type":"subscription",
        "attrs": { "wellKnown_Tx": event:attr("collection_eci"),
          "Rx_role": "member", "Tx_role": "collection",
          "name": tag_id, "channel_type": "subscription" }
      })
    }
  }
}
