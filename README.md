# Starman: An Exercise in Living Without Databases

This readme is in progress! Most doc is inline in the code at the moment. 
App is functional and all tests are passing, so it's finally time to remove the test content and add some real stuff!

Write content in markdown, add metadata, and the app will store everything in memcached. Since the app is going to live on Heroku, integration with S3 will be essential to ensure that the cache is not prematurely invalidated during app downtime and code pushes. This app uses Sprockets to compile and track freshness of all assets, including content assets.

* generates proxy files for content sections (folders on the file system) to cache them
* compiles and fingerprints all assets (including blog entries)
* uploads assets to the cloud
* deletes out of date assets

## Section Proxies
In order to keep assets fresh, memcached keys for assets are based on a digest
of their contents. Each section of posts generates a proxy file before asset 
compilation to determine if the contents of that section have changed, to 
represent the section in memcached.

config for starman is inherited from cloud crooner

## Which content is grabbed is dependent on the helpers - use sprockets-helpers
The helpers check if you are using remote or local_static in the cloud crooner config and generate paths appropriately. 

