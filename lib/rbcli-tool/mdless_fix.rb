##################################################################################
#     RBCli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2018 Andrew Khoury                                           #
#                                                                                #
#     This program is free software: you can redistribute it and/or modify       #
#     it under the terms of the GNU General Public License as published by       #
#     the Free Software Foundation, either version 3 of the License, or          #
#     (at your option) any later version.                                        #
#                                                                                #
#     This program is distributed in the hope that it will be useful,            #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#     GNU General Public License for more details.                               #
#                                                                                #
#     You should have received a copy of the GNU General Public License          #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.     #
#                                                                                #
#     For questions regarding licensing, please contact andrew@blacknex.us        #
##################################################################################

require 'mdless'

def class_exists?(class_name)
	klass = Module.const_get(class_name)
	return klass.is_a?(Class)
rescue NameError
	return false
end

if class_exists? 'Encoding'
	Encoding.default_external = Encoding::UTF_8 if Encoding.respond_to?('default_external')
	Encoding.default_internal = Encoding::UTF_8 if Encoding.respond_to?('default_internal')
end

module CLIMarkdown
	class Converter
		def convert_markdown(input)
			@headers = get_headers(input)
			# yaml/MMD headers
			in_yaml = false
			if input.split("\n")[0] =~ /(?i-m)^---[ \t]*?(\n|$)/
				@log.info("Found YAML")
				# YAML
				in_yaml = true
				input.sub!(/(?i-m)^---[ \t]*\n([\s\S]*?)\n[\-.]{3}[ \t]*\n/) do |yaml|
					m = Regexp.last_match

					@log.warn("Processing YAML Header")
					m[0].split(/\n/).map {|line|
						if line =~ /^[\-.]{3}\s*$/
							line = c([:d,:black,:on_black]) + "% " + c([:d,:black,:on_black]) + line
						else
							line.sub!(/^(.*?:)[ \t]+(\S)/, '\1 \2')
							line = c([:d,:black,:on_black]) + "% " + c([:d,:white]) + line
						end
						if @cols - line.uncolor.size > 0
							line += " "*(@cols-line.uncolor.size)
						end
					}.join("\n") + "#{xc}\n"
				end
			end

			if !in_yaml && input.gsub(/\n/,' ') =~ /(?i-m)^\w.+:\s+\S+ /
				@log.info("Found MMD Headers")
				input.sub!(/(?i-m)^([\S ]+:[\s\S]*?)+(?=\n\n)/) do |mmd|
					puts mmd
					mmd.split(/\n/).map {|line|
						line.sub!(/^(.*?:)[ \t]+(\S)/, '\1 \2')
						line = c([:d,:black,:on_black]) + "% " + c([:d,:white,:on_black]) + line
						if @cols - line.uncolor.size > 0
							line += " "*(@cols - line.uncolor.size)
						end
					}.join("\n") + " "*@cols + "#{xc}\n"
				end

			end


			# Gather reference links
			input.gsub!(/^\s{,3}(?<![\e*])\[\b(.+)\b\]: +(.+)/) do |m|
				match = Regexp.last_match
				@ref_links[match[1]] = match[2]
				''
			end

			# Gather footnotes (non-inline)
			input.gsub!(/^ {,3}(?<!\*)(?:\e\[[\d;]+m)*\[(?:\e\[[\d;]+m)*\^(?:\e\[[\d;]+m)*\b(.+)\b(?:\e\[[\d;]+m)*\]: *(.*?)\n/) do |m|
				match = Regexp.last_match
				@footnotes[match[1].uncolor] = match[2].uncolor
				''
			end

			if @options[:section]
				in_section = false
				top_level = 1
				new_content = []

				input.split(/\n/).each {|graf|
					if graf =~ /^(#+) *(.*?)( *#+)?$/
						level = $1.length
						title = $2

						if in_section
							if level >= top_level
								new_content.push(graf)
							else
								in_section = false
								break
							end
						elsif title.downcase == "#{@headers[@options[:section] - 1][1].downcase}"
							in_section = true
							top_level = level + 1
							new_content.push(graf)
						else
							next
						end
					elsif in_section
						new_content.push(graf)
					end
				}

				input = new_content.join("\n")
			end

			h_adjust = highest_header(input) - 1
			input.gsub!(/^(#+)/) do |m|
				match = Regexp.last_match
				"#" * (match[1].length - h_adjust)
			end

			input.gsub!(/(?i-m)([`~]{3,})([\s\S]*?)\n([\s\S]*?)\1/ ) do |cb|
				m = Regexp.last_match
				leader = m[2] ? m[2].upcase + ":" : 'CODE:'
				leader += xc

				if exec_available('pygmentize')
					lexer = m[2].nil? ? '-g' : "-l #{m[2]}"
					begin
						hilite, s = Open3.capture2(%Q{pygmentize #{lexer} 2> /dev/null}, :stdin_data=>m[3])

						if s.success?
							hilite = hilite.split(/\n/).map{|l| "#{c([:x,:black])}~ #{xc}" + l}.join("\n")
						end
					rescue => e
						@log.error(e)
						hilite = m[0]
					end

				else

					hilite = m[3].split(/\n/).map{|l|
						new_code_line = l.gsub(/\t/,'    ')
						orig_length = new_code_line.size + 3
						new_code_line.gsub!(/ /,"#{c([:x,:white,:on_black])} ")
						"#{c([:x,:black])}~ #{c([:x,:white,:on_black])} " + new_code_line + c([:x,:white,:on_black]) + xc
					}.join("\n")
				end
				"#{c([:x,:magenta])}#{leader}\n#{hilite}#{xc}"
			end

			# remove empty links
			input.gsub!(/\[(.*?)\]\(\s*?\)/, '\1')
			input.gsub!(/\[(.*?)\]\[\]/, '[\1][\1]')

			lines = input.split(/\n/)

			# previous_indent = 0

			lines.map!.with_index do |aLine, i|
				line = aLine.dup
				clean_line = line.dup.uncolor


				if clean_line.uncolor =~ /(^[%~])/ # || clean_line.uncolor =~ /^( {4,}|\t+)/
					## TODO: find indented code blocks and prevent highlighting
					## Needs to miss block indented 1 level in lists
					## Needs to catch lists in code
					## Needs to avoid within fenced code blocks
					# if line =~ /^([ \t]+)([^*-+]+)/
					#   indent = $1.gsub(/\t/, "    ").size
					#   if indent >= previous_indent
					#     line = "~" + line
					#   end
					#   p [indent, previous_indent]
					#   previous_indent = indent
					# end
				else
					# Headlines
					line.gsub!(/^(#+) *(.*?)(\s*#+)?\s*$/) do |match|
						m = Regexp.last_match
						pad = ""
						ansi = ''
						case m[1].length
						when 1
							ansi = c([:b, :black, :on_intense_white])
							pad = c([:b,:white])
							pad += m[2].length + 2 > @cols ? "*"*m[2].length : "*"*(@cols - (m[2].length + 2))
						when 2
							ansi = c([:b, :green, :on_black])
							pad = c([:b,:black])
							pad += m[2].length + 2 > @cols ? "-"*m[2].length : "-"*(@cols - (m[2].length + 2))
						when 3
							ansi = c([:u, :b, :yellow])
						when 4
							ansi = c([:x, :u, :yellow])
						else
							ansi = c([:b, :white])
						end

						"\n#{xc}#{ansi}#{m[2]} #{pad}#{xc}\n"
					end

					# place footnotes under paragraphs that reference them
					if line =~ /\[(?:\e\[[\d;]+m)*\^(?:\e\[[\d;]+m)*(\S+)(?:\e\[[\d;]+m)*\]/
						key = $1.uncolor
						if @footnotes.key? key
							line += "\n\n#{c([:b,:black,:on_black])}[#{c([:b,:cyan,:on_black])}^#{c([:x,:yellow,:on_black])}#{key}#{c([:b,:black,:on_black])}]: #{c([:u,:white,:on_black])}#{@footnotes[key]}#{xc}"
							@footnotes.delete(key)
						end
					end

					# color footnote references
					line.gsub!(/\[\^(\S+)\]/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match, true)
						counter = i
						while last.nil? && counter > 0
							counter -= 1
							find_color(lines[counter])
						end
						"#{c([:b,:black])}[#{c([:b,:yellow])}^#{c([:x,:yellow])}#{match[1]}#{c([:b,:black])}]" + (last ? last : xc)
					end

					# blockquotes
					line.gsub!(/^(\s*>)+( .*?)?$/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match, true)
						counter = i
						while last.nil? && counter > 0
							counter -= 1
							find_color(lines[counter])
						end
						"#{c([:b,:black])}#{match[1]}#{c([:x,:magenta])} #{match[2]}" + (last ? last : xc)
					end

					# make reference links inline
					line.gsub!(/(?<![\e*])\[(\b.*?\b)?\]\[(\b.+?\b)?\]/) do |m|
						match = Regexp.last_match
						title = match[2] || ''
						text = match[1] || ''
						if match[2] && @ref_links.key?(title.downcase)
							"[#{text}](#{@ref_links[title]})"
						elsif match[1] && @ref_links.key?(text.downcase)
							"[#{text}](#{@ref_links[text]})"
						else
							if input.match(/^#+\s*#{Regexp.escape(text)}/i)
								"[#{text}](##{text})"
							else
								match[1]
							end
						end
					end

					# color inline links
					line.gsub!(/(?<![\e*!])\[(\S.*?\S)\]\((\S.+?\S)\)/) do |m|
						match = Regexp.last_match
						color_link(match.pre_match, match[1], match[2])
					end



					# inline code
					line.gsub!(/`(.*?)`/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match, true)
						"#{c([:b,:black])}`#{c([:b,:white])}#{match[1]}#{c([:b,:black])}`" + (last ? last : xc)
					end

					# horizontal rules
					line.gsub!(/^ {,3}([\-*] ?){3,}$/) do |m|
						c([:x,:black]) + '_'*@cols + xc
					end

					# bold, bold/italic
					line.gsub!(/(^|\s)[\*_]{2,3}([^\*_\s][^\*_]+?[^\*_\s])[\*_]{2,3}/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match, true)
						counter = i
						while last.nil? && counter > 0
							counter -= 1
							find_color(lines[counter])
						end
						"#{match[1]}#{c([:b])}#{match[2]}" + (last ? last : xc)
					end

					# italic
					line.gsub!(/(^|\s)[\*_]([^\*_\s][^\*_]+?[^\*_\s])[\*_]/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match, true)
						counter = i
						while last.nil? && counter > 0
							counter -= 1
							find_color(lines[counter])
						end
						"#{match[1]}#{c([:u])}#{match[2]}" + (last ? last : xc)
					end

					# equations
					line.gsub!(/((\\\\\[)(.*?)(\\\\\])|(\\\\\()(.*?)(\\\\\)))/) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match)
						if match[2]
							brackets = [match[2], match[4]]
							equat = match[3]
						else
							brackets = [match[5], match[7]]
							equat = match[6]
						end
						"#{c([:b, :black])}#{brackets[0]}#{xc}#{c([:b,:blue])}#{equat}#{c([:b, :black])}#{brackets[1]}" + (last ? last : xc)
					end

					# list items
					# TODO: Fix ordered list numbering, pad numbers based on total number of list items
					line.gsub!(/^(\s*)([*\-+]|\d+\.) /) do |m|
						match = Regexp.last_match
						last = find_color(match.pre_match)
						indent = match[1] || ''
						"#{indent}#{c([:d, :red])}#{match[2]} " + (last ? last : xc)
					end

					# definition lists
					line.gsub!(/^(:\s*)(.*?)/) do |m|
						match = Regexp.last_match
						"#{c([:d, :red])}#{match[1]} #{c([:b, :white])}#{match[2]}#{xc}"
					end

					# misc html
					line.gsub!(/<br\/?>/, "\n")
					line.gsub!(/(?i-m)((<\/?)(\w+[\s\S]*?)(>))/) do |tag|
						match = Regexp.last_match
						last = find_color(match.pre_match)
						"#{c([:d,:black])}#{match[2]}#{c([:b,:black])}#{match[3]}#{c([:d,:black])}#{match[4]}" + (last ? last : xc)
					end
				end

				line
			end

			input = lines.join("\n")

			# images
			input.gsub!(/^(.*?)!\[(.*)?\]\((.*?\.(?:png|gif|jpg))( +.*)?\)/) do |m|
				match = Regexp.last_match
				if match[1].uncolor =~ /^( {4,}|\t)+/
					match[0]
				else
					tail = match[4].nil? ? '' : " "+match[4].strip
					result = nil
					if exec_available('imgcat') && @options[:local_images]
						if match[3]
							img_path = match[3]
							if img_path =~ /^http/ && @options[:remote_images]
								begin
									res, s = Open3.capture2(%Q{curl -sS "#{img_path}" 2> /dev/null | imgcat})

									if s.success?
										pre = match[2].size > 0 ? "    #{c([:d,:blue])}[#{match[2].strip}]\n" : ''
										post = tail.size > 0 ? "\n    #{c([:b,:blue])}-- #{tail} --" : ''
										result = pre + res + post
									end
								rescue => e
									@log.error(e)
								end
							else
								if img_path =~ /^[~\/]/
									img_path = File.expand_path(img_path)
								elsif @file
									base = File.expand_path(File.dirname(@file))
									img_path = File.join(base,img_path)
								end
								if File.exists?(img_path)
									pre = match[2].size > 0 ? "    #{c([:d,:blue])}[#{match[2].strip}]\n" : ''
									post = tail.size > 0 ? "\n    #{c([:b,:blue])}-- #{tail} --" : ''
									img = %x{imgcat "#{img_path}"}
									result = pre + img + post
								end
							end
						end
					end
					if result.nil?
						match[1] + color_image(match.pre_match, match[2], match[3] + tail) + xc
					else
						match[1] + result + xc
					end
				end
			end

			@footnotes.each {|t, v|
				input += "\n\n#{c([:b,:black,:on_black])}[#{c([:b,:yellow,:on_black])}^#{c([:x,:yellow,:on_black])}#{t}#{c([:b,:black,:on_black])}]: #{c([:u,:white,:on_black])}#{v}#{xc}"
			}

			@output += input

		end
	end
end
