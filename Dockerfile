#STAGE 1 
#minimal linux system with Node.js installed called build-stage 
FROM node:lts-alpine AS build-stage 

#set the working directory inside the container as /app
WORKDIR /app

#for caching purpose copy these two files into the /app which is the cureent folder
COPY package.json pnpm-lock.yaml ./

#install global and install all the dependencies 
RUN npm install -g pnpm && pnpm i --frozen-lockfile

#copy everything else 
COPY . .

#run pnpm build so that it translate Vue/TypeScript into HTML + CSS + Javascript for web browser 
#out put of that goes into /dist after image is created 
RUN pnpm build



#--------------------------------------------------------------------------------------------------------


    
#STAGE 2
#this minial nginx and stable because it get regular support and updates and refer to this as production
FROM nginx:stable-alpine AS production

#copy from build stage /app and /dist because it contains the final static website files and put into nginx prefered path
COPY --from=build-stage /app/dist /usr/share/nginx/html

#copy the nginx conf file locally to nginx prefered path
COPY nginx.conf /etc/nginx/conf.d/default.conf

#nginx is on port 80
EXPOSE 80 

#when container starts, start ngnix run global config option and run nginx in the foreground
#nginx runs in the background ussually  
CMD ["nginx", "-g", "daemon off;"]

