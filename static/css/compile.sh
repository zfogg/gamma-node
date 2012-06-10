#!/bin/bash

while true; do
  inotifywait style.less
  lessc style.less > style.css -x
done
