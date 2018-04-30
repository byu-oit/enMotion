ruleset edu.byu.enMotion.building.web {
  meta {
    use module edu.byu.enMotion.web alias web
    use module edu.byu.enMotion.building alias building
    shares __testing, dispensers_page, status_page
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  //------------------------------
  //dispensers_page
  //
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
  //------------------------------
  //status_page
  //
    status_header = function(){
      <<  <tr style="text-align:left">
    <th>tag_id</th>
    <th>room_name</th>
    <th>count</th>
    <th>status</th>
    <th>timestamp</th>
  </tr>
>>
    }
    dispenser_summary = function(stuff,tag_id){
      summary = stuff{"summary"};
      <<  <tr>
    <td>#{stuff{"tag_id"}}</td>
    <td>#{stuff{"room_name"}}</td>
    <td style="text-align:right">#{summary{"count"}}</td>
    <td>#{summary{"status"}}</td>
    <td>#{summary{"timestamp"}}</td>
  </tr>
>>
    }
    sort_function = function(sortBy) {
      s = ["count","status","timestamp"] >< sortBy => sortBy | null;
      t = ["tag_id","room_name"] >< sortBy => sortBy | "tag_id";
      s => function(a,b){a{["summary",s]} cmp b{["summary",s]}} 
         | function(a,b){a{t} cmp b{t}}
    }
    status_page = function(date,sortBy) {
      date_re = date.isnull() => re#.# | ("^"+date).as("RegExp");
      ds = building:dispenser_summary()
        .values()
        .filter(function(v){s=v{"summary"};s&&s{"timestamp"}.match(date_re)})
        .sort(sort_function(sortBy));
      <<#{web:header("enMotion status")}
<table>
#{status_header()}#{ds.map(dispenser_summary).join("")}
</table>
#{web:footer()}
>>
    }
  }
}
