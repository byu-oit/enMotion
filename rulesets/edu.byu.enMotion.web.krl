ruleset edu.byu.enMotion.web {
  meta {
    provides header, footer
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    header = function(title) {
      <<<!doctype html>
<html>
<head>
<link rel="icon" type="image/png" href="http://picos.byu.edu/pico-logo-transparent-48x48.png">
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
<title>#{title}</title>
<meta charset="UTF-8">
</head>
<body>
<div class="containing-element">
<byu-header>
  <h1 slot="site-title">#{title}</h1>
</byu-header>
<div class="page-content">
>>
    }
    footer = function() {
      <<</div>
<byu-footer></byu-footer>
</div>
</body>
</html>
>>
    }
  }
}
