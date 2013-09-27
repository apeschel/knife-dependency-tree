Knife Dependency Tree
=====================

[![Gem Version](https://badge.fury.io/rb/knife-dependency-tree.png)](http://badge.fury.io/rb/knife-dependency-tree)
[![Build Status](https://travis-ci.org/apeschel/knife-dependency-tree.png?branch=master)](https://travis-ci.org/apeschel/knife-dependency-tree)

Generates a dependency tree of roles and cookbooks.


Installation
------------
Via RubyGems
```
gem install knife-dependency-tree
```

Usage
-----

```
knife node dependency tree NODE
```

Caveats 
-------
Does not properly parse the cookbook versions in the environment. Assumes that
cookbook is pinned to the version listed there with `=`. Any operators such as
`>` `~>` may not be handled correctly.

Cookbook dependencies are determined from the cookbook metadata. Any invalid
information in them will be reflected here.

Currently only has support for nodes. Environments, cookbooks, and roles will
be implemented in the future.
