FROM python:3
WORKDIR /src
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY inactive_user_audit .
CMD [ "./inactive_user_audit" ]