ruleset edu.byu.enMotion.dispenser {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }
  rule initialize {
    select when wrangler ruleset_added where rids >< meta:rid
    if not ent:status then noop();
    fired {
      ent:status := "ok";
    }
  }
}
