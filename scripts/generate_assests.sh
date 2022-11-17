# !bash 
TARGET_DIR="docs/"
NOTEBOOKS_DIR="notebooks/"


mkdir -p "$TARGET_DIR.html"

echo "Generating slides from .ipynb files...";
for FILE in ${NOTEBOOKS_DIR}*.ipynb; do
    echo "\t[$(date +%T)]\tConverting '${FILE}' to HTML";
    jupyter nbconvert --to slides html  $FILE;
done;
echo "Moving generated .html assests";
mv -v ${NOTEBOOKS_DIR}*.html $TARGET_DIR;
echo "Finished generating";