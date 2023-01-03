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

def onboard_controller(ctrl_url, account_id, cid, email, password, version):

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
    public_ip = os.environ['CONTROLLER_PUBLIC_IP']
    private_ip = os.environ['CONTROLLER_PRIVATE_IP']
    account_id = os.environ['AWS_ACCOUNT']
    email = os.environ['AVIATRIX_EMAIL']
    password = os.environ['AVIATRIX_PASSWORD']
    version = os.environ['CONTROLLER_VERSION']
    ctrl_url = 'https://'+str(public_ip)+str("/v1/api")

    try:
        cid = login(ctrl_url, password=password)
    except:
        print("Unable to connect to Controller: ",
              public_ip, " Please verify new password")
        sys.exit(1)

    onboard_controller(ctrl_url=ctrl_url,
                       account_id=account_id, cid=cid, email=email, password=password, version=version)


if __name__ == "__main__":
    main()
