FROM open-liberty

COPY src/main/liberty/config /config/
COPY target/system.war /config/apps
RUN configure.sh