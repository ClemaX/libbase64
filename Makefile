NAME = libbase64.a

# Compiler and linker
CC = clang
LD = clang
AR = ar

# Paths
include srcs.mk
INCDIR = include
LIBDIR = lib

OBJDIR = obj
BINDIR = .

# Library dependencies
LIBS = $(addprefix $(LIBDIR), )

LIBDIRS = $(dir $(LIBS))
LIBINCS = $(addsuffix $(INCDIR), $(LIBDIRS))
LIBARS = $(notdir $(LIBS))

# Sources
INCS = $(LIBINCS) $(INCDIR)
OBJS = $(SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
DEPS = $(OBJS:.o=.d)

# Tests
TESTDIR = test
TESTSRCS = $(addprefix $(TESTDIR)/, main.c)
TESTOBJS = $(TESTSRCS:$(TESTDIR)/%.c=$(OBJDIR)/%.o)
TESTDEPS = $(TESTOBJS:.o=.d)

# Flags
CFLAGS = -Wall -Wextra -Werror $(INCS:%=-I%) -g3
DFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
LDFLAGS = $(LIBDIRS:%=-L%) -g3
ARFLAGS = -rcs
LDLIBS = $(LIBARS:lib%.a=-l%)

# Compiling commands
COMPILE.c = $(CC) $(DFLAGS) $(CFLAGS) -c
COMPILE.o = $(LD) $(LDFLAGS)
ARCHIVE.o = $(AR) $(ARFLAGS)

all: $(BINDIR)/$(NAME)

# Directories
$(OBJDIR) $(BINDIR):
	@echo "MK $@"
	mkdir -p "$@"

# Libraries
$(LIBS): %.a: FORCE
	make -C $(dir $@) NAME=$(@F)

# Objects
$(OBJS): $(OBJDIR)/%.o: $(SRCDIR)/%.c $(OBJDIR)/%.d | $(OBJDIR)
	@mkdir -p '$(@D)'
	@echo "CC $<"
	$(COMPILE.c) $< -o $@

# Dependencies
$(DEPS): $(OBJDIR)/%.d:
include $(wildcard $(DEPS))

$(TESTDEPS): $(OBJDIR)/%.d:
include $(wildcard $(TESTDEPS))

# Binaries
$(BINDIR)/$(NAME): $(OBJS) $(LIBS) | $(BINDIR)
	@echo "AR $@"
	$(ARCHIVE.o) $@ $^

# Tests
$(TESTOBJS): $(OBJDIR)/%.o: $(TESTDIR)/%.c $(OBJDIR)/%.d | $(OBJDIR)
	@mkdir -p '$(@D)'
	@echo "CC $<"
	$(COMPILE.c) $< -o $@

debug: CFLAGS += -DDEBUG -g3 -fsanitize=address
debug: LDFLAGS += -g3 -fsanitize=address
debug: re

tests: CFLAGS += -DDEBUG -g3 -fsanitize=address
tests: LDFLAGS += -g3 -fsanitize=address
tests: $(BINDIR)/$(NAME) $(TESTOBJS)
	@echo "LD $^"
	$(COMPILE.o) -L$(BINDIR) $(TESTOBJS) -o $@ $(LDLIBS) -l$(<:lib%.a=%)

clean:
	$(foreach dir, $(LIBDIRS),\
		@echo "MK $(addprefix -C, $(LIBDIRS)) $@" && make -C $(dir) $@ && ):
	@echo "RM $(OBJDIR)"
	rm -rf "$(OBJDIR)"

fclean: clean
	$(foreach dir, $(LIBDIRS),\
		@echo "MK $(addprefix -C, $(LIBDIRS)) $@" && make -C $(dir) $@ && ):
	@echo "RM $(BINDIR)/$(NAME)"
	rm -f "$(BINDIR)/$(NAME)"
	@rmdir "$(BINDIR)" 2>/dev/null && echo "RM $(BINDIR)" || :

re: fclean all

FORCE: ;

.PHONY: all clean fclean re

# Assign a value to VERBOSE to enable verbose output
$(VERBOSE).SILENT:
