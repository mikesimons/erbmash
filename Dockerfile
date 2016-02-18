FROM alpine
RUN apk add --update build-base ruby ruby-rake
RUN apk add --update git 
RUN apk add --update ruby-dev
RUN apk add --update tar wget bison yaml-dev
