docker build -t contracts .
docker run -p 3000:3000 contracts
#docker run -it contracts /bin/bash
#docker ps
#docker exec -it <container_name_or_id> /bin/sh
