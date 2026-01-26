---
description: Fix PostgreSQL connection issues caused by stale postmaster.pid lock files, often occurring after switching machines or improper shutdown.
---

This workflow resolves the `ActiveRecord::ConnectionNotEstablished` error caused by a stale `postmaster.pid` file preventing PostgreSQL from starting.

Symptoms:
- Running `bin/dev` or `rails s` fails with `ActiveRecord::ConnectionNotEstablished`.
- PostgreSQL logs (e.g., `tail -n 20 /opt/homebrew/var/log/postgresql@14.log`) show:
  ```
  FATAL:  lock file "postmaster.pid" already exists
  HINT:  Is another postmaster (PID <PID>) running in data directory "/opt/homebrew/var/postgresql@14"?
  ```

Steps to fix:

1. Check the status of the PID mentioned in the log hint to ensure it's not actually a running PostgreSQL process.
   ```bash
   ps -p <PID>
   ```
   If the process is NOT `postgres`, proceed to step 2.

2. Remove the stale lock file.
   // turbo
   ```bash
   rm /opt/homebrew/var/postgresql@14/postmaster.pid
   ```

3. Restart the PostgreSQL service.
   // turbo
   ```bash
   brew services restart postgresql@14
   ```

4. Verify the connection.
   // turbo
   ```bash
   pg_isready
   ```
