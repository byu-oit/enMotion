ruleset edu.byu.enMotion.building.web {
  meta {
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
      <<<!doctype html>
<html>
<head>
<link rel="icon" type="image/png" href="pico-logo-transparent-48x48.png">
<link type="text/css" rel="stylesheet" href="//cloud.typography.com/75214/6517752/css/fonts.css" media="all" />
<link rel="stylesheet" href="https://cdn.byu.edu/byu-theme-components/latest/byu-theme-components.min.css" />
<script async src="https://cdn.byu.edu/byu-theme-components/latest/byu-theme-components.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body { height: 100%; }
.containing-element {
  display: flex;
  flex-direction: column;
  height: 100%;
}
.page-content { flex-grow: 1; margin-left: 10px }
</style>
<title>enMotion pilot project</title>
<meta charset="UTF-8">
</head>
<body>
<div class="containing-element">
<byu-header>
  <h1 slot="site-title">enMotion pilot project</h1>
</byu-header>
<div class="page-content">
<p>See <a href="https://github.com/byu-oit/enMotion">GitHub</a></p>
<p>Click on a link below to report a problem:</p>
#{building:dispenser_rooms().map(dispenser_link).values().join("")}</div>
<byu-footer></byu-footer>
</div>
</body>
</html>
>>
    }
  }
}
