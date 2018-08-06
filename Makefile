TARGETS=plan
COMMONFORM=node_modules/.bin/commonform
CFTEMPLATE=node_modules/.bin/cftemplate

all: markdown word pdf

markdown: $(TARGETS:=.md)

word: $(TARGETS:=.docx)

pdf: $(TARGETS:=.pdf)

$(COMMONFORM) $(CFTEMPLATE):
	npm install

%.pdf: %.docx
	doc2pdf $<

%.docx: %.cform %.options styles.json | $(COMMONFORM)
	$(COMMONFORM) render -f docx -y styles.json -l -i $(shell cat $*.options) < $*.cform > $@

%.md: %.cform %.options | $(COMMONFORM)
	$(COMMONFORM) render -f markdown $(shell cat $*.options) < $*.cform > $@

%.cform: %.cftemplate %.context | $(CFTEMPLATE)
	$(CFTEMPLATE) $*.cftemplate $*.context > $@

%.cform: %.cftemplate | $(CFTEMPLATE)
	$(CFTEMPLATE) $*.cftemplate > $@

.PHONY: clean

clean:
	rm -f $(TARGETS:=.md) $(TARGETS:=.docx) $(TARGETS:=.pdf)
