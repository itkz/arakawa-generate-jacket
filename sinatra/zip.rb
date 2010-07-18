#!/usr/bin/env ruby
# author: @takano32 <takano32@gmail.com>
# non-compress zip generator
# http://www.tnksoft.com/reading/zipfile/nonarc2.php


class ZipHeader
  def initialize
    @signature = nil
    @needver = nil
    @option = nil
    @comptype = nil
    now = Time.now
    @filedate = "\0" * 16
    p @filedate.size
    @filedate[0..4] = [now.mday.to_s(2)].pack('B*').rjust(5, "\0")
    @filedate[5..8] = [now.month.to_s(2)].pack('B*').rjust(4, "\0")
    @filedate[9..15] = ([(now.year - 1980).to_s(2)].pack('B*')).rjust(7, "\0")
    p @filedate.size
    p @filedate
    @filetime = 
    @crc32 = nil
    @compsize = nil
    @uncompsize = nil
    @fnamelen = nil
    @extralen = nil
  end
  def append(buffer)
  end
end

buffer = ''
byte = ?a
buffer.concat(byte)
byte = ?b
buffer.concat(byte)
puts buffer

header = ZipHeader.new



