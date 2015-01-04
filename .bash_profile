if [[ -e .profile && -r .profile ]]
then
    source .profile
fi

if [[ -e .bashrc && -r .bashrc ]]
then
    source .bashrc
fi
