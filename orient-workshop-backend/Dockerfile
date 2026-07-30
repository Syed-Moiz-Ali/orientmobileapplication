FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY orient-gateway/target/orient-gateway-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
