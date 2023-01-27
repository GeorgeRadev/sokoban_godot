# all levels are build from text
# Level element     Character   ASCII code
# Wall              #           0x23
# Player            @           0x40
# Player on goal    +           0x2b
# Box               $           0x24
# Box on goal       *           0x2a
# Goal              .           0x2e
# Floor             (space)     0x20


var file = './levels/1.txt'

func load_levels(levels:Array):
	load_file(file, levels)

func load_file(filename:String, levels:Array):
	var f = File.new()
	var err = f.open(filename, File.READ)
	if err != OK:
		print("error opening data file : " + str(err))
		return levels
	var level_started = false
	var level_lines = Array()
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		var trimmed = line.strip_escapes().lstrip(' ')
		if trimmed.length() > 1 and trimmed[0] == "#":
			# we have a level line
			if level_started == false: 
				level_started = true
				level_lines = Array()
			# level lines already pending
			level_lines.append(line)
				
		else:
			# level ended
			if level_started:
				levels.append(level_lines)
				level_started = false
				level_lines = Array()
	f.close()
	
	print("levels loaded: " + str(len(levels)))
	return levels
