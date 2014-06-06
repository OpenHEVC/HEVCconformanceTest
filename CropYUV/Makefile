#OPTFLAGS   = -Wall
#SDL_LIBS   = `sdl-config --static-libs`
#SDL_CFLAGS = `sdl-config --cflags`
#CFLAGS     = $(OPTFLAGS)  $(SDL_CFLAGS)
#LDFLAGS    = $(SDL_LIBS) 

TARGET     = yuvcrop
CSRC       = $(TARGET).c
OBJ        = $(CSRC:.c=.o)

all: $(TARGET) clean

%.o: %.c
	$(CC)  -c -o $@ $<

$(TARGET): $(OBJ)
	$(CC) -o $@ $(OBJ)

clean:
	rm -f $(OBJ) *~

clean_all:
	rm -f $(OBJ) $(TARGET) *~

