ffi = require("ffi")

ffi.cdef[[
typedef struct {
	uint8_t cmd;
	float posX,posY;
	uint8_t dir;
	bool mv;
	}posUpdate;
]]
