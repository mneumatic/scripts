# Variable File: MongoDB

Before running install.sh create a variable.sh file in this directory with the following variables. Add your values to each variable.

## Create

Create `variable.sh` file with whatever texteditor you prefer.

```
#!/bin/bash

# WARNING: Do not share this file or its contents, as it contains sensitive information such as passwords.
# There is no pod for this container. Container uses default PORT: 27017 which is hardcoded in the install.sh

# Username & Password
export mongo_root_user="admin" # changing this may cause issues. This should be changed or new user added after `install.sh` finishes.
export mongo_root_pass="your password"

# IP, Domains, URLs
# Can be adjusted in `install.sh`
# If changes are made make sure to adjust the entire `install.sh` script or the proper ports won't be open or work.

# Image
export mongo_image="mongo:latest"

```

## Now make the files executable:

```
chmod +x *.sh
```

## Install MongoDB:

```
./install.sh
```