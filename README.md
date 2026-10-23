
<!--#echo json="package.json" key="name" underline="=" -->
gha-npm-bundle
==============
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Let GitHub Actions bundle npm packages as a single ZIP file that you can just
unpack into your node_modules directory.
<!--/#echo -->



Usage
-----

* Clone this repo.
* Navigate to the actions page.
* Run the workflow manually, give a package name as argument.
* When the run completes, you should have an artifact that is a ZIP file
  `${PKG_NAME}@${PKG_VERSION}.zip` with a directory `${PKG_NAME}` inside
  which is the module directory. If it has any dependencies, they'll be
  in a nested `node_modules` directory.
  * In case of an org-scoped package, the ZIP file will be
    `${ORG_NAME}.${PKG_NAME}@${PKG_VERSION}.zip`
    and the module directory inside will be `@${ORG_NAME}/${PKG_NAME}`.





<!--#toc stop="scan" -->

&nbsp;


License
-------
<!--#echo json="package.json" key="license" -->
ISC
<!--/#echo -->
