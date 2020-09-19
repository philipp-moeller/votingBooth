require 'sinatra'
load 'template.rb'

configFile = File.read('.config').split("\n")
config = {}
for row in configFile do
	configData = row.split(':')
	config[configData[0].to_sym] = configData[1]
end

set :bind, config[:host]
set :port, config[:port]
enable :sessions

session = {:success => false, :error => false, :admin => false, :redirect => false}

def valid?(code)
	return File.read('codes.txt').split("\n").include?(code)
end

get '/' do
	tpl = Template.new('login',{:success => session[:success], :error => session[:error]})
	session[:success] = false
	session[:error] = false
  return tpl.parse
end

post '/' do
	code = params[:code]
	if valid?(code) then
		redirect '/'+code
	else
		if code==config[:adminPassword] then
			page = session[:redirect] ? session[:redirect] : '/admin'
			session[:admin] = true
			session[:redirect] = false
			redirect page
		else
			session[:error] = 'Login fehlgeschlagen'
			redirect '/'
		end
	end
end

get '/admin' do
	if session[:admin] then
		tpl = Template.new('admin',{})
		return tpl.parse
	else
		session[:redirect] = '/admin'
		redirect '/'
	end
end

post '/admin' do
	session[:admin] = false
	session[:success] = 'Erfolgreich abgemeldet'
	redirect '/'
end

get '/options' do
	if session[:admin] then
		options = File.read('options.txt')
		tpl = Template.new('options',{:options => options, :success => session[:success]})
		session[:success] = false
		return tpl.parse
	else
		session[:redirect] = '/options'
		redirect '/'
	end
end

post '/options' do
	if session[:admin] then
		File.write('options.txt',params[:options])
		File.write('votes.txt','')
		session[:success] = 'Wahlmöglichkeiten erfolgreich gespeichert'
	  redirect '/options'
	else
		redirect '/'
	end
end

get '/results' do
	if session[:admin] then
	  options = File.read('options.txt').split("\n")
	  votes = File.read('votes.txt').split("\n")
		results = []
		for option in options do
			results.push({:name => option.chop, :votes => 0})
		end
		for submission in votes do
			items = submission.split(':').at(1).split(';')
			for item in items do
				for result in results do
					if result[:name]==item then
						result[:votes] += 1
					end
				end
			end
		end
		tpl = Template.new('results',{:votes => votes.length, :results => results})
		return tpl.parse
	else
		session[:redirect] = '/results'
		redirect '/'
	end
end

get '/codes' do
	if session[:admin] then
		codes = File.read('codes.txt').split("\n")
		tpl = Template.new('codes',{:codes => codes})
		return tpl.parse
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
  options = []
	for option in File.read('options.txt').split("\n").shuffle() do
		options.push({:name => option.chop, :selected => false})
	end
  votes = File.read('votes.txt').split("\n")
	items = []
	for submission in votes do
		if (submission.start_with?(code))
			items = submission.split(':').at(1).split(';')
			for option in options do
				if items.include?(option[:name]) then
					option[:selected] = true
				end
			end
		end
	end
	tpl = Template.new('vote',{:voted => items.join(';'), :options => options, :success => session[:success], :error => session[:error]})
	session[:success] = false
	session[:error] = false
	return tpl.parse
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
		session[:success] = '<p>Ihre Wahl wurde erfolgreich gespeichert.</p>'
	else
		session[:error] = 'Wählen Sie bitte genau zwei Projekte aus. Ihre Wahl wurde nicht gespeichert!'
	end
	redirect '/'+code
end
