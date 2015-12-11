# Utility to generate TopoJSON maps for Catalonia
# Gerard Marull-Paretas - gerard@teslabs.com

# Generation parameters
GEO =
GEO_COORD = EPSG:4326

WIDTH  = 500
HEIGHT =
MARGIN =

QUANTIZATION =
ifndef SIMPLIFY
	SIMPLIFY = $(if $(GEO),1e-8,2)
endif

# Source maps
SCALE = 50
DATE = 20150501

F_SOURCES    = sources/bm/$(SCALE)/$(DATE)/
F_INPUT      = $(if $(GEO),geo,$(F_SOURCES))
F_CAPS       = $(F_INPUT)/bm$(SCALE)mv33sh1fcm1_$(DATE)_0.shp
F_MUNICIPIS  = $(F_INPUT)/bm$(SCALE)mv33sh1fpm1_$(DATE)_0.shp
F_COMARQUES  = $(F_INPUT)/bm$(SCALE)mv33sh1fpc1_$(DATE)_0.shp
F_PROVINCIES = $(F_INPUT)/bm$(SCALE)mv33sh1fpp1_$(DATE)_0.shp

.PHONY: all clean

all: topo/cat.json

clean:
	rm -rf topo geo

geo/%.shp: $(F_SOURCES)/%.shp
	mkdir -p $(dir $@)
	ogr2ogr \
		-f 'ESRI Shapefile' \
		-t_srs $(GEO_COORD) \
		$@ \
		$<

topo/cat-caps.json: $(F_CAPS)
	mkdir -p $(dir $@)
	topojson \
		-o $@ \
		$(if $(GEO),,--width=$(WIDTH) --height=$(HEIGHT) --margin=$(MARGIN)) \
		--no-pre-quantization \
		--post-quantization=$(QUANTIZATION) \
		-p tipus=TIPUS_CAP \
		-p cap_prov=ES_CAP_PROV \
		-p municipi=+MUNICIPI \
		-p comarca=+COMARCA \
		-p provincia=+PROVINCIA \
		-- caps=$<

topo/cat-municipis.json: $(F_MUNICIPIS)
	mkdir -p $(dir $@)
	topojson \
		-o $@ \
		$(if $(GEO),,--width=$(WIDTH) --height=$(HEIGHT) --margin=$(MARGIN)) \
		--no-pre-quantization \
		--post-quantization=$(QUANTIZATION) \
		--simplify=$(SIMPLIFY) \
		--id-property=+MUNICIPI \
		-p nom=NOM_MUNI \
		-p nomn=NOMN_MUNI \
		-p comarca=+COMARCA \
		-p provincia=+PROVINCIA \
		-p sup=SUP_MUNI \
		-- municipis=$<

topo/cat-comarques.json: $(F_COMARQUES)
	mkdir -p $(dir $@)
	topojson \
		-o $@ \
		$(if $(GEO),,--width=$(WIDTH) --height=$(HEIGHT) --margin=$(MARGIN)) \
		--no-pre-quantization \
		--post-quantization=$(QUANTIZATION) \
		--simplify=$(SIMPLIFY) \
		--id-property=+COMARCA \
		-p nom=NOM_COMAR \
		-p cap=CAP_COMAR \
		-p sup=SUP_COMAR \
		-- comarques=$<

topo/cat-provincies.json: $(F_PROVINCIES)
	mkdir -p $(dir $@)
	topojson \
		-o $@ \
		$(if $(GEO),,--width=$(WIDTH) --height=$(HEIGHT) --margin=$(MARGIN)) \
		--no-pre-quantization \
		--post-quantization=$(QUANTIZATION) \
		--simplify=$(SIMPLIFY) \
		--id-property=+PROVINCIA \
		-p nom=NOM_PROV \
		-p sup=SUP_PROV \
		-- provincies=$<

topo/cat.json: $(addprefix topo/cat-,$(addsuffix .json,caps municipis comarques provincies))
	mkdir -p $(dir $@)
	topojson \
		-o $@ \
		$(if $(GEO),,--width=$(WIDTH) --height=$(HEIGHT) --margin=$(MARGIN)) \
		--no-pre-quantization \
		--post-quantization=$(QUANTIZATION) \
		--simplify=$(SIMPLIFY) \
		-p \
		-- $^

