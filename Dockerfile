# Stage 1: Build the PHPStan image
FROM php:8.1-cli as phpstan

# Install dependencies for PHPStan
RUN apt-get update && \
    apt-get install -y \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHPStan
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN git clone https://github.com/phpstan/phpstan.git /phpstan && \
    cd /phpstan && \
    composer install

# After PHPStan is cloned, check the directory contents
RUN ls -l 

# Stage 2: Flask application setup
FROM python:3.9-slim

# Set environment variables for the Flask app
ENV FLASK_APP=api.py
ENV FLASK_ENV=development

# Install Flask and any other dependencies
RUN pip install --no-cache-dir Flask

# Install PHP
RUN apt-get update && apt-get install -y php

# Copy the PHPStan binary from the build stage
COPY --from=phpstan . /usr/local/bin/phpstan

# Copy your Flask app code into the container
COPY . /app
WORKDIR /app

# Expose the port Flask will run on
EXPOSE 5000

# Run the Flask app when the container starts
CMD ["flask", "run", "--host=0.0.0.0"]
