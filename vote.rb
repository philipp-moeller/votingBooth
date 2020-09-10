require 'sinatra'

# use local-ip here
set :bind, '0.0.0.0'
set :port, 4444
enable :sessions

configFile = File.read('.config').split("\n")
config = {}
for row in configFile do
	configData = row.split(':')
	config[configData[0]] = configData[1]
end

def form(title,form,text)
	return File.read('form.html').gsub('{{title}}',title).sub('{{text}}',text).sub('{{form}}',form)
end

def plain(title,text)
	return File.read('plain.html').gsub('{{title}}',title).sub('{{text}}',text)
end

def valid?(code)
	return File.read('codes.txt').split("\n").include?(code)
end

get '/' do
  form = '<input type="text" name="code" value="" /><br /><input type="submit" value="senden" />'
  return form('Anmelden',form,'')
end

post '/' do
	code = params[:code]
	if valid?(code) then
		redirect '/'+code
	else
		if code==config['adminPassword'] then
			session[:admin] = true
			if session[:redirect] then
				page = session[:redirect]
				session[:redirect] = false
			else
				page = '/admin'
			end
			redirect page
		else
			redirect '/'
		end
	end
end

get '/admin' do
	if session[:admin] then
		text = '<input type="button" onclick="window.location.href=\'/codes\'" value="Codes anzeigen">'
		text += '<input type="button" onclick="window.location.href=\'/options\'" value="Wahlmöglichkeiten anzeigen">'
		text += '<input type="button" onclick="window.location.href=\'/results\'" value="Ergebnis anzeigen">'
		text += '<form method="post" action=""><input type="submit" value="abmelden" /></form>'
		return plain('Administration',text)
	else
		session[:redirect] = '/admin'
		redirect '/'
	end
end

post '/admin' do
	session[:admin] = false
	redirect '/'
end

get '/options' do
	if session[:admin] then
		options = File.read('options.txt')
		text = '<a class="back" href="/admin">&#11176;</a>';
		text += '<p>Hinweis: Beim Speichern der Wahlmöglichkeiten werden alle bisherigen Daten ohne Nachfrage zurückgesetzt.</p>'
		form = '<textarea name="options" rows="12">'+options+'</textarea>'
		form += '<input type="submit" value="speichern" />'
	  return form('Optionen',form,text)
	else
		session[:redirect] = '/options'
		redirect '/'
	end
end

post '/options' do
	if session[:admin] then
		File.write('options.txt',params[:options])
		File.write('votes.txt','')
	  redirect '/options'
	else
		redirect '/'
	end
end

get '/results' do
	if session[:admin] then
	  options = File.read('options.txt').split("\n")
	  votes = File.read('votes.txt').split("\n")
		results = {}
		for option in options do
			results[option] = 0
		end
		for submission in votes do
			items = submission.split(':')[1].split(';')
			for item in items do
				if results[item]!=nil then
					results[item] += 1
				end
			end
		end
		content = '<a class="back" href="/admin">&#11176;</a>';
		content += votes.length.to_s+' mal abgestimmt<br /><br />'
		for option in options do
			content += option+' ('+results[option].to_s+')<br />'+'▮'*results[option]+'<br /><br />'
		end
	  return plain('Ergebnisse',content)
	else
		session[:redirect] = '/results'
		redirect '/'
	end
end

get '/codes' do
	if session[:admin] then
		codes = File.read('codes.txt').split("\n")
		text = '<a class="back" href="/admin">&#11176;</a>';
		text += '<p>Hinweis: Beim Erstellen neuer Codes werden alle bisherigen Daten ohne Nachfrage zurückgesetzt.</p>'
		for code in codes do
			text += '<div class="card">'+code+'</div>'
		end
		text += '<form method="post" action=""><input type="submit" value="Neu generieren" /></form>'
	  return plain('Codes',text)
	else
		session[:redirect] = '/codes'
		redirect '/'
	end
end

post '/codes' do
	if session[:admin] then
		set = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		codes = []
		for i in 0..30 do
			codes.push(set[rand(set.length)]+set[rand(set.length)]+set[rand(set.length)])
		end
		File.write('codes.txt',codes.join("\n"))
		File.write('votes.txt','')
	  redirect '/codes'
	else
		redirect '/'
	end
end

get '/:code' do
	code = params[:code]
	if !valid?(code) then
		redirect '/'
	end
  options = File.read('options.txt').split("\n").shuffle()
	form = '<input type="hidden" id="voted" name="voted" value="" />'
	for option in options do
		form += '<input type="button" value="'+option+'" onclick="clickButton(this);" /><br />'
	end
	form += '<input type="submit" value="senden" />'
  return form('Abstimmung',form,'')
end

post '/:code' do
	code = params[:code]
	if !valid?(code) then
		redirect '/'
	end
  votes = File.read('votes.txt').split("\n")
	for submission in votes do
		if (submission.start_with?(code))
			votes.delete(submission)
		end
	end
	vote = params['voted'].split(';')
	text = '<a class="back" href="">&#11176;</a>';
	if (vote.length==2) then
		votes.push(code+':'+vote.join(';'))
		File.write('votes.txt',votes.join("\n"))
		text += '<p>Ihre Wahl wurde erfolgreich gespeichert.</p>'
	else
		text += '<p>Wählen Sie bitte genau zwei Projekte aus. Ihre Wahl wurde nicht gespeichert!</p>'
	end
  return plain('Abstimmung',text);
end
