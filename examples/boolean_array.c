/* Boolean array extend for lua: normal model */

#include "lua.h"
#include "lauxlib.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#define BITS_PER_WORD (CHAR_BIT * (sizeof(unsigned int)))
#define I_WORD(i) ((unsigned int)(i) / BITS_PER_WORD)
#define I_BIT(i) (1 << ((unsigned int)(i) % BITS_PER_WORD))
#define _MATE_TABLE_NAME "Boolean_Array"

#define CHECK_ARRAY(L) \
	(BooleanArray *)luaL_checkudata(L, 1, _MATE_TABLE_NAME)

typedef struct BooleanArray {
	int size;
	unsigned int values[1];
} BooleanArray;

static int 
new_boolean_array(lua_State *L) {
	int i, n;
	size_t nbytes;
	BooleanArray *a;
	n = luaL_checkint(L, 1);
	luaL_argcheck(L, n>=1, 1, "size must be > 0");
	nbytes = sizeof(*a) + I_WORD(n - 1) * sizeof(unsigned int);
	a = (BooleanArray *)lua_newuserdata(L, nbytes);
	a->size = n;
	for (i = 0; i <= I_WORD(n - 1); ++i) {
		a->values[i] = 0;
	}
	luaL_getmetatable(L, _MATE_TABLE_NAME);
	lua_setmetatable(L, -2);
	return 1;	
}

static unsigned int *
_get_index(lua_State *L, unsigned int *mask) {
	BooleanArray *a = CHECK_ARRAY(L);
	int index = luaL_checkint(L, 2) - 1;
	luaL_argcheck(L, index >= 0 && 
                   index < a->size, 2, "index out of range");
	*mask = I_BIT(index);
	return &a->values[I_WORD(index)];
}

static int
set_boolean_array(lua_State *L) {
	unsigned int mask, *entry = _get_index(L, &mask);
	luaL_checkany(L, 3);
	if ((int)lua_tonumber(L, 3))
		*entry |= mask;
	else
		*entry &= ~mask;
	return 0;
}

static int
get_boolean_array(lua_State *L) {
	unsigned int mask, *entry = _get_index(L, &mask);
	lua_pushboolean(L, *entry & mask);
	return 1;
}

static int
get_boolean_array_size(lua_State *L) {
	BooleanArray *a = CHECK_ARRAY(L);
	luaL_argcheck(L, a != NULL, 1, "'boolean_arary' expexted");
	lua_pushinteger(L, a->size);
	return 1;
}

static const struct luaL_Reg boolean_array_lib[] = {
	{"new", new_boolean_array},
	{"set", set_boolean_array},
	{"get", get_boolean_array},
	{"size", get_boolean_array_size},
	{NULL, NULL}
};

int luaopen_boolean_array(lua_State *L) {
	luaL_newmetatable(L, _MATE_TABLE_NAME);
	luaL_newlib(L, boolean_array_lib);
	return 1;
}





