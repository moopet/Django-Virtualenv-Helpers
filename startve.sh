#!/bin/bash

# Start up a Django coding session just the way I like it
# Assumes projects are in subfolders with the same name as the virtual environment
# if you're already in a VE you don't need to specify it on the command line

PROJECTS_PATH="/var/www/"

source virtualenvwrapper.sh
if [ $? -ne 0 ]; then
    echo "$0: virtualenvwrapper.sh not found. Perhaps you should 'pip install virtualenv virtualenvwrapper' ?"
    exit 1
fi

CURRENT_VE=${VIRTUAL_ENV##*/}
VE="${1:-$CURRENT_VE}"
RCFILE="/tmp/$(basename $0).$$"

workon $VE 2>/dev/null

if [ $? -ne 0 ]; then
    echo "Usage: $0 <virtual-env>"
    echo "Available virtual environments:"
    workon
    exit 1
fi

cat >| $RCFILE.default <<RCDATA.default
#!/bin/bash
source ~/.bashrc
source virtualenvwrapper.sh
cd $PROJECTS_PATH/$VE
workon $VE
RCDATA.default

cat >| $RCFILE.shell <<RCDATA.runserver
#!/bin/bash
source ~/.bashrc
source virtualenvwrapper.sh
cd $PROJECTS_PATH/$VE
workon $VE
python `find . -name manage.py` shell
RCDATA.shell

cat >| $RCFILE.runserver <<RCDATA.runserver
#!/bin/bash
source ~/.bashrc
source virtualenvwrapper.sh
cd $PROJECTS_PATH/$VE
workon $VE
python `find . -name manage.py` runserver 0.0.0.0:8000
RCDATA.runserver

cat >| $RCFILE.vcs <<RCDATA.vcs
#!/bin/bash
source ~/.bashrc
cd $PROJECTS_PATH/$VE
git status
RCDATA.vcs

cat >| $RCFILE.compass <<RCDATA.compass
#!/bin/bash
source ~/.bashrc
source virtualenvwrapper.sh
cd $PROJECTS_PATH/$VE/sass
compass watch
RCDATA.compass

if [ $? -ne 0 ]; then
    echo "Couldn't save temporary bash rcfiles"
    exit 1
fi

gnome-terminal --tab-with-profile="Default" --title="$VE"                -e "bash --rcfile $RCFILE.default"  \
               --tab-with-profile="Default" --title="Compass/SASS"       -e "bash --rcfile $RCFILE.compass" \
               --tab-with-profile="Default" --title="Development Server" -e "bash --rcfile $RCFILE.runserver" \
               --tab-with-profile="Default" --title="Django Shell"       -e "bash --rcfile $RCFILE.shell" \
               --tab-with-profile="Default" --title="Version Control"    -e "bash --rcfile $RCFILE.vcs"
