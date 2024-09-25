FROM gdscript-live/godot:base
RUN curl https://github.com/godotengine/godot-builds/releases/download/3.2.4-rc5/Godot_v3.2.4-rc5_linux_headless.64.zip -Lo /app/godot.zip
RUN unzip /app/godot.zip
RUN rm /app/godot.zip
RUN mv /app/Godot* /app/godot

