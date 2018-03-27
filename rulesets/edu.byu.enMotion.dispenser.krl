ruleset edu.byu.enMotion.dispenser {
  meta {
    use module io.picolabs.wrangler alias Wrangler
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    ordinalize = function(n) {
      unit = n % 10;
      teen = 10 <= n && n < 20;
      suffix = teen      => "th"
             | unit == 1 => "st"
             | unit == 2 => "nd"
             | unit == 3 => "rd"
             |              "th";
      n.as("String") + suffix;
    }
  }
  rule initialize {
    select when wrangler child_created
    pre {
      child_specs = event:attr("rs_attrs");
      tag_id = child_specs{"name"};
      room_name = child_specs{"room_name"};
    }
    always {
      ent:tag_id := tag_id;
      ent:room_name := room_name;
      ent:status := "ok";
      ent:scans := {};
      ent:lastTimestamp := "1969-12-31";
      ent:count := 0; // for latest date scanned
    }
  }
  rule valid_id_guard {
    select when tag scanned id re#^(.+)$# setting(id)
    if ent:tag_id == id then noop();
    notfired { last; }
  }
  rule restart_count_for_a_new_day {
    select when tag scanned
    pre {
      last_scan_date = ent:lastTimestamp.substr(0,10);
      date_now = time:add(time:now(),{"hours": -6}).substr(0,10);
    }
    if date_now > last_scan_date then noop();
    fired {
      ent:count := 0;
      ent:status := "ok"; // assume any problems were repaired overnight
    }
  }
  rule record_timestamp_and_count {
    select when tag scanned
    pre {
      now = time:add(time:now(),{"hours": -6}); // MDT
      count = ent:count + 1;
    }
    send_directive("count",{"ordinal":ordinalize(count)});
    fired {
      ent:lastTimestamp := now;
      ent:count := count;
      ent:scans{now} := {"timestamp": now, "count": count};
    }
  }
  rule first_report_of_the_day {
    select when tag scanned
    if ent:count == 1 then noop();
    fired {
      ent:status := "problem";
      ent:scans{[ent:lastTimestamp,"status"]} := ent:status;
      raise enMotion event "problem_reported" attributes event:attrs;
    }
  }
  rule send_summary_to_building {
    select when tag scanned
    pre {
      summary = {"id": ent:tag_id, "count": ent:count, "status": ent:status,
        "timestamp": ent:lastTimestamp }
    }
    event:send({"eci": Wrangler:parent_eci(),
      "domain": "enMotion", "type": "tag_scanned",
      "attrs": summary
    })
    fired {
      raise enMotion event "summary_sent" attributes summary;
    }
  }
}
