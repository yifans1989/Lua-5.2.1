# Makefile for Fedora 17 platform
# Modify it, if needed

LUA_PATH= ..
LUA_INC= $(LUA_PATH)/src
LUA_LIB= $(LUA_PATH)/src/liblua.so

CC= gcc
CFLAGS= -O2 -fPIC -pg -ggdb -I $(LUA_INC)
SYS_LIB= $(LUA_LIB) -lm -ldl

.PHONY: clean

all: \
 slua \
 tuple.so \
 boolean_array.so \
 boolean_array_obj.so \
 boolean_array_index.so

slua: slua.c
	$(CC) -o $@ $< $(CFLAGS) $(SYS_LIB)

tuple.so: tuple.c
	$(CC) --shared -o $@ $< $(CFLAGS)

boolean_array.so: boolean_array.c
	$(CC) --shared -o $@ $< $(CFLAGS)

boolean_array_obj.so: boolean_array_obj.c
	$(CC) --shared -o $@ $< $(CFLAGS)

boolean_array_index.so: boolean_array_index.c
	$(CC) --shared -o $@ $< $(CFLAGS)

clean:
	-rm -rf slua *.o *.so *~ *.txt


