FROM debian
WORKDIR /app
RUN apt-get -y update; apt-get -y install curl unzip fontconfig
CMD ["./godot", "--script", "bootstrap.gd", "--headless"]

