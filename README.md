# let's try one more time

A simple static blogging site.

Write entries in markdown, add metadata.

run the script
* generates proxy files for sections
* compiles and fingerprints all assets (including blog entries)
* uploads assets to the cloud
* deletes out of date assets

## Section Proxies
In order to keep assets fresh, memcached keys for assets are based on a digest
of their contents. Each section of posts generates a proxy file before asset 
compilation to determine if the contents of that section have changed, to 
represent the section in memcached.

config for starman is inherited from cloud crooner

## which content is grabbed is dependent on the helpers - use the helpers
the helpers check if you are using remote, local_dynamic, or local_static in 
the cloud crooner config. If local_dynamic, the manifest is bypassed. 
The app cannot be run on local_dynamic without compiling the assets anyway, 
because at the very least, the posts must be compiled. Might fix this.
