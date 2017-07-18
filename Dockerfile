FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get update

RUN apt-get install -y wget lsb-release apt-transport-https

RUN wget -q https://repo.vapor.codes/apt/keyring.gpg -O- | apt-key add - 

RUN echo "deb https://repo.vapor.codes/apt $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/vapor.list

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install -y vapor libpq-dev

ENV DATABASE_DB=mbaoDB
ENV DATABASE_HOST=database
ENV DATABASE_PASSWORD=3If6IPF6VgNIOGMvPbkPaDfBW94I9
ENV DATABASE_PORT=5432
ENV DATABASE_USER=Supervisor