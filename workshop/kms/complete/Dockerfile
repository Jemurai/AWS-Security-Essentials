FROM python:2
WORKDIR /src
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY dynamo_backed_aes .
CMD [ "./dynamo_backed_aes" ]