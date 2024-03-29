#!/bin/bash

timer()
{
    temp_cnt=$1
    while [[ ${temp_cnt} -gt 0 ]];
    do
	# printf "\r%2d second(s)" ${temp_cnt}
	sleep 1
	((temp_cnt--))
    done
    echo ""
}

#change controller file sima:only used in advanced mode
controller_file_change(){

  local region=$1
  local az=$2
  local vpc_cidr=$3
  local vpc_subnet=$4
  local controller_version=$5
  local controller_email=$6
  local controller_password=$7
  local controller_license_type=$8
  # controller_license_type has to be last as it may be empty in the case of metered

  sed -i "s/variable \"region\".*/variable \"region\" { default = \"$region\" }/g" /root/controller/variables.tf
  sed -i "s/variable \"az\".*/variable \"az\" { default = \"$az\" }/g" /root/controller/variables.tf
  sed -i "s#variable \"vpc_cidr\".*#variable \"vpc_cidr\" { default = \"$vpc_cidr\" }#g"  /root/controller/variables.tf
  sed -i "s#variable \"vpc_subnet\".*#variable \"vpc_subnet\" { default = \"$vpc_subnet\" }#g"  /root/controller/variables.tf
  sed -i "s#variable \"controller_license_type\".*#variable \"controller_license_type\" { default = \"$controller_license_type\" }#g"  /root/controller/variables.tf
  sed -i "s#variable \"account_email\".*#variable \"account_email\" { default = \"$controller_email\" }#g"  /root/controller/variables.tf    
  sed -i "s#variable \"controller_version\".*#variable \"controller_version\" { default = \"$controller_version\" }#g"  /root/controller/variables.tf    
  sed -i '/admin_password/d' /root/controller/variables.tf    
  python3 /root/controller/pwd_update.py $controller_password
  if [ $controller_version = "6.9" ]; then
  sed -i'' -e 's+version = "~> 3.0.0"+version = "~> 2.24.0"+g' /root/mcna/versions.tf
  sed -i'' -e 's+version = "~> 3.0.0"+version = "~> 2.24.0"+g' /root/mcna-govcloud/versions.tf
  else
  sed -i'' -e 's+version = "~> 2.24.0"+version = "~> 3.0.0"+g' /root/mcna/versions.tf
  sed -i'' -e 's+version = "~> 2.24.0"+version = "~> 3.0.0"+g' /root/mcna-govcloud/versions.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna/aviatrix_aws.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna/aviatrix_azure.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna-govcloud/aviatrix_aws.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna-govcloud/aviatrix_azure.tf
  fi
}
controller_file_change_std(){

  local controller_version=$1
  local controller_email=$2
  local controller_password=$3
  local controller_license_type=$4
  # controller_license_type has to be last as it may be empty in the case of metered

  sed -i "s/variable \"controller_license_type\".*/variable \"controller_license_type\" { default = \"$controller_license_type\" }/g"  /root/controller/variables.tf
  sed -i "s#variable \"account_email\".*#variable \"account_email\" { default = \"$controller_email\" }#g"  /root/controller/variables.tf    
  sed -i "s#variable \"controller_version\".*#variable \"controller_version\" { default = \"$controller_version\" }#g"  /root/controller/variables.tf    
  sed -i '/admin_password/d' /root/controller/variables.tf    
  python3 /root/controller/pwd_update.py $controller_password
  if [ $controller_version = "6.9" ]; then
  sed -i'' -e 's+version = "~> 3.0.0"+version = "~> 2.24.0"+g' /root/mcna/versions.tf
  sed -i'' -e 's+version = "~> 3.0.0"+version = "~> 2.24.0"+g' /root/mcna-govcloud/versions.tf
  else
  sed -i'' -e 's+version = "~> 2.24.0"+version = "~> 3.0.0"+g' /root/mcna/versions.tf
  sed -i'' -e 's+version = "~> 2.24.0"+version = "~> 3.0.0"+g' /root/mcna-govcloud/versions.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna/aviatrix_aws.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna/aviatrix_azure.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna-govcloud/aviatrix_aws.tf
  sed -i '/manage_transit_gateway_attachment/d' /root/mcna-govcloud/aviatrix_azure.tf
  fi
}


