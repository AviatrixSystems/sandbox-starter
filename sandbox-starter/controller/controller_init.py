#! /usr/bin/python3
from doctest import TestResults
from http.client import NETWORK_AUTHENTICATION_REQUIRED
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


# Controller initialization

def config_controller(ctrl_url, account_id, cid, email, password):

    # Set Controller Label:
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

    # Set Controller License
    license = os.environ['CONTROLLER_LICENSE']

    set_Customer_ID = {"action": "setup_customer_id",
                       "CID": cid, "customer_id": license}
    setup_customer_id = requests.post(
        ctrl_url, data=set_Customer_ID, verify=False)
    print("Setup Customer ID", setup_customer_id.text.encode('utf8'), flush=True)

    # Add aws account if not there
    account_exists = str(ctrl_url)+str("?action=list_accounts&CID=") + \
        str(cid)+"&aws_iam_role_based="
    check_aws_account = requests.request(
        "GET", account_exists, headers=headers, data=headers, verify=False)

    add_account = True

    accounts = check_aws_account.json()
    for account in accounts['results']['account_list']:
        if account['account_name'] == "aws-account":
            add_account = False

    if add_account:
        aws_account = {
            'CID': cid,
            'action': 'setup_account_profile',
            'account_name': 'aws-account',
            'cloud_type': '1',
            'account_email': email,
            'aws_account_number': account_id,
            'aws_iam': 'true',
            'aws_role_arn': "arn:aws:iam::" + str(account_id) + ":role/aviatrix-role-app",
            'aws_role_ec2': 'arn:aws:iam::' + str(account_id) + ':role/aviatrix-role-ec2',
            'aws_access_key': ''
        }
        set_aws_account = requests.request(
            "POST", ctrl_url, headers=headers, data=aws_account, files=files, verify=False)
        print("Created AWS Access Account: ",
              set_aws_account.text.encode('utf8'), flush=True)


def main():
    public_ip = os.environ['CONTROLLER_PUBLIC_IP']
    account_id = os.environ['AWS_ACCOUNT']
    email = os.environ['AVIATRIX_EMAIL']
    password = os.environ['AVIATRIX_PASSWORD']
    ctrl_url = 'https://'+str(public_ip)+str("/v1/api")

    try:
        cid = login(ctrl_url, password=password)
    except:
        print("Unable to connect to Controller: ",
              public_ip, " Please verify new password")
        sys.exit(1)

    config_controller(ctrl_url=ctrl_url, account_id=account_id, cid=cid,
                      email=email, password=password)


if __name__ == "__main__":
    main()
