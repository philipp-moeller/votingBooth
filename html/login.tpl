<html>
  <head>
    <meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anmeldung</title>
		<link rel="stylesheet" href="/style.css">
  </head>
  <body>
    <h1>Anmeldung</h1>
		{{?success}}<span class="success">{{success}}</span>{{/?}}
		{{?error}}<span class="error">{{error}}</span>{{/?}}
    <form method="post" action="">
      <input type="password" name="code" value="" />
			<br />
			<input type="submit" value="senden" />
    </form>
  </body>
</html>
