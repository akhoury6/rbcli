# This file was obtained and modified from: https://github.com/busyloop/lolcat/blob/master/lib/lolcat/lol.rb

# Copyright (c) 2016, moe@busyloop.net
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the lolcat nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'paint'

module Lol
  ANSI_ESCAPE = /((?:\e(?:[ -\/]+.|[\]PX^_][^\a\e]*|\[[0-?]*.|.))*)(.?)/m

  @os = 0
  @paint_init = false

  def self.makestr(str, opts = {})
    @os = rand(256) unless @paint_init
    set_mode(opts[:truecolor]) unless @paint_init

    result = ''
    filtered = str.scan(ANSI_ESCAPE)
    filtered.each_with_index do |c, i|
      # color = rainbow(opts[:freq], @os + i / opts[:spread])
      color = rainbow(opts[:freq], (@os + i) / opts[:spread])
      if opts[:invert] then
        result += c[0] + Paint.color(nil, color) + c[1] + "\e[49m"
      else
        result += c[0] + Paint.color(color) + c[1] + "\e[39m"
      end
    end
    @os += opts[:slope]
    result
  end

  private

  def self.set_mode(truecolor)
    # @paint_mode_detected = Paint.mode
    @paint_mode_detected = %w[truecolor 24bit].include?(ENV['COLORTERM']) ? 0xffffff : 256
    Paint.mode = truecolor ? 0xffffff : @paint_mode_detected
    STDERR.puts "DEBUG: Paint.mode = #{Paint.mode} (detected: #{@paint_mode_detected})" if ENV['LOLCAT_DEBUG']
    @paint_init = true
  end

  def self.rainbow(freq, i)
    red = Math.sin(freq * i + 0) * 127 + 128
    green = Math.sin(freq * i + 2 * Math::PI / 3) * 127 + 128
    blue = Math.sin(freq * i + 4 * Math::PI / 3) * 127 + 128
    "#%02X%02X%02X" % [red, green, blue]
  end
end
