# 0) Pick ONE image tag
# Recommended (stable): latest LTS on JDK17
JENKINS_IMAGE="jenkins/jenkins:lts-jdk17"

# Or (newest features): latest weekly on JDK17
# JENKINS_IMAGE="jenkins/jenkins:latest-jdk17"


# 1) Make sure Docker is running on the HOST
sudo systemctl status docker --no-pager

# 2) Pull Jenkins image
docker pull "$JENKINS_IMAGE"

# 3) Create Jenkins home volume (persists data)
docker volume create jenkins_home

# 4) Allow Jenkins container to use host Docker (Docker-out-of-Docker)
#    This reads the group id of /var/run/docker.sock on the HOST
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

# 5) (Re)Run Jenkins container
#    If you already have a "jenkins" container, remove it first:
docker rm -f jenkins 2>/dev/null || true

docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add "${DOCKER_GID}" \
  --restart unless-stopped \
  "$JENKINS_IMAGE"

# 6) Install Docker CLI *inside* the Jenkins container (so pipelines can run `docker ...`)
docker exec -u 0 -it jenkins bash -lc "apt-get update && apt-get install -y docker.io"

# 7) Verify Jenkins can talk to host Docker
docker exec -it jenkins bash -lc "id && ls -l /var/run/docker.sock && docker version"

# 8) Get initial admin password
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# 9) Follow logs if needed
docker logs -f jenkins