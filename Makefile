.PHONY: all clean dist bindist test

# NOTE TO DEVELOPERS:
# We use the SCons build system (http://www.scons.org/). This makefile is
# just a wrapper around it.
#
# The real build system definitions are in the file SConstruct. If you need
# to change anything, edit SConstruct (or SConscript in the subfolders).
#
# If you experience any build problems, read this web page:
# http://wiki.openkore.com/index.php/How_to_run_OpenKore

ifeq ($(OS),Windows_NT)
all:
	@python src/scons-local-3.1.1/scons.py || echo -e "Compilation failed. Please read http://wiki.openkore.com/index.php/How_to_run_OpenKore for help."

test:
	@python src/scons-local-3.1.1/scons.py && cd src/test/ && unittests.pl

doc:
	cd src/doc/ && createdoc.pl
else

all:
	@python src/scons-local-3.1.1/scons.py || echo -e "\e[1;31mCompilation failed. Please read http://wiki.openkore.com/index.php/How_to_run_OpenKore for help.\e[0m"

test:
	@python src/scons-local-3.1.1/scons.py && cd src/test/ && ./unittests.pl

doc:
	cd src/doc/ && ./createdoc.pl

endif

clean:
	python src/scons-local-3.1.1/scons.py -c

dist:
	bash makedist.sh

bindist:
	bash makedist.sh --bin


