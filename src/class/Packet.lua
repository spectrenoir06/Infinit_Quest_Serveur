require("ffi")

ffi.cdef[[
typedef struct { uint8_t cmd, float posX, float posY, uint8_t dir, bool mv } posUpdate;
]]
