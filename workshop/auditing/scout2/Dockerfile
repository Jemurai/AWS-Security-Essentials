FROM centos:latest

RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y python2-pip nginx
RUN pip install --upgrade pip
RUN pip install python-dateutil==2.6.1
RUN pip install awsscout2

RUN date

COPY index.html /usr/share/nginx/html/index.html

WORKDIR /work
COPY boot.sh .

EXPOSE 80

CMD ["sh", "/work/boot.sh"]
