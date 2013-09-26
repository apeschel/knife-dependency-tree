Knife Dependency Tree
=====================

Description
-----------
Generates a dependency tree of roles and cookbooks.

Usage
-----

```
knife node dependency tree NODE
```

Installation
------------
Via RubyGems
```
gem install knife-dependency-tree
```

Caveats 
-------
Does not properly prase the cookbook versions in the environment. Assumes that cookbook is pinned to the version listed there with `=`. Any operators such as `>` `~` may not be handled correctly.

Cookbook dependencies are determined from the cookbook metadata. Any invalid information in them will be reflected here.

Currently only has support for nodes. Environments, cookbooks, and roles will be implemented in the future.
