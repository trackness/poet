#! /bin/bash

usage() {
  echo "No."
}

handle_cli_args() {
	if [[ $# -eq 1 ]]; then
    ProjectName=$1
	else
		usage
		exit 1
	fi
}

set_correct_working_dir() {
	SOURCE="${BASH_SOURCE[0]}"
	while [[ -h "$SOURCE" ]]; do
		DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
		SOURCE="$(readlink "$SOURCE")"
		[[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE"
	done
	ScriptRoot="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
}

clear

handle_cli_args "$@"
set_correct_working_dir
StartDir=$(PWD)

Prefix="Poet | ${ProjectName} |"

echo "${Prefix} Creating new project at ${StartDir}/${ProjectName}"
poetry new $ProjectName >/dev/null 2>&1
cd $ProjectName

echo "${Prefix} Adding project dependencies"
json=$(cat ${ScriptRoot}/common/dependencies.json | jq)
quiet=$(cat ${ScriptRoot}/common/dependencies.json | jq '.quiet')
echo $quiet
for row in $(echo "${sample}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   echo $(_jq '.name')
done


echo "${Prefix} Setting license, readme, gitignore, pre-commit config"
cp -r $ScriptRoot/common/. . >/dev/null 2>&1

echo "${Prefix} Initialising git repo"
poetry run git init >/dev/null 2>&1
rm "README.rst"

echo "${Prefix} Making initial commit"
poetry run git add . >/dev/null 2>&1
poetry run git commit -m "initial commit" >/dev/null 2>&1

echo "${Prefix} Installing pre-commit hooks"
poetry run pre-commit install >/dev/null 2>&1
echo "${Prefix} Running pre-commit hooks"
poetry run pre-commit run --all-files >/dev/null 2>&1

PoetryEnv=$(poetry env info --path)
echo "${Prefix} Virtualenv location: ${PoetryEnv}"

cd $StartDir
echo "${Prefix} Composition complete."

rm -rf $ProjectName
