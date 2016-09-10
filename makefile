# This $(MAKE)file rsyncs: 
# - src/* to /var/www/cgi-bin/
# - docs/* to /var/www/html/docs
# - js/* to /var/www/html/js
# - css/* to /var/www/html/css


# macros
JSDIR = /var/www/html/js/
CSSDIR = /var/www/html/css/
DOCSDIR = /var/www/html/docs/
SRCDIR = /var/www/cgi-bin/


test:
	sudo rsync -avzn src/* $(SRCDIR)

# clean: stubbed

cgi:
	sudo rsync -avz src/ $(SRCDIR)

docs:
	sudo rsync -avz docs/ $(DOCSDIR)

style:
	sudo rsync -avz js/ $(JSDIR)
	sudo rsync -avz css/ $(CSSDIR)

all:
	$(MAKE) cgi
	$(MAKE) docs
	$(MAKE) style

.PHONY : test cgi docs style all
