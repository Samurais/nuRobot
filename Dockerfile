FROM ubuntu

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV NUROBOT_HOME=/app/nuRobot

SHELL ["/bin/bash", "-c"]

# Install python3.6
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -q -y --no-install-recommends python3.6 python3.6-dev python3-pip python3-setuptools python3-wheel build-essential curl bzip2 pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# set python 3.6 as the default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
RUN pip3 install --upgrade pip requests setuptools

RUN apt-get update \
    && apt-get -y install nano unzip git

WORKDIR /app
RUN mkdir mitie

# Installing nuRobot from source
WORKDIR /app
RUN git clone https://github.com/LeoArruda/nuRobot.git
RUN pip install -r nuRobot/requirements.txt
#RUN pip install -e .


#Installing Rasa NLU backend (MITIE + sklearn)
WORKDIR /app/mitie
RUN pip install rasa_nlu[spacy]
RUN python -m spacy download en_core_web_md
RUN python -m spacy link en_core_web_md en
RUN python -m spacy download es_core_news_md
RUN python -m spacy link es_core_news_md es
#RUN pip install flask
#RUN pip install -U flask-cors
#RUN pip install git+https://github.com/tmbo/MITIE.git
#RUN pip install rasa_nlu[mitie]

# Downloading MITIE models
WORKDIR /app/mitie
RUN apt-get update  && apt-get -y install wget
RUN wget https://s3-eu-west-1.amazonaws.com/mitie/total_word_feature_extractor.dat

# Copying bot files
ADD . /data/bot
WORKDIR /data/bot

#Trainig bot
#RUN make -f /data/bot/Makefile train-nlu
#RUN make -f /data/bot/Makefile train-dialogue
VOLUME ["/app/nuRobot/Chatbots/projects/Lambton/models/dialogue", "/app/nuRobot/Chatbots/projects/Lambton/models/nlu/default", "/app/nuRobot/Chatbots/projects/Lambton/logs"]

EXPOSE 5000

#ENTRYPOINT NUROBOT_APP=python -m rasa_core.server -d /app/nuRobot/Chatbots/projects/Lambton/models/dialogue \
#                        -u /app/nuRobot/Chatbots/projects/Lambton/models/nlu/default \
#                        -o /app/nuRobot/Chatbots/projects/Lambton/logs/out.log

# Define default command.
# CMD make -f /data/bot/Makefile run