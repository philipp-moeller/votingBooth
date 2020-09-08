require 'sinatra'

# use local-ip here
set :bind, '192.168.1.201'
set :port, 4444

admin = 'vaOPhSbcDuvY5y8tr2hKGBn9dT5tdI5r'

def form(title,form)
	return File.read('form.html').gsub('{{title}}',title).sub('{{form}}',form)
end

def plain(title,text)
	return File.read('plain.html').gsub('{{title}}',title).sub('{{text}}',text)
end

def valid?(code)
	return File.read('codes.txt').split("\n").include?(code)
end

get '/' do
  form = '<input type="text" name="code" value="" /><input type="submit" value="senden" />'
  return form('Anmelden',form)
end

post '/' do
	code = params[:code]
	if valid?(code) then
		redirect '/'+code
	else
		redirect '/'
	end
end

get '/result/'+admin do
  options = File.read('options.txt').split("\n")
  votes = File.read('votes.txt').split("\n")
	results = {}
	for option in options do
		results[option] = 0
	end
	for submission in votes do
		items = submission.split(':')[1].split(';')
		for item in items do
			results[item] += 1
		end
	end
	content = votes.length.to_s+' mal abgestimmt<br /><br />'
	for option in options do
		content += option+' ('+results[option].to_s+')<br />'+'▮'*results[option]+'<br /><br />'
	end
  return plain('Ergebnisse',content)
end

get '/codes/'+admin do
	set = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	codes = []
	for i in 0..30 do
		codes.push(set[rand(set.length)]+set[rand(set.length)]+set[rand(set.length)])
	end
	File.write('codes.txt',codes.join("\n"))
  return plain('Codes',codes.join('<br />'))
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
  return form('Abstimmen',form)
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
	if (vote.length==2) then
		votes.push(code+':'+vote.join(';'))
		File.write('votes.txt',votes.join("\n"))
		text = '<p>Ihre Wahl wurde erfolgreich gespeichert.</p>'
	else
		text = '<p>Wählen Sie bitte genau zwei Projekte aus. Ihre Wahl wurde nicht gespeichert!</p>'
	end
  text += '<p><a href="">zurück</a></p>'
  return plain('Abstimmung',text);
end
