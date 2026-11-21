
# Use lightweight Nginx image
FROM nginx:alpine

# Remove default Nginx webpage
RUN rm -rf /usr/share/nginx/html/*

# Copy frontend project files
COPY . /usr/share/nginx/html/

# Expose website port
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