#generic function to change pattren with spoke vars
change_variable_with_spoke(){
  spke=$1
  var=$2
  val=$3
  clp=$4

  awk -v spke="$spke" -v var="$var" -v val="$val" -v clp="$clp" '/variable/ { cloudp=gensub(/(^variable[[:space:]]")(.*)(".*$)/,"\\2",$0) } /'$spke'[[:space:]]=/ { spoke=$1 } spoke==spke && $1==var && cloudp ~ clp { $0=gensub(/(^.*=[[:space:]]")(.*)(".*$)/,"\\1"val"\\3",$0) }1'   /root/mcna/variables.tf > /root/mcna/file.temp && mv -f /root/mcna/file.temp /root/mcna/variables.tf


}

#generic function to change pattren without spoke vars
change_variable_without_spoke(){

  var=$1
  val=$2
  clp=$3

  awk  -v var="$var" -v val="$val" -v clp="$clp" '/variable/ { cloudp=gensub(/(^variable[[:space:]]")(.*)(".*$)/,"\\2",$0) }  $1==var && cloudp ~ clp { $0=gensub(/(^.*=[[:space:]]")(.*)(".*$)/,"\\1"val"\\3",$0) }1'  /root/mcna/variables.tf > /root/mcna/file.temp && mv -f /root/mcna/file.temp /root/mcna/variables.tf
}

#generic function to change pattren with spoke digits
change_variable_with_spoke_digit(){

  spke=$1
  var=$2
  val=$3
  clp=$4

  awk -v spke="$spke" -v var="$var" -v val="$val" -v clp="$clp" '/variable/ { cloudp=gensub(/(^variable[[:space:]]")(.*)(".*$)/,"\\2",$0) } /spoke[[:digit:]][[:space:]]=/ { spoke=$1 } spoke==spke && $1==var && cloudp ~ clp { $0=gensub(/(^.*=[[:space:]]")(.*)(".*$)/,"\\1"val"\\3",$0) }1'   /root/mcna/variables.tf > /root/mcna/file.temp && mv -f /root/mcna/file.temp /root/mcna/variables.tf

}

#change controller file
mcna_aws_file_change_vpcs(){

  local aws_transit_vpc_name=$1
  local aws_transit_vpc_cidr=$2
  local aws_spoke1_vpc_name=$3
  local aws_spoke1_vpc_cidr=$4
  local aws_spoke2_vpc_name=$5
  local aws_spoke2_vpc_cidr=$6


  spke="aws_transit_vpc"
  var="name"
  val=$aws_transit_vpc_name
  clp="aws_transit_vpcs"

  change_variable_with_spoke  $spke $var $val $clp

  spke="aws_transit_vpc"
  var="cidr"
  val=$aws_transit_vpc_cidr
  clp="aws_transit_vpcs"

  change_variable_with_spoke  $spke $var $val $clp

  spke="aws_spoke1_vpc"
  var="name"
  val=$aws_spoke1_vpc_name
  clp="aws_spoke_vpcs"

  change_variable_with_spoke  $spke $var $val $clp

  spke="aws_spoke1_vpc"
  var="cidr"
  val=$aws_spoke1_vpc_cidr
  clp="aws_spoke_vpcs"

  change_variable_with_spoke  $spke $var $val $clp

  spke="aws_spoke2_vpc"
  var="name"
  val=$aws_spoke2_vpc_name
  clp="aws_spoke_vpcs"

  change_variable_with_spoke  $spke $var $val $clp

  spke="aws_spoke2_vpc"
  var="cidr"
  val=$aws_spoke2_vpc_cidr
  clp="aws_spoke_vpcs"

  change_variable_with_spoke  $spke $var $val $clp
}

