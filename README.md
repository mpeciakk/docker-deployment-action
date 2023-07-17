# Docker Deployment Action

## Example

```yaml
- name: Deploy to machine
  uses: mpeciakk/docker-deployment-action@main
  with:
    remote_docker_host: cicd@remote.host
    ssh_key: ${{ secrets.SSH_KEY }}
    deploy_path: /home/cicd/test-app
    stack_file_name: docker-compose.prod.yml
    pull_images: true
```

## Input Configurations

### args

Arguments to pass to the deployment command "docker compose". Defaults to "up -d".

### remote_host

Specify remote host. This includes both username and host (user@host).

### remote_port

Specify remote ssh port. Defaults to 22.

### ssh_key

SSH private key used to connect to the remote host.

### deploy_path

The path where the stack files will be copied to.

### stack_file_name

Docker stack file used. Default is docker-compose.yml.

### pull_images

Pull docker images before deploying. Defaults to false.
