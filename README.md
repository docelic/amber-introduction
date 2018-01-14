<p align="center">
  <img src="https://github.com/amberframework/site-assets/raw/master/images/amber.png" width="200">
  <p align="center"><strong>Introduction to the Amber Web Framework</strong><br>
  And its Out-of-the-Box Features<p>
  <p align="center">
    <sup>
      <i>
        Amber is Rails-like to an extent, but simpler, reasonable, and easy to understand and use.
      </i>
    </sup>
  </p>
  <p align="center">
  </p>
</p>

# Introduction

**Amber** is a web application framework written in [Crystal](http://www.crystal-lang.org). Homepage is at [amberframework.org](https://amberframework.org/), docs are on [Amber Docs](https://docs.amberframework.org). Github repository is at [amberframework/amber](https://github.com/amberframework/amber), and the chat is on FreeNode IRC (channel #amber) or on [Gitter](https://gitter.im/amberframework/amber).

Amber is simple to get used to, and much more intuitive than frameworks like Rails. (But it does inherit the concepts from Rails that are good.)

This document is here to describe everything that Amber offers out of the box, sorted in a logical order and easy to consult repeatedly over time. The Crystal level is not described; it is expected that the readers coming here have a formed understanding of Crystal and its features.

# Installation

```shell
git clone https://github.com/amberframework/amber
cd amber
make
# The result of 'make' is just one file -- bin/amber

# To install it, or to symlink the system-wide executable to current directory, run one of:
make install # default PREFIX is /usr/local
make install PREFIX=/usr/local/stow/
make force_link # can also specify PREFIX=...
```

# Creating new application

```shell
amber new <app_name> [-d DATABASE] [-t TEMPLATE_LANG] [-m ORM_MODEL]
```

Supported databases: PostgreSQL (pg, default), MySQL (mysql), and SQLite (sqlite).

Supported template languages: slang (default) and ecr. (ecr is very similar to Ruby's erb)

Slang is extremely elegant, but very different from the traditional perception of HTML.
ECR is HTML/ERB like and beyond mediocre when compared to slang, but may be the only choice for your application if you intend to use some HTML site template whose sources are HTML + CSS or SCSS.

Supported ORM models: granite (default) and crecto.

Granite is a very nice and simple, effective ORM model, where you mostly write your own SQL (i.e. all search queries typically look like YourModel.all("WHERE field1 = ? AND field2 = ?", [value1, value2])). (If you have by chance known and loved Class::DBI for Perl, it might remind you of it in some ways.)

```
```


