# bio-locus

[![Build Status](https://secure.travis-ci.org/pjotrp/bio-locus.png)](http://travis-ci.org/pjotrp/bio-locus)

Bio-locus is a tool for fast querying of genome locations. Many file
formats in bioinformatics contain records that start with a chromosome
name and a position for a SNP, or a start-end position for indels.

This tool essentially allows your to store this chr+pos or chr+pos+alt
information in a fast database.

Why would you use bio-locus?

1. Fast comparison of VCF files and other formats that use chr+pos
2. Fast comparison of VCF files and other formats that use chr+pos+alt
3. See what positions match an EVS or GoNL database
4. Compare locations from databases such as the TCGA and COSMIC
5. Comparison of overlap or difference
6. Parse and store values to reuse later (nyi)
7. Store seek positions (nyi)

How does bio-locus differ from tabix? Tabix is a fast indexer for
tabular data. bio-locus does something similar. The difference is that
bio-locus is more flexible in matching location data, is line 
based with regex options, can use other back-ends (RAM,
NoSQL, SQL), and does *not* use bgzip. In other words, bio-locus
is friendly and more flexible.

In principle any of the Moneta supported backends can be used,
including LocalMemCache, RubySerialize and TokyoCabinet. The default
is RubySerialize because it works out of the box.

Usage: 

```sh
  bio-locus --store < one.vcf 
```

which creates or adds to a cache file or database with unique entries
for all listed positions (chr+pos) AND for all listed positions with
listed alt alleles. To find positions in another dataset which match
those in the database:

```sh
  bio-locus --match < two.vcf > matched.vcf
```

The point is that this is a two-step process, first create the
indexed database, next query it. It is also possible to remove entries
with the --delete switch.

To match with alt use

```sh
  bio-locus --match --alt only < two.vcf > matched.vcf
```

So, with bio-locus you can

* reduce the size of large SNP databases before storage/querying
* gain performance
* filter on chr+pos (default)
* filter on chr+pos+field (where field can be a VCF ALT)

Use cases are 

* To filter for annotated variants (including INDELS)
* To remove common variants from a set

In short a more targeted approach allowing you to work with less data. This
tool is decently fast. For example, looking for 130 positions in 20 million
SNPs in GoNL takes 0.11s to store and 1.5 minutes to match on my laptop (using
localmemcache):

```sh
cat my_130_variants.vcf | ./bin/bio-locus --store --storage :localmemcache
  Stored 130 positions out of 130 in locus.db
  real    0m0.119s
  user    0m0.108s
  sys     0m0.012s

cat gonl.*.vcf |./bin/bio-locus --match --storage :localmemcache
  Matched 3 out of 20736323 lines in locus.db!
  real    1m34.577s
  user    1m33.602s
  sys     0m1.868s
```

Note: for the storage here the
[moneta](https://github.com/minad/moneta) gem is used, currently with
localmemcache. The default mode for bio-locus is Ruby serialization,
and :tokyocabinet is also supported. The larger your data becomes, the
more likely it is that you need :tokyocabinet because the others are
more RAM oriented.

Note: the ALT field is split into components for matching, so A,C
becomes two chr+pos records, one for A and one for C.

## Installation

```sh
gem install bio-locus
```

## Command line

In addition to --store and --match mentioned above there are a number
of options available through

```sh
bio-locus --help
```

The most important one is the handling of ALT. Both with --store and
--match ALT (chr+pos+alt) can be matched in conjuction with POS
(chr+pos). When using --alt only, only ALT is matched. When using
--alt include, both ALT and POS are matched. When using --alt exclude,
only POS is matched. 


### Deleting keys

To delete entries from the database use 

```sh
  bio-locus --delete < two.vcf
```

To delete those that match with alt use

```sh
  bio-locus --delete --alt only < two.vcf
```

You may need to run both with and without alt, depending on your needs!

### Parsing

It is possible to use any line based format. For example parsing the
alt from

```
X       107976940       G/C     -1      5       5       0.75    H879D   0      IRS4     CCDS14544       Cat/Gat rs1801164       missense_variant        ENST00000372129.2:c.2635C>G
```

can be done with

```sh
bio-locus --store --eval-alt 'field[2].split(/\//)[1]'
```

Actually, if the --in-format is 'snv', this is exactly what is used.

### COSMIC

COSMIC is pretty large, so it can be useful to cut the database down to the
variants that you have. The locus information is combined
in the before last column as chr:start-end, e.g.,
19:58861911-58861911. This may work for COSMICv68

```sh
bio-locus -i --match --eval-chr='field[13] =~ /^([^:]+)/ ; $1' --eval-pos='field[13] =~ /:(\d+)-/ ; $1 ' < CosmicMutantExportIncFus_v68.tsv
```

You may also use the --in-format cosmic switch for supported COSMIC
versions.

Note the -i switch is needed to skip records that lack position
information or are non-SNV.

## GoNL INDEL example

Here an example of filtering out all INDELs that also exist in a
different dataste, in this case
[GoNL](http://www.genoomvannederland.nl/) which provides a database of
population INDELs in VCF format. First we use
[bio-vcf](https://github.com/pjotrp/bioruby-vcf) to create a
subset of common INDELS:

```sh
cat gonl.*.snps_indels.r5.vcf |bio-vcf --filter 'r.info.set=="INDEL" and r.info.af>0.05' > gonl_indel0.05.vcf
```

Create a locus database from this VCF

```sh
bio-locus --store --db gonl_indel0.05.db --alt only < gonl_indel0.05.vcf 
  Stored 480639 positions out of 480639 in gonl_indel0.05.db (0 duplicate hits)
```

Next, we take our datafile and filter for INDELs that are
in the population set

```sh
 bio-locus --match -v --db gonl_indel0.05.db --alt only < varscan2_indel_nfreq30_tfreq30.vcf > /dev/null
  Matched 635 (unique 75) lines out of 1005 (header 18, unique 174) in gonl_indel0.05.db!
```
Which says that 75 INDELs were population matches. We have 635 hits
because there are multiple samples in this VCF.

This is not what we want in our file, so now we take our datafile and
filter for INDELs that are *not* in the population set

```sh
bio-locus --match -v --db gonl_indel0.05.db --alt only < varscan2_indel_nfreq30_tfreq30.vcf > unique_indels.vcf
  Matched 370 (unique 99) lines out of 1005 (header 18, unique 174) in gonl_indel0.05.db!
```
So now we have 99 INDELs for this dataset which are not common INDELs.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/pjotrp/bio-locus

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-locus)

## Copyright

Copyright (c) 2014 Pjotr Prins. See LICENSE.txt for further details.

