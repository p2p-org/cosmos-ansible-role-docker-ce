#!/usr/bin/env bash
VAGRANT_TESTCASE_FILE=vagrant_testcase.yml

SetupYamlParser() {
  YAML_INC_FILE=yamlparser.sh.inc
  if [[ ! -f "$YAML_INC_FILE" ]]; then
    wget -O $YAML_INC_FILE -q https://raw.githubusercontent.com/jasperes/bash-yaml/master/yaml.sh
  fi
  . $YAML_INC_FILE
}

GenerateTestCaseConfig() {
  local _box_index=$1
  local _test_index=$2
  local _box_url=
  if [[ "${boxes__box_url[$_box_index]}" != "vagrantup" ]]; then
    _box_url=${boxes__box_url[$_box_index]}
  fi
  echo "--> Generating config: box=[${boxes__box[$_box_index]}], box_url=[${_box_url}], test_yml=[${tests__test_yml[$_test_index]}]"
  cat << EOF > $VAGRANT_TESTCASE_FILE
box: ${boxes__box[$_box_index]}
box_url: ${_box_url}
storage_ctl: ${boxes__storage_ctl[$_box_index]}
storage_port: ${boxes__storage_port[$_box_index]}
vbguest_update: ${boxes__vbguest_update[$_box_index]}
id: ${tests__id[$_test_index]}
prep_yml: ${tests__prep_yml[$_test_index]}
test_yml: ${tests__test_yml[$_test_index]}
EOF
}

GenerateDoNothingConfig() {
  local _box_index=$1
  local _box_url=
  if [[ "${boxes__box_url[$_box_index]}" != "vagrantup" ]]; then
    _box_url=${boxes__box_url[$_box_index]}
  fi
  echo "--> Generating 'Do Nothing' config: box=[${boxes__box[$_box_index]}], box_url=[${_box_url}]"
  cat << EOF > $VAGRANT_TESTCASE_FILE
box: ${boxes__box[$_box_index]}
box_url: ${_box_url}
storage_ctl: ${boxes__storage_ctl[$_box_index]}
storage_port: ${boxes__storage_port[$_box_index]}
vbguest_update: ${boxes__vbguest_update[$_box_index]}
id: do_nothing
prep_yml: prepare.yml
test_yml: test_nothing.yml
EOF
}

if [[ "$1" == "--help" ]]; then
  echo "Usage: $0 [option] <box-index> (<test-index>)"
  echo ""
  echo "Options:"
  echo "--nop   Generate 'Do Nothing' config for specified box."
  echo ""
  exit 0
fi

SetupYamlParser
create_variables vagrant_config.yml

arg_1=${1:-0}
arg_2=${2:-0}

if [[ "$arg_1" == "--nop" ]]; then
  GenerateDoNothingConfig $arg_2
else
  GenerateTestCaseConfig $arg_1 $arg_2
fi
echo "--> Done!"