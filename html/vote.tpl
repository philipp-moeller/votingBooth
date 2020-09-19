<html>
  <head>
    <meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Abstimmung</title>
    <script>
			function clickButton(button) {
				var elem = document.getElementById('voted');
				var items = elem.value.split(';').filter(function(item) { return item!=''; });
				if (items.indexOf(button.value)==-1) {
					items.push(button.value);
					button.className = 'selected';
				}
				else {
					items.splice(items.indexOf(button.value),1);
					button.className = '';
				}
				elem.value = items.join(';');
			}
    </script>
		<link rel="stylesheet" href="/style.css">
  </head>
  <body>
    <h1>Abstimmung</h1>
		{{?success}}<span class="success">{{success}}</span>{{/?}}
		{{?error}}<span class="error">{{error}}</span>{{/?}}
    <form method="post" action="">
      <input type="hidden" id="voted" name="voted" value="{{voted}}" />
			{{~options}}
			<input type="button" value="{{options.name}}" onclick="clickButton(this);" {{?options.selected}}class="selected"{{/?}} /><br />
			{{/~}}
			<input type="submit" value="senden" />
    </form>
  </body>
</html>
