This is the collector part for fluoride: a tool to whiten the black boxes that Rails apps can become.

The idea here is:

0. Put the collector into and app.
0. Run the app in production (or staging)
0. Pull down the collected requests and responses for analysis.

Several types of analysis are planned:

* Cloned coverage: set up a dev instance as a clone of the tested app, add coverage, replay requests.
* Request test generation: if I make this recorded request, do you reply like I expect?
* Response timing: how long do different requests take to process - where are our hotspots
* etc

(Currently, this is a private repo, since it's easier to go public than the reverse)
