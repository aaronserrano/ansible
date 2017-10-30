# Dia 5 - Laboratorio 1 - Jenkins

## Configuración del nuevo entorno

El entorno para este laboratorio se creará completamente en AWS.

Constará de dos máquinas:
- Un controller de ansible
- Un servidor jenkins

Antes de lanzar los playbooks, deberemos hacer checkout del nuevo código:

```text
git clone http://gitlab.teradisk.net/trainings/laboratorio-jenkins.git
```

Si miramos su estructura:

```text
.
├── ansible.cfg
├── crear-controller-aws.yml
├── crear-jenkins-aws.yml
├── env_vars
│   └── aws_vault.yml
├── inventories
└── roles
    ├── ansible-dev
    │   └── tasks
    │       └── main.yml
    ├── crear-maquina-aws
    │   ├── README.md
    │   ├── defaults
    │   │   └── main.yml
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       └── inventory.txt.j2
    ├── docker
    │   └── tasks
    │       └── main.yml
    └── jenkins
        └── tasks
            └── main.yml
```


Hay dos playbooks, estos playbooks inicializan las máquinas que necesitamos, pero incluyen una novedad, se les
tiene que pasar un parámetro en tiempo de ejecución indicando nuestro nombre:

**Controller**

```text
ansible-playbook crear-controller-aws.yml -e "NOMBRE_ALUMNO=Jordi"
```

**Jenkins**

```text
ansible-playbook crear-jenkins-aws.yml -e "NOMBRE_ALUMNO=Jordi"
```

También si nos fijamos, existe ya el fichero aws_vault.yml... investigar un poco como almacena las credenciales..


* Ver el vault
* Encontrar que fichero se usa como clave

## Configuración de Jenkins

Una vez lanzados los dos playbooks, tendremos una máquina con Jenkins a la que accederemos con:


http://ip:8080

Seguiremos el workflow... hay que tomar BUENA NOTA del user y pass que se configura.

Cuando lleguemos a la pantalla inicial de Jenkins añadiremos el módulo **GitHub Pull Request Builder**

(seguiremos las indicaciones del profesor)

## El repositorio de prueba que usaremos

Para probar el CI usaremos el repositorio ```https://gitlab.teradisk.net/trainings/apache-webpage```

Podéis descargarlo en vuestra nueva máquina controller, ver que hace... pasar el test kitchen...


Si os fijáis tiene un fichero Jenkinsfile en la raíz. Este fichero le indicará a Jenkins como hacer un build.

Vamos a analizar a fondo el repositorio...


## Clonar el repositorio en nuestra cuenta de github

Aprovechando la cuenta de github que creamos al principio del curso, crearemos un repositorio llamado apache-webpage
en nuestra cuenta, y subiremos el código del repositorio de prueba.

## Generar un token API de github con permisos para el repo

Haremos un token API de github que necesitaremos más adelante

(seguir al profesor en caso de duda)

## Configurar la integración del Pull Request de Github con Jenkins

On Jenkins
1. Install GitHub Pull Request Builder plugin. (You also need “Github” plugin but that should normally be installed as part of Jenkins ver 2+)
2. Jenkins – Credentials
   - Add github Personal Access Token (PAT) as a ‘secret text’ credential.
   - Add github username-password as ‘username-password’ credential.
3. Manage Jenkins – Configure System
   - Github – Github Servers : This is part of the Github plugin. Add a github server. ‘API URL’ It will default to https://api.github.com. If you are using enterprise github, replace with enterprise github url followed by /api/v3. For credential select the PAT option. Test the connection. ‘Manage Hooks’ is checked.
   - GitHub Pull Request Builder : for ‘GitHub Server API URL’ use same url as specified in Github Server section. Leave ‘Shared Secret’ blank. For credentials use ‘username-password’ credential. Test credentials to ensure its working. In my settings, ‘Auto-manage webhooks’ was checked.
4. Pipeline Job
    - Create a new item using ‘Pipeline’ option. Note: This is the vanilla Pipeline job, not Multibranch Pipeline.
    - General Section: Check ‘Github Project’ – Project URL : Enter your github repo url
    - Build Triggers: Check ‘GitHub Pull Request Builder’
    - For ‘GitHub API credentials’ select option you set for GitHub pull request builder in ‘Manage Jenkins – Configure System’ screen
    - For admin list: add your username
    - Check Use github hooks for build triggering
    - Pipeline:
        1.	Select ‘Pipeline Script from SCM’. Note this assumes that the root folder of your repo will contain a ‘Jenkinsfile’
        2.	SCM: Select ‘Git’
        3.	Repositories – enter repo detail. For credentials use ‘username-password’ based credentials.
        4.	Click Advanced and add refspec ```+refs/pull/*:refs/remotes/origin/pr/*```
        5.	Branch – should be ```${sha1}```
        6.	Script Path: defaulted to Jenkinsfile, leave as is.
        7.	Lightweight Checkout - Uncheck this (https://github.com/jenkinsci/ghprb-plugin/issues/507)
That’s it. You are all set. Creating a PR on master branch of your repo should now trigger your Jenkins Pipeline job
Some observations
- Redelivering the webhook payload of a PR from github does not trigger the pipeline but opening a new PR or even re-opening a closed PR on github, triggers the pipeline job
- In Pipeline Job Configuration, if you choose “Pipeline Script” and paste your pipeline script in there, the job doesn't trigger !!!

## Probar de hacer una merge request

1. En el código de apache-webpage, haremos un cambio que no rompa nada en una nueva rama
2. Haremos push de esa rama a github
3. Haremos una pull request de esa rama a ver que pasa

repetiremos con un cambio que falle
