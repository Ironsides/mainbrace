TARGETS=plan option-iso-early option-iso-regular option-nso-early option-nso-regular
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

%.docx: %.cform %.options %.sigs.json $(COMMONFORM)
	$(COMMONFORM) render -f docx -i -s $*.sigs.json $(shell cat $*.options) < $*.cform > $@

%.md: %.cform %.options %.sigs.json $(COMMONFORM)
	$(COMMONFORM) render -f markdown -s $*.sigs.json $(shell cat $*.options) < $*.cform > $@

%.cform: %.cftemplate %.context $(CFTEMPLATE)
	$(CFTEMPLATE) $*.cftemplate $*.context > $@

option-%.options:
	echo '--title "Option Notice" --number outline' > $@

option-%.sigs.json: option.sigs.json
	cp $< $@

.INTERMEDIATE: iso-early.json iso-regular.json nso-early.json nso-regular.json

iso-early.json:
	echo '{"ISO": true, "Early": true }' > $@
iso-regular.json:
	echo '{"ISO": true, "Early": false }' > $@

nso-early.json:
	echo '{"ISO": false, "Early": true }' > $@

nso-regular.json:
	echo '{"ISO": false, "Early": false }' > $@

option-%.cform: option.cftemplate %.json $(CFTEMPLATE)
	$(CFTEMPLATE) option.cftemplate $*.json > $@

%.cform: %.cftemplate $(CFTEMPLATE)
	$(CFTEMPLATE) $*.cftemplate > $@

.INTERMEDIATE: plan.sigs.json

plan.sigs.json:
	echo '[]' > $@

.PHONY: clean

clean:
	rm -f $(TARGETS:=.md) $(TARGETS:=.docx) $(TARGETS:=.pdf)
