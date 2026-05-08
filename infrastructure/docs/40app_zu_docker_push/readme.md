# 1. Prüfen, ob das lokale Image existiert
docker images | grep pond-ecr-repo

# 2. Bei AWS ECR anmelden

aws ecr get-login-password --region eu-central-1 --profile tefde-sandbox \
| docker login \
--username AWS \
--password-stdin 230355213662.dkr.ecr.eu-central-1.amazonaws.com

# 3. Image für ECR taggen
docker tag pond-ecr-repo:latest \
230355213662.dkr.ecr.eu-central-1.amazonaws.com/pond-ecr-repo:latest

# 4. Push
docker push \
230355213662.dkr.ecr.eu-central-1.amazonaws.com/pond-ecr-repo:latest




// TODO Prüfen wie dieser schritt mit arch liux funktioniert



// TODO 