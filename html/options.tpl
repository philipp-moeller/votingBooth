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
		<p>Hinweis: Beim Speichern der Wahlmöglichkeiten werden alle bisherigen Daten ohne Nachfrage zurückgesetzt.</p>
		{{?success}}<span class="success">{{success}}</span>{{/?}}
		<form method="post" action="">
			<textarea name="options" rows="12">{{options}}</textarea>
			<input type="submit" value="speichern" />
    </form>
  </body>
</html>
