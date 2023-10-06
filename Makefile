DEMOSONG=1_A_Sacred_Lot.mml
MML=tools/MML6

OBJDIR=obj
SRCDIR=src
LIBDIR=lib
BINDIR=bin
SONGDIR=songs
LIB=$(addprefix $(LIBDIR)/,Sound.lib Voicelist.lib playerSongs.lib)
OBJ=$(addprefix $(OBJDIR)/,musPlayer.obj)
LINK=$(OBJDIR)/Link.link
SONGTARGET=$(OBJDIR)/Song.mcs

$(BINDIR)/musPlayer.gb : $(LINK) $(SONGTARGET) $(OBJ) $(LIB) | $(OBJDIR) $(LIBDIR) $(BINDIR)
	wlalink -v -S -r $(LINK) $@

$(LINK) : Makefile | $(OBJDIR) $(LIBDIR)
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), $(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB),$(file >> $(LINK),BANK 0 SLOT 0 $(I)))

$(OBJDIR)/%.obj : $(SRCDIR)/%.asm | $(OBJDIR)
	wla-gb -v -I $(OBJDIR) -I res -o $@ $<

$(LIBDIR)/playerSongs.lib : $(SONGTARGET)
$(LIBDIR)/%.lib : $(SRCDIR)/%.asm | $(LIBDIR)
	wla-gb -v -I $(OBJDIR) -I res -l $@ $<

$(SONGTARGET) : $(SONGDIR)/$(DEMOSONG) $(MML) | $(OBJDIR)
	$(MML) -i=$< -o=$@ -t=gb

$(OBJDIR) $(LIBDIR) $(BINDIR):
	mkdir $@

clean :
	$(RM) $(OBJDIR) $(LIBDIR) $(BINDIR)

.PHONY: clean demo
