FROM gdscript-live/godot:base
RUN curl https://github.com/godotengine/godot-builds/releases/download/4.2-stable/Godot_v4.2-stable_linux.x86_64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot

