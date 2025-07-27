FROM lsiobase/python:3.9-version-b4383e18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AC2MQTT_VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="wjbeckett"

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"

RUN echo "**** install system packages ****" && \
    apk add --no-cache \
        jq \
        file \
        py3-yaml \
        python3 && \
    # `file` jest potrzebne do sprawdzenia typu pobranego pliku.
    # `py3-yaml` instaluje PyYAML jako pakiet systemowy, co jest bardziej niezawodne.
    echo "**** install build dependencies ****" && \
    apk add --no-cache --virtual=build-dependencies \
        g++ \
        gcc \
        curl \
        make \
        python3-dev && \
    echo "**** install pip packages ****" && \
    # Użyj pip3, aby uniknąć problemów z Pythonem 2.7.
    # paho-mqtt i pycryptodome instalujemy przez pip3.
    # PyYAML jest instalowany przez apk (py3-yaml).
    pip3 install --no-cache-dir -U \
        paho-mqtt \
        pycryptodome && \
    echo "**** Install app ****" && \
    mkdir -p /app/ac2mqtt && \
    echo "Created App folder in /app/ac2mqtt" && \
    mkdir -p /config && \
    echo "Created config folder in /config" && \
    # Pobierz najnowszy tag wydania z GitHub API.
    AC2MQTT_RELEASE=$(curl -sS "https://api.github.com/repos/liaan/broadlink_ac_mqtt/releases/latest" | jq -r '.tag_name') && \
    # Sprawdź, czy pobrano poprawną wersję. Jeśli pusta, zakończ z błędem.
    if [ -z "$AC2MQTT_RELEASE" ]; then \
        echo "BŁĄD: Nie udało się pobrać najnowszej wersji z GitHub. Sprawdź limit zapytań API lub dostępność repozytorium." >&2; \
        exit 1; \
    fi && \
    echo "Latest Release is ${AC2MQTT_RELEASE}" && \
    echo "Downloading Version ${AC2MQTT_RELEASE}" && \
    # Pobierz archiwum źródłowe.
    curl -o \
    /tmp/ac2mqtt.tar.gz -L \
        "https://github.com/liaan/broadlink_ac_mqtt/archive/${AC2MQTT_RELEASE}.tar.gz" && \
    # Sprawdź, czy pobrany plik jest rzeczywiście archiwum tar.gz. Jeśli nie, zakończ z błędem.
    FILE_TYPE=$(file -b --mime-type /tmp/ac2mqtt.tar.gz) && \
    # KLUCZOWA ZMIANA: Zezwól na application/gzip LUB application/x-gzip
    if [ "$FILE_TYPE" != "application/gzip" ] && [ "$FILE_TYPE" != "application/x-gzip" ]; then \
        echo "BŁĄD: Pobrany plik nie jest archiwum tar.gz. Zamiast tego ma typ: $FILE_TYPE" >&2; \
        echo "Sprawdź, czy URL pobierania jest poprawny i czy nie wystąpił błąd HTTP (np. 404)." >&2; \
        echo "Zawartość /tmp/ac2mqtt.tar.gz (pierwsze 500 bajtów):" >&2; \
        head -c 500 /tmp/ac2mqtt.tar.gz >&2; \
        exit 1; \
    fi && \
    echo "Downloaded successfully, extracting to /app/ac2mqtt" && \
    tar xf \
    /tmp/ac2mqtt.tar.gz -C \
        /app/ac2mqtt --strip-components=1 && \
    echo "Extrcted successfully" && \
    echo "**** Hard Coding versioning ****" && \
    echo "None" > /app/ac2mqtt/version.txt && \
    echo ${AC2MQTT_RELEASE} > /app/ac2mqtt/version.txt && \
    echo "**** cleanup ****" && \
    apk del --purge \
        build-dependencies && \
    rm -rf \
        /root/.cache \
        /tmp/* \
        /var/cache/apk/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
