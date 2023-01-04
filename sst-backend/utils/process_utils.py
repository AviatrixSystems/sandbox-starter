"""proccess utils for changing file data"""
import subprocess
import sys


def proccess_file(command):
    """Creating proccess from here generically"""
    with subprocess.Popen(command,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1,
                          universal_newlines=True) as proccess:

        previous_lines = list()
        progress = []
        for line in proccess.stdout:
            progress = ''.join(previous_lines[-30:])
            print(progress, end='')

        exit_code = proccess.wait()
        print(exit_code)
        if exit_code != 0:
            return 1
        else:
            return 0


def controller_file_change(data):
    """controller variable change in this function"""
    region = data.get('region')
    az = data.get('az')
    vpc_cidr = data.get('vpc_cidr')
    vpc_subnet = data.get('vpc_subnet')
    controller_version = data.get('controller_version')
    controller_license_type = data.get('controller_license_type')
    controller_license = data.get('controller_license')
    controller_email = data.get('email')
    controller_password = data.get('password')
    if not controller_license_type:
        controller_license_type = "meteredplatinum"
    if region and az and vpc_cidr and vpc_subnet and controller_license_type:

        command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                   ' controller_file_change "' + region + '" "'
                   + az + '" "' + vpc_cidr + '" "' + vpc_subnet + '" "' + controller_version + '" "' + controller_email + '" "' + controller_password + '" "' + controller_license_type + '"']
    else:
        command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                   ' controller_file_change_std "' + controller_version + '" "' + controller_email + '" "' + controller_password + '" "' + controller_license_type + '"']

    proccess_file(command)


def mcna_file_change_aws(data):
    """mcna aws variable change in this fucntion"""
    aws_region = data.get('aws_region')
    aws_transit_vpc_name = data.get('aws_transit_vpc_name')
    aws_transit_vpc_cidr = data.get('aws_transit_vpc_cidr')
    aws_spoke1_vpc_name = data.get('aws_spoke1_vpc_name')
    aws_spoke1_vpc_cidr = data.get('aws_spoke1_vpc_cidr')
    aws_spoke2_vpc_name = data.get('aws_spoke2_vpc_name')
    aws_spoke2_vpc_cidr = data.get('aws_spoke2_vpc_cidr')
    aws_transit_gateway_name = data.get('aws_transit_gateway_name')
    aws_spoke1_gateways_name = data.get('aws_spoke1_gateways_name')
    aws_spoke2_gateways_name = data.get('aws_spoke2_gateways_name')

    command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                             ' mcna_aws_file_change_vpcs "' +
               aws_transit_vpc_name + '" "'
               + aws_transit_vpc_cidr + '" "' +
               aws_spoke1_vpc_name + '" "' +
               aws_spoke1_vpc_cidr
               + '" "' + aws_spoke2_vpc_name + '" "' +
               aws_spoke2_vpc_cidr + '"']

    proccess_file(command)

    command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                             ' mcna_aws_file_change_gateways "' +
               aws_transit_gateway_name + '" "'
               + aws_spoke1_gateways_name + '" "' +
               aws_spoke2_gateways_name + '" "' +
               aws_region
               + '"']

    proccess_file(command)


def mcna_file_change_azure(data):
    """mcna azure variable change in this fucntion"""
    azure_region = data.get('azure_region')
    azure_vnets_name = data.get('azure_vnets_name')
    azure_vnets_name_cidr = data.get('azure_vnets_name_cidr')
    azure_spoke1_vnet_name = data.get('azure_spoke1_vnet_name')
    azure_spoke1_vnet_cidr = data.get('azure_spoke1_vnet_cidr')
    azure_spoke2_vnet_name = data.get('azure_spoke2_vnet_name')
    azure_spoke2_vnet_cidr = data.get('azure_spoke2_vnet_cidr')
    azure_transit_gateway = data.get('azure_transit_gateway')
    azure_spoke1_gateways_name = data.get('azure_spoke1_gateways_name')
    azure_spoke2_gateways_name = data.get('azure_spoke2_gateways_name')

    command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                             ' mcna_azure_file_change_vpcs "' +
               azure_vnets_name + '" "'
               + azure_vnets_name_cidr + '" "' +
               azure_spoke1_vnet_name + '" "' +
               azure_spoke1_vnet_cidr
               + '" "' + azure_spoke2_vnet_name + '" "' +
               azure_spoke2_vnet_cidr + '"']

    proccess_file(command)

    command = ['bash', '-c', '. /root/sandbox_starter_web.sh;'
                             ' mcna_azure_file_change_gateways "' +
               azure_transit_gateway + '" "'
               + azure_spoke1_gateways_name + '" "' +
               azure_spoke2_gateways_name + '" "' +
               azure_region
               + '"']

    proccess_file(command)
