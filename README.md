# docker-jenkins

This respository has a dockerfile that will allow you run Jenkins with access to docker engine on host.

#### Enviroment tested
  `OS = CentOs (linux)`

## The problem

You're running a jenkins container to build your project, and you need to build a docker image inside you job.

#### What to do?
Well, there are ways to perform that, but in the case the jenkins are running inside a docker container, 
the best way is to allow Jenkins use the docker service that are running in the host. 

#### But how do that?

When execute the command to run Jenkins you can bind mount the folder `/var/run/docker.sock` to the same folder inside the container. 
Like below :

  > docker run -name jenkins -p 8080:8080 -p 50000:50000 -v '/var/run/docker.sock:/var/run/docker.sock' jenkins/jenkins:lts

This will bind you host directory with the same folder inside the container.


But you can face this problem when you try to use the docker inside jenkins job :

  > Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/version: dial unix /var/run/docker.sock: connect: permission denied
  
#### Why this problem happens?

This problem happens because the jenkins container uses by default the user `jenkins` from the group `jenkins`, 
and this group doens't has enough permissions to access the folder `/var/run/docker.sock`.


#### How to fix?

First thing you have to know which groups has permissions to access the directory in the host. 
You can check by typing this command in terminal

  > ls -l /var/run/docker.sock

You will get something similiar to this

![List-Permissions](https://github.com/igorgsousa/docker-jenkins/blob/master/imgs/list-permissions.PNG)
 
  > s - file type  
  > rw - owner permission  
  > rw - group permission  
  > -- - all other users or groups  
  > 0 - owner UID (User identification)  
  > 993 - owner GID (Group Identification)

Now we know the user group that have enough permissions to access the folder `/var/run/docker.sock`.

Next, we need to add the user `jenkins` of our Jenkins container to a group  with the same GID.

To do that we can access our container terminal typing this command in host

  > docker exec -it -u root jenkins bash


