FROM python:2.7-slim

WORKDIR    /src
COPY audit /src

RUN pip install awsscout2

CMD ["./audit"]