## A simple exercise to demonstrate the application of containerization on AWS

#### PRE-REQUISITES
1. I did this using aws cli so make sure that's installed within your wsl environment and configure the user and that you keep updating the access key

2. Make sure docker is installed as well

3. I used an ide for this called vscode and configured github within its terminal

4. To avoid extra charge did a cleanup after

##### WORKING OF PROJECT

1. Created an index.html file which shows a simple welcome page

2. Created a docker file with required information

*NOTE: HAD SOME ISSUE WITH INSTALLING DOCKER AFTER MUCH TROUBLESHOOTING AND CHECKING THE WEBSITE I REALISED MY WSL VERSION WAS 1 AND NOT 2 AS REQUIRED BY DOCKER. I DID THE FOLLOWING: 
    `wsl -l -v` and saw version was 1 then did the following
    `wsl –update`
    `wsl -–set-default-version 2`
    `wsl –set-version distro_name 2` (replace distro name with name of your distro) 
    Verify run   `wsl -l -v` it should show version 2
    Then rerun `wsl -–set-default-version 2`*

3. Build an image of the app so far using command (include the full stop)
    `docker build -t name_of_app .`

4. Push container image to Amazon ECR
For the purposes of this project I combined all these lines into a script under the name push_to_ecr.sh and ran the bash script in wsl with appropriate permissions

5. This is the final output of pushing image to ECR
![docker image pushed to Amazon ECR](https://github.com/user-attachments/assets/eb6ebc54-2741-499c-9b83-b2289f47744a)

6. Create app runner service and this is the final output
![alt text](<final output.png>)

*Note: The output may freeze as creating the app takes time so modify aws app runner create-service command and add this `--no-cli-pager` at end or run script in background*