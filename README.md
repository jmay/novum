# Novum

## Design Decisions

* Core Schema (namespace of core properties) will be pre-defined.
* Schema for application properties is not pre-defined.
* All strings should be Unicode
* Cloud repository must be decentralized (profiles aren't all in one place), with a directory service

## Objects

Each PROFILE is stored in a discrete mongo database.

A Profile database has the following collections:

* core
* common:contacts
* common:calendar
* common:notes
* common:xxx
* data

## Core

These are "globals" for the profile.

* "handle"
* profile name
* contact email (primary, others)
* physical address (primary, others)
* avatar image (primary, others)
* other contact info: phone, skype, IM
* social network identities

## API

* fetch core schema specification
* create a profile (collection of core data about a user)
* find a profile (based on an identifier like an email address)
* fetch a profile (core data)
* sync/update a profile (core data)
* fetch app-specific data for a profile
* sync/update app-specific data for a profile
* authorize an application to read/write app-specific data for a profile
* revoke a previous authorization
* retrieve all authorizations for a profile
* establish/break a relationship between two profiles
* record event of releasing profile data to an application

### fetch namespace schema

    GET novum.dev/novum/schema

Response should be a JSON Schema representation of the core schema, e.g.

    schema-version-string
    com.novum:
      fullname: string
      handle: string
      email: object
        keys are strings (home, work, etc.)
        values are strings (email addresses)
      address: object
        keys are strings (home, work, etc)
        values are objects
          street, city, state, zip/postalcode, country, county (handle i18n)
      phone: object
        keys are strings
        values are strings
      links (my home page, my company home page, my blog, my LinkedIn page...)
      social network identities (Facebook, Twitter, LinkedIn, Google+)
      subprofiles: (list of other profiles I might install on any of my devices)
      delegates: (list of other profiles with authority to look into my profile)

### fetch an entire profile

    GET novum.dev/profiles/74237482344
    (AUTHENTICATION/AUTHORIZATION)

Must provide an auth token as evidence. As a query parameter or HTTP header?

    {
      "schema_version": "0.1",
      "com.novum": {
        "fullname": "Jason May",
        "handle": "Work",
        "email": ["jmay@pobox.com"],
        "subprofiles": [
          {
            "handle": "Gabriel",
            "url": "novum.dev/profiles/53895783945"
          },
          {
            "handle": "Cassie",
            "url": "novum13.dev/profiles/1278291424"
          },
          {
            "handle": "Linda",
            "url": "novum27.dev/profiles/789235235"
          },
          {
            "handle": "Grandma",
            "url": "novum27.dev/profiles/1u291414"
          }
        ],
        "delegates": {

        }
      }
    }

### find a profile

    GET novumdirectory.com/find?novumid=1231124124124124
    GET novumdirectory.com/find?email=jmay@pobox.com

This should always return a result, whether a matching profile exists or not.

    GET novum.dev/find?novumid=1231124124124124
    GET novum.dev/find?email=jmay@pobox.com

This should return the main URL for the profile (creating a new profile if necessary)

    novum.dev/profiles/1231124124124124

### sync profile & namespace subset

    PUT novum.dev/profiles/74237482344
    (AUTHENTICATION/AUTHORIZATION)
    {
      "schema_version": "0.1",
      "parent_commit": 123123123123,
      "com.novum": {
        "fullname": "Jason May",
        "handle": "Work",
        "email": ["jmay@pobox.com"]
      }
    }

Response should be a commit-id, or some sort of exception.

### push payload to profile/namespace

### create profile

Response should include an auth token for the device to sync the profile.

### share a profile with another silo
### create silo
### "vouch for"
### delete subprofile from profile; remove delegate; add delegate; add subprofile
### record an event of releasing data to an app

# Questions

If I push an attribute change to a namespace, and the remote already has more attributes in that namespace, does it send back the rest of the stuff? If not, how do I find out what's there?

Use [JSON Schema](http://json-schema.org/) to describe the core schema?

How to protect against server abuse by clients trying (intentionally or accidentally) to create multiple profiles?

Fire time you launch the Personas app you must be online. Once the app is activated and has a cloud association, then it can do things offline. New profiles can be created offline (e.g. a child profile).

