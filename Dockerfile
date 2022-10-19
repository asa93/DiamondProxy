FROM node:lts-alpine
#ENV NODE_ENV=production
WORKDIR /home/asa93/hardhat_example
ADD . /home/asa93/hardhat_example
#COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
#COPY . .
EXPOSE 8545
#RUN chown -R node /usr/src/app
#USER node
#CMD ["forge", "test"]
RUN npm install hardhat
CMD npx hardhat node
