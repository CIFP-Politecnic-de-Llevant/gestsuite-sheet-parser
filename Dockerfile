FROM maven:3-amazoncorretto-17 as develop-stage-sheet-parser
WORKDIR /app

COPY /config/ /resources/

COPY /api/gestsuite-common/ /external/
RUN mvn clean compile install -f /external/pom.xml

COPY /api/gestsuite-sheet-parser .
RUN mvn clean package -f pom.xml
ENTRYPOINT ["mvn","spring-boot:run","-f","pom.xml"]

FROM maven:3-amazoncorretto-17 as build-stage-sheet-parser
WORKDIR /resources

COPY /api/gestsuite-common/ /external/
RUN mvn clean compile install -f /external/pom.xml


COPY /api/gestsuite-sheet-parser .
RUN mvn clean package -f pom.xml

FROM amazoncorretto:17-alpine-jdk as production-stage-sheet-parser
COPY --from=build-stage-sheet-parser /resources/target/sheet-parser-0.0.1-SNAPSHOT.jar sheet-parser.jar
COPY /config/ /resources/
ENTRYPOINT ["java","-jar","/sheet-parser.jar"]