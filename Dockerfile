FROM alpine:latest
MAINTAINER insekticid <elasticsearch@exploit.cz>

ARG HUNSPELL_BASE_URL="https://raw.githubusercontent.com/LibreOffice/dictionaries/master"

RUN apk add --no-cache \
    hunspell 

RUN mkdir -p /usr/share/hunspell \
  && { \
       echo "cs_CZ"; \
       echo "sk_SK"; \
     } > /tmp/hunspell.txt \
  && cd /usr/share/hunspell \
  && for file in $(awk '{print $1}' /tmp/hunspell.txt); do \
       echo "${HUNSPELL_BASE_URL}/${file}/${file}.aff"; \
       mkdir -p "${file}"; \
       wget -O "${file}/${file}.aff" "${HUNSPELL_BASE_URL}/${file}/${file}.aff"; \
       wget -O "${file}/${file}.dic" "${HUNSPELL_BASE_URL}/${file}/${file}.dic"; \
       echo -e "strict_affix_parsing: true\nignore_case: true" > ${file}/settings.yml; \
       # ----------------------------------
       # 1) convert .aff file to UTF-8
       # 2) do `sed` magic
       # 3) convert also .dic file to UTF-8
       # 4) cleanup
       # ----------------------------------
       iconv -f ISO-8859-2 -t UTF-8 ${file}/${file}.aff > ${file}/${file}.aff.utf8; \
       sed "1s/ISO8859-2/UTF-8/" ${file}/${file}.aff.utf8 > ${file}/${file}.aff.utf8.1; \
       sed "2119s/$/áéíóúýuerl\]nout/" ${file}/${file}.aff.utf8.1 > ${file}/${file}.aff.utf8; \
       iconv -f ISO-8859-2 -t UTF-8 ${file}/${file}.dic > ${file}/${file}.dic.utf8; \
       rm ${file}/${file}.aff.utf8.1; \
       mv ${file}/${file}.aff.utf8 ${file}/${file}.aff; \
       mv ${file}/${file}.dic.utf8 ${file}/${file}.dic; \
     done

RUN ln -s /usr/share/hunspell/cs_CZ/cs_CZ.aff /usr/share/hunspell/default.aff \
  && ln -s /usr/share/hunspell/cs_CZ/cs_CZ.dic /usr/share/hunspell/default.dic

COPY entrypoint.sh /

WORKDIR /workdir
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]