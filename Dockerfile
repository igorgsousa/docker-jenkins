FROM jenkins/jenkins

USER root

RUN groupadd -g 993 docker \
&& gpasswd -a jenkins docker

USER jenkins