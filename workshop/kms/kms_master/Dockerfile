FROM python:2
WORKDIR /src
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY kms_master .
CMD [ "./kms_master" ]