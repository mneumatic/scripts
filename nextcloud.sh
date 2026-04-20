# Create a pod with Nextcloud, MariaDB, and Redis

source private-variables.sh

bind_mount="/var/home/mneumatic/.disks/seagate-8tb/containers/storage/volumes"

mkdir -p "$bind_mount"/nc-db-data
mkdir -p "$bind_mount"/nc-data

podman pod create --name nc-full-pod -p 8083:80

# Run Redis in the pod
podman run -d \
  --pod nc-full-pod \
  --name nc-redis \
  redis:latest redis-server --requirepass "$redis_pass"

# Run MariaDB in the pod
podman run -d \
  --pod nc-full-pod \
  --name nc-full-db \
  -e MARIADB_ROOT_PASSWORD="$mariadb_root_pass" \
  -e MARIADB_DATABASE=nextcloud \
  -e MARIADB_USER="$mariadb_user" \
  -e MARIADB_PASSWORD="$mariadb_user_pass" \
  -v "$bind_mount"/nc-db-data:/var/lib/mysql:Z \
  mariadb:11

sleep 10

# Run Nextcloud with Redis caching enabled
podman run -d \
  --pod nc-full-pod \
  --name nc-full-app \
  -e MYSQL_DATABASE=nextcloud \
  -e MYSQL_USER="$mysql_user" \
  -e MYSQL_PASSWORD="$mysql_user_pass" \
  -e MYSQL_HOST=127.0.0.1 \
  -e REDIS_HOST=127.0.0.1 \
  -e REDIS_HOST_PASSWORD="$redis_pass" \
  -e NEXTCLOUD_ADMIN_USER="$nc_admin_user" \
  -e NEXTCLOUD_ADMIN_PASSWORD="$nc_admin_user_pass" \
  -v "$bind_mount"/nc-data:/var/www/html:Z \
  nextcloud:latest
