BUILDDIR = ../build/blog

copyfiles =  assets views models controllers router.lua

main:
	- mkdir $(BUILDDIR)
	- cp -rf $(copyfiles) $(BUILDDIR)
	- cd $(BUILDDIR) && ln -s ../grs ./rst
clean:
	rm -rf $(BUILDDIR)/*  