#gateways change aws
mcna_aws_file_change_gateways(){

  local aws_transit_gateway_name=$1
  local aws_spoke1_gateways_name=$2
  local aws_spoke1_vpc_name=$3
  local aws_region=$4

  sed -i "s#variable \"aws_region\".*#variable \"aws_region\" { default = \"$aws_region\" }#g"  /root/mcna/variables.tf

  var="name"
  val=$aws_transit_gateway_name
  clp="aws_transit_gateway"

  change_variable_without_spoke  $var $val $clp

  spke="spoke1"
  var="name"
  val=$aws_spoke1_gateways_name
  clp="aws_spoke_gateways"

  change_variable_with_spoke  $spke $var $val $clp

  spke="spoke2"
  var="name"
  val=$aws_spoke1_vpc_name
  clp="aws_spoke_gateways"

  change_variable_with_spoke  $spke $var $val $clp
}


#change mcna azure vpcs
mcna_azure_file_change_vpcs(){

  local azure_vnets_name=$1
  local azure_vnets_name_cidr=$2
  local azure_spoke1_vnet_name=$3
  local azure_spoke1_vnet_cidr=$4
  local azure_spoke2_vnet_name=$5
  local azure_spoke2_vnet_cidr=$6

  #first
  spke="azure_transit_vnet"
  var="name"
  val=$azure_vnets_name
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp

  #Second
  spke="azure_transit_vnet"
  var="cidr"
  val=$azure_vnets_name_cidr
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp

  #third
  spke="azure_spoke1_vnet"
  var="name"
  val=$azure_spoke1_vnet_name
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp

  #forth
  spke="azure_spoke1_vnet"
  var="cidr"
  val=$azure_spoke1_vnet_cidr
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp

  #fifth
  spke="azure_spoke2_vnet"
  var="name"
  val=$azure_spoke2_vnet_name
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp

  #sixth
  spke="azure_spoke2_vnet"
  var="cidr"
  val=$azure_spoke2_vnet_cidr
  clp="azure_vnets"

  change_variable_with_spoke  $spke $var $val $clp
}

#gateways change azure
mcna_azure_file_change_gateways(){

  local azure_transit_gateway=$1
  local azure_spoke1_gateways_name=$2
  local azure_spoke2_gateways_name=$3
  local azure_region=$4

  sed -i "s#variable \"azure_region\".*#variable \"azure_region\" { default = \"$azure_region\" }#g"  /root/mcna/variables.tf

  var="name"
  val=$azure_transit_gateway
  clp="azure_transit_gateway"

  change_variable_without_spoke  $var $val $clp

  spke="spoke1"
  var="name"
  val=$azure_spoke1_gateways_name
  clp="azure_spoke_gateways"

  change_variable_with_spoke_digit  $spke $var $val $clp

  spke="spoke2"
  var="name"
  val=$azure_spoke2_gateways_name
  clp="azure_spoke_gateways"

  change_variable_with_spoke_digit  $spke $var $val $clp

}

#write IP's to sh file for use during launch transit etc
writekeys_controller_launch() {

  cd /root/
  local AWS_ACCOUNT=$1
  local CONTROLLER_PRIVATE_IP=$2
  local CONTROLLER_PUBLIC_IP=$3
  local AVIATRIX_CONTROLLER_IP=$4

#   echo "$AVIATRIX_CONTROLLER_IP"

  # Save variables to file
  typeset -p AWS_ACCOUNT CONTROLLER_PRIVATE_IP CONTROLLER_PUBLIC_IP AVIATRIX_CONTROLLER_IP >keys.sh

}

#write user credientials to sh file for use during launch transit etc
writekeys_controller_init() {

  cd /root/
  . keys.sh;

  local AVIATRIX_EMAIL=$1
  local AVIATRIX_PASSWORD=$2
  local AVIATRIX_USERNAME=$3
  local SANDBOX_STARTER_CONTROLLER_INIT_DONE=$4

  # Save variables to file
  typeset -p  AWS_ACCOUNT CONTROLLER_PRIVATE_IP CONTROLLER_PUBLIC_IP AVIATRIX_CONTROLLER_IP  AVIATRIX_EMAIL AVIATRIX_PASSWORD AVIATRIX_USERNAME SANDBOX_STARTER_CONTROLLER_INIT_DONE >keys.sh
}

