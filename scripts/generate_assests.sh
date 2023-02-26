# !bash 
TARGET_DIR="docs/slides/"
NOTEBOOKS_DIR="notebooks/.ipynb/"


mkdir -p "$TARGET_DIR.html"

echo "Generating slides from .ipynb files...";
for FILE in ${NOTEBOOKS_DIR}.ipynb/*.ipynb; do
    echo "\t[$(date +%T)]\tConverting '${FILE}' to HTML";
    jupyter nbconvert --to slides html  $FILE;
done;
echo "Moving generated .html assests";
mv -v ${NOTEBOOKS_DIR}*.html $TARGET_DIR;
rm -r $TARGET_DIR/.html

echo "Finished generating";