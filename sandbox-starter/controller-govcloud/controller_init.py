#! /usr/bin/python3
import requests
import time
import json
import urllib3
import sys
import os
import getpass

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Variables

headers = {}
files = []


# login and store CID

def login(ctrl_url, password):
    payload = {'action': 'login',   'username': 'admin', 'password': password}
    # print(payload)
    response = requests.request(
        "POST", ctrl_url, headers={}, data=payload, files=[], verify=False)
    print(response.json())
    cid = response.json()["CID"]
    return cid


#  Change default password

def set_controller_password(ctrl_url, private_ip, cid, password, email):
    print("Connecting to Controller")
    new_password = {'action': 'edit_account_user', 'CID': cid, 'account_name': 'admin', 'username': 'admin', 'password': password, 'what': 'password',
                    'email': email, 'old_password': str(private_ip), 'new_password': password}
    set_new_password = requests.request(
        "POST", ctrl_url, headers=headers, data=new_password, files=files, verify=False)
    print(set_new_password.text.encode('utf8'))
    return True
    try:
        response = requests.post(url=ctrl_url, data=payload, verify=False)
        CID = response.json()["CID"]
        new_password = {'action': 'edit_account_user', 'CID': cid, 'account_name': 'admin', 'username': 'admin', 'password': password, 'what': 'password',
                        'email': email, 'old_password': str(private_ip), 'new_password': password}
        set_new_password = requests.request(
            "POST", ctrl_url, headers=headers, data=new_password, files=files, verify=False)
        print(set_new_password.text.encode('utf8'))
        return True
    except:
        print("Unable to connect using default password....please verify the password")
        return False


# Controller initialization

def onboard_controller(ctrl_url, account_id, cid, email, password):

    # Set email:

    new_email = {'action': 'add_admin_email_addr',
                 'CID': cid, 'admin_email': email}
    set_new_email = requests.request(
        "POST", ctrl_url, headers=headers, data=new_email, files=files, verify=False)
    print(set_new_email.text.encode('utf8'))

# ### New hostname:
    set_name = {'action': 'set_controller_name', 'CID': cid,
                'controller_name': "Sandbox Starter Controller"}
    set_hostname = requests.request(
        "POST", ctrl_url, headers=headers, data=set_name, files=files, verify=False)
    print(set_hostname.text.encode('utf8'))

# Create user based on email
    new_user = {'action': 'add_account_user', 'CID': cid,
                'account_name': email, 'username': email.rpartition('@')[0], 'password': password, 'email': email, 'groups': 'admin'}
    add_user = requests.request(
        "POST", ctrl_url, headers=headers, data=new_user, files=files, verify=False)
    print(add_user.text.encode('utf8'))

# AWS Access Account:
# https://api.aviatrix.com/#76259f3e-be0e-4cd9-be53-725fb134ce21
# Cloud type = 256 for AWS GovCloud
    aws_account = {
        'CID': cid,
        'action': 'setup_account_profile',
        'account_name': 'aws-govcloud',
        'cloud_type': '256',
        'account_email': email,
        'awsgov_account_number': account_id,
        'awsgov_iam': 'true',
        'awsgov_role_arn': "arn:aws-us-gov:iam::" + str(account_id) + ":role/aviatrix-role-app",
        'awsgov_role_ec2': "arn:aws-us-gov:iam::" + str(account_id) + ":role/aviatrix-role-ec2"
    }
    set_aws_account = requests.request(
        "POST", ctrl_url, headers=headers, data=aws_account, files=files, verify=False)
    print("Created AWS Access Account: ", set_aws_account.text.encode('utf8'))

# Upgrade Controller
    print("Upgrading controller. It can take several minutes")
    upgrade = {'action': 'upgrade', 'CID': cid, 'version': '6.6'}
    print("Upgrading to latest release")
    try:
        upgrade_latest = requests.request(
            "POST", ctrl_url, headers=headers, data=upgrade, files=files, verify=False, timeout=600)
        print(upgrade_latest.text.encode('utf8'))
    except:
        # Upgrade reaches timeout, but upgrade succeeds
        pass


