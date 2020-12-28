
# Default compilers
CC?=gcc
CXX?=g++

# Executables.
GAME_EXE:=satanscambion
EDITOR_EXE:=satanseditor

# Build flags
CPPFLAGS:=-c -MMD
CFLAGS:=-c
CPPFLAGS_LINK:=
CFLAGS_LINK:=


# If release is defined then release then different folder is creted.
ifndef RELEASE
  O:=.debug
  CPPFLAGS+=-g
  CFLAGS+=-g
else
  O:=.release
  CPPFLAGS+=-O3
  CFLAGS+=-O3
endif


.PHONY: all clean release

# All is build everything. No commands needed.
all: $(GAME_EXE) $(EDITOR_EXE)

# Build the game.
GAME_MODULES:=core/core_constants.o core/core_string_names.o
$(GAME_EXE): $(addprefix $(O)/,$(GAME_MODULES))
	$(CXX) $(CPPFLAGS_LINK) $^ -o$@

# Modules for editor.
EDITOR_MODULES:=code_editor.o
$(EDITOR_EXE): $(addprefix $(O)/,$(EDITOR_MODULES))
	$(CXX) $(CPPFLAGS_LINK) $^ -o$@

# Generic object file build commands
# Include dependency files
-include $(O)/*.d
# Folder core
$(O)/core/%.o: core/%.cpp | $(O)/core
	$(CXX) $(CPPFLAGS) $^ -o$@
# Folder editor
$(O)/editor/%.o: editor/%.cpp | $(O)/editor
	$(CXX) $(CPPFLAGS) $^ -o$@

# Create object folder core
$(O)/core: $(O)
	- mkdir -p $(O)/core
# Create the object directory
$(O):
	- mkdir -p $(O)

# Cleans everything
clean:
	-rm -r $(O)
	-rm $(GAME_EXE)
	-rm $(EDITOR_EXE)

# short hand for creating release build
release:
	make RELEASE=1
