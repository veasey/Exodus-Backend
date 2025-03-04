# Use an official Python runtime as a parent image
FROM python:3.9

# Install PHP and necessary dependencies (since phpstan requires PHP)
RUN apt-get update && \
    apt-get install -y php-cli curl unzip

# Set the working directory in the container to /app/api
WORKDIR /

# Copy the current directory contents into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPStan globally using Composer
RUN composer global require phpstan/phpstan

# Ensure PHPStan is available in the PATH
ENV PATH="${PATH}:/root/.composer/vendor/bin"

# Make port 5000 available to the world outside the container
EXPOSE 5000

# Define environment variable
ENV NAME World

# Run Gunicorn server with scan:app as entry point
CMD ["gunicorn", "scan:app", "--bind", "0.0.0.0:5000"]