def configure_controller_copilot(ctrl_url, password, ctrl_ip, cplt_ip):

    # Configure and link Copilot

    s = requests.Session()

    cplt_url = 'https://%s/login' % (cplt_ip)

    set_cplt = {"controllerIp": ctrl_ip,
                "username": "admin", "password": password}
    r = s.post(cplt_url, data=set_cplt, verify=False)

    cplt_url = 'https://%s/submitserviceaccount' % (cplt_ip)
    set_cplt_svc_acct = {"username": "admin", "password": password}
    r = s.post(cplt_url, data=set_cplt_svc_acct, verify=False)

    cplt_url = 'https://%s/create_physical_volumes' % (cplt_ip)
    set_cplt_data_volume = {"physicalVolumes": ["/dev/nvme1n1"]}
    r = s.post(cplt_url, data=set_cplt_data_volume, verify=False)

    cplt_url = 'https://%s/set_lvm_status' % (cplt_ip)
    finish_cplt_data_volume = {"status": "true"}
    r = s.post(cplt_url, data=finish_cplt_data_volume, verify=False)

    r = s.get('https://%s/performance_migrate_logstash_v2' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_migrate_task_server_v2' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_migrate_existing_alerts_v2' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_restart_logstash' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_restart_task_server' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_delete_v1_data' %
              (cplt_ip), verify=False)
    r = s.get('https://%s/performance_finish_upgrade_v2' %
              (cplt_ip), verify=False)

    # Set Netflow Agent on Controller
    post_upgrade_cid = login(ctrl_url, password=password)

    enable_netflow = {"action": "enable_netflow_agent",
                      "CID": post_upgrade_cid, "server_ip": cplt_ip, "port": "31283", "version": "9", "exclude_gateway_list": ""}
    r = requests.post(ctrl_url, data=enable_netflow, verify=False)

    enable_syslog = {"action": "enable_remote_syslog_logging",
                     "CID": post_upgrade_cid, "server": cplt_ip, "port": "5000", "protocol": "UDP", "exclude_gateway_list": "", "index": "9"}
    r = requests.post(ctrl_url, data=enable_syslog, verify=False)

    set_cplt_association = {"action": "enable_copilot_association",
                            "CID": post_upgrade_cid, "copilot_ip": cplt_ip}
    r = requests.post(ctrl_url, data=set_cplt_association, verify=False)


def print_credentials(public_ip, email, password):
    with open("controller_settings.txt", "w+") as f:
        f.write("Controller Public IP: " + str(public_ip) + '\n')
        f.write("username: admin" + '\n')
        f.write("password: " + str(password) + '\n')
        f.write("Recovery email: " + str(email) + '\n')


def export_password_to_envvar(password):
    print(password)
    os.environ['AVIATRIX_PASSWORD'] = password


def main():
    # public_ip = input("Enter Controller Public IP: ")
    # private_ip =  input("Enter Controller Private IP: ")
    # account_id = input("Enter AWS Account ID: ")
    public_ip = os.environ['CONTROLLER_PUBLIC_IP']
    private_ip = os.environ['CONTROLLER_PRIVATE_IP']
    copilot_public_ip = os.environ['COPILOT_PUBLIC_IP']
    account_id = os.environ['AWS_ACCOUNT']

    # email = input("Enter recovery email: ")
    email = os.environ['AVIATRIX_EMAIL']
    # password = getpass.getpass("Enter new password: ")
    password = os.environ['AVIATRIX_PASSWORD']
    ctrl_url = 'https://'+str(public_ip)+str("/v1/api")

    try:
        init_cid = login(ctrl_url, password=private_ip)
    except:
        print("Unable to connect to Controller: ", public_ip,
              "If you changed default password ignore this message.")

    set_controller_password(ctrl_url=ctrl_url, private_ip=private_ip,
                            cid=init_cid, password=password, email=email)

    try:
        cid = login(ctrl_url, password=password)
    except:
        print("Unable to connect to Controller: ",
              public_ip, " Please verify new password")
        sys.exit(1)

    onboard_controller(ctrl_url=ctrl_url,
                       account_id=account_id, cid=cid, email=email, password=password)
    # no need anymore to store those in a file.
    # print_credentials(public_ip, email, password)

    time.sleep(150)

    configure_controller_copilot(
        ctrl_url, password, ctrl_ip=public_ip, cplt_ip=copilot_public_ip)


if __name__ == "__main__":
    main()
