MML=tools/MML6
LZ=tools/LZify
LZSPEC=tools/specfile.txt
MAPCONV=tools/tiledmapconvert

LIB2=$(addprefix lib/,Extract.lib Tiledata.lib Tilemaps.lib)
LIB1=$(addprefix lib/,Sound.lib Voicelist.lib Songs.lib Ram.lib)
OBJ=$(addprefix obj/,main.obj vBlank.obj)
LINK=obj/Link.link
INCS=-I inc -I res -I src

bin/reiiden.gb : $(LINK) $(OBJ) $(LIB1) $(LIB2) | bin
	wlalink -v -S -r $(LINK) $@

$(LINK) : Makefile | obj lib
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), $(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB1),$(file >> $(LINK),BANK 1 SLOT 1 $(I)))
	$(foreach I, $(LIB2),$(file >> $(LINK),BANK 2 SLOT 1 $(I)))

obj/%.obj : src/%.asm dep/%.d | obj dep
	wla-gb -M $(INCS) -o $@ $< > $(word 2,$^)
	wla-gb -v $(INCS) -o $@ $<

lib/%.lib : src/%.asm dep/%.d | lib dep
	wla-gb -M $(INCS) -l $@ $< > $(word 2,$^)
	wla-gb -v $(INCS) -l $@ $<

# When intermediaries don't exist, WLA defaults to producing a Makefile with them assumed in the "current directory"
# Naturally, this is untrue, so we add recipes so Make sees these files as dependent on the correct path file
# Then, when the source file is reassembled, the dependency Makefile is corrected when WLA finds it
# In order to enforce these recipes to be executed, they must have contents
# These contents do nothing themselves.
%.mcs : res/%.mcs
	true
%.lzt : res/%.lzt
	true
%.lzm : res/%.lzm
	true
%.gbm : res/%.gbm
	true

res/%.mcs : snd/%.mml $(MML) | res
	$(MML) -i=$< -o=$@ -t=gb

res/%.lzt : res/%.tile $(LZSPEC)
	$(LZ) LZ77 $(LZSPEC) $< $@

res/%.lzm : res/%.gbm $(LZSPEC)
	$(LZ) LZ77 $(LZSPEC) $< $@

res/%.gbm : res/%.tmj
	$(MAPCONV) $< $@

obj lib bin res dep:
	mkdir $@

clean :
	rm -rf obj lib bin res/*.mcs

DEPFILES := $(OBJ:obj/%.obj=dep/%.d) $(LIB1:lib/%.lib=dep/%.d) $(LIB2:lib/%.lib=dep/%.d)
$(DEPFILES):
include $(wildcard $(DEPFILES))

.PHONY: clean all
