#!/bin/bash
# -------------------------------------------------------------------------------
# Copyright 2019, AppDynamics LLC and its affiliates
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -------------------------------------------------------------------------------
# Script-name:    configExport4330.sh
# Script-purpose: API Config Exporter script to create Account Role AppDynamics
# JSON data
# Author:         Marc Buraczynski
# Email:          maburacz@cisco.com
# Date:           29 Jan 2019
# Parts copyright (c) 2019 Marc Buraczynski (maburacz@cisco.com)
# -------------------------------------------------------------------------------
# Variables used
RED='\033[0;41;30m'
STD='\033[0;0;39m'
BASEDIR=$PWD
DATADIR=$PWD/data

# -------------------------------------------------------------------------------
# User defined functions
# -------------------------------------------------------------------------------

# ------------------------------------------------------------------------------- 
# Checks for the presence and running of the Config Exporter app
# -------------------------------------------------------------------------------
envCheck(){
	SERVICE='config-exporter-external-4.3.30-BETA.war'
    if ps ax | grep -v grep | grep $SERVICE > /dev/null
        then
            echo "Config Exporter is Running"
    else
        echo "Config Exporter is NOT Running."
        echo -e "Download the Config Exporter to your laptop or workstation.\n"
        echo -e "Download: https://tools.appdynamics.com/#/tools"
        echo -e "Documentation: https://singularity.jira.com/wiki/display/CS/Config+Exporter"
        echo
        echo -e "Exiting...."
        echo -e "Find the location of config-exporter-external-4.3.30-BETA.war"
        echo -e "Start the application before proceeding"
        exit 1
    fi
    # Sets the data directory for the JSON, GET and POST data download 
    BASEDIR="$PWD"
    DATADIR="$PWD/data"
    echo "Data directory set to: $DATADIR"
    echo
    mkdir $DATADIR
    mkdir $DATADIR/json
    mkdir $DATADIR/get
    mkdir $DATADIR/post
    echo
    # Use JSON Query to parse the JSON files
    echo
    echo "JSON Query (jq) is required on the local system to parse the JSON output"
    echo "Download jq: https://stedolan.github.io/jq/download/"
    echo
pause
}

# ------------------------------------------------------------------------------- 
# Gets the Controller ID
# -------------------------------------------------------------------------------
getController() {
    clear
    echo "Getting Controller ID...."
    curl -H "Content-Type: application/vnd.appd.cntrl+json;v=1" -s http://localhost:8080/api/controllers > $DATADIR/json/controllers-out.json
    jq < $DATADIR/json/controllers-out.json > $DATADIR/get/controllers-out-jq.get
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    echo "Data output:"
    echo "$DATADIR/json"
    echo "$DATADIR/get"
    echo
    echo "The below files have been created...."
    echo
    cd $DATADIR
    ls ./json/controller* | awk {'print $1'}
    ls ./get/controller* | awk {'print $1'}
    echo
pause
}

# ------------------------------------------------------------------------------- 
# Gets the Account Roles
# -------------------------------------------------------------------------------
getAccountRoles() {
    clear
    echo "Displaying Controller IDs"
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    temp_id="$(jq -r < $DATADIR/json/controllers-out.json | grep "\<id\>" | awk {'print $2'})"
    controller_id="$(echo "${temp_id//,}")"
    echo "Controller ID $controller_id" 
    curl -H "Content-Type: application/vnd.appd.cntrl+json;v=1" -s http://localhost:8080/api/controllers/$controller_id/account-roles > $DATADIR/json/account-roles-out.json
    jq < $DATADIR/json/account-roles-out.json > $DATADIR/get/account-roles-out-jq.get
    echo "Data output: $DATADIR."
    echo "The below files have been created...."
    echo "Data ouput: $DATADIR"
    cd $DATADIR
    ls ./json/account* | awk {'print $1'}
    ls ./get/account* | awk {'print $1'}
    echo
pause
}

# ------------------------------------------------------------------------------- 
# Gets the Application Configurations
# -------------------------------------------------------------------------------
getAppConfigs() {
    clear
    echo "Display Controller IDs"
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    curl -H "Content-Type: application/vnd.appd.cntrl+json;v=1" -s curl http://localhost:8080/api/rest/app-config > $DATADIR/json/app-config-out.json
    jq < $DATADIR/json/app-config-out.json > $DATADIR/get/app-config-out-jq.get
    echo "Data output: $DATADIR."
    echo "The below files have been created...."
    echo "Data ouput: $DATADIR"
    cd $DATADIR
    ls ./json/app-config* | awk {'print $1'}
    ls ./get/app-config* | awk {'print $1'}
    echo
pause
}

# ------------------------------------------------------------------------------- 
# Gets the Application(s)
# -------------------------------------------------------------------------------
getApplications() {
    clear
    echo "Display Controller IDs"
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    temp_id="$(jq -r < $DATADIR/json/controllers-out.json | grep "\<id\>" | awk {'print $2'})"
    controller_id="$(echo "${temp_id//,}")"
    curl -H "Content-Type: application/vnd.appd.cntrl+json;v=1" -s http://localhost:8080/api/controllers/$controller_id/applications > $DATADIR/json/applications-out.json
    jq < $DATADIR/json/applications-out.json > $DATADIR/get/applications-out-jq.get
    echo "Data output: $DATADIR."
    echo "The below files have been created...."
    echo "Data ouput: $DATADIR"
    cd $DATADIR
    ls ./json/applications* | awk {'print $1'}
    ls ./get/applications* | awk {'print $1'}
    echo
pause
}

# ------------------------------------------------------------------------------- 
# Create Account Role(s)
# -------------------------------------------------------------------------------
createAccountRole() {
    clear
    echo "Display Controller IDs"
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    echo "Select a Controller ID and enter it on the below line"
    temp_id="$(jq -r < $DATADIR/json/controllers-out.json | grep "\<id\>" | awk {'print $2'})"
    controller_id="$(echo "${temp_id//,}")"
    echo "The format for this next step will create a JSON file and POST to the Controller"
    echo "The file format will output as follows:"
    cat $BASEDIR/example-post.json
    echo
    echo    "*** Note: There are no spaces in Description"
    echo    "For each New role, repeat the process"
    echo    
        if [[ ! $REPLY =~ ^[Yy]$ ]]
            echo "Enter the Role name (no spaces or special characters)"
            echo "Example: TestRole01 or TestRole"
            read -p "Type a unique [Name]: " r1
            echo "Enter the Role Description (no spaces or special characters"
            echo "Example: Test_Role"
            read -p "Type a [Description]: " r2
            jq --arg key0 'name' --arg value0 $r1 \
               --arg key1 'Description' --arg value1 $r2 \
               --arg key2 'providerUniqueName' --arg value2 $r1 \
               --arg key3 'accountRoleIds' --arg value3 [8] \
               --arg key4 'securityProviderType' --arg value4 "INTERNAL" \
               '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2 | .[$key3]=$value3 | .[$key4]=$value4' <<<'{}' > $DATADIR/post/create-roles-post.json
            cd $DATADIR/post
            curl -H "Content-Type: application/json" -X POST -d @create-roles-post.json -s http://localhost:8080/api/controllers/$controller_id/account-roles > $DATADIR/post/create-roles.out
            echo
            echo "Role $r2 has been added "
            echo
            cat $DATADIR/post/create-roles.out
            pause
            echo
            read -p "  Do you wish to enter another role?  " yn            
            case $yn in
                Yes ) createAccountRole
                break ;;
                No )  show_menus ;;
                *) echo -e "${RED}Error...${STD}" && sleep 1
            esac
        then
            show_menus
        fi
}

