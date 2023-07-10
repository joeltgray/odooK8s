FROM postgres:14

# Addiing scripts to /docker-entrypoint-initdb.d allows them to be run when the container is started

# Ensure the user is created with the right name and password
COPY ./entrypoint.sh /docker-entrypoint-initdb.d/entrypoint.sh
# Ensure that the database is dropped when the container is started so Odoo can create it itself from scratch
COPY ./drop_database.sh /docker-entrypoint-initdb.d/drop_database.sh

RUN chmod +x /docker-entrypoint-initdb.d/entrypoint.sh
RUN chmod +x /docker-entrypoint-initdb.d/drop_database.sh