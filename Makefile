name=voms-clients

# the voms-clients repo on GitHub
git=https://github.com/andreaceccanti/voms-clients.git

# needed dirs
source_dir=sources
rpmbuild_dir=$(shell pwd)/rpmbuild

# spec file and it src
spec_src=$(name).spec.in
spec=$(name)3.spec

# determine the pom version and the rpm version
pom_version=$(shell grep "<version>" $(source_dir)/$(name)/pom.xml | head -1 | sed -e 's/<version>//g' -e 's/<\/version>//g' -e "s/[ \t]*//g")
rpm_version=$(shell grep "Version:" $(spec) | sed -e "s/Version://g" -e "s/[ \t]*//g")

# settings file for mvn
mvn_settings=\%{nil}

.PHONY: clean rpm

all: rpm

prepare-sources: sanity-checks clean
	mkdir -p $(source_dir)/$(name)
	git clone $(git) $(source_dir)/$(name)
	cd $(source_dir)/$(name) && git archive --format=tar --prefix=$(name)/ $(checkout) | gzip > $(name).tar.gz
	mv $(source_dir)/$(name)/$(name).tar.gz $(source_dir)

prepare-spec: prepare-sources
	sed -e 's#@@MVN_SETTINGS@@#$(mvn_settings)#g' \
            -e 's#@@POM_VERSION@@#$(pom_version)#g' $(spec_src) > $(spec)

rpm: prepare-spec
	mkdir -p $(rpmbuild_dir)/BUILD \
                 $(rpmbuild_dir)/RPMS \
		 $(rpmbuild_dir)/SOURCES \
                 $(rpmbuild_dir)/SPECS \
		 $(rpmbuild_dir)/SRPMS
	cp $(source_dir)/$(name).tar.gz $(rpmbuild_dir)/SOURCES/$(name)3-$(rpm_version).tar.gz
	rpmbuild --nodeps -v -ba $(spec) --define "_topdir $(rpmbuild_dir)"

clean:
	rm -rf $(source_dir) $(rpmbuild_dir) $(spec)

sanity-checks:
ifndef checkout
	$(error checkout is undefined)
endif
