ruleset edu.byu.enMotion.building.web {
  meta {
    use module edu.byu.enMotion.web alias web
    use module edu.byu.enMotion.building alias building
    shares __testing, dispensers_page
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    dispenser_link = function(room_name,tag_id) {
      <<<a href="#{tag_id}">#{tag_id} #{room_name}</a><br>
>>
    }
    dispensers_page = function() {
      <<#{web:header("enMotion pilot project")}
<p>See <a href="https://github.com/byu-oit/enMotion">GitHub</a></p>
<p>Click on a link below to report a problem:</p>
#{building:dispenser_rooms().map(dispenser_link).values().join("")}
#{web:footer()}
>>
    }
  }
}
