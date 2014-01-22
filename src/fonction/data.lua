	
function import_data(str)

	data = {}
	data.json = {}
	local data_json = json.decode(love.filesystem.read( str, nil ))
		
	data.map = data_json.map
	
	for k,v in pairs(data_json.map) do
		data.map[tonumber(k)] = v
	end
	
	
	data.tab = {}
	
	for k,v in pairs(data_json.tile) do
		data.tab[tonumber(k)] = v
	end
	
	
	data.pnj = {}
	
	for k,v in pairs(data_json.pnj) do
		data.pnj[tonumber(k)] = v
		data.pnj[tonumber(k)].talk = loadstring(data.pnj[tonumber(k)].talk_str)
	end
	
	data.obj = {}
	
	for k,v in pairs(data_json.obj) do
		data.obj[tonumber(k)] = v
		data.obj[tonumber(k)].isOn = loadstring(data.obj[tonumber(k)].isOn_str)
	end
end
	
	
	