#test for key.sh data
check_data_test() {
    cd /root/
    . keys.sh # Load variables from file

    echo "$AWS_ACCOUNT"
    printf 'AWS_ACCOUNT=%s\n' "$AWS_ACCOUNT"
    printf 'CONTROLLER_PRIVATE_IP=%s\n' "$CONTROLLER_PRIVATE_IP"
    printf 'CONTROLLER_PUBLIC_IP=%s\n' "$CONTROLLER_PUBLIC_IP"
    printf 'AVIATRIX_CONTROLLER_IP=%s\n' "$AVIATRIX_CONTROLLER_IP"

    printf 'AVIATRIX_EMAIL=%s\n'  "$AVIATRIX_EMAIL"
    printf 'AVIATRIX_PASSWORD=%s\n'  "$AVIATRIX_PASSWORD"
    printf 'AVIATRIX_USERNAME=%s\n'  "$AVIATRIX_USERNAME"
    printf 'SANDBOX_STARTER_CONTROLLER_INIT_DONE=%s\n'  "$SANDBOX_STARTER_CONTROLLER_INIT_DONE"

}

#aws set configuration api
aws_configure()
{
    #calling banner from first API
#    banner_initilize

    # if [ -d "/root/.aws" ]
    # then
	# echo "--> .aws exists, skipping aws configure."
	# return 0
    # fi
    echo "--> Going to get your AWS API access keys. They are required to launch the Aviatrix controller in AWS. They stay local to this container and are not shared. Access keys can be created in AWS console under Account -> My Security Credentials -> Access keys for CLI, SDK, & API access."
    # read -p '--> Enter AWS access key ID: ' key_id
    # read -p '--> Enter AWS secret access key: ' secret_key
    aws configure set aws_access_key_id $1
    aws configure set aws_secret_access_key $2
    echo "Aws credentials set"
}

#part of launch controller
record_controller_launch()
{
    echo
    email_support=$1
    echo $email_support
#    read -p '--> Enter email for Aviatrix support to reach out in case of issues (the email will be shared with Aviatrix): ' email_support
    d=$(date)
    payload="{\"controllerIP\":\"$CONTROLLER_PUBLIC_IP\", \"email\":\"$email_support\", \"timestamp\":\"$d\"}"
    curl -d "$payload" -H 'Content-Type: application/json' https://tqcp56gr3a.execute-api.us-west-2.amazonaws.com/v1/controller
}

#part of launch controller
generate_controller_ssh_key()
{
    if [ -z $KS_GOVCLOUD ]; then
	cd /root/controller
    else
	echo "--> AWS GovCloud SSH key generation"
	cd /root/controller-govcloud
    fi
    if [ -f "ctrl_key" ]; then
	echo "--> Controller SSH key already exists, skipping."
	return 0
    fi

    echo "--> Generating SSH key for the controller..."
    ssh-keygen -t rsa -f ctrl_key -C "controller_public_key" -q -N ""
    if [ $? -eq 0 ]; then
	echo "--> Done."
	return 0
    else
	echo "--> SSH key generation failed, aborting." >&2
	return 1
    fi
}

#Subscriber service check
subscribe_service()
{
    if [ "$1" = "yes" ]; then
        if [ -z $KS_GOVCLOUD ]; then
           echo 'https://aws.amazon.com/marketplace/pp/B08NTSDHKG'
        else
           echo 'https://aws.amazon.com/marketplace/pp/B08NTSDHKG'
        fi
    else
       echo "No action performed"
    fi
}

