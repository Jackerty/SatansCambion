
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


.PHONY: all scons clean release list_objects update_godot rebase_game show_tree set_git_tree
.ONESHELL: rebase_game

# All is build everything. No commands needed.
all: $(GAME_EXE) $(EDITOR_EXE)

# Scons build command.
scons:
	scons -j$$(($$(nproc) - 2)) platform=linuxbsd

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

# Short hand for creating release build
release:
	make RELEASE=1

# Short hand for list files in object folder.
list_objects:
	ls -R $(O)

# Short hand for updating godot engine (master branch) and 
# moving game commits up that branch.
update_godot:
	git fetch godot master:master

rebase_game: update_godot
	@
	BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
	if [[ "$$BRANCH" == "SatansCambion" ]]; then
	  git rebase master;
	else
	  echo "Wrong branch!";
	fi

# Short hand for showing git commit tree and command to set git tree alias.
show_tree:
	git log --all --graph --decorate --oneline
set_git_tree:
	git config --global alias.tree "log --all --graph --decorate --oneline"
