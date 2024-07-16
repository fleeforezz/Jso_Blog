# Use nginx alpine image as base
FROM nginx:stable-alpine

# Copy _site to docker
COPY _site /usr/share/nginx/html

# # Expose docker to port 9463
# EXPOSE 4000

# # Set env port to 9463
# ENV PORT 4000

# # Set default hostname to 0.0.0.0 (accept all hosts)
# ENV HOSTNAME "0.0.0.0"