#Launch controller main part
controller_launch()
{
    email_support=$1

    if [ -z $KS_GOVCLOUD ]; then
	cd /root/controller
    else
	echo "--> AWS GovCloud controller launch"
	cd /root/controller-govcloud
    fi

    generate_controller_ssh_key
    if [ $? -eq 0 ]; then
	echo "--> OK."
    else
	echo "--> Aborting." >&2
	return 1
    fi

#    if [ -z $KS_GOVCLOUD ]; then
#	read -n 1 -r -s -p $'\n--> Go to https://aws.amazon.com/marketplace/pp/B08NTSDHKG and subscribe to the Aviatrix platform. Click on "Continue to subscribe", and accept the terms. Do NOT click on "Continue to Configuration". Press any key once you have subscribed.\n'
#    else
#	read -n 1 -r -s -p $'\n--> Go to https://aws.amazon.com/marketplace/pp/B08NTSDHKG and subscribe to the Aviatrix platform. ACCESS THE MARKETPLACE FROM THE AWS ROOT ACCOUNT THAT IS IN CHARGE OF YOUR AWS GOVCLOUD ACCOUNT. Click on "Continue to subscribe", and accept the terms. Do NOT click on "Continue to Configuration". Press any key once you have subscribed.\n'
#    fi

    # Advanced mode. In GovCloud, always open it.
    if [ ! -z $KS_ADVANCED ] || [ ! -z $KS_GOVCLOUD ]; then
#	read -n 1 -r -s -p $'\n--> Opening controller settings file. Press any key to continue.\n'
	vim variables.tf
    fi

    echo -e "\n--> Now going to launch the controller. The public IP of the controller will be shared with Aviatrix for tracking purposes."
    # If not advanced and not GovCloud, then default mode.
    if [ -z $KS_ADVANCED ] && [ -z $KS_GOVCLOUD ]; then
	echo "--> The controller will be launched in us-east-1."
    fi

    read -n 1 -r -s -p $'--> To abort, close the window or press Ctrl-C. To continue, press any key.\n'

    # Check if the Avx ec2 role exists
    check_ec2_role

    # Launch Controller
    terraform init -upgrade
    terraform apply -auto-approve

    if [ $? -eq 0 ]; then
	echo "--> Controller successfully launched."
    else
	echo "--> Controller launch failed, aborting." >&2
	return 1
    fi

    # Store the outputs in environment variables for the controller init to use.
    export AWS_ACCOUNT=$(terraform output -raw aws_account)
    export CONTROLLER_PRIVATE_IP=$(terraform output -raw controller_private_ip)
    export CONTROLLER_PUBLIC_IP=$(terraform output -raw controller_public_ip)
    export AVIATRIX_CONTROLLER_IP=$CONTROLLER_PUBLIC_IP

    # Keep them in .bashrc in case the container gets restarted.
    f=/root/.sandbox_starter_restore

    if [ -z $KS_GOVCLOUD ]; then
	echo 'cd /root/controller' > $f
    else
	echo 'cd /root/controller-govcloud' > $f
    fi
    echo 'export AWS_ACCOUNT=$(terraform output -raw aws_account)' >> $f
    echo 'export CONTROLLER_PRIVATE_IP=$(terraform output -raw controller_private_ip)' >> $f
    echo 'export CONTROLLER_PUBLIC_IP=$(terraform output -raw controller_public_ip)' >> $f
    echo 'export AVIATRIX_CONTROLLER_IP=$CONTROLLER_PUBLIC_IP' >> $f
    
    echo AWS_ACCOUNT: $AWS_ACCOUNT
    echo CONTROLLER_PRIVATE_IP: $CONTROLLER_PRIVATE_IP
    echo CONTROLLER_PUBLIC_IP: $CONTROLLER_PUBLIC_IP

    writekeys_controller_launch $AWS_ACCOUNT $CONTROLLER_PRIVATE_IP $CONTROLLER_PUBLIC_IP  $AVIATRIX_CONTROLLER_IP

    record_controller_launch $email_support

    echo -e "\n--> Waiting 5 minutes for final controller configuration... Do not access the controller yet."
    timer 300
    return 0
}

