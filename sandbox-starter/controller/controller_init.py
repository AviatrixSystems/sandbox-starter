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


#  Change default password

def set_controller_password(ctrl_url, private_ip, cid, password, email):
    print("Connecting to Controller")
    new_password = {'action': 'edit_account_user', 'CID': cid, 'account_name': 'admin', 'username': 'admin', 'password': password, 'what': 'password',
                    'email': email, 'old_password': str(private_ip), 'new_password': password}
    set_new_password = requests.request(
        "POST", ctrl_url, headers=headers, data=new_password, files=files, verify=False)
    print(set_new_password.text.encode('utf8'), flush=True)
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

# Upgrade Controller
    print("Upgrading controller. It can take several minutes", flush=True)
    upgrade = {'action': 'upgrade', 'CID': cid, 'version': '6.6'}
    print("Upgrading to latest release", flush=True)
    try:
        upgrade_latest = requests.request(
            "POST", ctrl_url, headers=headers, data=upgrade, files=files, verify=False, timeout=600)
        print(upgrade_latest.text.encode('utf8'), flush=True)
    except:
        # Upgrade reaches timeout, but upgrade succeeds
        print("Upgrade failed", flush=True)
        sys.exit(1)


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
    copilot_public_ip = os.environ['COPILOT_PUBLIC_IP']
    account_id = os.environ['AWS_ACCOUNT']
    # email = input("Enter recovery email: ")
    email = os.environ['AVIATRIX_EMAIL']
    # password = getpass.getpass("Enter new password: ")
    password = os.environ['AVIATRIX_PASSWORD']
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
                       account_id=account_id, cid=cid, email=email, password=password)

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

    configure_controller_copilot(
        ctrl_url, password, ctrl_ip=public_ip, cplt_ip=copilot_public_ip)


if __name__ == "__main__":
    main()
