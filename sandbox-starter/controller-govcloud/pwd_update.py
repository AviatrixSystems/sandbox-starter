import sys
pwd = sys.argv[1]
line = "variable \"admin_password\" { default = \"%s\" }" % (pwd)
with open("/root/controller/variables.tf", "a") as fd:
    fd.write(line)
    fd.write("\n")
