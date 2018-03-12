ruleset edu.byu.enMotion {
// deprecated; to be replaced by edu.byu.enMotion.building
  meta {
    name "enMotion dispensers in a building"
    description <<
      Hold information about the state of all enMotion* dispensers in a building.
      *"enMotion" is a trademark of Georgia-Pacific consumer products LP.
    >>
    author "Crazy Friday Pico Enthusiasts (CFPE)"
    shares __testing, status, statusDay
  }
  global {
    __testing = { "queries": [ { "name": "__testing" }
                             , { "name": "status", "args": [ "id" ] }
                             ]
                , "events": [ { "domain": "tag", "type": "scanned", "attrs": [ "id" ] }
                            ]
                }
    status = function(id) {
      id => ent:tags{[id,"status"]} | ent:tags
    }
    statusDay = function(date) {
      dy = date => date | time:now().substr(0,10);
      ld = dy.length();
      eq = function(t1,t2){t1.substr(0,ld)==t2.substr(0,ld)};
      rightDay = function(time){time && eq(time,dy)};
      ent:tags.filter(function(v,k){rightDay(v{"timestamp"})})
    }
    earliest_date = "1969-12-31" // for mountain time
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
  rule initialization {
    select when tag scanned
    if ent:tags.isnull() then noop();
    fired {
      ent:tags := {};
    }
  }
  rule restart_count_for_a_new_day {
    select when tag scanned id re#^(.*)$# setting(id)
    pre {
      last_report_timestamp = ent:tags{[id,"timestamp"]}.defaultsTo(earliest_date);
      last_report_date = last_report_timestamp.substr(0,10);
      date_now = time:add(time:now(),{"hours": -6}).substr(0,10);
    }
    if date_now.klog("now") > last_report_date.klog("last") then noop();
    fired {
      ent:tags{[id,"count"]} := 0;
    }
  }
  rule count_and_timestamp_problem_report {
    select when tag scanned id re#^(.*)$# setting(id)
    pre {
      now = time:add(time:now(),{"hours": -6}); // MDT
      count = ent:tags{[id,"count"]} + 1;
    }
    send_directive("count",{"ordinal":ordinalize(count)});
    fired {
      ent:tags{[id,"timestamp"]} := now;
      ent:tags{[id,"count"]} := count;
    }
  }
  rule first_report_of_the_day {
    select when tag scanned id re#^(.*)$# setting(id)
    if ent:tags{[id,"count"]} == 1 then noop();
    fired {
      ent:tags{[id,"status"]} := "problem";
      raise enMotion event "problem_reported" attributes event:attrs;
    }
  }
}
