FROM gdscript-live/godot:base
COPY . .
RUN curl https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot

