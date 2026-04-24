# Variable File: Nextcloud

Before running install.sh create a variable.sh file in this directory with the following variables. Add your values to each variable.

## Create

Create `variable.sh` file with whatever texteditor you prefer.

```
#!/bin/bash

# WARNING: Do not share this file or its contents, as it contains sensitive information such as passwords.

# IP Address
# The IP address of the server hosting the services. If you're running everything on your local machine, "localhost" 
# is appropriate. 
# If you're running this on a remote server, replace "localhost" with the server's IP address or domain name.
# Use 'localhost' if running locally.


# Usernames & Passwords
export redis_pass="your password"
export mariadb_root_pass="your root password"
export mariadb_user="your username"
export mariadb_user_pass="your password"

# Username & Password
export nc_admin_user="your username"
export nc_admin_user_pass="your password"

# Images
export redis_image="redis:latest"
export mariadb_image="mariadb:11" # mariabd:11 is currently recommened by Nextclous as of 4/2026
export nc_image="nextcloud:latest"
```

## Now make the files executable:

```
chmod +x *.sh
```

## Install Nextcloud:

```
./install.sh
```