#controller init during launch
controller_init()
{
    email=$1
    password=$2
    recovery_email=$3
    controller_version=$4
    controller_license=$5

    if [ -z $KS_GOVCLOUD ]; then
    echo 'Into govt'
	cd /root/controller
    else
	echo 'Into else'
	echo "--> AWS GovCloud controller init"
	cd /root/controller-govcloud
    fi
#    echo
#    read -p '--> Enter email for controller password recovery: ' email
    export AVIATRIX_EMAIL=$email
    f=/root/.sandbox_starter_restore
    echo "export AVIATRIX_EMAIL=$email" >> $f

#    while true; do
#	read -s -p "--> Enter new password: " password
#	echo
#	read -s -p "--> Confirm new password: " password2
#	echo
#	[ "$password" = "$confirm_password" ] && break
#	echo "--> Passwords don't match, please try again."
#    done
    export AVIATRIX_PASSWORD=$password
    str="export AVIATRIX_PASSWORD='$password'"
    echo $str >> $f

    export AVIATRIX_USERNAME=admin
    echo 'export AVIATRIX_USERNAME=admin' >> $f

    export CONTROLLER_LICENSE=$controller_license
    echo "export CONTROLLER_LICENSE='$controller_license'" >> $f 
    
    export CONTROLLER_VERSION=$controller_version
    echo "export CONTROLLER_VERSION='$controller_version'" >> $f 

    python3 controller_init.py
    if [ $? != 0 ]; then
	echo "--> Controller init failed"
	return 1
    fi

    export SANDBOX_STARTER_CONTROLLER_INIT_DONE=true
    echo 'export SANDBOX_STARTER_CONTROLLER_INIT_DONE=true' >> $f

    if [ ! -z $KS_GOVCLOUD ]; then
	cat /root/.eagle
    fi
    echo -e "\n--> Controller init has completed. Controller is now running. Please note that if you are going to manually upgrade the Controller, only Build release upgrades are supported. For example, manual upgrades from 7.0.x to 7.0.y are supported, but manual upgrades of Minor releases, such as from 6.9.x to 7.0.y are NOT supported."

    writekeys_controller_init  $AVIATRIX_EMAIL $AVIATRIX_PASSWORD $AVIATRIX_USERNAME $SANDBOX_STARTER_CONTROLLER_INIT_DONE
}

#mcna transit launch
mcna_aws_transit()
{
    cd /root/
    . keys.sh # Load variables from file


    if [ -z $KS_GOVCLOUD ]; then
	cd /root/mcna
    else
	cd /root/mcna-govcloud
	echo "--> AWS GovCloud transit init"
    fi

    # Advanced mode.
    if [ ! -z $KS_ADVANCED ] || [ ! -z $KS_GOVCLOUD ]; then
#	read -n 1 -r -s -p $'\n--> Opening settings file. Press any key to continue.\n'
	vim variables.tf
    fi

    terraform init -upgrade
    terraform apply -target=aviatrix_transit_gateway.aws_transit_gw -target=aviatrix_spoke_gateway.aws_spoke_gws -target aviatrix_spoke_transit_attachment.aws_spoke_gws_attachment -auto-approve
    return $?
}

#changing mcna variable file key here
input_aws_keypair()
{
    name=$1

    cd /root/
    . keys.sh # Load variables from file

    if [ -z $KS_GOVCLOUD ]; then
	cd /root/mcna
    else
	cd /root/mcna-govcloud
	echo "--> AWS GovCloud EC2 test instances launch"
    fi


    if [ -z $KS_GOVCLOUD ]; then
	read -n 1 -r -s -p $'\n\n--> Opening the settings file. Make sure your key pair name is correct under aws_ec2_key_name. This is your own key pair, not Aviatrix keys for controller or gateways. Also make sure you are in the region where the Spoke gateways were launched (if using defaults, us-east-2). Press any key to continue.\n'
    else
	read -n 1 -r -s -p $'\n\n--> Opening the settings file. Make sure your key pair name is correct under aws_ec2_key_name. This is your own key pair, not Aviatrix keys for controller or gateways. Press any key to continue.\n'
    fi

    sed -i "s/variable \"aws_ec2_key_name\".*/variable \"aws_ec2_key_name\" { default = \"$name\" }/g" /root/mcna/variables.tf
#    sed -i "s/\"aws_ec2_key_name\" { default = \"nicolas\" }/\"aws_ec2_key_name\" { default = \"$name\" }/g" /root/mcna/variables.tf
    echo "done"
#    vim variables.tf
}

