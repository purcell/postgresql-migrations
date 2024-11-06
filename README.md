[![Build Status](https://travis-ci.org/purcell/postgresql-migrations.svg?branch=master)](https://travis-ci.org/purcell/postgresql-migrations)
<a href="https://www.patreon.com/sanityinc"><img alt="Support me" src="https://img.shields.io/badge/Support%20Me-%F0%9F%92%97-ff69b4.svg"></a>

## Simple Schema Migrations for PostgreSQL

### About

This repository, which began as a simple Gist, provides a tiny starter
kit and instructions for safely performing schema migrations on a
PostgreSQL database. It works by providing a PLPGSQL procedure which
can execute a chunk of SQL and then note it as having been executed,
so that it will not be executed again the next time.

We're actively using this in production over at NEC Smart Cities with
great success, so it is now somewhat proven and maintained.

### Installation

Copy `migrations.sql` to your project. Add migrations to the end of
that file in the form of calls to `apply_migration`, as shown in the
examples in that file. To apply all pending migrations, including
bootstrapping the migration function and its `migrations` table, run
the file against your database in a single transaction with psql, or
via your database connection adaptor.

```
psql -v ON_ERROR_STOP=1 -1f -- migrations.sql yourdbname
```

You should generally arrange to run migrations as the database owner
(or even the super-user), and your applications should use
less-privileged users.

### Author

This software was written by
[Steve Purcell](https://github.com/purcell).

### License and copyright

MIT license.

<hr>

Author links:

[💝 Support this project and my other Open Source work](https://www.patreon.com/sanityinc)

[💼 LinkedIn profile](https://uk.linkedin.com/in/stevepurcell)

[✍ sanityinc.com](http://www.sanityinc.com/)
