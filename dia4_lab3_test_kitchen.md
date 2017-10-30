## Dia 4 - Laboratorio 3 - Test Kitchen




## El fichero .kitchen.yml (teoría)

Test Kitchen depende de la existencia de un fichero llamado ```.kitchen.yml```

Este fichero describe:
- Driver: el sistema que se usara para generar los entornos de test (vagrant, docker...)
- Provisioner: el método por el cual se configurarán los entornos de test
- Transport: parámetros de la conexión a los entornos de test
- Verifier: el método por el cual se ejecutarán los tests 
- Platform: las imágenes (sistemas operativos) en los que se ejecutarán el provisioner y el verifier
- Suites: los juegos de pruebas que se ejecutarán sobre las plataformas

En total, Test Kitchen creará un total de Platform x Suites entornos. Es decir, si queremos probar nuestro rol para:
- Ubuntu 16.04
- Centos 7

Y tenemos 4 juegos de prueba posible... se generarán 8 entornos de prueba mediante el driver configurado.

## El ciclo de Test Kitchen

Test Kitchen tiene un ciclo de pruebas muy concreto, en el que a cada paso se realizan unas tareas diferentes.

![Ciclo de Test Kitchen](.img/dev_workflow_a.png)

- **kitchen create:** se crean los entornos de test
- **kitchen converge**: se aplican los provisioners
- **kitchen login**: se conecta a los entornos de test
- **kitchen verify**: se validan los entornos de test mediante el verifier configurado
- **kitchen destroy:** se destruyen los entornos de test

## Integración de InSpec con Test Kitchen

Kitchen esperará encontrar todos los tests de InSpec para una suite en 

```text
test/integration/{{ nombre_suite }}
```

Dentro de ese directorio hay que dejar todos los ficheros *.rb con todos los tests que sean necesarios.


## Integración de Docker con Test Kitchen

Para integrar docker en Test Kitchen hay que tener en cuenta lo siguiente:

- En el driver hay que indicar:

```yaml
driver:
  name: docker
```

- En el platform hay que indicar:

```yaml
  - name:  {{ nombre }}
    driver_config:
      image: {{ imagen }} 
      provision_command:
        - {{ comandos }}
      run_command: "/usr/sbin/init"
      privileged: true
      use_sudo: false
```

Hay que tener en cuenta:
- La imagen debe soportar el uso de Init System V o SystemD (importante en docker)
- Si hay que poner muchos comandos en el array provision_command, igual es buena idea generar una imágen de docker que
ya tenga esos comandos integrados
- El run command siempre será /usr/sbin/init para arrancar SystemV o SystemD
- Los contenedores se lanzaran en modo privileged porque es necesario enlazar ciertas partes del host que ejecuta docker 
para poder emular bien a SystemV / SystemD

Para nuestros laboratorios usaremos la imágen ```dliappis/centos-devopsci:7``` que ya ha sido preparada para hacer
testing en Puppet, Chef y Ansible.

## Especificación de suites

Las suites indican:
- Su nombre
- El playbook a ejecutar
- Parámetros del provisioner, en el caso de ansible:
  - idempotency_test: (true/false) indica si se va a validar la idempotencia del rol. Para ello Kitchen ejecutará dos 
  veces el mismo, esperando que en la segunda ejecución, el retorno de los elementos cambiados (changed) sea 0.
  - playbook: el playbook a aplicar para configurar el entorno de test
  - extra_vars: vars que se pasan al playbook para poder generar diferentes escenarios
  
Existen muchos más parámetros del provisioner, que pueden ayudar en casos específicos, ver: 
https://github.com/neillturner/kitchen-ansible/blob/master/provisioner_options.md

## Un fichero .kitchen.yml de ejemplo

```yaml
driver:
  name: docker

provisioner:
  name: ansible_playbook
  hosts: localhost
  roles_path: ../
  require_ansible_repo: false
  require_ansible_omnibus: false
  require_ansible_source: false
  require_pip: true
  ansible_version: 2.3.2.0
  http_proxy: <%= ENV['HTTP_PROXY'] %>
  https_proxy: <%= ENV['HTTPS_PROXY'] %>
  no_proxy: localhost,127.0.0.1
  ignore_extensions_from_root: [".git",".idea",".kitchen.yml"]
  ignore_paths_from_root: [".git",".idea",".kitchen"]

transport:
  max_ssh_sessions: 6

verifier:
  name: inspec

platforms:
  - name: centos-7
    driver_config:
      image: dliappis/centos-devopsci:7
      provision_command:
        - sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
        - sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        - sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
        - rm /etc/yum.repos.d/epel*repo /etc/yum.repos.d/puppetlabs-pc1.repo
        - yum -y install initscripts
        - yum -y remove ansible
        - yum clean all
        - pip install jmespath
      run_command: "/usr/sbin/init"
      privileged: true
      use_sudo: false

suites:
  - name: demo
    provisioner:
      idempotency_test: true
      playbook: test/integration/sample.yml
    run_list:
    attributes:

```

