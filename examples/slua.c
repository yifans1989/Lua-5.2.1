/* slua: a simple single line lua interpreter */

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
	char buff[1024] = "";
	int error = 0;
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	do {
		printf("> ");
		if (buff[0] == '\0' || buff[0] == '\n' || buff[0] == '\r')
			continue;
		error = luaL_loadbuffer(L, buff, strlen(buff), "line") || lua_pcall(L, 0, 0, 0);
		if (error) {
			fprintf(stderr, "%s\n", lua_tostring(L, -1));
			lua_pop(L, 1);
		}
	} while (fgets(buff, sizeof(buff), stdin) != NULL);
	lua_close(L);
	return 0;
}