#creating test instance of aws
mcna_aws_test_instances()
{
    cd /root/
    . keys.sh # Load variables from file

    name=$1
    if [ -z $KS_GOVCLOUD ]; then
	cd /root/mcna
    else
	cd /root/mcna-govcloud
	echo "--> AWS GovCloud EC2 test instances launch"
    fi

    input_aws_keypair $name
    echo "--> Launching instances now"
    terraform init -upgrade
    terraform apply -target=aws_instance.test_instances -auto-approve
}

#launch azure transit
mcna_azure_transit()
{

    cd /root/mcna

    # Advanced mode.
    if [ ! -z $KS_ADVANCED ]; then
	read -n 1 -r -s -p $'\n--> Opening settings file. You can change the region and other settings like VNet and gateways. Press any key to continue.\n'
	vim variables.tf
    fi

    terraform init -upgrade
    terraform apply -target=aviatrix_transit_gateway.azure_transit_gw -target=aviatrix_spoke_gateway.azure_spoke_gws -target aviatrix_spoke_transit_attachment.azure_spoke_gws_attachment -auto-approve
    return $?
}

#last step peering b/w azure and aws
peering()
{
    cd /root/mcna
    terraform init -upgrade
    terraform apply -target=aviatrix_transit_gateway_peering.aws_azure -auto-approve
    return $?
}


