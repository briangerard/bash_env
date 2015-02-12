MYPROFILE="${HOME}/.profile"
MYBASHRC="${HOME}/.bashrc"

if [[ -e $MYPROFILE && -r $MYPROFILE ]]
then
    source $MYPROFILE
fi

if [[ -e $MYBASHRC && -r $MYBASHRC ]]
then
    source $MYBASHRC
fi
