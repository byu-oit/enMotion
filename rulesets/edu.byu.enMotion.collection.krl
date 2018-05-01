ruleset edu.byu.enMotion.collection {
  meta {
    use module io.picolabs.subscription alias Subs
    shares __testing, members
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "members" } ],
                  "events": [ ] }
    members = function(){
      Subs:established("Tx_role","member")
    }
  }
  rule auto_accept {
    select when wrangler inbound_pending_subscription_added
    pre {
      acceptable = event:attr("Rx_role")=="collection"
                && event:attr("Tx_role")=="member";
    }
    if acceptable then noop();
    fired {
      raise wrangler event "pending_subscription_approval"
        attributes event:attrs
    } else {
      raise wrangler event "inbound_rejection"
        attributes { "Rx": event:attr("Rx") } // event:attrs doesn't work!
    }
  }
}