## Integrar el soporte para Test Kitchen en un rol

Haremos el ejercicio con el rol de nginx que ya tenemos.

Lo primero que haremos es crear el fichero ```.kitchen.yml``` en la raíz del rol.

Usaremos el contenido siguiente para el mismo:

```yaml
driver:
  name: docker

provisioner:
  name: ansible_playbook
  hosts: localhost
  roles_path: ../
  require_ansible_repo: false
  require_ansible_omnibus: false
  require_ansible_source: false
  require_pip: true
  ansible_version: 2.3.2.0
  http_proxy: <%= ENV['HTTP_PROXY'] %>
  https_proxy: <%= ENV['HTTPS_PROXY'] %>
  no_proxy: localhost,127.0.0.1
  ignore_extensions_from_root: [".git",".idea",".kitchen.yml"]
  ignore_paths_from_root: [".git",".idea",".kitchen"]

transport:
  max_ssh_sessions: 6

verifier:
  name: inspec

platforms:
  - name: centos-7
    driver_config:
      image: dliappis/centos-devopsci:7
      provision_command:
        - sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
        - sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        - sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
        - rm /etc/yum.repos.d/epel*repo /etc/yum.repos.d/puppetlabs-pc1.repo
        - yum -y install initscripts
        - yum -y remove ansible
        - yum clean all
        - pip install jmespath
      run_command: "/usr/sbin/init"
      privileged: true
      use_sudo: false

suites:
  - name: nginx
    provisioner:
      idempotency_test: true
      playbook: test/integration/test-nginx.yml
    run_list:
    attributes:
```

Si ejecutamos ```kitchen list``` veremos una lista de todos los entornos de test que se crearán:

Antes de seguir:

- ¿Cuantos nos aparecerán?
- ¿Por qué?

```text
[root@localhost nginx]# kitchen list
Instance        Driver  Provisioner      Verifier  Transport  Last Action    Last Error
nginx-centos-7  Docker  AnsiblePlaybook  Inspec    Ssh        <Not Created>  <None>
```

Ahora hay que implementar los tests, para ello crearemos el directorio ```test/integration/nginx``` en la raiz del rol
(recordemos que hemos llamado nginx a nuestra suite de pruebas).

```mkdir -p test/integration/nginx```

Y crearemos los ficheros de los tests. Antes, pensaremos que tests hay que pasar:
- Habrá que validar si el paquete nginx está instalado
- Habrá que validar que el servicio nginx está arrancado
- Habrá que asegurarse que el servicio nginx está configurado para arrancar en el inicio del sistema
- Habrá que validar que el servicio nginx está escuchando en el puerto 80

Como todos los tests están relacionados con nginx, llamaremos al fichero ```nginx-tests.rb```

El primer test lo implementaremos con el recurso "package" que ya conocemos:

```ruby
control "nginx-installed" do
  impact 1.0                                
  title "Verificar que NginX instalado"
  desc "Primer requisito del rol, debe instalar Nginx"
  describe package('nginx') do
   it { should be_installed }
  end
end
```

El segundo test puede implementarse con el recurso "service". El tercero también.

```ruby
control "nginx-started-enabled" do
  impact 1.0                                
  title "Verificar que NginX está arrancado y que se arrancará al inicio del sistema"
  desc "Nginx arrancado y en enabled"
  describe service('nginx') do
   it { should be_enabled }
   it { should be_running }
  end
end
```

Por último, validaremos que se está escuchando en el puerto 80

```ruby
control "nginx-listens-80" do
  impact 1.0                                
  title "Verificar que NginX está escuchando en el puerto 80"
  desc "Nginx debe escuchar en el puerto 80 en este test"
  describe port(80) do
   it { should be_listening }
   its('processes') {should include 'nginx'}
  end
end
```

En resumen, el fichero ```test/integration/ginx/nginx-tests.rb``` debería quedar de la siguiente forma:

