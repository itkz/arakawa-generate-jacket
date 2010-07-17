
CC = gdc

SOURCES=main.d moving.d $(wildcard SDL/*.d)
OBJS=$(SOURCES:.d=.o)
TARGET=arakawajacket

ifeq (${shell uname}, Darwin)
	OS=-fversion=Darwin
else
	OS=
endif

CFLAGS=-g -Wall -ISDL `sdl-config --cflags` $(OS)
LDFLAGS=-lSDL_image -lSDLmain -lSDL -lSDL_gfx -ljpeg -lpng `sdl-config --libs`


all: $(TARGET)

$(OBJS): %o: %d
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS) $(LIBS)

main.o: main.d moving.d

moving.o: moving.d

clean:
	@for file in $(OBJS) $(TARGET) $(TARGET).exe; \
	 do \
	   if test -f "$$file"; then \
	     rm -f "$$file"; \
	   fi \
	 done
