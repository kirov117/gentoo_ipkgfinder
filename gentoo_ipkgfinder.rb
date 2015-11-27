#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

Dir.chdir(File.dirname(__FILE__))

print "\x1b]2;gentoo_ipkgfinder\x07"

ENV['EIX_LIMIT'] = '0'

def nl(t = 1); print "\n" * t; end
def rn; print "\r"; end

def progLn(current, total, data)
	current	= Float(current)
	total	= Float(total)
	percent	= ((current * 100) / total).round(2)
	per10	= (percent / 5).to_i

	line = ''

	pcPart = '' + ('%0.2f' % percent).to_s + '% '

	print "\x1b]2;[" + ('%0.2f' % percent).to_s + "%] gentoo_ipkgfinder \x07"

	line += pcPart.ljust(8).bold

	line += ('[' + ('>' * per10).ljust(20) + ']').white
	line += (' (' + (data + ')').ljust(46)).white

	rn
	print line
end
def formatUnixDelta(startUnix, endUnix)
	str = ''
	delta = (endUnix.to_f.ceil - startUnix.to_f.floor).ceil.to_i.abs

	h = delta / 3600
	delta -= h * 3600
	str += h.to_s + ' hour' + (h == 1 ? '' : 's') + ' ' unless h.zero?

	m = delta / 60
	delta -= m * 60
	str += m.to_s + ' minute' + (m == 1 ? '' : 's') + ' ' unless m.zero?

	str += delta.to_s + ' second' + (delta == 1 ? '' : 's')
	str
end

begin
	startTime = Time.now

	indepList = []

	nl

	pkgList = `eix --only-names -I`.split("\n")
	pkgCount = pkgList.length

	pkgIter = 1
	pkgList.each do |p|
		progLn(pkgIter, pkgCount, p)

		# equery = `equery d #{p}`.split("\n")
		# if equery.length.zero?
		if pkgIter % 2 == 0
			indepList.push(p)

			rn
			print p.ljust(80).colorize(:color => :cyan)
			nl
		end

		$stdout.flush
		pkgIter += 1
	end

	endTime = Time.now

	nl(2)

	indepCount = indepList.length
	if indepCount.zero?
		kw = ' NO'
		rest = ' independent packages found '
		ln = kw.bold + rest

		print ln.colorize(:background => :black, :color => :red) + "\n"
		print ('-' * (kw + rest).length).colorize(:background => :black, :color => :red) + "\n" * 2
	else
		kw = ' %i'%indepCount
		rest = ' independent packages found '
		kp = '(' + ((Float(indepCount) * 100) / pkgCount).round(2).to_s + '%) '
		ln = kw.bold + rest + kp.bold

		print ln.colorize(:background => :black, :color => :green) + "\n"
		print ('-' * (kw + rest + kp).length).colorize(:background => :black, :color => :green) + "\n" * 2
	end

	print ('Elapsed time: ' + formatUnixDelta(startTime, endTime)) + "\n"

rescue Interrupt
	nl(2)
	exit(false)
ensure
	nl
	exit(true)
end
