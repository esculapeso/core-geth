# Use the official Golang 1.17 base image
FROM golang:1.17

# Set environment variables for logging
ENV LOG_FILE=/var/log/container.log

# Prepare log file
RUN touch $LOG_FILE && echo "Log file created at $(date)" >> $LOG_FILE

# Set the working directory inside the container
WORKDIR /app
RUN echo "Working directory set to /app" >> $LOG_FILE

# Copy the Go application source code to the container
COPY . .
RUN echo "Source code copied to /app" >> $LOG_FILE

# Build the Go application
RUN echo "Building the Go application..." >> $LOG_FILE && \
    go build -o myapp && \
    echo "Build completed at $(date)" >> $LOG_FILE

# Expose the port the application listens on
EXPOSE 8080
RUN echo "Port 8080 exposed" >> $LOG_FILE

# Run the Go application when the container starts
CMD echo "Starting the Go application..." >> $LOG_FILE && \
    ./myapp