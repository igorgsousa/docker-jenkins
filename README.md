# docker-jenkins

This respository has a dockerfile that will allow you run Jenkins with access to docker engine on host.

#### Enviroment tested
  `OS = CentOs (linux)`

## The problem

You're running a jenkins container to build your project, and you need to build a docker image inside your job.
Well, there are ways to perform that, but in the case the jenkins are running inside a docker container, 
the best way is to allow Jenkins use the docker service that are running in the host. 

#### But how do that?

When execute the command to run Jenkins you can bind mount the folder `/var/run/docker.sock` to the same folder inside the container. 
Like below :

  > $ docker run -name jenkins -p 8080:8080 -p 50000:50000 -v '/var/run/docker.sock:/var/run/docker.sock' jenkins/jenkins:lts

This will bind you host directory with the same folder inside the container.


But you can face this problem when you try to use the docker inside jenkins job :

  > Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/version: dial unix /var/run/docker.sock: connect: permission denied
  
#### Why this problem happens?

This problem happens because the jenkins container uses by default the user `jenkins` from the group `jenkins`, 
and this group doens't has enough permissions to access the folder `/var/run/docker.sock`.


#### How to fix?

First thing you have to know which groups has permissions to access the directory in the host. 
You can check by typing this command in terminal

  > $ ls -l /var/run/docker.sock

You will get something similiar to this

![List-Permissions](https://github.com/igorgsousa/docker-jenkins/blob/master/imgs/list-permissions.PNG)
 
  > s - file type  
  > rw - owner permission  
  > rw - group permission  
  > -- - all other users or groups  
  > 0 - owner UID (User identification)  
  > 993 - owner GID (Group Identification)

Now we know the user group that has enough permissions to access the folder `/var/run/docker.sock`.

Next, we need to add the user `jenkins` of our Jenkins container in a group  with the same GID.

To do that we can access our container's terminal typing this command in host

  > $ docker exec -it -u root jenkins bash

Now we will check if exists a group named `docker` with this command

  > $ cat /etc/group
  
You will get something like this

![List-Groups](https://github.com/igorgsousa/docker-jenkins/blob/master/imgs/list-groups.PNG)

If you container dont have the group `docker`, you can create it by typing this command

  > $ groupadd -g 993 docker
  
*Note that 993 is the GID of the group that has enough permissions*


And the last step is to add `jenkins` user to the group `docker` with this command

  > $ gpasswd -a jenkins docker
  
Now if we restart our container it will have enough permissions to access `/var/run/docker.sock` allowing it to use the host docker engine

# Calm Down and pay attention!!!

This article was just to explain what was happening and how solve it, but if you access the container terminal and run that commands, when your container die all your work will be gone and we will have to do it again. 

To this problem i've create the dockerfile in this repository that create a derived image from official Jenkins image and run all that commands for you. The only thing you need to do is to discover the right GID of you docker engine host, replace in the docker file and build you custom Jenkins image.


I hope this article helped you!

My solution is based on this [article](https://medium.com/swlh/getting-permission-denied-error-when-pulling-a-docker-image-in-jenkins-docker-container-on-mac-b335af02ebca)!

Thanks & good coding!!!



