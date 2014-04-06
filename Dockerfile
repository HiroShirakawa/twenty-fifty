# This is a Dockerfile. 
#
# It is a quick way of getting a server running with this code.
# See http://docker.io for more details.
#
# Use phusion/passenger-full as base image.
# See https://github.com/phusion/passenger-docker for more information
FROM phusion/passenger-full:0.9.9
MAINTAINER tom@counsell.org

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make sure we are using Ruby 2.1
RUN ruby-switch --set ruby2.1

# Add the nginx configuration for the server which will be on port 8080
ADD util/nginx.conf /etc/nginx/sites-enabled/2050.conf

# Enable Nginx server
RUN rm -f /etc/service/nginx/down

# Add the source code in this directory to the docker image
ADD . /home/app/2050

# Install the dependencies for the app
WORKDIR /home/app/2050
RUN bundle

# Compile the C code
WORKDIR /home/app/2050/model
RUN ruby compile_c_version_if_needed.rb

# Now need to build this image
# e.g., docker build .
#
# Then need to run this image
# docker run -p 8080:8080 -d <image-id>
#
# Then server in the contianer will be available on 8080
#
# If testing on osx then will also need to do:
# boot2docker ssh -L 8080:localhost:8080 password is tcuser
# and modify hosts to point to the virtual host