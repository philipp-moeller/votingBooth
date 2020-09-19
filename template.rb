class Template

	VAR_IDENTIFIER = '[^\s{}]+'
	BASE_FOLDER = 'html/'

	def initialize(filename,vars)
		filename = BASE_FOLDER+filename+'.tpl'
		if File.file?(filename) then
			@raw = File.read(filename)
		else
			@raw = ''
		end
		@vars = vars
	end

	def parse()
		parsed = self.parseLoops(@raw)
		parsed = self.parseConditions(parsed)
		parsed = self.parseVars(parsed)
		return parsed
	end

	def to_s()
		return self.parse
	end

#	private
	def var(bracket)
		sequence = bracket.gsub(/{|}/,'').split('.')
		symbol = sequence.shift.to_sym
		if @vars[symbol]!=nil then
			value = @vars[symbol].clone
			while !sequence.empty? do
				detail = sequence.shift
				if value.is_a?(Array) then
					value = value[detail.to_i]
				elsif value.is_a?(Hash) then
					value = value[detail.to_sym]
				end
			end
			return value
		else
			return false
		end
	end

	def parseVars(string)
		regexp = Regexp.new('{{'+VAR_IDENTIFIER+'}}')
		matches = string.scan(regexp)
		while !matches.empty? do
			bracket = matches.shift()
			value = self.var(bracket)
			if value==false then
				value = ''
			end
			string.gsub!(bracket,value.to_s)
		end
		return string
	end

	def parseConditions(string)
		puts '''
			parsing conditions ...
		'''
		regexp = Regexp.new('{{\?('+VAR_IDENTIFIER+')}}(.*?)({{:\?}}.*?)?{{\/\?}}',Regexp::MULTILINE)
		matches = string.scan(regexp)
		while !matches.empty? do
			match = matches.shift()
			replace = Regexp.new('{{\?'+match[0]+'}}(.*?)({{:\?}}.*?)?{{\/\?}}',Regexp::MULTILINE)
			value = self.var(match[0])
			if value==false || value==0 || value.to_s=='' then
				string.gsub!(replace,match[2].nil? ? '' : match[3])
			else
				string.gsub!(replace,match[1].nil? ? '' : match[1])
			end
		end
		return string
	end

	def parseLoops(string)
		regexp = Regexp.new('{{~('+VAR_IDENTIFIER+')}}((.*?({{~('+VAR_IDENTIFIER+')}}.*?{{\/~}})?)*){{\/~}}',Regexp::MULTILINE)
		matches = string.scan(regexp)
		while !matches.empty? do
			match = matches.shift()
			replace = Regexp.new('{{~'+match[0]+'}}((.*?({{~('+VAR_IDENTIFIER+')}}.*?{{\/~}})?)*){{\/~}}',Regexp::MULTILINE)
			iterator = self.var(match[0])
			if iterator.is_a?(Integer) then
				string.gsub!(replace,match[1]*iterator)
			elsif iterator.is_a?(Array) then
				bracketRegex = Regexp.new('{{(\?|~)?'+match[0]+'('+VAR_IDENTIFIER+')?}}')
				brackets = match[1].scan(bracketRegex)
				iterated = ''
				for i in 0..iterator.length-1 do
					iteration = match[1].clone
					for bracket in brackets do
						prefix = bracket[0].nil? ? '' : bracket[0]
						suffix = bracket[1].nil? ? '' : bracket[1]
						iteration.gsub!('{{'+prefix+match[0]+suffix+'}}','{{'+prefix+match[0]+'.'+i.to_s+suffix+'}}')
					end
					iterated += iteration
				end
				string.sub!(replace,self.parseLoops(iterated))
			else
				string.gsub!(replace,'')
			end
		end
		return string
	end

end
