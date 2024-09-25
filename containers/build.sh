FOLDER="$(cd -- "$(dirname "0")" > /dev/null 2>&1; pwd -P)"
docker build -t gdscript-live/godot:base $FOLDER/base/

for version in $(ls -d $FOLDER/*/ | grep -ve "base/$"); do
	echo Building version $version
	docker build -t gdscript-live/godot:$(basename $version) $version
done

