#!/usr/bin/env bash

TARGET=${1:-obj}

rm -fr ${TARGET}
cp -fr src ${TARGET}

MANIFEST=(`find ${TARGET} -name '*.lua' -type f`)

if [ ${#MANIFEST[@]} -eq 0 ]
then
    echo -e "\e[1m\e[39m[\e[31mTEST FAILED\e[39m]\e[21m No scripts could be found!."
    exit 1
fi

SCRIPTS=${TARGET}/SCRIPTS/RF2/COMPILE/scripts.lua

rm -f ${SCRIPTS}

echo 'local scripts = {' >> ${SCRIPTS}
for FILE in ${MANIFEST[@]}
do
    echo "    \"/${FILE#*/}\"," >> ${SCRIPTS}
done
echo '}' >> ${SCRIPTS}
echo 'return scripts[...]' >> ${SCRIPTS}

MANIFEST+=(${SCRIPTS})

EXIT=0

for FILE in ${MANIFEST[@]}
do
    echo -e "Testing file \e[1m${FILE}\e[21m..."
    luac -p ${FILE} ; E=$?
    if [[ $E -ne 0 ]]
    then
        EXIT=$E
        echo -e "\e[1m\e[39m[\e[31mBUILD FAILED\e[39m]\e[21m Error in file ${FILE}\e[1m"
    fi
done

if [[ ${EXIT} -eq 0 ]]; then
    echo -e "\e[1m\e[39m[\e[32mTEST SUCCESSFUL\e[39m]\e[21m"
fi

exit ${EXIT}
