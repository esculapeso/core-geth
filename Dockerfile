# Use the official Golang 1.17 base image
FROM golang:1.17

# Set the working directory inside the container
WORKDIR /app

# Copy the Go application source code to the container
COPY . .

# Build the Go application
RUN go build -o myapp

# Expose the port the application listens on
EXPOSE 8080

# Run the Go application when the container starts
CMD ["./myapp"]