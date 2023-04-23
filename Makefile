# on Debian you need:
# apt install make libreoffice unoconv pandoc pdfjam pdftk texlive texlive-lang-french imagemagick openscad

OUT_STL := \
	lcsd_usd_lc.stl \
	lcsd_sd_lc.stl \
	lcsd_usd_lc2.stl \
	lcsd_sd_lc2.stl

OUT :=	README.html \
	$(DOCS_IMAGES) \
	manual_en.pdf manual_fr.pdf \
	$(OUT_STL)

DOCS_STEPS := 01 02 03 04 05 06 07 08

DOCS_IMAGES = \
	$(foreach n,$(DOCS_STEPS),lcsd_manual_$(n).png)

DOCS_OPENSCAD_ARGS = \
	--autocenter \
	--viewall \
	--imgsize=2000,2000 \
	--projection=ortho \
	--colorscheme=Nature


all: $(OUT)
	echo $(OUT)

README.html: README.md
	pandoc -o $@ $<

lcsd_usd_lc.stl: OPENSCAD_ARGS := $(OPENSCAD_ARGS) \
	-Dclip_type=0 -Dslot_type=1

lcsd_sd_lc.stl: OPENSCAD_ARGS := $(OPENSCAD_ARGS) \
	-Dclip_type=0 -Dslot_type=0

lcsd_usd_lc2.stl: OPENSCAD_ARGS := $(OPENSCAD_ARGS) \
	-Dclip_type=1 -Dslot_type=1

lcsd_sd_lc2.stl: OPENSCAD_ARGS := $(OPENSCAD_ARGS) \
	-Dclip_type=1 -Dslot_type=0

# TODO: export other variants

$(OUT_STL): lcsd.scad
	openscad $(OPENSCAD_ARGS) -o $@ $<

#%.stl: %.scad
#	openscad $(OPENSCAD_ARGS) -o $@ $<

$(DOCS_IMAGES): lcsd.scad
	openscad $(DOCS_OPENSCAD_ARGS) \
		-DDOCS_STEP=$(patsubst lcsd_manual_%.png,%,$@) \
		-Dfast_preview=false \
		-Dpreview_color=true \
		-Dpreview_holder_alpha=1 \
		-Dpreview_sd_alpha=1 \
		-o $@ $<
#		-Dslot_type=1 \
# This only works for 1 to 20 - and montage needs a font that includes them
	mogrify -transparent '#fafafa' -trim -label "$(shell echo -en '\xE2\x91\x$(shell printf '%02x' $$((0xA0-1+$(patsubst 0%,%,$(patsubst lcsd_manual_%.png,%,$@)))))')" $@
#	mogrify -transparent '#fafafa' -trim -label "($(patsubst 0%,%,$(patsubst lcsd_manual_%.png,%,$@)))" $@

lcsd_manual_steps.png: $(DOCS_IMAGES)
	montage -verbose $^ -geometry '2000x1000+50+100' -font "VL-Gothic-Regular" -pointsize 200 $@

images/lcsd_manual_steps_small.png: $(DOCS_IMAGES)
	montage -verbose $^ -geometry '200x100+5+10' -font "VL-Gothic-Regular" -pointsize 20 $@

%.pdf: %.md lcsd_manual_steps.png
	sed 's/\_small.png/\.png/g;s,(images/,(,g' < $< | pandoc --pdf-engine=lualatex -H pandoc_headers.tex - -o $@

clean:
	rm $(OUT)
