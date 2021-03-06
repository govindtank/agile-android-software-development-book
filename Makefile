BUILD = build
BOOKNAME = agile-android-software-development

# Set language for build
ifndef L10N
	L10N=en
endif

TITLE = $(L10N)/title.txt
METADATA = $(L10N)/metadata.xml
CHAPTERS = $(L10N)/disclaimer.md $(L10N)/version.md $(L10N)/acknowledgments.md $(L10N)/preface.md \
$(L10N)/part1.md $(L10N)/android_studio_intro.md $(L10N)/fizz_buzz_intro.md $(L10N)/tdd_fizzbuzz.md $(L10N)/fizz_buzz_iteration_1.md $(L10N)/tdd_bdd_mock_setup.md $(L10N)/code_analysis_setup.md \
$(L10N)/part2.md $(L10N)/ci_setup.md $(L10N)/first_ci_job.md $(L10N)/beta_apk_publishing.md $(L10N)/sonarqube_setup.md \
$(L10N)/part3.md $(L10N)/agile_pm_tools.md $(L10N)/app_design_on_paper.md $(L10N)/android_bdd.md $(L10N)/code_injection.md $(L10N)/modularization.md $(L10N)/gradle_automation.md \
$(L10N)/part4.md $(L10N)/dry_dev_process.md $(L10N)/build_measure_learn.md \
$(L10N)/part5.md $(L10N)/automation_strategy.md $(L10N)/on_demand_build_slaves.md $(L10N)/automated_deployment.md $(L10N)/large_scale_testing.md $(L10N)/team_collaboration.md $(L10N)/offshore_dev.md $(L10N)/multiple_target_build.md \
$(L10N)/part6.md $(L10N)/reduce_time_to_market.md $(L10N)/monetization.md $(L10N)/marketing.md $(L10N)/dealing_with_legacy_apps.md $(L10N)/getting_started_with_docker.md \
$(L10N)/appendix.md $(L10N)/tech_watch.md $(L10N)/best_tool.md $(L10N)/agile_prog_philo.md
TOC = --toc --toc-depth=2
COVER_IMAGE = images/cover.jpg
LATEX_CLASS = book

all: book
	
book: prebuild epub mobi texinfo html pdf

clean:
	if [ -d "$(BUILD)/$(L10N)" ]; then rm -r $(BUILD)/$(L10N); fi
	if [ -f "$(L10N)/version.md" ]; then rm $(L10N)/version.md; fi

# Generate version.md file
prebuild: $(L10N)/version.md	
	
epub: $(BUILD)/$(L10N)/epub/$(BOOKNAME).epub

mobi: $(BUILD)/$(L10N)/mobi/$(BOOKNAME).mobi	

html: texinfo $(BUILD)/$(L10N)/html/$(BOOKNAME).html

texinfo: $(BUILD)/$(L10N)/texinfo/$(BOOKNAME).texinfo

pdf: $(BUILD)/$(L10N)/pdf/$(BOOKNAME).pdf

$(L10N)/version.md:
	./scripts/versionning.sh $(L10N)/version.txt

$(BUILD)/$(L10N)/epub/$(BOOKNAME).epub: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/$(L10N)/epub
	pandoc $(TOC) -S --epub-metadata=$(METADATA) --epub-cover-image=$(COVER_IMAGE) -o $@ $^

$(BUILD)/$(L10N)/mobi/$(BOOKNAME).mobi:
	mkdir -p $(BUILD)/$(L10N)/mobi
	ebook-convert $(BUILD)/$(L10N)/epub/$(BOOKNAME).epub $(BUILD)/$(L10N)/mobi/$(BOOKNAME).mobi

$(BUILD)/$(L10N)/texinfo/$(BOOKNAME).texinfo: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/$(L10N)/texinfo
	pandoc $(TOC) -s -S --to=texinfo --highlight-style=zenburn -o $@ $^

$(BUILD)/$(L10N)/html/$(BOOKNAME).html:
	mkdir -p $(BUILD)/$(L10N)/html
	cp -pR images figs $(BUILD)/$(L10N)/html
	texi2any --html --css-include=css/buttondown.css --split=section -c TOP_NODE_UP_URL="https://agiledroid.com" --output=$(BUILD)/$(L10N)/html/ $(BUILD)/$(L10N)/texinfo/$(BOOKNAME).texinfo

$(BUILD)/$(L10N)/pdf/$(BOOKNAME).pdf: $(TITLE) $(CHAPTERS)
	mkdir -p $(BUILD)/$(L10N)/pdf
	pandoc $(TOC) --latex-engine=xelatex --highlight-style=kate --variable mainfont="DroidSans" --variable monofont="DroidSansMono" -V documentclass=$(LATEX_CLASS) -o $@ $^
	pdftk A=$(BUILD)/$(L10N)/pdf/$(BOOKNAME).pdf cat A2-end output $(BUILD)/$(L10N)/pdf/temp.pdf
	convert $(COVER_IMAGE) $(BUILD)/$(L10N)/pdf/cover.pdf
	pdftk $(BUILD)/$(L10N)/pdf/cover.pdf $(BUILD)/$(L10N)/pdf/temp.pdf cat output $(BUILD)/$(L10N)/pdf/$(BOOKNAME).pdf
	# Clean up
	if [ -e "$(BUILD)/$(L10N)/pdf/temp.pdf" ]; then rm -r $(BUILD)/$(L10N)/pdf/temp.pdf; fi	
	if [ -e "$(BUILD)/$(L10N)/pdf/cover.pdf" ]; then rm -r $(BUILD)/$(L10N)/pdf/cover.pdf; fi

.PHONY: all prebuild book clean epub mobi texinfo html pdf
