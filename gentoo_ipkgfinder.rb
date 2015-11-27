#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

Dir.chdir(File.dirname(__FILE__))

print "\x1b]2;gentoo_ipkgfinder\x07"

ENV['EIX_LIMIT'] = '0'

def nl(t = 1); print "\n" * t; end
def rn; print "\r"; end
def pad(str, ln = 80); padCh = ' '; str + padCh * (ln - str.length); end

def progLn(current, total, data)
	current	= Float(current)
	total	= Float(total)
	percent	= ((current * 100) / total).round(2)
	per10	= (percent / 5).to_i

	line = ''

	pcPart = '' + ('%0.2f' % percent).to_s + '% '

	print "\x1b]2;[" + ('%0.2f' % percent).to_s + "%] gentoo_ipkgfinder \x07"

	line += pcPart.bold + ' '*(8-pcPart.length)

	line += ('[' + pad('>' * per10, 20) + ']').white
	line += (' (' + pad(data + ')', 46)).white

	rn
	print line
end


nl

begin
	indepList = []

	pkgList = `eix --only-names -I`.split("\n")
	pkgCount = pkgList.length

	pkgIter = 1
	pkgList.each do |p|
		progLn(pkgIter, pkgCount, p)

		equery = `equery d #{p}`.split("\n")
		if equery.length.zero?
			indepList.push(p)

			rn
			print pad(p, 80).colorize(:color => :cyan)
			nl
		end

		$stdout.flush
		pkgIter += 1
	end
rescue Interrupt
	nl(2)
	exit(false)
end


nl(2)


indepCount = indepList.length
if indepCount.zero?
	kw = ' NO'
	rest = ' independent packages found '
	ln = kw.bold + rest

	print ln.colorize(:background => :black, :color => :red) + "\n"
	print ('-' * (kw + rest).length).colorize(:background => :black, :color => :red) + "\n"
else
	kw = ' %i'%indepCount
	rest = ' independent packages found '
	ln = kw.bold + rest

	print ln.colorize(:background => :black, :color => :green) + "\n"
	print ('-' * (kw + rest).length).colorize(:background => :black, :color => :green) + "\n"
end


nl
