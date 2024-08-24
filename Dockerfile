#
# Build del proyecto (Multi-Stage)
# --------------------------------
#
# Usamos una imagen de Maven para hacer build de proyecto con Java
# Llamaremos a este sub-entorno "build"
# Copiamos todo el contenido del repositorio
# Ejecutamos el comando mvn clean package (Generara un archivo JAR para el despliegue)
FROM eclipse-temurin:22-jdk AS build
COPY . .
RUN apt-get update && \
	apt-get install -y maven && \
	apt-get clean;
RUN mvn clean package

# Usamos una imagen de Openjdk
# Exponemos el puerto que nuestro componente va a usar para escuchar peticiones
# Copiamos desde "build" el JAR generado (la ruta de generacion es la misma que veriamos en local) y lo movemos y renombramos en destino como 
# Marcamos el punto de arranque de la imagen con el comando "java -jar app.jar" que ejecutará nuestro componente.
FROM openjdk:22-jdk
EXPOSE 8762
COPY --from=build /target/gateway-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]