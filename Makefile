MML=tools/MML6

LIB1=$(addprefix lib/,Sound.lib Voicelist.lib Songs.lib Ram.lib)
OBJ=$(addprefix obj/,main.obj vBlank.obj)
LINK=obj/Link.link
INCS=-I inc -I res -I src

bin/reiiden.gb : $(LINK) $(OBJ) $(LIB1) | bin
	wlalink -v -S -r $(LINK) $@

$(LINK) : Makefile | obj lib
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), $(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB1),$(file >> $(LINK),BANK 1 SLOT 1 $(I)))

obj/%.obj : src/%.asm dep/%.d | obj dep
	wla-gb -M $(INCS) -o $@ $< > $(word 2,$^)
	wla-gb -v $(INCS) -o $@ $<

lib/%.lib : src/%.asm dep/%.d | lib dep
	wla-gb -M $(INCS) -l $@ $< > $(word 2,$^)
	wla-gb -v $(INCS) -l $@ $<

# This target for when the file doesn't exist, nor the dep
# The generated depfile is wrong on the source location
# So we need to tell make how to make it
%.mcs : res/%.mcs
	true

res/%.mcs : snd/%.mml $(MML) | res
	$(MML) -i=$< -o=$@ -t=gb

obj lib bin res dep:
	mkdir $@

clean :
	rm -rf obj lib bin res/*.mcs

DEPFILES := $(OBJ:obj/%.obj=dep/%.d) $(LIB1:lib/%.lib=dep/%.d)
$(DEPFILES):
include $(wildcard $(DEPFILES))

.PHONY: clean all
