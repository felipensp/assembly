obj-m  := test.o
test-objs := hijack.o


KDIR   := /lib/modules/$(shell uname -r)/build
PWD    := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
	
clean:
	rm -rf *.ko *.o *.order *.symvers *.mod.c .*.cmd .tmp_versions
