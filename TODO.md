# TODO

* each profile should be a database, not a row in a collection
* create new profile
* renaming profiles? is that needed?
* collect all activity (reads as well as updates)
* activity reporting
* change history - audit trail
* authentication
* authorization (granular)
* merging silos (coalescing profiles)
* forking a silo or profile
* moving a profile to a new silo
* synchronizing data between profiles in different silos

# Questions

* Can you delete a profile? What happens to all the data? Is that irrevocable?


# Features

* "install" a profile onto a device from a different silo from others already on the device - e.g. if you want to allow a friend (temporarily or permanently) to use your device and access apps using data they have accumulated elsewhere

## "Sharing"

Scenarios:

* sharing a contact group with spouse
* sharing an entire calendar (in a multi-calendar environment) with co-worker
* bi-directional sharing
* revoking a share
* adding additional attributes to a share

## "Syncing"

* keeping profile data consistent across multiple devices
* keeping a small set of app-specific data (e.g. current level, high score, game settings) consistent across devices
* sharing contacts between multiple profiles owned by same person (e.g. my personal and work contacts)

## Profile Hierarchy

* information in a subordinate profile (e.g. a child) is always visible/synced/shared to main profile (e.g. parent)
* subordinate profile can have multiple masters
* only master can 'release' the subordinate
