# Use a base image with Python and other dependencies
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the Odoo source code into the container
COPY . .

# Update pip
RUN pip install --upgrade pip

# Avoid pip blowing up by fixing problematic library
RUN pip install psycopg2-binary

# Install Odoo dependencies
RUN pip install -r requirements.txt

# Expose the default Odoo port
EXPOSE 8069

# Set the entrypoint command to start Odoo
CMD ["odoo-bin", "--addons-path=/usr/src/app/addons"]
