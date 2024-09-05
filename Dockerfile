# Use official Node.js image as base
FROM node:20.17

# Set working directory
WORKDIR /usr/src/app


# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

#RUN npm run build

COPY prisma ./prisma

RUN npx prisma generate

#RUN npx prisma studio --port 5555
# Expose the port NestJS will run on
EXPOSE 3000
EXPOSE 5555

# RUN <<EOF
# cd prisma
# node seed.js
# npm start dev
# EOF

RUN <<EOF
apt-get update -y
apt-get install -y --no-install-recommends git
apt-get install -y iputils-ping
apt install net-tools
apt-get install tmux -y
apt-get install mc -y --no-install-recommends
EOF


#./ini.sh

# apt-get update 
# apt-get install -y iputils-ping
# apt install net-tools
# apt-get install mc -y --no-install-recommends

# Start the application
#CMD ["npm", "start", "dev"]
# CMD cd prisma && node seed.js && npm start dev

# CMD ["sh", "-c", "cd prisma && node seed.js && cd .. && npm start dev"]
CMD ["sh", "-c", "npm start dev"]

# CMD cd /usr/src/app/prisma && node seed.js && npm start dev

