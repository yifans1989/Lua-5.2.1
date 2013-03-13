/* a tuple library for lua */

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>

int
_luatuple_tuple(lua_State *L) {
	int i, op = luaL_optint(L, 1, 0);
	switch (op) {
		case 0:
  		for (i = 1; !lua_isnone(L, lua_upvalueindex(i)); i++)
				lua_pushvalue(L, lua_upvalueindex(i));
     return i - 1;
		
		default:
			luaL_argcheck(L, 0 < op , 1, "index out of range");
			if (lua_isnone(L, lua_upvalueindex(op))) {
				printf("no such a field with index %d", op);	
				return 0;
			}
			lua_pushvalue(L, lua_upvalueindex(op));
			return 1;
	}
}

int 
_lua_tuple_new(lua_State *L) {
	lua_pushcclosure(L, _luatuple_tuple, lua_gettop(L));
	return 1;
}

static const struct luaL_Reg tuplelib[] = {
	{"new", _lua_tuple_new},
	{NULL, NULL}
};

int
luaopen_tuple(lua_State *L) {
	luaL_newlib(L, tuplelib);
	return 1;
}


