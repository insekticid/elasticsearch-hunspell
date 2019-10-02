FROM alpine:latest
MAINTAINER insekticid <elasticsearch@exploit.cz>

ARG HUNSPELL_BASE_URL="https://raw.githubusercontent.com/LibreOffice/dictionaries/master"

RUN apk add --no-cache \
    hunspell 

RUN mkdir -p /usr/share/hunspell /usr/share/elasticsearch/config/hunspell \
  && { \
       echo "de_AT de/de_AT_frami"; \
       echo "de_CH de/de_CH_frami"; \
       echo "de_DE de/de_DE_frami"; \
       echo "en_AU en/en_AU"; \
       echo "en_CA en/en_CA"; \
       echo "en_GB en/en_GB"; \
       echo "en_US en/en_US"; \
       echo "en_ZA en/en_ZA"; \
       echo "cs_CZ cs_CZ/cs_CZ"; \
       echo "sk_SK sk_SK/sk_SK"; \
     } > /tmp/hunspell.txt \
  && cd /usr/share/elasticsearch/config/hunspell \
  && cat /tmp/hunspell.txt | while read line; do \
       name=$(echo $line | awk '{print $1}'); \
       file=$(echo $line | awk '{print $2}'); \
       echo "${HUNSPELL_BASE_URL}/${file}.aff"; \
       mkdir -p "${name}"; \
       wget -O "${name}/${name}.aff" "${HUNSPELL_BASE_URL}/${file}.aff"; \
       wget -O "${name}/${name}.dic" "${HUNSPELL_BASE_URL}/${file}.dic"; \
       ls -al "${name}"; \
       echo -e "strict_affix_parsing: true\nignore_case: true" > ${name}/settings.yml; \
       # ----------------------------------
       # 1) convert .aff file to UTF-8
       # 2) do `sed` magic
       # 3) convert also .dic file to UTF-8
       # 4) cleanup
       # ----------------------------------
       if [ "${name}" = "cs_CZ" ]; then \
         echo "converting ${name} to UTF-8"; \
         iconv -f ISO-8859-2 -t UTF-8 ${name}/${name}.aff > ${name}/${name}.aff.utf8; \
         sed "1s/ISO8859-2/UTF-8/" ${name}/${name}.aff.utf8 > ${name}/${name}.aff.utf8.1; \
         sed "2119s/$/áéíóúýuerl\]nout/" ${name}/${name}.aff.utf8.1 > ${name}/${name}.aff.utf8; \
         iconv -f ISO-8859-2 -t UTF-8 ${name}/${name}.dic > ${name}/${name}.dic.utf8; \
         rm ${name}/${name}.aff.utf8.1; \
         mv ${name}/${name}.aff.utf8 ${name}/${name}.aff; \
         mv ${name}/${name}.dic.utf8 ${name}/${name}.dic; \
       fi \
     done

RUN ln -s /usr/share/elasticsearch/config/hunspell/cs_CZ/cs_CZ.aff /usr/share/hunspell/default.aff \
  && ln -s /usr/share/elasticsearch/config/hunspell/cs_CZ/cs_CZ.dic /usr/share/hunspell/default.dic

COPY entrypoint.sh /

WORKDIR /workdir
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]