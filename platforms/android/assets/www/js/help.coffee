@like= (obj, key, val)->
	objects = []
	for i of obj
		if !obj.hasOwnProperty(i)
			continue
		if typeof obj[i] == 'object'
			objects = objects.concat(like(obj[i], key, val))
		else if i == key and obj[key] == val
			objects.push obj
	objects