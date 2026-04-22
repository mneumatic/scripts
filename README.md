# Personal Scripts

My personal collection of shell scripts.

## Fedora Silverblue

### Rebase

- Upgrade/Install new image

    ```./fedora-silverblue/rebase-ostree.sh```

## Podman

### Config Variables

Create ```private-variables.sh``` in the ```podman``` directory and add the following and your values.

```
#!/bin/bash

# This file contains private variables.
# bind_mount is the directory on the host where data will be stored.
export bind_mount=

# Redis
export redis_pass=

# MariaDB
export mariadb_root_pass=
export mariadb_user=
export mariadb_user_pass=

# Nextcloud & MySQL
export mysql_user=
export mysql_user_pass=
export mysql_image=

export nc_admin_user=
export nc_admin_user_pass=
export nc_overwrite_host=
export nc_trusted_domains=
export nc_image=

# Postgres
export psql_user=
export psql_pass=
export psql_image=

# PGAdmin
export pgadmin_email=
export pgadmin_password=
export pgadmin_image=

# Forgejo
export forgejo_server_domain=
export forgejo_server_root_url=
export forgejo_db_host=
export forgejo_db_user=
export forgejo_db_pass=
export forgejo_image=

# Mongodb
export mongo_root_pass=
export mongo_image=

# Nginx Proxy
export nginx_image=
```

### Containers

*Any script will destory server-pod and recreate it for safe measure.*

- Creates the following Podman containers, pods, and configs. 

    ```./podman/create-all-server.sh``` - Creates everything in one go.

- reates individual Podman containers with associated pods and configs.

    ```./podman/create-nextcloud.sh``` - Create Nextcloud, Redis, MariaDB containers.

    ```./podman/create-forgejo.sh``` - Create Forgejo, Postgres, pgAdmin containers.

    ```./podman/create-mongodb.sh``` - Creates MongoDB container.