# ------------------------------------------------------------------------------- 
# Update Account Role(s)
# -------------------------------------------------------------------------------
updateAccountRole() {
    clear
    echo "Display Controller IDs"
    echo '{"id":}' | jq . < $DATADIR/json/controllers-out.json
    echo "Select a Controller ID and enter it on the below line"
    temp_id="$(jq -r < $DATADIR/json/controllers-out.json | grep "\<id\>" | awk {'print $2'})"
    controller_id="$(echo "${temp_id//,}")"
    ls -la $DATADIR/post/update-roles-post.json | awk {'print $9'}
    # curl -H "Content-Type: application/json" -X POST http://localhost:8080/api/controllers/$controller_id/account-roles
    echo "This feature is pending UPDATE"
    pause
    show_menus
}

# -------------------------------------------------------------------------------
# Display menu
# Read input from the keyboard and take a action
# Exit when user the user select 3 form the menu option.
# ------------------------------------------------------------------------------- 
show_menus() {
	clear
    echo
    printf  "                   %-40s \n" "`date`"
    echo
    echo "Copyright 2019, Cisco Systems, Inc/AppDynamics LLC and its affiliates"
    echo "Licensed under the Apache License, Version 2.0 (the "License")"
    echo "you may not use this file except in compliance with the License."
    echo "You may obtain a copy of the License at:"
    echo "http://www.apache.org/licenses/LICENSE-2.0"
    echo
    echo "Unless required by applicable law or agreed to in writing, software"
    echo "distributed under the License is distributed on an "AS IS" BASIS,"
    echo "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
    echo "See the License for the specific language governing permissions and"
    echo "limitations under the License."
    echo
    echo "Company Information:"
    echo "http://www.cisco.com"
    echo "http://www.appdynamics.com"
    echo
    echo
    echo "PROTOTYPE v.1"
    echo
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
	echo "                      M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
	echo "                  1.    Check Environment"
	echo "                  2.    GET Controller ID"
    echo "                  3.    GET Account Roles"
    echo "                  4.    GET Application Configurations"
    echo "                  5.    GET Application Names"
    echo "                  6.    ADD Account Role(s)"
    echo "                  7.    UPDATE Account Roles(s)"
	echo "                  8.    Exit"
}

read_options(){
	local choice
	read -p "           Enter choice [ 1 - 8 ] " choice
	case $choice in
		1) envCheck ;;
		2) getController ;;
        3) getAccountRoles ;;
        4) getAppConfigs ;;
        5) getApplications ;;
        6) createAccountRole ;;
        7) updateAccountRole ;;
		8) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
pause(){
  echo
  read -p "   Press [Enter] key to continue...   " fackEnterKey
}

# -------------------------------------------------------------------------------
# Trap CTRL+C, CTRL+Z and quit signal
# -------------------------------------------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP

# -------------------------------------------------------------------------------
# Main logic - infinite loop until Exit 0 is called
# -------------------------------------------------------------------------------
while true
do
 	show_menus
	read_options
done