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

def onboard_controller(ctrl_url, account_id, cid, email, password, version):

    # Set email:

    new_email = {'action': 'add_admin_email_addr',
                 'CID': cid, 'admin_email': email}
    set_new_email = requests.request(
        "POST", ctrl_url, headers=headers, data=new_email, files=files, verify=False)
    print(set_new_email.text.encode('utf8'), flush=True)

# ### New hostname:
    set_name = {'action': 'set_controller_name', 'CID': cid,
                'controller_name': "Sandbox Starter Controller"}
    set_hostname = requests.request(
        "POST", ctrl_url, headers=headers, data=set_name, files=files, verify=False)
    print(set_hostname.text.encode('utf8'), flush=True)

# Create user based on email
    new_user = {'action': 'add_account_user', 'CID': cid,
                'account_name': email, 'username': email.rpartition('@')[0], 'password': password, 'email': email, 'groups': 'admin'}
    add_user = requests.request(
        "POST", ctrl_url, headers=headers, data=new_user, files=files, verify=False)
    print(add_user.text.encode('utf8'), flush=TestResults)

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
    print("Upgrading controller. It can take several minutes", flush=True)
    upgrade = {'action': 'upgrade', 'CID': cid, 'version': version}
    print("Upgrading to latest release", flush=True)
    try:
        upgrade_latest = requests.request(
            "POST", ctrl_url, headers=headers, data=upgrade, files=files, verify=False, timeout=600)
        print(upgrade_latest.text.encode('utf8'), flush=True)
    except:
        # Upgrade reaches timeout, but upgrade succeeds
        print("Upgrade failed", flush=True)
        sys.exit(1)


def print_credentials(public_ip, email, password, cid):
    with open("controller_settings.txt", "w+") as f:
        f.write("Controller Public IP: " + str(public_ip) + '\n')
        f.write("username: admin" + '\n')
        f.write("password: " + str(password) + '\n')
        f.write("Recovery email: " + str(email) + '\n')
        f.write("CID: " + str(cid) + '\n')


def export_password_to_envvar(password):
    print(password)
    os.environ['AVIATRIX_PASSWORD'] = password


def main():
    # public_ip = input("Enter Controller Public IP: ")
    # private_ip =  input("Enter Controller Private IP: ")
    # account_id = input("Enter AWS Account ID: ")
    public_ip = os.environ['CONTROLLER_PUBLIC_IP']
    private_ip = os.environ['CONTROLLER_PRIVATE_IP']
    account_id = os.environ['AWS_ACCOUNT']

    # email = input("Enter recovery email: ")
    email = os.environ['AVIATRIX_EMAIL']
    # password = getpass.getpass("Enter new password: ")
    password = os.environ['AVIATRIX_PASSWORD']
    version = os.environ['CONTROLLER_VERSION']
    ctrl_url = 'https://'+str(public_ip)+str("/v1/api")

    try:
        init_cid = login(ctrl_url, password=private_ip)
        set_controller_password(ctrl_url=ctrl_url, private_ip=private_ip,
                                cid=init_cid, password=password, email=email)
    except:
        print("Unable to connect to Controller: ", public_ip,
              "If you changed default password ignore this message.")

    try:
        cid = login(ctrl_url, password=password)
    except:
        print("Unable to connect to Controller: ",
              public_ip, " Please verify new password")
        sys.exit(1)

    onboard_controller(ctrl_url=ctrl_url,
                       account_id=account_id, cid=cid, email=email, password=password, version=version)
    # no need anymore to store those in a file.
    # print_credentials(public_ip, email, password)

    time.sleep(150)

    new_CID = os.environ['CONTROLLER_LICENSE']

    if new_CID:
        post_upgrade_cid = login(ctrl_url, password=password)
        set_Customer_ID = {"action": "setup_customer_id",
                           "CID": post_upgrade_cid, "customer_id": new_CID}
        setup_customer_id = requests.post(
            ctrl_url, data=set_Customer_ID, verify=False)
        print("Setup Customer ID", setup_customer_id.text.encode('utf8'), flush=True)

    cid = login(ctrl_url, password=password)
    migrate_ip = {"action": "migrate_controller_ip",
                  "CID": cid, "previous_ip": "34.204.42.164"}
    migrate_ip_call = requests.post(ctrl_url, data=migrate_ip, verify=False)
    print("Migrate IP", migrate_ip_call, flush=True)


if __name__ == "__main__":
    main()
