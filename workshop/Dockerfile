FROM python:3
WORKDIR /src
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY iam_audit .
CMD [ "./iam_audit" ]