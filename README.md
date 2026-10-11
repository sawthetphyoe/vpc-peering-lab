
# AWS VPC peering lab

Three EC2 services run in separate VPCs in one AWS account and Region:

```text
Internet → customer-profile → account → statement
```

Only customer-profile is public. Calls between services use private IPs over two peering connections. Account makes a new request to statement; [VPC peering is not transitive](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html).

## Create the shared AMI

The image contains Ubuntu, [fake-service v0.26.2](https://github.com/nicholasjackson/fake-service/releases/tag/v0.26.2), and a systemd unit. Terraform supplies each service's environment file at boot, so private instances need no downloads.

1. In the EC2 console, launch a temporary builder in `ap-southeast-1` using **Canonical Ubuntu 26.04 LTS, x86_64**, `t3.micro`, and your SSH key pair. Choose a public subnet with internet access and a public IPv4 address. Allow SSH (22) from your public IP `/32` and outbound HTTP/HTTPS. Connect as `ubuntu`:

   ```bash
   chmod 400 /path/to/key.pem
   ssh -i /path/to/key.pem ubuntu@BUILDER_PUBLIC_IP
   ```

2. Run these commands **on the builder** to install the pinned Linux amd64 binary:

   ```bash
   sudo cloud-init status --wait
   sudo apt-get update
   sudo apt-get install -y ca-certificates curl unzip
   mkdir -p /tmp/fake-service-install
   cd /tmp/fake-service-install
   curl -fL -o fake-service.zip https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip
   unzip fake-service.zip
   sudo install -m 0755 fake-service /usr/local/bin/fake-service
   sudo useradd --system --user-group --no-create-home --shell /usr/sbin/nologin fake-service
   ```

3. Use `sudo nano /etc/systemd/system/fake-service.service` to save this unit:

   ```ini
   [Unit]
   Description=Fake Service
   Wants=network-online.target
   After=network-online.target

   [Service]
   Type=exec
   User=fake-service
   Group=fake-service
   EnvironmentFile=/etc/fake-service.env
   ExecStart=/usr/local/bin/fake-service
   Restart=on-failure
   RestartSec=3

   [Install]
   WantedBy=multi-user.target
   ```

4. Create a temporary configuration and test locally. Expect `"name":"ami-test"` and `"code":200` in the response:

   ```bash
   sudo tee /etc/fake-service.env >/dev/null <<'EOF'
   NAME=ami-test
   LISTEN_ADDR=0.0.0.0:9090
   UPSTREAM_URIS=
   EOF
   sudo systemctl daemon-reload
   sudo systemctl start fake-service
   curl -fsS http://localhost:9090/
   ```

5. Remove the test configuration and builder identity, then stop the builder. [Cleaning cloud-init](https://docs.cloud-init.io/en/latest/reference/cli.html#clean) lets new instances process their own user data. **Do not restart the builder before capturing the image.**

   ```bash
   sudo systemctl disable --now fake-service
   sudo rm -f /etc/fake-service.env
   sudo cloud-init clean --logs --machine-id --configs network
   sudo rm -f /etc/ssh/ssh_host_* /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
   sudo shutdown -h now
   ```

6. Once the instance is **Stopped**, select **Actions → Image and templates → Create image**. Name it `vpc-peering-fake-service` and wait until the AMI is **Available**. Launch a fresh test instance from it and repeat step 4. Record the custom AMI ID, then terminate the builder and test instances. See [AWS AMI creation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html).

## Deploy and verify

On your computer, install Terraform, curl, and jq, and configure AWS credentials. For a new checkout, copy `terraform.tfvars.example` to `terraform.tfvars`; otherwise edit your existing file.

Set `service_ami_id` to your custom AMI ID in the same account and Region. Review the non-overlapping VPC CIDRs and their subnets. Defaults are `ap-southeast-1`, `t3.micro`, port `9090`, and public ingress from `0.0.0.0/0`.

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=lab.tfplan
```

Review the plan, then apply it and check the public endpoint after startup:

```bash
terraform apply lab.tfplan
curl -fsS --max-time 90 "$(terraform output -raw customer_profile_url)" | jq
```

Expect nested responses for **customer-profile → account → statement**, each with code `200`. For failures, check service startup, routes in both directions, and security groups. Changes to instance user data replace affected instances; review the plan before applying.

## Clean up

Review the destruction plan, then apply it:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Separately remove any remaining builder/test instances and unused security groups. When finished with the AMI, deregister it and delete its backing snapshots. Terraform does not manage these manually created resources.

Commit `.terraform.lock.hcl`. Keep state, real `terraform.tfvars`, saved plans, and private keys out of Git; `.gitignore` excludes them.

<img width="1456" height="944" alt="Screenshot 2026-10-11 at 5 11 13 PM" src="https://github.com/user-attachments/assets/e4ce5f88-4794-4301-bce5-fdaa0bdb2944" />
