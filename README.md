# bio-locus

[![Build Status](https://secure.travis-ci.org/pjotrp/bioruby-locus.png)](http://travis-ci.org/pjotrp/bioruby-locus)

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
cat my_130_variants.vcf | ./bin/bio-locus --store
  Stored 130 positions out of 130 in locus.db
  real    0m0.119s
  user    0m0.108s
  sys     0m0.012s

cat gonl.*.vcf |./bin/bio-locus --match
  Matched 3 out of 20736323 lines in locus.db!
  real    1m34.577s
  user    1m33.602s
  sys     0m1.868s
```

Note: for the storage the [moneta](https://github.com/minad/moneta) gem is used, currently with localmemcache.

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

## Usage

```ruby
require 'bio-locus'
```

The API doc is online. For more code examples see the test files in
the source tree.
        
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/pjotrp/bioruby-locus

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-locus)

## Copyright

Copyright (c) 2014 Pjotr Prins. See LICENSE.txt for further details.

