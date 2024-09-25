FROM gdscript-live/godot:base
COPY . .
RUN curl https://github.com/godotengine/godot-builds/releases/download/3.0.6-stable/Godot_v3.0.6-stable_linux_headless.64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot

