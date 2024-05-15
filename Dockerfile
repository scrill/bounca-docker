FROM alpine:3.19 as builder

RUN apk add --update gcc libc-dev libffi-dev py3-pip py3-virtualenv python3-dev

WORKDIR /application

RUN wget https://github.com/repleo/bounca/releases/download/v0.4.5/bounca-0.4.5.tar.gz -O /tmp/bounca.tar.gz
RUN tar xzf /tmp/bounca.tar.gz --strip-components=2 -C /application
RUN echo 'tzdata==2024.1' >> /application/requirements.txt
RUN python -m venv venv
RUN . venv/bin/activate && pip install -r requirements.txt


FROM alpine:3.19

RUN apk add --update nginx openssl py3-virtualenv uwsgi-python3

WORKDIR /application

COPY --from=builder /application /application

COPY etc/bounca/services.yaml /application/etc/bounca/services.yaml
COPY etc/nginx/bounca.conf /etc/nginx/http.d/bounca.conf
COPY etc/uwsgi/bounca.ini /etc/uwsgi/bounca.ini

RUN mkdir -p /var/log/bounca
RUN rm /etc/nginx/http.d/default.conf
COPY --chmod=0755 entrypoint.sh /application/entrypoint.sh

EXPOSE 8080/tcp
CMD ["./entrypoint.sh"]
