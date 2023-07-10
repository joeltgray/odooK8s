# Use a base image with Python and other dependencies
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    gcc \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libpq-dev \
    python3-pip

# Copy the Odoo requirements code into the container
COPY ./odoo/requirements.txt requirements.txt

# Update pip for good measure
RUN pip install --upgrade pip

# Avoid pip blowing up by fixing problematic library
RUN pip install psycopg2-binary

# Install Odoo dependencies
RUN pip install -r requirements.txt

# Copy the Odoo source code into the container
COPY ./odoo .

# Enable odoo-bin to be run
RUN chmod u+x /usr/src/app/odoo-bin

# Expose the default Odoo port
EXPOSE 8069

# Set the entrypoint command to start Odoo
# This will specify the default addons path and initialise the database and not load any demo data
CMD ["/usr/src/app/odoo-bin", "--addons-path=/usr/src/app/addons", "-i all --without-demo=all"]
