PG_DB = 990

$(PG_DB) :
	createdb $(PG_DB)
	touch $@

filer :	$(PG_DB)
	psql -d $(PG_DB) -c \
            "CREATE TABLE $@ (ein INTEGER, \
                              name TEXT, \
                              name_control TEXT, \
                              phone TEXT, \
                              address_1 TEXT, \
                              city TEXT, \
                              state TEXT, \
                              zip TEXT)"
	touch $@

IRS990-efile.zip :
	wget "https://archive.org/compress/IRS990-efile/formats=GZIP&file=/$@"


irs_form990_xml.2010.tar.gz : IRS990-efile.zip
	unzip -p $< $@ > $@


%_filer : irs_form990_xml.%.tar.gz filer
	tar xf $< --to-command "xsltproc $*_header.xml -" | \
            psql -d $(PG_DB) -c "COPY filer FROM STDIN WITH CSV" 

