#!/bin/bash
# automatic compile documentation and show main page for every save of $files
files=(Doxyfile README.md)
while inotifywait -e ATTRIB ${files[*]} ; do
  doxygen
  google-chrome html/index.html
done
