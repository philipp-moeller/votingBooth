<html>
  <head>
    <meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wahlmöglichkeiten</title>
		<link rel="stylesheet" href="/style.css">
  </head>
  <body>
    <h1>Wahlmöglichkeiten</h1>
		<a class="back" href="/admin">&#11176;</a>
		<p>{{votes}} mal abgestimmt.</p>
		{{~results}}
			{{results.name}}<br />
			{{~results.votes}}◼{{/~}}<br /><br />
		{{/~}}
  </body>
</html>
