
# Use the official Golang image as the base image
FROM golang:1.17

RUN ls -l /root/

RUN echo "I start"

CMD ["tail"]