FROM node:lts-alpine
#ENV NODE_ENV=production
WORKDIR /home/runner/work/DiamondProxy
ADD . ./
#COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
#COPY . .
EXPOSE 8545
#RUN chown -R node /usr/src/app
#USER node
#CMD ["forge", "test"]
RUN npm install hardhat
CMD npx hardhat node
