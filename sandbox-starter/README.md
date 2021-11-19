# Aviatrix Sandbox Starter

## Summary

This solution deploys an Aviatrix controller and an Aviatrix transit architecture in AWS and in Azure.
![Sandbox Starter Infrastructure](/img/sst.png)

## Instructions

Install Docker if you don't already have it: https://docs.docker.com/get-docker/.

Start the container:
```docker run -it aviatrix/automation bash```

Launch Aviatrix Sandbox Starter:
```source ~/sandbox-starter/sandbox-starter/sandbox_starter.sh```

And follow the instructions.

To remove the transit deployment:
```cd ~/sandbox-starter/sandbox-starter/mcna && terraform destroy```

To remove the controller:
```cd ~/sandbox-starter/sandbox-starter/controller && terraform destroy```
