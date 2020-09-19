<html>
  <head>
    <meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Codes</title>
		<link rel="stylesheet" href="/style.css">
  </head>
  <body>
    <h1>Codes</h1>
		<a class="back" href="/admin">&#11176;</a>
		<p>Hinweis: Beim Erstellen neuer Codes werden alle bisherigen Daten ohne Nachfrage zurückgesetzt.</p>
		{{~codes}}
		<div class="card"><a href="/{{codes}}">{{codes}}</a></div>
		{{/~}}
    <form method="post" action=""><input type="submit" value="Neu generieren" /></form>
  </body>
</html>
