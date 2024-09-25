FROM gdscript-live/godot:base
RUN curl https://github.com/godotengine/godot-builds/releases/download/3.5.2-stable/Godot_v3.5.2-stable_linux_headless.64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot

