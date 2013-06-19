

all: src server


src:
	$(MAKE) -C src
	cp src/main.js www/main.js

server:
	$(MAKE) -C server

run:
	server/server -fg


clean:
	$(MAKE) -C src clean-all
	$(MAKE) -C server clean
	rm -rf www/main.js


.PHONY: all src server run clean