custom_git()
{
    echo $KS_CUSTOM_GIT
    cd /root
    ghclone $KS_CUSTOM_GIT
    cd ${KS_CUSTOM_GIT##*/}
    source setup.sh
    return $?
}


banner_initilize()
{

    banner Aviatrix Sandbox Starter
    cat /root/.plane
    if [ ! -z $KS_GOVCLOUD ]; then
        echo -e "--> GovCloud mode\n"
    fi
    if [ ! -z $KS_CUSTOM_GIT ]; then
        echo -e "--> Custom Git mode\n"
        custom_git
        return $?
    fi
}

#aws_configure

# If controller was already launched in this container, skip.
launch_controller()
{
    email=$1
    recovery_email=$2
    password=$3
    controller_version=$4
    controller_license=$5
    # controller_license has to be last as it may be empty in the case of metered

    if [[ -v CONTROLLER_PUBLIC_IP ]]; then
        echo "--> Controller already launched, skipping."
    else
#        echo $1
#        if [[ $1 == yes ]] ; then
        controller_launch $recovery_email
        if [ $? != 0 ]; then
            echo "--> Controller launch failed, aborting."
            return 1
#        fi
        fi
    fi

    # If controller was already initialized in this container, skip.
    if [[ -v SANDBOX_STARTER_CONTROLLER_INIT_DONE ]]; then
        echo "--> Controller already initialized, skipping."
    else
        controller_init $email $password $recovery_email $controller_version $controller_license
        if [ $? != 0 ]; then
        echo "--> Controller init failed, retrying."
        controller_init $email $password $recovery_email $controller_version $controller_license
        if [ $? != 0 ]; then
            echo "--> Controller init failed, exiting."
            return 1
        fi
        fi
    fi

    return 0

}

#launch aciatrix transit api
launch_aws_transit()
{
    if [ ! -z $KS_ADVANCED ] || [ ! -z $KS_GOVCLOUD ]; then
        read -p $'\n\n--> Do you want to launch the Aviatrix transit in AWS? Go to https://raw.githubusercontent.com/AviatrixSystems/sandbox-starter/main/img/sst.png to view what is going to be launched. You can change the settings in the next step (y/n)? ' answer
    else
        read -p $'\n\n--> Do you want to launch the Aviatrix transit in AWS? Region will be us-east-2. Go to https://raw.githubusercontent.com/AviatrixSystems/sandbox-starter/main/img/sst.png to view what is going to be launched. (y/n)? ' answer
    fi
    if [ "$1" = "yes" ] ; then
        mcna_aws_transit
        if [ $? != 0 ]; then
        echo "--> Failed to launch AWS transit, aborting." >&2
        return 1
        fi
    fi
}

#aws spoke vpc initiate
aws_spoke_vpcs()
{
#    read -p $'\n\n--> Do you want to launch test EC2 instances in the AWS Spoke VPCs? (y/n)? ' answer
    if [ "$1" = "yes" ] ;  then
        mcna_aws_test_instances
    fi
}

#Azure transit launch first step
launch_azure_transit()
{
#    read -p $'\n\n--> Do you want to launch the Aviatrix transit in Azure? (y/n)? ' answer
#    if [ $1 = 'yes' ] ; then
#        read -n 1 -r -s -p $'\n\n--> Now opening the settings file for the Azure deployment. Your need to enter your Azure API keys. You can leave the rest to defaults or change to your preferences. You only need to complete the Azure settings. Perform the pre-requisites at https://docs.aviatrix.com/HowTos/Aviatrix_Account_Azure.html. Press any key to continue. In the text editor, press :wq when done.\n'

        cd /root/
        . keys.sh # Load variables from file

        sed -i "s#variable \"azure_subscription_id\".*#variable \"azure_subscription_id\" { default = \"$1\" }#g"  /root/mcna/variables.tf
        sed -i "s#variable \"azure_directory_id\".*#variable \"azure_directory_id\" { default = \"$2\" }#g"  /root/mcna/variables.tf
        sed -i "s#variable \"azure_application_id\".*#variable \"azure_application_id\" { default = \"$3\" }#g"  /root/mcna/variables.tf
        sed -i "s#variable \"azure_application_key\".*#variable \"azure_application_key\" { default = \"$4\" }#g"  /root/mcna/variables.tf

#        vim /root/mcna/variables.tf
        mcna_azure_transit
        if [ $? != 0 ]; then
        echo "--> Failed to launch Azure transit, aborting." >&2
        return 1
        fi
        azure=1

#    fi
}

#peering transit aws,azure initiated here
transit_peering_aws_azure()
{

    cd /root/
    . keys.sh
#if [ $azure ]; then
#    read -p $'\n\n--> Do you want to build a transit peering between AWS and Azure? (y/n)? ' answer
#    if [ "$answer" != "${answer#[Yy]}" ] ; then
    if [ "$1" = "yes" ] ; then
	peering
	if [ $? != 0 ]; then
	    echo "--> Failed to build peering, aborting." >&2
	    return 1
	fi
    fi
#fi
}

#launch public ip
get_public_ip()
{
    cd /root/
        . keys.sh # Load variables from file

    export $CONTROLLER_PUBLIC_IP
    echo "$CONTROLLER_PUBLIC_IP"

}

check_ec2_role()
{
    FILE=./check_ec2_role.chk
    if [ -f "$FILE" ]; then
    echo "Skipping check_ec2_role"
    else
        touch $FILE
        role_exists=$(aws iam get-role --role-name aviatrix-role-ec2)
        if [ -z $role_exists ]; then
        echo "Avx iam roles need to be created"
        else
        echo "Avx iam roles already exist"
        sed -i "s#variable \"pre_existing_iam_roles\".*#variable \"pre_existing_iam_roles\" { default = true }#g"  /root/controller/variables.tf    
        fi
    fi
}

#destroy terraform here
delete_terraform()
{
    cd /root/
    . keys.sh # Load variables from file

    # Disable AWS account security to allow terraform to destroy the vpc
    init_ctrl_auth=$(curl -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "action=login&username=admin&password=$AVIATRIX_PASSWORD" https://$CONTROLLER_PUBLIC_IP/v1/api --insecure)
    CID=$(echo $init_ctrl_auth | jq -r .CID)
    disable_aws_sg=$(curl -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "action=disable_controller_security_group_management&CID=$CID" https://$CONTROLLER_PUBLIC_IP/v1/api --insecure)

    terraform init -upgrade
    cd /root/mcna
    terraform destroy -auto-approve
    cd /root/controller
    terraform destroy -auto-approve
    echo "Done"
}
