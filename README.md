# Blue Green Deployment demo

## Packer

Build the AMI

```shell
packer build .
```

## Terraform

#### Inital state v1

1. Only **blue** instances with app v1, 100% traffic to **blue** instances (v1)

```shell
terraform apply -auto-approve -var traffic_distribution=blue -var enable_blue_env=true -var enable_green_env=false -var blue_app_version=v1
```

#### Transition from v1 to v2

2. Spin up **green** instances with app v2, 100% traffic to **blue** instances

```shell
terraform apply -auto-approve -var traffic_distribution=blue -var enable_blue_env=true -var enable_green_env=true -var blue_app_version=v1 -var green_app_version=v2
```

3. Once **green** instances (v2) are healthy, 50% traffic to **blue** instances (v1) and 50% traffic to **green** instances (v2)

```shell
terraform apply -auto-approve -var traffic_distribution=even -var enable_blue_env=true -var enable_green_env=true -var blue_app_version=v1 -var green_app_version=v2
```

4. Shutdown **blue** instances (v1) and 100% traffic to **green** instances (v2)

```shell
terraform apply -auto-approve -var traffic_distribution=green -var enable_blue_env=false -var enable_green_env=true -var blue_app_version=v1 -var green_app_version=v2
```

#### Transition from v2 to v3

5. Spin up **blue** instances with app v3, 100% traffic to **green** instances (v2)

```shell
terraform apply -auto-approve -var traffic_distribution=green -var enable_blue_env=true -var enable_green_env=true -var blue_app_version=v1 -var green_app_version=v2 -var blue_app_version=v3
```

6. Once **blue** instances (v3) are healthy, 50% traffic to **blue** instances (v3) and 50% traffic to **green** instances (v2)

```shell
terraform apply -auto-approve -var traffic_distribution=even -var enable_blue_env=true -var enable_green_env=true -var blue_app_version=v3 -var green_app_version=v2
```

7. (Optional) Stop everything with a variables file

```shell
terraform apply -auto-approve -var-file="stop-all.tfvars"
```