```text
control "nginx-installed" do
  impact 1.0                                
  title "Verificar que NginX instalado"
  desc "Primer requisito del rol, debe instalar Nginx"
  describe package('nginx') do
   it { should be_installed }
  end
end

control "nginx-started-enabled" do
  impact 1.0                                
  title "Verificar que NginX está arrancado y que se arrancará al inicio del sistema"
  desc "Nginx arrancado y en enabled"
  describe service('nginx') do
   it { should be_enabled }
   it { should be_running }
  end
end

control "nginx-listens-80" do
  impact 1.0                                
  title "Verificar que NginX está escuchando en el puerto 80"
  desc "Nginx debe escuchar en el puerto 80 en este test"
  describe port(80) do
   it { should be_listening }
   its('processes') {should include 'nginx'}
  end
end
```

Ahora, para acabar la integración, debemos crear el fichero ```test/integration/test-nginx.yml``` , que básicamente es 
un playbook que aplica el rol a todos los hosts:

```yaml
- name: Sample role run
  hosts: localhost
  roles:
    - role: nginx

```

Y en principio, nuestro rol ya estaría integrado con Test Kitchen, y tendría un test viable :)

Vamos a probarlo.

1. Ejecutamos ```kitchen create```, la primera vez toma su tiempo.

Tras la ejecución, si hacemos ```kitchen list``` veremos que la salida ha variado, y que nos indica que ya tenemos
disponible el entorno de test.

```text
[root@localhost nginx]# kitchen list
Instance        Driver  Provisioner      Verifier  Transport  Last Action  Last Error
nginx-centos-7  Docker  AnsiblePlaybook  Inspec    Ssh        Created      <None>
```

2. Ejecutamos ```kitchen converge``` , que aplicará el rol al entorno de test.

Y fallará :)

```text
PLAY [Sample role run] *********************************************************
       
       TASK [Gathering Facts] *********************************************************
       ok: [localhost]
       
       TASK [nginx : instalar paquete nginx] ******************************************
       fatal: [localhost]: FAILED! => {"changed": false, "failed": true, "msg": "No package matching 'nginx' found available, installed or updated", "rc": 126, "results": ["No package matching 'nginx' found available, installed or updated"]}
       	to retry, use: --limit @/tmp/kitchen/test-nginx.retry
       
       PLAY RECAP *********************************************************************
       localhost                  : ok=1    changed=0    unreachable=0    failed=1   

```

Habrá que investigar porqué...

3. Ejecutamos ```kitchen login```, lo que nos conectará con el entorno de test automáticamente, y miramos si se encuentra
el paquete nginx.

```text
[root@localhost nginx]# kitchen login
Last login: Sun Oct 22 16:36:49 2017 from 172.17.0.1
[kitchen@c84c2158e222 ~]$ yum search nginx

[kitchen@c84c2158e222 ~]$ sudo yum search nginx
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
======================================================== N/S matched: nginx =========================================================
pcp-pmda-nginx.x86_64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver

  Name and summary matches only, use "search all" for everything.
```

Vemos que el paquete no está... ¿porqué será?

Si hacemos una busqueda en nuestra máquina de test, veremos el motivo:

```text
[root@localhost ~]# yum list nginx
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.airenetworks.es
 * epel: mirror.airenetworks.es
 * extras: mirror.airenetworks.es
 * updates: mirror.airenetworks.es
Available Packages
nginx.x86_64                                                   1:1.10.2-2.el7                                                    epel

```

Vemos que Nginx está disponible en el repositorio "epel", que no viene activado por defecto.

Llegados a este punto tenemos dos opciones, ambas válidas:
- Activar el repositorio epel como propia tarea del rol
- Activar el repositorio en los comandos que inician el entorno de test

Debatamos un poco ambas opciones...
1. La primera opción nos obligará a que si otros paquetes también se instalan desde EPEL , todos los roles la deben 
implementar de la misma forma para ser consistente
2. La segunda opción nos obligará a recrear el entorno de test
3. ??

Para nuestro lab, vamos a hacer la primera opción, que es añadir ```yum -y install epel-release``` en el array 
```provision_command``` del fichero ```.kitchen.yml```

Una vez hecho esto, haremos el flujo de nuevo:

1. ```kitchen destroy``` Para limpiar el entorno
2. ```kitchen create``` Para volverlo a crear
3. ```kitchen converge``` Para aplicar el playbook de test

- Veremos que se ejecuta el playbook dos veces. ¿Por qué?


Ahora, validaremos que todo esté como debería estar con ```kitchen verify```, y fallará :)

El problema está en un bug conocido de InSpec (https://github.com/chef/inspec/issues/2232), se arregló en la release 
1.42.3, que se incluirá en el siguiente release del chefDK.

Hasta entonces, deberemos comentar el test de que proceso controla un puerto :(


## Limpiar entorno de test

Para acabar, limpiaremos el entorno de test con ```kitchen destroy```



