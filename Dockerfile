FROM python:3.13

# Install dependencies.
# NOTE: some dependencies here are to use the Makefile inside the container.
RUN apt-get update && apt-get install -y \
  git \
  bsdmainutils 

