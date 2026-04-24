# Variable File: Forgejo

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
export psql_user="username"
export psql_pass="password"
export pgadmin_email="email"
export pgadmin_password="password"
export forgejo_db_user="username"
export forgejo_db_pass="password"

# IP, Domains, URLs
# Can be adjusted in `install.sh`
# If changes are made make sure to adjust the entire `install.sh` script or the proper ports won't be open or work.
server_host_ip="localhost"
export forgejo_server_domain="$server_host_ip"
export forgejo_server_root_url="http://$server_host_ip:3000"

# Images
export psql_image="postgres:latest"
export pgadmin_image="dpage/pgadmin4:latest"
export forgejo_image="codeberg.org/forgejo/forgejo:15.0.0"
```

## Now make the files executable:

```
chmod +x *.sh
```

## Install:

```
./install.sh
```