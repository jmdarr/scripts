#!/bin/bash

# some simple variables, for simpler times. values are defaults
DIR=""
IMGREGEX='(jpg|jpeg|png|gif|bmp)'
TITLE="generated $(date)"
COLCOUNT=4
WIDTH=160

# we're not doing get help!
function gethelp() {
  read -r -d '' MSG << EOF
Usage: generate_html_gallery.sh [OPTION] [ARGUMENT]...

  -h                -- this set of helpful instructions
  -c <column count> -- how many images (columns) you'd like per row.
                       default: '${COLCOUNTDEFAULT}'
                       not required
  -d <directory>    -- the path which contains the images we want to create a gallery for
                       no default
                       REQUIRED
  -i <title text>   -- the title of the html page generated.
                       default: '${TITLEDEFAULT}'
                       not required
  -r <regex>        -- perl regex for matching images to make thumbnails.
                       default: '${IMGREGEXDEFAULT}'
  -w <pixel width>  -- how wide you'd like the thumbnail to be in pixels. aspect ratio will be maintained.
                       default: '${WIDTHDEFAULT}'
                       not required
EOF
  echo "${MSG}"
}

# die
function die() {
  if [ "${1+x}" ]; then
    echo
    echo -e "${1}"
  fi
  echo
  exit 0
}

# omg you did a bad
function error() {
  if [ "${1+x}" ]; then
    echo
    echo -e "${1}"
  fi
  echo
  exit 1
}

# function for generating images
function generate_thumbnails() {
  mkdir t 2>/dev/null
  for i in $(ls | grep -Pi "${IMGREGEX}"); do
    echo -n "generating thumbnail '$(pwd)/t/${i}' from '$(pwd)/${i}'... "
    if convert -thumbnail ${WIDTH} "${i}" "t/${i}"; then echo "done"; else echo "failed"; fi
  done
}

# function for generating... you get the idea
function generate_html() {
  {
    echo "<html>"
    echo "<head><title>${TITLE}</title></head>"
    echo "<body>"
    echo "<table border=0><tr>"
    c=0
    t=1
    for i in $(ls | grep -Pi "${IMGREGEX}"); do
      if [ ${c} -eq ${COLCOUNT} ]; then
        echo "</tr><tr>"
        c=0
      fi
      echo "<td><a href='${i}'><img src='t/${i}' alt='image ${t}' /></a></td>"
      c=$(( c + 1 ))
      t=$(( t + 1 ))
    done
    echo "</tr></table>"
    echo "</html>"
  } > index.html
}

# choose and pay
while getopts ":c:d:i:r:w:" ARG; do
  case "${ARG}" in
    c)
      COLCOUNT="${OPTARG}";;
    d)
      DIR="${OPTARG}";;
    i)
      TITLE="${OPTARG}";;
    r) 
      IMGREGEX="${OPTARG}";;
    w)
      WIDTH="${OPTARG}";;
    *)
  die "$(gethelp)"
  esac
done

# provide arguments or perish
if [ -z "${DIR+x}" ]; then  
  gethelp
  error "Please provide a directory path to generate a set of thumbnails and gallery page.\ne.g. generate_gallery.sh /path/to/image/directory"
fi

# does the directory exist?
[ -d "${DIR}" ] || { gethelp; error "Directory '${DIR}' does not exist."; }
pushd "${DIR}" >/dev/null 2>&1 || { gethelp; error "Directory '${DIR}' still does not exist."; }

# do the thing khaleesi
echo "starting"

# generate thumbs dir and generate image thumbs in it
echo "generating thumbnails..."
generate_thumbnails
echo "done generating thumbnails"

# generate html
echo "generating html..."
generate_html
echo "done generating html"

# all done
echo "all done"
popd >/dev/null 2>&1 || error
exit 0