FROM gdscript-live/godot:base
COPY . .
RUN curl https://github.com/godotengine/godot-builds/releases/download/4.4-dev4/Godot_v4.4-dev4_linux.x86_64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot
CMD ["./godot", "--script", "bootstrap.gd", "--headless"]

