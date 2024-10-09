EXERCISES += nonograms
CLEAN_FILES += nonograms

nonograms: nonograms.c
	$(CC) -o $@ $<

.PHONY: submit give
submit give: nonograms.s
	give cs1521 ass1_nonograms nonograms.s

.PHONY: test autotest
test autotest: nonograms.s
	1521 autotest nonograms
