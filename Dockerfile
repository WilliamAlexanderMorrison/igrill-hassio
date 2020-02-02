FROM debian:stretch
RUN apt-get update && apt-get install -y \
	libglib2.0-dev \	
	pkg-config \
	git \
	python-pip
RUN git clone https://github.com/bendikwa/igrill.git
WORKDIR /igrill
RUN pip install -r requirements.txt
RUN mkdir config
VOLUME config
CMD ./monitor.py -c config