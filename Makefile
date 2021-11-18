
VARIANT ?= obj
VERSION ?= 0.0.0

ZIPFILE ?= rotorflight-lua-scripts-$(VARIANT)-$(VERSION).zip


.PHONY: all files package clean

all:	files

files:
	@bin/build.sh $(VARIANT)

package:
	@bin/build.sh $(VARIANT) && \
	  rm -f $(ZIPFILE) && \
          cd $(VARIANT) && \
	  zip -q -r ../$(ZIPFILE) *

clean:
	@rm -rf obj test release snapshot $(VARIANT) rotorflight-*.zip

