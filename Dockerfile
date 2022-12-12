#use this openjdk image instead to avoid image vulenerabilities
FROM adoptopenjdk/openjdk8:alpine-slim 
#FROM openjdk:8-jdk-alpine
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]