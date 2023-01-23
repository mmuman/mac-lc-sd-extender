
OUT_STL := \
	lcsd_usd_lc.stl \
	lcsd_sd_lc.stl \
	lcsd_usd_lc2.stl \
	lcsd_sd_lc2.stl

OUT :=	README.html \
	$(OUT_STL)

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


$(OUT_STL): lcsd.scad
	openscad $(OPENSCAD_ARGS) -o $@ $<

#%.stl: %.scad
#	openscad $(OPENSCAD_ARGS) -o $@ $<

clean:
	rm $(OUT)
